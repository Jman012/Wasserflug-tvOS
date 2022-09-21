import Foundation
import FloatplaneAPIClient
import NIO
import AVKit
import SwiftUI

class VideoViewModel: BaseViewModel, ObservableObject {
	
	enum VideoError: Error, CustomStringConvertible {
		case badResponse
		case noQualityLevelsFound
		
		var description: String {
			switch self {
			case .badResponse:
				return "There was an error retrieving the livestream information. Please try again."
			case .noQualityLevelsFound:
				return "Unable to find any playable content from this video for your device."
			}
		}
	}
	
	@Published var state: ViewModelState<CdnDeliveryV2VodResponse> = .idle
	
	private let fpApiService: FPAPIService
	let videoAttachment: VideoAttachmentModel
	let contentPost: ContentPostV3Response
	let description: AttributedString
	
	var avMetadataItems: [AVMetadataItem] {
		let desc = String(description.characters)
		
		var releaseDate = videoAttachment.releaseDate?.formatted(.dateTime) ?? ""
		if releaseDate == "" {
			releaseDate = contentPost.releaseDate.formatted(.dateTime)
		}
		
		return [
			metadataItem(identifier: .commonIdentifierTitle, value: videoAttachment.title),
			metadataItem(identifier: .commonIdentifierDescription, value: desc),
			metadataItem(identifier: .iTunesMetadataTrackSubTitle, value: releaseDate),
//			metadataItem(identifier: .commonIdentifierArtwork, value: videoAttachment.thumbnail.path),
		]
	}
	
	private(set) var qualityLevels: [String: URL] = [:]
	
	init(fpApiService: FPAPIService, videoAttachment: VideoAttachmentModel, contentPost: ContentPostV3Response, description: AttributedString) {
		self.fpApiService = fpApiService
		self.videoAttachment = videoAttachment
		self.contentPost = contentPost
		self.description = description
	}
	
	func load() {
		state = .loading
		
		let type: CDNV2API.ModelType_getDeliveryInfo = .vod
		logger.info("Loading video information.", metadata: [
			"type": "\(type)",
			"id": "\(videoAttachment.guid)",
		])
		
		fpApiService
			.getCdn(type: type, id: videoAttachment.guid)
			.flatMapResult { (response) -> Result<CdnDeliveryV2Response, ErrorModel> in
				switch response {
				case let .http200(value: cdnResponse, raw: clientResponse):
					self.logger.debug("Video information raw response: \(clientResponse.plaintextDebugContent)")
					return .success(cdnResponse)
				case let .http0(value: errorModel, raw: clientResponse),
					let .http400(value: errorModel, raw: clientResponse),
					let .http401(value: errorModel, raw: clientResponse),
					let .http403(value: errorModel, raw: clientResponse),
					let .http404(value: errorModel, raw: clientResponse):
					self.logger.warning("Received an unexpected HTTP status (\(clientResponse.status.code)) while loading video information. Reporting the error to the user. Error Model: \(String(reflecting: errorModel)).")
					return .failure(errorModel)
				}
			}
			.whenComplete { result in
				DispatchQueue.main.async {
					switch result {
					case let .success(response):
						guard case let .typeCdnDeliveryV2VodResponse(cdnVod) = response else {
							self.state = .failed(VideoError.noQualityLevelsFound)
							return
						}
						self.logger.notice("Received video information.", metadata: [
							"cdn": "\(cdnVod.cdn)",
						])
						let baseCdn = cdnVod.cdn
						let pathTemplate = cdnVod.resource.uri
						let screenNativeBounds = UIScreen.main.nativeBounds
						let levels = cdnVod.resource.data.qualityLevels
							.filter({ qualityLevel in
								// Filter out resolutions larger than the device's screen resolution to save
								// on bandwidth and downscaling performance.
								// Use height for these comparisons. If using width, we run into funny issues with
								// LTT videos which use 2:1 aspect ratios (1080p is 2160x1080 instead of 1920x1080,
								// and 4K is 4320x2160 instead of 3480x2160) which makes screen size comparisons
								// difficult to do correctly.
								// Just in case some creators have funny heights, allow for a 15% tolerance.
								let result = CGFloat(qualityLevel.height) <= (screenNativeBounds.height * 1.15)
								if !result {
									self.logger.warning("Ignoring quality level \(String(describing: qualityLevel)) (\(qualityLevel.width) x \(qualityLevel.height)) due to larger-than-screen height of \(screenNativeBounds.height).")
								}
								return result
							})
							.compactMap({ (qualityLevel) -> (String, URL)? in
								// Map the quality levels to the correct URL
								guard let param = cdnVod.resource.data.qualityLevelParams[qualityLevel.name] else {
									self.logger.warning("Ignoring quality level \(qualityLevel.name) because no parameter information was found.")
									return nil
								}
								let path = pathTemplate
									.replacingOccurrences(of: "{qualityLevels}", with: qualityLevel.name)
									.replacingOccurrences(of: "{qualityLevelParams.token}", with: param.token)
								return (qualityLevel.name, URL(string: baseCdn + path)!)
							})
						self.qualityLevels = Dictionary(uniqueKeysWithValues: levels)
						
						if self.qualityLevels.isEmpty {
							self.logger.warning("No quality levels were able to be parsed from the video response. Showing an error to the user.", metadata: [
								"id": "\(self.videoAttachment.guid)",
								"qualityLevelNames": "\(cdnVod.resource.data.qualityLevels.map({ $0.name }).joined(separator: ", "))",
								"qualityLevelParams": "\(cdnVod.resource.data.qualityLevelParams.keys.joined(separator: ", "))",
							])
							self.state = .failed(VideoError.noQualityLevelsFound)
						}
						
						self.state = .loaded(cdnVod)
					case let .failure(error):
						self.logger.error("Encountered an unexpected error while loading video information. Reporting the error to the user. Error: \(String(reflecting: error))")
						self.state = .failed(error)
					}
				}
			}
	}
	
	private func metadataItem(identifier: AVMetadataIdentifier, value: Any) -> AVMetadataItem {
		let item = AVMutableMetadataItem()
		item.value = value as? NSCopying & NSObjectProtocol
		item.identifier = identifier
		item.extendedLanguageTag = "und" // undefined (wildcard) language
		return item
	}
	
	func createAVPlayerItem(desiredQuality: String) -> AVPlayerItem {
		self.logger.notice("Creating new AVPlayerItem for video playback.", metadata: [
			"id": "\(videoAttachment.guid)",
			"desiredQuality": "\(desiredQuality)",
		])
		var url = qualityLevels[desiredQuality]
		if url == nil {
			url = qualityLevels
				.sorted(by: { Int($0.key) ?? 0 < Int($1.key) ?? 0 })
				.filter({ Int($0.key) ?? 0 < Int(desiredQuality) ?? Int.max }) // Don't get a resolution larger than the desired.
				.last?
				.value
		}
		guard let url = url else {
			self.logger.critical("No playable URL was found for the video. Invalid state. Closing the application.")
			fatalError()
		}
		self.logger.debug("Setting up AVPlayerItem with matched content url.", metadata: [
			"url": "\(url)",
		])
		
		let asset = AVURLAsset(url: url, options: [AVURLAssetHTTPCookiesKey: HTTPCookieStorage.shared.cookies as Any])
		let templateItem = AVPlayerItem(asset: asset)
		templateItem.externalMetadata = avMetadataItems
		
		return templateItem
	}
}


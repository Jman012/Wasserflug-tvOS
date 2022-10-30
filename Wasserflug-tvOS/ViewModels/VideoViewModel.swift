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
	
	@Published var state: ViewModelState<(CdnDeliveryV3Response, ContentVideoV3Response)> = .idle
	
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
	
	private(set) var qualityLevels: [String: (URL, CdnDeliveryV3Variant)] = [:]
	
	init(fpApiService: FPAPIService, videoAttachment: VideoAttachmentModel, contentPost: ContentPostV3Response, description: AttributedString) {
		self.fpApiService = fpApiService
		self.videoAttachment = videoAttachment
		self.contentPost = contentPost
		self.description = description
	}
	
	func load() {
		Task { @MainActor in
			self.state = .loading
			
			let type: CDNV2API.ModelType_getDeliveryInfo = .vod
			self.logger.info("Loading video information.", metadata: [
				"type": "\(type)",
				"id": "\(videoAttachment.guid)",
			])
			
			let deliveryInfo: CdnDeliveryV3Response
			let videoContent: ContentVideoV3Response
			do {
				deliveryInfo = try await self.fpApiService.getDeliveryInfo(scenario: .ondemand, entityId: videoAttachment.guid, outputKind: nil)
				videoContent = try await self.fpApiService.getVideoContent(id: videoAttachment.id)
			} catch {
				self.state = .failed(error)
				return
			}
			
			self.logger.notice("Received video information.", metadata: [
				"origins": "\(deliveryInfo.groups.flatMap({ $0.origins ?? [] }).map({ $0.url }).joined(separator: ", "))"
			])
			
			let screenNativeBounds = UIScreen.main.nativeBounds
			// Only use the first group, for now.
			let group = deliveryInfo.groups.first
			let variants = group?.variants
			let filteredVariants = variants?.filter({ variant in
				let enabled = variant.enabled ?? false
				let hidden = variant.hidden ?? false
				
				// Filter out resolutions larger than the device's screen resolution to save
				// on bandwidth and downscaling performance.
				// Use height for these comparisons. If using width, we run into funny issues with
				// LTT videos which use 2:1 aspect ratios (1080p is 2160x1080 instead of 1920x1080,
				// and 4K is 4320x2160 instead of 3480x2160) which makes screen size comparisons
				// difficult to do correctly.
				// Just in case some creators have funny heights, allow for a 15% tolerance.
				var videoSizeOkay: Bool = false
				if let video = variant.meta?.video {
					videoSizeOkay = CGFloat(video.height ?? 0) <= (screenNativeBounds.height * 1.15)
					if !videoSizeOkay {
						self.logger.warning("Ignoring quality level \(String(describing: variant.name)) (\(video.width ?? 0) x \(video.height ?? 0)) due to larger-than-screen height of \(screenNativeBounds.height).")
					}
				}
				return enabled && !hidden && videoSizeOkay
			})
			
			let qualityLevelsAndUrls = filteredVariants?.compactMap({ (variant) -> (String, (URL, CdnDeliveryV3Variant))? in
				// Map the quality level to the correct URL
				if let url = DeliveryHelper.getBestUrl(variant: variant, group: group) {
					return (variant.name, (url, variant))
				}
				return nil
			}) ?? []
			self.qualityLevels = Dictionary(uniqueKeysWithValues: qualityLevelsAndUrls)
			
			if self.qualityLevels.isEmpty {
				self.logger.warning("No quality levels were able to be parsed from the video response. Showing an error to the user.", metadata: [
					"id": "\(self.videoAttachment.guid)",
					"qualityLevelNames": "\(group?.variants.map({ $0.name }).joined(separator: ", ") ?? "<nil>")",
				])
				self.state = .failed(VideoError.noQualityLevelsFound)
			}
			
			self.state = .loaded((deliveryInfo, videoContent))
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
		var url = qualityLevels[desiredQuality]?.0
		if url == nil {
			url = qualityLevels
				.sorted(by: { Int($0.key) ?? 0 < Int($1.key) ?? 0 })
				.filter({ Int($0.key) ?? 0 < Int(desiredQuality) ?? Int.max }) // Don't get a resolution larger than the desired.
				.last?
				.value.0
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
	
	func updateProgress(progressSeconds: Int) {
		Task { @MainActor in
			guard case let .loaded((_, videoModel)) = self.state else {
				return
			}
			
			self.logger.notice("Attempting to record watch progress for a video.", metadata: [
				"blogPostId": "\(videoModel.primaryBlogPost)",
				"videoId": "\(videoModel.id)",
				"progressSeconds": "\(progressSeconds)",
			])
			
			do {
				try await self.fpApiService.updateProgress(id: videoModel.id, contentType: .video, progress: progressSeconds)
			} catch {
				self.logger.warning("Could not update progress. Not showing an error as this is not critical.", metadata: [
					"id": "\(videoModel.id)",
					"progress": "\(progressSeconds)",
				])
			}
		}
	}
}


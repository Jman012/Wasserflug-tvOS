import Foundation
import FloatplaneAPIClient
import NIO
import AVKit
import SwiftUI
import Vapor
import zlib

class LivestreamViewModel: BaseViewModel, ObservableObject {
	
	enum LivestreamError: Error, CustomStringConvertible {
		case badResponse
		case missingCreator
		case badUrl
		
		var description: String {
			switch self {
			case .badResponse:
				return "There was an error retrieving the livestream information. Please try again."
			case .missingCreator:
				return "There was an error retrieving the creator information. Please try again."
			case .badUrl:
				return "There was an error preparing the livestream. Please try again."
			}
		}
	}
	
	@Published var state: ViewModelState<(CreatorModelV2, CdnDeliveryV2VodLivestreamResponse, URL)> = .idle
	@Published var isLive: Bool = false
	@Published var isLoadingLiveStatus: Bool = false
	
	private let fpApiService: FPAPIService
	let creatorId: String
	
	var shouldUpdatePlayer = false
	var liveStatusTimer: Timer?
	
	init(fpApiService: FPAPIService, creatorId: String) {
		self.fpApiService = fpApiService
		self.creatorId = creatorId
	}
	
	func load() {
		state = .loading
		
		let type: CDNV2API.ModelType_getDeliveryInfo = .live
		logger.debug("Loading livestream information.", metadata: [
			"type": "\(type)",
			"id": "\(creatorId)",
		])
		
		// First, load the creator information. We do get some static information
		// at app startup from the authentication code, but since we want to load
		// the livestream thumbnail, we don't want this to be out of date and stale.
		fpApiService
			.getInfo(creatorGUID: [creatorId])
			.flatMapResult { (response) -> Result<[CreatorModelV2], ErrorModel> in
				switch response {
				case let .http200(value: creators, raw: clientResponse):
					self.logger.debug("Creator information raw response: \(clientResponse.plaintextDebugContent)")
					return .success(creators)
				case let .http0(value: errorModel, raw: clientResponse),
					let .http400(value: errorModel, raw: clientResponse),
					let .http401(value: errorModel, raw: clientResponse),
					let .http403(value: errorModel, raw: clientResponse),
					let .http404(value: errorModel, raw: clientResponse):
					self.logger.warning("Received an unexpected HTTP status (\(clientResponse.status.code)) while loading creator information. Error Model: \(String(reflecting: errorModel)).")
					return .failure(errorModel)
				}
			}
			.whenComplete { result in
				switch result {
				case let .success(creators):
					guard let creator = creators.first(where: { $0.id == self.creatorId }) else {
						self.logger.error("Did not receive creator information correctly. Reporting the error to the user.")
						self.state = .failed(LivestreamError.missingCreator)
						return
					}
					
					// Second, get the CDN information
					self.fpApiService
						.getCdn(type: type, id: self.creatorId)
						.flatMapResult { (response) -> Result<CdnDeliveryV2Response, ErrorModel> in
							switch response {
							case let .http200(value: cdnResponse, raw: clientResponse):
								self.logger.debug("Livestream informaton raw response: \(clientResponse.plaintextDebugContent)")
								return .success(cdnResponse)
							case let .http0(value: errorModel, raw: clientResponse),
								let .http400(value: errorModel, raw: clientResponse),
								let .http401(value: errorModel, raw: clientResponse),
								let .http403(value: errorModel, raw: clientResponse),
								let .http404(value: errorModel, raw: clientResponse):
								self.logger.warning("Received an unexpected HTTP status (\(clientResponse.status.code)) while loading livestream information. Error Model: \(String(reflecting: errorModel)).")
								return .failure(errorModel)
							}
						}
						.whenComplete { result in
							DispatchQueue.main.async {
								switch result {
								case let .success(response):
									guard case let .typeCdnDeliveryV2VodLivestreamResponse(cdnLivestream) = response else {
										self.state = .failed(LivestreamError.badResponse)
										return
									}
									self.logger.notice("Received livestream information.", metadata: [
										"cdn": "\(cdnLivestream.cdn)",
									])
									let baseCdn = cdnLivestream.cdn
									let pathTemplate = cdnLivestream.resource.uri
									let newPath = baseCdn + CDNTemplateRenderer.render(template: pathTemplate, data: cdnLivestream.resource.data, quality: cdnLivestream.resource.data.qualityLevels?.first ?? CdnDeliveryV2QualityLevelModel(name: "", label: "", order: 0))
									guard let newUrl = URL(string: newPath) else {
										self.state = .failed(LivestreamError.badUrl)
										return
									}
									if case let .loaded((_, _, oldUrl)) = self.state {
										if newUrl != oldUrl {
											self.shouldUpdatePlayer = true
										}
									}
									self.startLoadingLiveStatus()
									
									self.state = .loaded((creator, cdnLivestream, newUrl))
								case let .failure(error):
									self.logger.error("Encountered an unexpected error while loading livestream information. Reporting the error to the user. Error: \(String(reflecting: error))")
//									self.path = nil
									self.state = .failed(error)
								}
							}
						}
					
				case let .failure(error):
					self.logger.error("Encountered an unexpected error while loading creator information. Reporting the error to the user. Error: \(String(reflecting: error))")
					self.state = .failed(error)
				}
			}
	}
	
	func loadLiveStatus() {
		guard case let .loaded((_, _, url)) = self.state else {
			return
		}
		logger.debug("Loading livestream status", metadata: [
			"id": "\(creatorId)",
		])
		self.isLoadingLiveStatus = true
		fpApiService
			.getLivestream(url: URI(string: url.absoluteString))
			.whenComplete({ result in
				DispatchQueue.main.async {
					self.isLoadingLiveStatus = false
					switch result {
					case let .success(clientResponse):
						if clientResponse.status == .ok {
							self.isLive = true
							self.logger.debug("Livestream is live", metadata: [
								"id": "\(self.creatorId)",
							])
						} else {
							self.isLive = false
							self.logger.debug("Livestream is not live", metadata: [
								"id": "\(self.creatorId)",
							])
						}
					case let .failure(error):
						self.logger.warning("Encountered unexpected error when loading livestream status. Error: \(String(reflecting: error))")
						self.isLive = false
					}
				}
			})
	}
	
	func stopLoadingLiveStatus() {
		logger.debug("Stopping livestream polling", metadata: [
			"id": "\(creatorId)",
		])
		self.liveStatusTimer?.invalidate()
		self.liveStatusTimer = nil
	}
	
	func startLoadingLiveStatus() {
		let interval: TimeInterval = 5.0
		logger.info("Starting livestream polling", metadata: [
			"id": "\(creatorId)",
			"interval": "\(interval)",
		])
		guard self.liveStatusTimer == nil else {
			return
		}
		self.loadLiveStatus()
		self.liveStatusTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { _ in
			self.loadLiveStatus()
		})
	}
	
	private func metadataItem(identifier: AVMetadataIdentifier, value: Any) -> AVMetadataItem {
		let item = AVMutableMetadataItem()
		item.value = value as? NSCopying & NSObjectProtocol
		item.identifier = identifier
		item.extendedLanguageTag = "und" // undefined (wildcard) language
		return item
	}
	
	func avMetadataItems(for creator: CreatorModelV2) -> [AVMetadataItem] {
		return [
			metadataItem(identifier: .commonIdentifierTitle, value: creator.liveStream?.title ?? "Livestream"),
			metadataItem(identifier: .commonIdentifierDescription, value: creator.liveStream?.description ?? ""),
		]
	}
	
	func createAVPlayerItem() -> AVPlayerItem {
		self.logger.notice("Creating new AVPlayerItem for livestream playback.", metadata: [
			"id": "\(creatorId)",
		])
		guard case let .loaded((creator, _, url)) = self.state else {
			self.logger.critical("No playable URL was found for the livestream. Invalid state. Closing the application.")
			fatalError()
		}
		self.logger.debug("Setting up AVPlayerItem with matched content url.", metadata: [
			"url": "\(url)",
		])
		
		let asset = AVURLAsset(url: url, options: [AVURLAssetHTTPCookiesKey: HTTPCookieStorage.shared.cookies as Any])
		let templateItem = AVPlayerItem(asset: asset)
		templateItem.externalMetadata = avMetadataItems(for: creator)
		
		return templateItem
	}
}


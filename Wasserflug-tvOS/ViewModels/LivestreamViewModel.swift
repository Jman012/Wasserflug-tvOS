import Foundation
import FloatplaneAPIClient
import NIO
import AVKit
import SwiftUI
import Vapor

class LivestreamViewModel: BaseViewModel, ObservableObject {
	@Published var state: ViewModelState<CdnDeliveryV2Response> = .idle
	@Published var isLive: Bool = false
	@Published var isLoadingLiveStatus: Bool = false
	
	private let fpApiService: FPAPIService
	let creator: CreatorModelV2
	
	var avMetadataItems: [AVMetadataItem] {
		return [
			metadataItem(identifier: .commonIdentifierTitle, value: creator.liveStream?.title ?? "Livestream"),
			metadataItem(identifier: .commonIdentifierDescription, value: creator.liveStream?.description ?? ""),
		]
	}
	
	@Published var path: String? = nil
	var shouldUpdatePlayer = false
	var liveStatusTimer: Timer?
	
	init(fpApiService: FPAPIService, creator: CreatorModelV2) {
		self.fpApiService = fpApiService
		self.creator = creator
	}
	
	func load() {
		state = .loading
		
		let type: CDNV2API.ModelType_getDeliveryInfo = .live
		logger.debug("Loading livestream information.", metadata: [
			"type": "\(type)",
			"id": "\(creator.id)",
		])
		
		fpApiService
			.getCdn(type: type, id: creator.id)
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
						self.logger.notice("Received livestream information.", metadata: [
							"cdn": "\(response.cdn)",
						])
						let baseCdn = response.cdn
						let pathTemplate = response.resource.uri!
						let newPath = baseCdn + pathTemplate.replacingOccurrences(of: "{token}", with: response.resource.data.token ?? "")
						if newPath != self.path {
							self.path = newPath
							self.shouldUpdatePlayer = true
						}
						self.startLoadingLiveStatus()
						
						self.state = .loaded(response)
					case let .failure(error):
						self.logger.error("Encountered an unexpected error while loading livestream information. Reporting the error to the user. Error: \(String(reflecting: error))")
						self.path = nil
						self.state = .failed(error)
					}
				}
			}
	}
	
	func loadLiveStatus() {
		guard let path = self.path, path != "" else {
			return
		}
		logger.debug("Loading livestream status", metadata: [
			"id": "\(creator.id)",
		])
		self.isLoadingLiveStatus = true
		fpApiService
			.getLivestream(url: URI(string: path))
			.whenComplete({ result in
				DispatchQueue.main.async {
					self.isLoadingLiveStatus = false
					switch result {
					case let .success(clientResponse):
						if clientResponse.status == .ok {
							self.isLive = true
							self.logger.debug("Livestream is live", metadata: [
								"id": "\(self.creator.id)",
							])
						} else {
							self.isLive = false
							self.logger.debug("Livestream is not live", metadata: [
								"id": "\(self.creator.id)",
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
			"id": "\(creator.id)",
		])
		self.liveStatusTimer?.invalidate()
		self.liveStatusTimer = nil
	}
	
	func startLoadingLiveStatus() {
		let interval: TimeInterval = 5.0
		logger.info("Starting livestream polling", metadata: [
			"id": "\(creator.id)",
			"interval": "\(interval)",
		])
		guard self.liveStatusTimer == nil else {
			return
		}
		self.loadLiveStatus()
		let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { _ in
			self.loadLiveStatus()
		})
//		RunLoop.main.add(timer, forMode: .common)
		self.liveStatusTimer = timer
	}
	
	private func metadataItem(identifier: AVMetadataIdentifier, value: Any) -> AVMetadataItem {
		let item = AVMutableMetadataItem()
		item.value = value as? NSCopying & NSObjectProtocol
		item.identifier = identifier
		item.extendedLanguageTag = "und" // undefined (wildcard) language
		return item
	}
	
	func createAVPlayerItem() -> AVPlayerItem {
		self.logger.notice("Creating new AVPlayerItem for livestream playback.", metadata: [
			"id": "\(creator.id)",
		])
		guard let url = URL(string: self.path ?? "") else {
			self.logger.critical("No playable URL was found for the livestream. Invalid state. Closing the application.")
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


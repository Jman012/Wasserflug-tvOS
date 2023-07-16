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
	
	@Published var state: ViewModelState<(CreatorModelV2, CdnDeliveryV3Response, URL)> = .idle
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
		Task { @MainActor in
			state = .loading
			
			let type: CDNV2API.ModelType_getDeliveryInfo = .live
			logger.debug("Loading livestream information.", metadata: [
				"type": "\(type)",
				"id": "\(creatorId)",
			])
			
			// First, load the creator information. We do get some static information
			// at app startup from the authentication code, but since we want to load
			// the livestream thumbnail, we don't want this to be out of date and stale,
			// in the case that it was updated since app launch when a livestream begins.
			let creatorsResponse: [CreatorModelV2]
			do {
				creatorsResponse = try await fpApiService.getInfo(creatorGUID: [creatorId])
			} catch {
				self.state = .failed(error)
				return
			}
			
			guard let creator = creatorsResponse.first(where: { $0.id == self.creatorId }), let livestream = creator.liveStream else {
				self.logger.error("Did not receive creator information correctly. Reporting the error to the user.")
				self.state = .failed(LivestreamError.missingCreator)
				return
			}
			
			let cdnResponse: CdnDeliveryV3Response
			do {
				cdnResponse = try await fpApiService.getDeliveryInfo(scenario: .live, entityId: livestream.id, outputKind: nil)
			} catch {
				self.state = .failed(error)
				return
			}
			
			self.logger.notice("Received livestream information.", metadata: [
				"origins": "\(cdnResponse.groups.flatMap({ $0.origins ?? [] }).map({ $0.url }).joined(separator: ", "))",
			])
			// Only use the first group, for now.
			let group = cdnResponse.groups.first
			let urls = group?.variants.compactMap({ variant -> URL? in
				return DeliveryHelper.getBestUrl(variant: variant, group: group)
			})
			// Livestreams should only really have a single variant. Use the first one returned.
			guard let newUrl = urls?.first else {
				self.state = .failed(LivestreamError.badUrl)
				return
			}
			
			self.shouldUpdatePlayer = true
			self.state = .loaded((creator, cdnResponse, newUrl))
			self.startLoadingLiveStatus()
			self.loadLiveStatus()
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
		self.liveStatusTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { _ in
			self.loadLiveStatus()
		})
		self.loadLiveStatus()
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

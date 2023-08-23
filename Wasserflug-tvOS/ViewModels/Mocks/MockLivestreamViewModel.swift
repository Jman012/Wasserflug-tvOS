import Foundation
import SwiftUI
import FloatplaneAPIClient

class MockOfflineLivestreamViewModel: LivestreamViewModel {
	
	init() {
		super.init(fpApiService: MockFPAPIService(), creatorId: "")
		
		let creator = CreatorModelV2(id: "",
									 owner: "",
									 title: "",
									 urlname: "",
									 description: "",
									 about: "",
									 category: "",
									 cover: nil,
									 icon: .init(width: 0, height: 0, path: "", childImages: nil),
									 liveStream: .init(id: "",
													   title: "",
													   description: "",
													   thumbnail: nil,
													   owner: "",
													   streamPath: "",
													   offline: .init(title: "Offline",
																	  description: "We're offline for now",
																	  thumbnail: .init(width: 1920,
																					   height: 1080,
																					   path: "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026.jpeg",
																					   childImages: nil))),
									 subscriptionPlans: nil,
									 discoverable: true,
									 subscriberCountDisplay: "",
									 incomeDisplay: false)
		let cdn = CdnDeliveryV3Response(groups: [])
		let url: URL = URL(string: "https://google.com")!
		self.state = .loaded((creator, cdn, url))
	}
	
	override func load() {
	}
	
	override func loadLiveStatus() {
	}
	
	override func startLoadingLiveStatus() {
	}
	
	override func stopLoadingLiveStatus() {
	}
}

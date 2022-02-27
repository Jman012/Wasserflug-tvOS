import Foundation
import FloatplaneAPIClient
import Vapor

class HomeViewModel: BaseViewModel, ObservableObject {
	
	enum LoadingMode {
		case append
		case prepend
	}
	
	let userInfo: UserInfo
	private let fpApiService: FPAPIService
	
	@Published var state: ViewModelState<ContentCreatorListV3Response> = .idle
	private var isVisible = true
	
	init(userInfo: UserInfo, fpApiService: FPAPIService) {
		self.userInfo = userInfo
		self.fpApiService = fpApiService
	}
	
	func load(loadingMode: LoadingMode = .append) {
		if self.state.isIdle {
			state = .loading
		}
		
		var lastElements: [ContentCreatorListLastItems]? = nil
		switch (loadingMode, state) {
		case let (.append, .loaded(response)):
			lastElements = response.lastElements
		default:
			break
		}
		
		let limit = 20
		let ids = self.userInfo.creators.keys.map({ $0 })
		logger.info("Loading home content.", metadata: [
			"loadingMode": "\(loadingMode)",
			"userId": "\(self.userInfo.userSelf?.id ?? "")",
			"creatorIds": "\(ids.description)",
			"limit": "\(limit)",
			"lastElements": "\(lastElements?.description ?? "<nil>")",
		])
		
		fpApiService
			.getHomeContent(ids: ids, limit: limit, lastItems: lastElements)
			.whenComplete { result in
				DispatchQueue.main.async {
					switch result {
					case let .success(response):
						switch response {
						case let .http200(value: response, raw: clientResponse):
							self.logger.debug("Home content raw response: \(clientResponse.plaintextDebugContent)")
							switch (loadingMode, self.state) {
							case let (.append, .loaded(prevResponse)):
								self.logger.notice("Received home content. Appending new items to list. Received \(response.blogPosts.count) items.")
								self.state = .loaded(.init(blogPosts: prevResponse.blogPosts + response.blogPosts, lastElements: response.lastElements))
							case (.prepend, let .loaded(prevResponse)):
								let prevResponseIds = Set(prevResponse.blogPosts.lazy.map({ $0.id }))
								if let last = response.blogPosts.last, prevResponseIds.contains(last.id) {
									let newBlogPosts = response.blogPosts.filter({ !prevResponseIds.contains($0.id) })
									self.logger.notice("Received home content. Received \(response.blogPosts.count) items. Prepending only new items to list. Prepending \(newBlogPosts.count) items.")
									if !newBlogPosts.isEmpty {
										self.state = .loaded(.init(blogPosts: newBlogPosts + prevResponse.blogPosts, lastElements: prevResponse.lastElements))
									}
								} else {
									self.logger.notice("Received home content. Encountered gap in new items and old items. Resetting list to only new items. Received \(response.blogPosts.count) items.")
									
									self.state = .loaded(.init(blogPosts: response.blogPosts, lastElements: response.lastElements))
								}
							default:
								self.logger.notice("Received initial home content. Received \(response.blogPosts.count) items.")
								self.state = .loaded(response)
							}
						case let .http0(value: errorModel, raw: clientResponse),
							let .http400(value: errorModel, raw: clientResponse),
							let .http401(value: errorModel, raw: clientResponse),
							let .http403(value: errorModel, raw: clientResponse),
							let .http404(value: errorModel, raw: clientResponse):
							self.logger.warning("Received an unexpected HTTP status (\(clientResponse.status.code)) while loading home content. Reporting the error to the user. Error Model: \(String(reflecting: errorModel)).")
							self.state = .failed(errorModel)
						}
					case let .failure(error):
						self.logger.error("Encountered an unexpected error while loading home content. Reporting the error to the user. Error: \(String(reflecting: error))")
						self.state = .failed(error)
					}
				}
			}
	}
	
	func itemDidAppear(_ item: BlogPostModelV3) {
		switch state {
		case let .loaded(response):
			if response.lastElements.contains(where: { $0.creatorId == item.creator.id && $0.blogPostId == item.id }) {
				self.logger.info("Last item appeared on screen. Loading more home content.")
				self.load()
			}
		default:
			break
		}
	}
	
	func homeDidDisappear() {
		isVisible = false
	}
	
	func homeDidAppearAgain() {
		if !isVisible {
			self.load(loadingMode: .prepend)
		}
	}
}

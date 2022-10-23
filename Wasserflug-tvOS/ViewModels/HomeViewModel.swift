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
	@Published var progresses: Dictionary<String, Int> = [:]
	private var isVisible = true
	
	init(userInfo: UserInfo, fpApiService: FPAPIService) {
		self.userInfo = userInfo
		self.fpApiService = fpApiService
	}
	
	func load(loadingMode: LoadingMode = .append) {
		Task { @MainActor in
			if self.state.isIdle {
				state = .loading
			}
			
			var lastElements: [ContentCreatorListLastItems]? = nil
			switch (loadingMode, state) {
			case let (.append, .loaded(response)):
				// Floatplane doesn't like when we send one of these without a blogPostId.
				// so, filter those objects out before using them.
				lastElements = response.lastElements.filter({ $0.blogPostId != nil })
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
		
			let response: ContentCreatorListV3Response
			do {
				response = try await fpApiService.getHomeContent(ids: ids, limit: limit, lastItems: lastElements)
			} catch {
				self.state = .failed(error)
				return
			}
			
			logger.info("Loading progress for home content in background.")
			Task {
				do {
					let progresses = try await fpApiService.getProgress(ids: response.blogPosts.map({ $0.id }))
					for progress in progresses {
						self.progresses[progress.id] = progress.progress
					}
					self.logger.info("Done loading \(progresses.count) progresses for home content.")
				} catch {
					self.state = .failed(error)
				}
			}
			
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

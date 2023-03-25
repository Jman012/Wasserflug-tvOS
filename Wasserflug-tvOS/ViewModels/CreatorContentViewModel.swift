import SwiftUI
import Combine
import FloatplaneAPIClient

class CreatorContentViewModel: BaseViewModel, ObservableObject {
	
	enum LoadingMode {
		case append
		case prepend
	}
	
	@Published var state: ViewModelState<[BlogPostModelV3]> = .idle
	@Published var searchText: String = ""
	@Published var progresses: Dictionary<String, Int> = [:]
	
	private var isVisible = true
	private let fpApiService: FPAPIService
	let creator: CreatorModelV2
	let creatorOwner: UserModelShared
	var searchDebounce: AnyCancellable? = nil
	
	var hasCover: Bool {
		creator.cover == nil
	}
	
	var coverImagePath: URL? {
		if let cover = creator.cover {
			return URL(string: cover.path)
		} else {
			return nil
		}
	}
	
	var creatorProfileImagePath: URL? {
		URL(string: creatorOwner.profileImage.path)
	}
	
	fileprivate var creatorAboutFirstNewlineIndex: String.Index {
		creator.about.firstIndex(of: "\n") ?? creator.about.startIndex
	}
	lazy var creatorAboutHeader: AttributedString = (try? AttributedString(markdown: String(creator.about[..<creatorAboutFirstNewlineIndex]))) ?? AttributedString("")
	lazy var creatorAboutBody: AttributedString = (try? AttributedString(markdown: String(creator.about[creatorAboutFirstNewlineIndex...]))) ?? AttributedString("")
	
	init(fpApiService: FPAPIService, creator: CreatorModelV2, creatorOwner: UserModelShared) {
		self.fpApiService = fpApiService
		self.creator = creator
		self.creatorOwner = creatorOwner
		super.init()
		
		searchDebounce = $searchText
			.debounce(for: 0.8, scheduler: DispatchQueue.main)
			.dropFirst()
			.sink(receiveValue: { _ in
				self.state = .loading
				self.load()
			})
	}
	
	func createSubViewModel() -> CreatorContentViewModel {
		return CreatorContentViewModel(fpApiService: fpApiService, creator: creator, creatorOwner: creatorOwner)
	}
	
	func load(loadingMode: LoadingMode = .append) {
		Task { @MainActor in
			if self.state.isIdle {
				state = .loading
			}
			
			var fetchAfter = 0
			switch (loadingMode, state) {
			case let (.append, .loaded(posts)):
				fetchAfter = posts.count
			default:
				break
			}
			
			let id = creator.id
			let limit = 20
			logger.info("Loading creator content.", metadata: [
				"creatorId": "\(id)",
				"limit": "\(limit)",
				"fetchAfter": "\(fetchAfter)",
				"serchText": "\(self.searchText)",
			])
			
			let response: [BlogPostModelV3]
			do {
				response = try await fpApiService.getCreatorContent(id: id, limit: limit, fetchAfter: fetchAfter, search: self.searchText)
			} catch {
				self.state = .failed(error)
				return
			}
			
			logger.info("Loading progress for creator content in background.")
			Task {
				do {
					let progresses = try await fpApiService.getProgress(ids: response.map({ $0.id }))
					for progress in progresses {
						self.progresses[progress.id] = progress.progress
					}
					self.logger.info("Done loading \(progresses.count) progresses for creator content.")
				} catch {
					// Ignore errors
					//self.state = .failed(error)
				}
			}
			
			switch (loadingMode, self.state) {
			case let (.append, .loaded(posts)):
				self.logger.notice("Received creator content. Appending new items to list. Received \(response.count) items.")
				self.state = .loaded(posts + response)
			case let (.prepend, .loaded(prevResponse)):
				let prevResponseIds = Set(prevResponse.lazy.map({ $0.id }))
				if let last = response.last, prevResponseIds.contains(last.id) {
					let newBlogPosts = response.filter({ !prevResponseIds.contains($0.id) })
					self.logger.notice("Received creator content. Received \(response.count) items. Prepending only new items to list. Prepending \(newBlogPosts.count) items.")
					if !newBlogPosts.isEmpty {
						self.state = .loaded(newBlogPosts + prevResponse)
					}
				} else {
					self.logger.notice("Received creator content. Encountered gap in new items and old items. Resetting list to only new items. Received \(response.count) items.")
					
					self.state = .loaded(response)
				}
			default:
				self.logger.notice("Received creator content. Received \(response.count) items.")
				self.state = .loaded(response)
			}
		}
	}
	
	func itemDidAppear(_ item: BlogPostModelV3) {
		switch state {
		case let .loaded(posts):
			if posts.lastIndex(of: item) == posts.endIndex.advanced(by: -1) {
				self.logger.info("Last item appeared on screen. Loading more creator content.")
				self.load()
			}
		default:
			break
		}
	}
	
	func creatorContentDidDisappear() {
		isVisible = false
	}
	
	func creatorContentDidAppearAgain() {
		if !isVisible {
			self.load(loadingMode: .prepend)
		}
	}
}

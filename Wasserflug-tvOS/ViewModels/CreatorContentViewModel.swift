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
	
	private var isVisible = true
	private let fpApiService: FPAPIService
	let creator: CreatorModelV2
	let creatorOwner: UserModel
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
    
    var coverImageWidth: CGFloat? {
        if let cover = creator.cover {
            return CGFloat(cover.width)
        } else {
            return nil
        }
    }
    
    var coverImageHeight: CGFloat? {
        if let cover = creator.cover {
            return CGFloat(cover.height)
        } else {
            return nil
        }
    }
    
    var coverRatio: CGFloat? {
        if let cover = creator.cover {
            return CGFloat(cover.aspectRatio)
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
	
	init(fpApiService: FPAPIService, creator: CreatorModelV2, creatorOwner: UserModel) {
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
		
		fpApiService.getCreatorContent(id: id, limit: limit, fetchAfter: fetchAfter, search: self.searchText)
			.whenComplete { result in
				DispatchQueue.main.async {
					switch result {
					case let .success(response):
						switch response {
						case let .http200(value: response, raw: clientResponse):
							self.logger.debug("Creator content raw response: \(clientResponse.plaintextDebugContent)")
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
							
						case let .http0(value: errorModel, raw: clientResponse),
							let .http400(value: errorModel, raw: clientResponse),
							let .http401(value: errorModel, raw: clientResponse),
							let .http403(value: errorModel, raw: clientResponse),
							let .http404(value: errorModel, raw: clientResponse):
							self.logger.warning("Received an unexpected HTTP status (\(clientResponse.status.code)) while loading creator content. Reporting the error to the user. Error Model: \(String(reflecting: errorModel)).")
							self.state = .failed(errorModel)
						}
					case let .failure(error):
						self.logger.error("Encountered an unexpected error while loading creator content. Reporting the error to the user. Error: \(String(reflecting: error))")
						self.state = .failed(error)
					}
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

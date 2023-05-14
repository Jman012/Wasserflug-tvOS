import SwiftUI

struct CreatorSearchView: View {
	
	@StateObject var viewModel: CreatorContentViewModel
	
	let creatorName: String
	
	private let gridColumns: [GridItem] = [
		GridItem(.flexible(minimum: 0, maximum: .infinity), alignment: .top),
		GridItem(.flexible(minimum: 0, maximum: .infinity), alignment: .top),
		GridItem(.flexible(minimum: 0, maximum: .infinity), alignment: .top),
		GridItem(.flexible(minimum: 0, maximum: .infinity), alignment: .top),
	]
	
	var body: some View {
		ScrollView {
			switch viewModel.state {
			case .idle:
				EmptyView()
			case .loading:
				ProgressView()
			case let .failed(error):
				ErrorView(error: error, tryAgainText: "Try Again", tryAgainHandler: {
					viewModel.state = .loading
					viewModel.load()
				})
			case let .loaded(content):
				LazyVGrid(columns: gridColumns, spacing: 60) {
					ForEach(content) { blogPost in
						BlogPostSelectionView(
							blogPost: blogPost,
							viewOrigin: .creator,
							watchProgresses: FetchRequest(entity: WatchProgress.entity(), sortDescriptors: [], predicate: NSPredicate(format: "blogPostId = %@", blogPost.id), animation: .default)
						)
							.onAppear(perform: {
								viewModel.itemDidAppear(blogPost)
							})
					}
				}
					.padding(40)
			}
		}
		.searchable(text: $viewModel.searchText, prompt: "Search \(self.creatorName)")
	}
}

struct CreatorSearchView_Previews: PreviewProvider {
	static var previews: some View {
		CreatorSearchView(viewModel: CreatorContentViewModel(fpApiService: MockFPAPIService(), managedObjectContext: PersistenceController.preview.container.viewContext, creator: MockData.creators.first!, creatorOwner: MockData.creatorOwners.users[0].user.userModelShared), creatorName: "Linus Tech Tips")
	}
}

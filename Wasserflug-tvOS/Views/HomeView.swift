import SwiftUI
import FloatplaneAPIClient

struct HomeView: View {
	@StateObject var viewModel: HomeViewModel
	
	@Environment(\.scenePhase) var scenePhase
	@EnvironmentObject var userInfo: UserInfo
	
	@FocusState var blogPostFocus: String?
	
	private let gridColumns: [GridItem] = [
		GridItem(.flexible(minimum: 0, maximum: .infinity), alignment: .top),
		GridItem(.flexible(minimum: 0, maximum: .infinity), alignment: .top),
		GridItem(.flexible(minimum: 0, maximum: .infinity), alignment: .top),
		GridItem(.flexible(minimum: 0, maximum: .infinity), alignment: .top),
	]
	
	var body: some View {
		switch viewModel.state {
		case .idle:
			Color.clear.onCombinedCustomAppear {
				viewModel.load()
			}
		case .loading:
			ProgressView()
		case let .failed(error):
			ErrorView(error: error, tryAgainText: "Refresh", tryAgainHandler: {
				viewModel.state = .idle
			})
		case let .loaded(response):
			ScrollView {
				LazyVGrid(columns: gridColumns, spacing: 60) {
					ForEach(response.blogPosts) { blogPost in
						BlogPostSelectionView(
							blogPost: blogPost,
							viewOrigin: .home(userInfo.creatorOwners[blogPost.creator.owner.id]?.asAnyUserModelShared()),
							progressPercentage: viewModel.progresses[blogPost.id] ?? 0
						)
							.focused($blogPostFocus, equals: blogPost.id)
							.onAppear(perform: {
								viewModel.itemDidAppear(blogPost)
							})
					}
				}
					.padding(40)
			}.onCombinedCustomDisappear {
				viewModel.homeDidDisappear()
			}.onCombinedCustomAppear {
				blogPostFocus = response.blogPosts.first?.id
				// Load new content when the view re-appears, like when switching
				// tabs. There is no refresh button.
				viewModel.homeDidAppearAgain()
			}.onChange(of: scenePhase, perform: { phase in
				switch phase {
				case .active:
					// Similarly, load new content if the app wakes up from
					// inactive/background activity.
					viewModel.homeDidAppearAgain()
				case .inactive, .background:
					viewModel.homeDidDisappear()
				@unknown default:
					break
				}
			})
		}
	}
}

struct HomeView_Previews: PreviewProvider {
	static var previews: some View {
		NavigationView {
			HomeView(viewModel: HomeViewModel(userInfo: MockData.userInfo, fpApiService: MockFPAPIService()))
				.environmentObject(MockData.userInfo)
		}
	}
}

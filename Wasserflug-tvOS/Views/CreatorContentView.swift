import SwiftUI
import FloatplaneAPIClient
import CachedAsyncImage

struct CreatorContentView: View {
	@StateObject var viewModel: CreatorContentViewModel
	@StateObject var livestreamViewModel: LivestreamViewModel
	
	@State var isShowingSearch = false
	@State var isShowingLive = false
	
	@EnvironmentObject var userInfo: UserInfo
	@Environment(\.fpApiService) var fpApiService
	
	let gridColumns: [GridItem] = [
		GridItem(.flexible(minimum: 0, maximum: .infinity), alignment: .top),
		GridItem(.flexible(minimum: 0, maximum: .infinity), alignment: .top),
		GridItem(.flexible(minimum: 0, maximum: .infinity), alignment: .top),
		GridItem(.flexible(minimum: 0, maximum: .infinity), alignment: .top),
	]
	
	var body: some View {
		VStack {
			switch viewModel.state {
			case .idle:
				ProgressView().onAppear(perform: {
					viewModel.load()
					livestreamViewModel.load()
					livestreamViewModel.startLoadingLiveStatus()
				})
			case .loading:
				ProgressView()
			case let .failed(error):
				ErrorView(error: error)
			case let .loaded(content):
				GeometryReader { geometry in
					ScrollView {
						CachedAsyncImage(url: viewModel.coverImagePath, content: { image in
							ZStack {
								image
									.resizable()
									.scaledToFill()
									.overlay(LinearGradient(
										colors: [.clear, .black.opacity(0.6)],
										startPoint: .top,
										endPoint: .bottom)
									)
							}
						}, placeholder: {
							ProgressView()
								.frame(maxWidth: .infinity, maxHeight: .infinity)
								.aspectRatio(viewModel.creator.cover?.aspectRatio ?? 1.0, contentMode: .fit)
						})
						
						HStack(alignment: .top) {
							CachedAsyncImage(url: viewModel.creatorProfileImagePath, content: { image in
								image
									.resizable()
									.frame(width: 150, height: 150)
									.clipShape(Circle())
							}, placeholder: {
								ProgressView()
									.frame(width: 150, height: 150)
							})
								.offset(x: 20, y: -95)
							
							Button(action: {
								isShowingSearch = true
							}, label: {
								Label("Search", systemImage: "magnifyingglass")
							})
								.sheet(isPresented: $isShowingSearch, onDismiss: {
									isShowingSearch = false
								}, content: {
									CreatorSearchView(viewModel: CreatorContentViewModel(fpApiService: fpApiService, creator: viewModel.creator, creatorOwner: viewModel.creatorOwner), creatorName: viewModel.creator.title)
								})
							Button(action: {
								isShowingLive = true
//								self.livestreamViewModel.stopLoadingLiveStatus()
							}, label: {
								Label("Livestream", systemImage: livestreamViewModel.isLive ? "play.tv" : "bolt.horizontal")
							})
								.disabled(!livestreamViewModel.isLive)
								.sheet(isPresented: $isShowingLive, onDismiss: {
									self.isShowingLive = false
//									self.livestreamViewModel.startLoadingLiveStatus()
								}, content: {
									LivestreamPlayerView(viewModel: self.livestreamViewModel)
										.edgesIgnoringSafeArea(.all)
								})
							
							VStack {
								Text(viewModel.creatorAboutHeader)
									.fontWeight(.bold)
									.font(.system(.headline))
									.frame(maxWidth: .infinity, alignment: .leading)
								Text(viewModel.creatorAboutBody)
									.frame(maxWidth: .infinity, alignment: .leading)
							}
						}
							.padding(.top)
							.focusSection()
						
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
				}.onDisappear {
					viewModel.creatorContentDidDisappear()
				 }.onAppear {
					viewModel.creatorContentDidAppearAgain()
					livestreamViewModel.loadLiveStatus()
				 }
			}
		}
	}

}

struct CreatorContentView_Previews: PreviewProvider {
	@State static var selection = RootTabView.Selection.creator(MockData.creators[0].id)
	static var previews: some View {
		TabView(selection: $selection) {
			Text("test").tabItem {
				Text("Home")
			}
			CreatorContentView(viewModel: CreatorContentViewModel(
				fpApiService: MockFPAPIService(),
				creator: MockData.creators[0],
				creatorOwner: MockData.creatorOwners.users[0].user
			), livestreamViewModel: LivestreamViewModel(
				fpApiService: MockFPAPIService(),
				creator: MockData.creators[0])
			)
				.tag(RootTabView.Selection.creator(MockData.creators[0].id))
				.tabItem {
					Text(MockData.creators[0].title)
				}
				.environmentObject(MockData.userInfo)
			Text("test").tabItem {
				Text("Settings")
			}
		}
	}
}

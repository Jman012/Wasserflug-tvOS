import SwiftUI
import FloatplaneAPIClient

struct RootTabView: View {
	
	enum Selection: Hashable {
		case home
		case creator(String)
		case settings
	}
	
	@EnvironmentObject var userInfo: UserInfo
	@Environment(\.fpApiService) var fpApiService
	@State var selection: Selection = .home
	
	var body: some View {
		TabView(selection: $selection) {
			HomeView(viewModel: HomeViewModel(userInfo: userInfo, fpApiService: fpApiService))
				.tag(Selection.home)
				.tabItem {
					Text("Home")
				}
			
			// There is an issue where multiple subscriptions for one creator might be active.
			// Instead of showing one tab per subscription, show one per creator.
			ForEach(userInfo.creatorsInOrder, id: \.0.id) { (creator, creatorOwner) in
				CreatorContentView(viewModel: CreatorContentViewModel(fpApiService: fpApiService, creator: creator, creatorOwner: creatorOwner), livestreamViewModel: LivestreamViewModel(fpApiService: fpApiService, creator: creator))
					.tag(Selection.creator(creator.id))
					.tabItem {
						Text(creator.title)
					}
			}
			SettingsView()
				.tag(Selection.settings)
				.tabItem {
					Text("Settings")
				}
		}
	}
}

struct RootTabView_Previews: PreviewProvider {
	static var previews: some View {
		RootTabView()
			.environmentObject(MockData.userInfo)
			.environment(\.fpApiService, MockFPAPIService())
	}
}

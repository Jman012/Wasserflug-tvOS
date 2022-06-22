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
                    #if os(tvOS)
					Text("Home")
                    #else
                    Label("Home", systemImage: "house")
                    #endif
				}
			ForEach(userInfo.userSubscriptions) { sub in
				let creator = userInfo.creators[sub.creator]!
				let creatorOwner = userInfo.creatorOwners[creator.owner]!
				CreatorContentView(viewModel: CreatorContentViewModel(fpApiService: fpApiService, creator: creator, creatorOwner: creatorOwner), livestreamViewModel: LivestreamViewModel(fpApiService: fpApiService, creator: creator))
					.tag(Selection.creator(creator.id))
					.tabItem {
                        #if os(tvOS)
                        Text(creator.title)
                        #else
                        Label(creator.title, systemImage: "person.crop.rectangle")
                        #endif
					}
			}
			SettingsView()
				.tag(Selection.settings)
				.tabItem {
                    #if os(tvOS)
                    Text("Settings")
                    #else
                    Label("Settings", systemImage: "gear")
                    #endif
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

import SwiftUI
import FloatplaneAPIClient
import NIO
import Network

struct ContentView: View {
	
	@ObservedObject var viewModel: AuthViewModel
	
	@Environment(\.colorScheme) var colorScheme
	@Environment(\.fpApiService) var fpApiService
	@Environment(\.managedObjectContext) var managedObjectContext
	
	@StateObject var navigationCoordinator = NavigationCoordinator<WasserflugRoute>()
	@State var hasInitiallyLoaded = false
	@State var showErrorMoreDetails = false
	
	@AppStorage(SettingsView.showNewSidebarKey) var showNewSidebar: Bool = true
	
	var body: some View {
		NavigationStack(path: $navigationCoordinator.path) {
			ZStack {
				if viewModel.isLoadingAuthStatus || !viewModel.isLoggedIn {
					ZStack {
						// Logo and headings in center
						HStack {
							Image("wasserflug-logo")
								.resizable()
								.renderingMode(.template)
								.foregroundColor(colorScheme == .dark ? .white : .black)
								.scaledToFit()
								.frame(height: 300)
								.accessibilityHidden(true)
							VStack {
								Text("Wasserflug")
									.font(.title)
									.accessibilityAddTraits(.isHeader)
								Text("An unofficial Floatplane client")
							}
						}
						
						// Loading indicator/login button at bottom of screen
						VStack {
							Spacer()
							if viewModel.isLoadingAuthStatus {
								ProgressView()
									.accessibilityLabel("Loading")
							} else if !viewModel.isLoggedIn {
								NavigationLink("Login", value: WasserflugRoute.login)
									.accessibilityHint("Login to Wasserflug")
							}
						}
					}
					.onAppear {
						viewModel.determineAuthenticationStatus()
					}
					.background(ZStack {
						// Background blurred image of FP website splash image
						Image("splash-bg")
							.resizable()
							.scaledToFill()
						VisualEffectView(effect: UIBlurEffect(style: colorScheme == .dark ? .dark : .light))
					}
					.ignoresSafeArea()
					.accessibilityHidden(true))
				} else {
					// Main content view if logged in
					ZStack {
						if showNewSidebar {
							RootTabView2(fpFrontendSocket: FPFrontendSocket(sailsSid: FloatplaneAPIClientAPI.rawCookieValue))
						} else {
							RootTabView()
						}
					}
				}
			}
			.navigationDestination(for: WasserflugRoute.self, destination: { route in
				switch route {
				case .login:
					LoginView(viewModel: viewModel)
				case .secondFactor:
					SecondFactorView(viewModel: viewModel)
				case let .blogPostView(blogPostId: blogPostId, autoPlay: autoPlay):
					BlogPostView(viewModel: BlogPostViewModel(fpApiService: fpApiService,
															  id: blogPostId),
								 shouldAutoPlay: autoPlay)
				case let .searchView(creatorOrChannel: creatorOrChannel, creatorOwner: creatorOwner):
					CreatorSearchView(viewModel: CreatorContentViewModel(fpApiService: fpApiService,
																		 managedObjectContext: managedObjectContext,
																		 creatorOrChannel: creatorOrChannel,
																		 creatorOwner: creatorOwner),
									  creatorName: creatorOrChannel.title)
				case let .livestreamView(creatorId: creatorId, livestreamId: livestreamId):
					LivestreamView(viewModel: LivestreamViewModel(fpApiService: fpApiService,
																  creatorId: creatorId),
								   fpChatSocket: FPChatSocket(sailsSid: FloatplaneAPIClientAPI.rawCookieValue,
															  channelId: livestreamId))
				case let .videoView(videoAttachment: video, content: content, description: description, beginningWatchTime: beginningWatchTime):
					VideoView(viewModel: VideoViewModel(fpApiService: fpApiService,
														videoAttachment: video,
														contentPost: content,
														description: description),
							  beginningWatchTime: beginningWatchTime)
				}
			})
		}
		.overlay(alignment: .topTrailing, content: {
			ToastBarView()
		})
		.environmentObject(viewModel.userInfo)
		.environmentObject(navigationCoordinator) // Inject the navigation coordinator for children to access
		.onReceive(NotificationCenter.default.publisher(for: .loggedOut, object: nil), perform: { _ in
			viewModel.determineAuthenticationStatus()
		})
		.alert("Application Error", isPresented: $viewModel.showAuthenticationErrorAlert, presenting: viewModel.authenticationCheckError, actions: { _ in
			Button("OK", action: {})
			Button("More Information", action: {
				showErrorMoreDetails = true
			})
		}, message: { error in
			Text("""
			Logging in was successful, but an error was encountered while loading your user profile. Please submit a bug report with the app developer, *NOT* with Floatplane staff.

			\(error.localizedDescription)
			""")
		})
		.alert("Application Error", isPresented: $showErrorMoreDetails, presenting: viewModel.authenticationCheckError, actions: { _ in }, message: { error in
			Text("\(String(describing: error))")
		})
		.alert("Subscriptions", isPresented: $viewModel.showNoSubscriptionsAlert, actions: {}, message: {
			Text("Logging in was successful, but the account does not have any subscriptions at this time. Wasserflug requires at least one subscription in order to work properly. Please try again later.")
		})
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView(viewModel: AuthViewModel(fpApiService: MockFPAPIService()))
	}
}

struct VisualEffectView: UIViewRepresentable {
	var effect: UIVisualEffect?
	func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
	func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}

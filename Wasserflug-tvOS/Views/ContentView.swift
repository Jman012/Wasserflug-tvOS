import SwiftUI
import FloatplaneAPIClient
import NIO
import Network

struct ContentView: View {
	
	@ObservedObject var viewModel: AuthViewModel
	
	@Environment(\.colorScheme) var colorScheme
	
	@StateObject var navigationCoordinator = NavigationCoordinator()
	@State var hasInitiallyLoaded = false
	@State var showErrorMoreDetails = false
	
	@AppStorage(SettingsView.showNewSidebarKey) var showNewSidebar: Bool = true
	
	var body: some View {
		ZStack {
			if viewModel.isLoadingAuthStatus || !viewModel.isLoggedIn {
				NavigationStack(path: $navigationCoordinator.path) {
					ZStack {
						// Logo and headings in center
						HStack {
							Image("wasserflug-logo")
								.resizable()
								.renderingMode(.template)
								.foregroundColor(colorScheme == .dark ? .white : .black)
								.scaledToFit()
								.frame(height: 300)
							VStack {
								Text("Wasserflug")
									.font(.title)
								Text("An unofficial Floatplane client")
							}
						}
						
						// Loading indicator/login button at bottom of screen
						VStack {
							Spacer()
							if viewModel.isLoadingAuthStatus {
								ProgressView()
							} else if !viewModel.isLoggedIn {
								NavigationLink("Login", value: AuthStep.login)
							}
						}
					}
					.onAppear {
						viewModel.determineAuthenticationStatus()
					}
					.navigationDestination(for: AuthStep.self, destination: { step in
						switch step {
						case .login:
							LoginView(viewModel: viewModel)
						case .secondFactor:
							SecondFactorView(viewModel: viewModel)
						}
					})
				}
				.environmentObject(navigationCoordinator)
				.background(ZStack {
					// Background blurred image of FP website splash image
					Image("splash-bg")
						.resizable()
						.scaledToFill()
					VisualEffectView(effect: UIBlurEffect(style: colorScheme == .dark ? .dark : .light))
				}.ignoresSafeArea())
			} else {
				// Main content view if logged in
				if showNewSidebar {
					RootTabView2()
				} else {
					RootTabView()
				}
			}
		}
		.overlay(alignment: .topTrailing, content: {
			ToastBarView()
		})
		.environmentObject(viewModel.userInfo)
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

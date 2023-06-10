import SwiftUI
import FloatplaneAPIClient
import NIO
import Network

enum FPColors {
	static let blue = Color(.sRGB, red: 0, green: 175.0/256.0, blue: 236.0/256.0, opacity: 1.0)
	static let darkBlue = Color(.sRGB, red: 0, green: 175.0/256.0, blue: 236.0/256.0, opacity: 1.0)
	static let watchProgressIndicatorBegin = Color(.sRGB, red: 244.0/256.0, green: 66.0/256.0, blue: 66.0/256.0, opacity: 1.0)
	static let watchProgressIndicatorEnd = Color(.sRGB, red: 247.0/256.0, green: 125.0/256.0, blue: 125.0/256.0, opacity: 1.0)
}

struct ContentView: View {
	
	@ObservedObject var viewModel: AuthViewModel
	
	@Environment(\.colorScheme) var colorScheme
	
	@State var isLoggingIn = false
	@State var hasInitiallyLoaded = false
	@State var showErrorMoreDetails = false
	
	@AppStorage(SettingsView.showNewSidebarKey) var showNewSidebar: Bool = true
	
	enum Notifications {
		static let loggedOut = Notification.Name("com.jamesnl.Wasserflug-tvOSApp.loggedOut")
	}
	
	var body: some View {
		VStack {
			if viewModel.isLoadingAuthStatus {
				ZStack {
					Image("splash-bg")
						.resizable()
						.ignoresSafeArea()
						.scaledToFill()
					VisualEffectView(effect: UIBlurEffect(style: colorScheme == .dark ? .dark : .light))
						.ignoresSafeArea()
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
					VStack {
						Spacer()
						ProgressView()
					}
				}
			} else if !viewModel.isLoggedIn {
				ZStack {
					Image("splash-bg")
						.resizable()
						.ignoresSafeArea()
						.scaledToFill()
					VisualEffectView(effect: UIBlurEffect(style: colorScheme == .dark ? .dark : .light))
						.ignoresSafeArea()
					VStack {
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
					}
					VStack {
						Spacer()
						Button("Login", action: {
							isLoggingIn = true
						})
							.fullScreenCover(isPresented: $isLoggingIn, onDismiss: {
								viewModel.determineAuthenticationStatus()
							}, content: {
								NavigationView {
									LoginView(isLoggingIn: $isLoggingIn, viewModel: viewModel)
								}
								.background(.ultraThinMaterial)
							})
					}
				}
			} else {
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
		.onAppear(perform: {
			if !hasInitiallyLoaded {
				hasInitiallyLoaded = true
				viewModel.determineAuthenticationStatus()
			}
		})
		.onReceive(NotificationCenter.default.publisher(for: Notifications.loggedOut, object: nil), perform: { _ in
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

import SwiftUI
import FloatplaneAPIClient
import NIO
import Network

struct ContentView: View {
	
	@ObservedObject var viewModel: AuthViewModel
	
	@Environment(\.colorScheme) var colorScheme
	
	@State var isLoggingIn = false
	@State var hasInitiallyLoaded = false
	@State var showErrorMoreDetails = false
	
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
				RootTabView()
			}
		}
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
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView(viewModel: AuthViewModel(fpApiService: MockFPAPIService()))
	}
}

import SwiftUI
import FloatplaneAPIClient
import NIO
import Network

enum FPColors {
	static let blue = Color(.sRGB, red: 0, green: 175.0/256.0, blue: 236.0/256.0, opacity: 1.0)
	static let darkBlue = Color(.sRGB, red: 0, green: 175.0/256.0, blue: 236.0/256.0, opacity: 1.0)
}

struct ContentView: View {
	
	@ObservedObject var viewModel: AuthViewModel
	
	@Environment(\.colorScheme) var colorScheme
	
	@State var isLoggingIn = false
	@State var hasInitiallyLoaded = false
	@State var showJoinAlert = false
	
	enum Notifications {
		static let loggedOut = Notification.Name("com.jamesnl.Wasserflug-tvOSApp.loggedOut")
	}
	
	var body: some View {
		VStack {
			if viewModel.isLoadingAuthStatus {
				ZStack {
					Image("splash")
						.resizable()
						.ignoresSafeArea()
						.scaledToFill()
					VisualEffectView(effect: UIBlurEffect(style: colorScheme == .dark ? .dark : .light))
						.ignoresSafeArea()
					VStack {
						Image("logo-white")
							.renderingMode(.template)
							.foregroundColor(FPColors.blue)
					}
					VStack {
						Spacer()
						ProgressView()
					}
				}
			} else if !viewModel.isLoggedIn {
				ZStack {
					Image("splash")
						.resizable()
						.ignoresSafeArea()
						.scaledToFill()
					VisualEffectView(effect: UIBlurEffect(style: colorScheme == .dark ? .dark : .light))
						.ignoresSafeArea()
					VStack {
						Image("logo-white")
							.renderingMode(.template)
							.foregroundColor(FPColors.blue)
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
						Button("Join", action: {
							showJoinAlert = true
						})
							.alert("Join Floatplane", isPresented: $showJoinAlert, actions: { }, message: {
								Text("In order to create an account on Floatplane, please visit https://www.floatplane.com/signup. After this has been completed, you may return here and login.")
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

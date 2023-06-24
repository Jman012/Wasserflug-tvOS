import SwiftUI
import FloatplaneAPIClient

struct LoginView: View {
	@ObservedObject var viewModel: AuthViewModel
	@EnvironmentObject var navigationCoordinator: NavigationCoordinator<WasserflugRoute>
	
	@State var username: String = ""
	@State var password: String = ""
	
	private enum Field: Hashable {
		case usernameField
		case passwordField
		case loginButton
	}
	@FocusState private var focusedField: Field?
	
	var body: some View {
		GeometryReader { geometry in
			ZStack {
				VStack {
					Text("Login to Floatplane")
						.bold()
					Spacer()
					
					TextField("Username", text: $username)
						.textContentType(.username)
						.font(.system(size: 36))
						.focused($focusedField, equals: .usernameField)
						.onSubmit {
							DispatchQueue.main.asyncAfter(deadline: .now() + 0.50, execute: {
								if username != "" {
									if password == "" {
										focusedField = .passwordField
									} else {
										focusedField = .loginButton
									}
								}
							})
						}

					SecureField("Password", text: $password)
						.textContentType(.password)
						.font(.system(size: 36))
						.focused($focusedField, equals: .passwordField)
						.onSubmit {
							DispatchQueue.main.asyncAfter(deadline: .now() + 0.50, execute: {
								if password != "" {
									focusedField = .loginButton
								}
							})
						}
					
					Spacer()
					
					Button(action: {
						if username == "" {
							focusedField = .usernameField
						} else if password == "" {
							focusedField = .passwordField
						} else {
							viewModel.attemptLogin(username: username, password: password, isLoggedIn: {
								navigationCoordinator.popToRoot()
							}, needsSecondFactor: {
								navigationCoordinator.push(route: .secondFactor)
							})
						}
					}, label: {
						HStack {
							if viewModel.isAttemptingLogin {
								ProgressView()
							}
							Text("Login")
						}
					})
						.disabled(viewModel.isAttemptingLogin)
						.focused($focusedField, equals: .loginButton)
				}
				.multilineTextAlignment(.center)
				.frame(maxWidth: geometry.size.width * 0.4)
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)
		}
		.alert("Login", isPresented: $viewModel.showIncorrectLoginAlert, actions: { }, message: {
			if let error = viewModel.loginError {
				Text("""
There was an error while attempting to log in. Please submit a bug report with the app developer, *NOT* with Floatplane staff.

\(error.localizedDescription)
""")
			} else {
				Text("""
Username or password is incorrect.
If you have forgotten your password, please reset it via https://www.floatplane.com/reset-password
""")
			}
		})
	}
}

struct LoginView_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			LoginView(viewModel: AuthViewModel(fpApiService: MockFPAPIService()))
		}
	}
}

import SwiftUI
import FloatplaneAPIClient

struct LoginView: View {
	@Binding var isLoggingIn: Bool
	@ObservedObject var viewModel: AuthViewModel
	
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
							.focused($focusedField, equals: .usernameField)
							.onSubmit {
								print("username on submit")
								DispatchQueue.main.asyncAfter(deadline: .now() + 0.50, execute: {
									print("username on submit delayed")
									if username != "" {
										if password == "" {
											print("un: setting to password field")
											focusedField = .passwordField
										} else {
											print("un: setting to login button")
											focusedField = .loginButton
										}
									}
								})
							}

						SecureField("Password", text: $password)
							.textContentType(.password)
							.focused($focusedField, equals: .passwordField)
							.onSubmit {
								print("password on submit")
								DispatchQueue.main.asyncAfter(deadline: .now() + 0.50, execute: {
									print("password on submit delayed")
									if password != "" {
										print("pw: setting to login button")
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
									self.isLoggingIn = false
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
		.navigationDestination(isPresented: $viewModel.needsSecondFactor, destination: {
			SecondFactorView(isLoggingIn: $isLoggingIn, viewModel: viewModel)
		})
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
	@State static var isLoggingIn = true
	static var previews: some View {
		Group {
			LoginView(isLoggingIn: $isLoggingIn, viewModel: AuthViewModel(fpApiService: MockFPAPIService()))
		}
	}
}

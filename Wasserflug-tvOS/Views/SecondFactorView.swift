import SwiftUI
import FloatplaneAPIClient

struct SecondFactorView: View {
	@ObservedObject var viewModel: AuthViewModel
	@EnvironmentObject var navigationCoordinator: NavigationCoordinator<WasserflugRoute>
	
	@State var secondFactorCode: String = ""
	
	private enum Field: Hashable {
		case secondFactorField
		case loginButton
	}
	@FocusState private var focusedField: Field?
	
	var body: some View {
		GeometryReader { geometry in
			ZStack {
				VStack {
					Text("One more step")
					Spacer()
					
					TextField("2FA Code", text: $secondFactorCode)
						.textContentType(.oneTimeCode)
						.font(.system(size: 36))
						.focused($focusedField, equals: .secondFactorField)
						.onSubmit {
							DispatchQueue.main.asyncAfter(deadline: .now() + 0.50, execute: {
								if secondFactorCode != "" {
									focusedField = .loginButton
								}
							})
						}
					Spacer()
					
					Button(action: {
						if secondFactorCode == "" {
							focusedField = .secondFactorField
						} else {
							viewModel.attemptSecondFactor(secondFactorCode: secondFactorCode, isLoggedIn: {
								navigationCoordinator.popToRoot()
							})
						}
					}, label: {
						HStack {
							if viewModel.isAttemptingSecondFactor {
								ProgressView()
							}
							Text("Submit")
						}
					})
						.disabled(viewModel.isAttemptingSecondFactor)
						.focused($focusedField, equals: .loginButton)
				}
				.multilineTextAlignment(.center)
				.frame(maxWidth: geometry.size.width * 0.4)
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)
		}
		.alert("Second Factor", isPresented: $viewModel.showIncorrectSecondFactorAlert, actions: { }, message: {
			if let error = viewModel.secondFactorError {
				Text("""
There was an error while attempting to log in.

\(error.localizedDescription)
""")
			} else {
				Text("Invalid authentication code provided.")
			}
		})
	}
}

struct SecondFactorView_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			SecondFactorView(viewModel: AuthViewModel(fpApiService: MockFPAPIService()))
		}
	}
}

//
//  LoginView.swift
//  Wasserflug-tvOS
//
//  Created by Nils Bergmann on 22.06.22.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: AuthViewModel
    
    @State var username: String = ""
    @State var password: String = ""
    @State var secondFactorCode: String = ""
    
    @Environment(\.colorScheme) var colorScheme
    
    private enum Field: Hashable {
        case usernameField
        case passwordField
        case secondFactorField
        case loginButton
    }
    @FocusState private var focusedField: Field?
    
    var body: some View {
        NavigationView {
            List {
                // Logo
                HStack {
                    Spacer()
                    Image("wasserflug-logo")
                        .resizable()
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .scaledToFit()
                        .frame(maxWidth: 250)
                    Spacer()
                }
                    .listRowBackground(EmptyView())
                    .listRowSeparator(.hidden)
                
                // Login Form
                Section(header: Text("Credentials")) {
                    
                    TextField("Username", text: $username)
                        .textInputAutocapitalization(.never)
                        .textContentType(.username)
                        .focused($focusedField, equals: .usernameField)
                        .disabled(viewModel.isAttemptingLogin || viewModel.needsSecondFactor || viewModel.isAttemptingSecondFactor)
                    
                    SecureField("Password", text: $password)
                        .textContentType(.password)
                        .focused($focusedField, equals: .passwordField)
                        .onSubmit {
                            withAnimation {
                                self.login()
                            }
                        }
                        .submitLabel(SubmitLabel.send)
                        .disabled(viewModel.isAttemptingLogin || viewModel.needsSecondFactor || viewModel.isAttemptingSecondFactor)
                    
                    if viewModel.needsSecondFactor {
                        TextField("2FA Code", text: $secondFactorCode)
                            .textContentType(.oneTimeCode)
                            .disabled(viewModel.isAttemptingSecondFactor)
                    }
                    
                    Button(action: {
                        withAnimation {
                            self.login()
                        }
                    }, label: {
                        HStack {
                            if viewModel.isAttemptingLogin || viewModel.isAttemptingSecondFactor {
                                ProgressView()
                            }
                            if viewModel.needsSecondFactor {
                                Text("Submit 2FA ✈️")
                            } else {
                                Text("Login ✈️")
                            }
                        }
                    })
                        .focused($focusedField, equals: .loginButton)
                        .disabled(viewModel.isAttemptingLogin || viewModel.isAttemptingSecondFactor)
                    
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Login")
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
    
    func login() {
        if username.isEmpty {
            focusedField = .usernameField
        } else if password.isEmpty {
            focusedField = .passwordField
        } else {
            if viewModel.needsSecondFactor, secondFactorCode.isEmpty {
                focusedField = .secondFactorField
            } else if viewModel.needsSecondFactor {
                viewModel.attemptSecondFactor(secondFactorCode: secondFactorCode) {
                    viewModel.determineAuthenticationStatus()
                    print("Second Factor correct")
                }
            } else {
                viewModel.attemptLogin(username: username, password: password) {
                    viewModel.determineAuthenticationStatus()
                    print("Logged in")
                }
            }
            print("Test")
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            LoginView(viewModel: AuthViewModel(fpApiService: MockFPAPIService()))
                .previewInterfaceOrientation(.portrait)
        }
    }
}

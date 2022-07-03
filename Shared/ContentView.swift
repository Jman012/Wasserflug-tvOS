//
//  ContentView.swift
//  Shared
//
//  Created by Nils Bergmann on 22.06.22.
//

import SwiftUI
import FloatplaneAPIClient

struct ContentView: View {
    @ObservedObject var viewModel: AuthViewModel
    
    @State var showErrorMoreDetails = false
    
    @State var hasInitiallyLoaded = false
    
    @State var width = UIScreen.main.bounds.width
    
    @Environment(\.colorScheme) var colorScheme
    
    enum Notifications {
        static let loggedOut = Notification.Name("com.jamesnl.Wasserflug-tvOSApp.loggedOut")
    }
    
    var body: some View {
        VStack {
            ZStack {
                if viewModel.isLoadingAuthStatus {
                    Image("wasserflug-logo")
                        .resizable()
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .scaledToFit()
                        .frame(maxWidth: 250)
                    ProgressView()
                } else if !viewModel.isLoggedIn {
                    LoginView(viewModel: viewModel)
                } else {
                    RootTabView()
                }
                GeometryReader { proxy in
                    Color.clear.onChange(of: proxy.size.width) { newValue in
                        DispatchQueue.main.async {
                            self.width = newValue
                        }
                    }.onAppear {
                        DispatchQueue.main.async {
                            self.width = proxy.size.width
                        }
                    }
                }
                .hidden()
            }
        }
        .environmentObject(viewModel.userInfo)
        .environment(\.screenWidth, self.width)
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

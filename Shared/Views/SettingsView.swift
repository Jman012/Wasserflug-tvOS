//
//  SettingsView.swift
//  Wasserflug-tvOS
//
//  Created by Nils Bergmann on 22.06.22.
//

import SwiftUI
import CachedAsyncImage
import FloatplaneAPIClient

struct SettingsView: View {
    @EnvironmentObject var userInfo: UserInfo
    
    var body: some View {
        NavigationView {
            List {
                if let userSelf = userInfo.userSelf, let imageUrl = URL(string: userSelf.profileImage.path) {
                    HStack {
                        Spacer()
                        HStack(spacing: 20) {
                            let pfpSize: CGFloat = 150
                            CachedAsyncImage(url: imageUrl, content: { image in
                                image
                                    .resizable()
                                    .frame(width: pfpSize, height: pfpSize)
                            }, placeholder: {
                                ProgressView()
                                    .frame(width: pfpSize, height: pfpSize)
                            })
                        }
                        Spacer()
                    }
                    .listRowBackground(EmptyView())
                    Section {
                        Text(verbatim: userSelf.username)
                        Button("Logout") {
                            FloatplaneAPIClientAPI.removeAuthenticationCookies()
                            NotificationCenter.default.post(name: ContentView.Notifications.loggedOut, object: nil)
                        }
                    } header: {
                        Text("User")
                    }
                    .listStyle(.insetGrouped)
                    
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(MockData.userInfo)
    }
}

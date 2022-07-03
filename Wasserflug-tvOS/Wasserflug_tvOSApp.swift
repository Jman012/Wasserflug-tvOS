import SwiftUI
import FloatplaneAPIClient
import Vapor
import os
import Logging

@main
struct Wasserflug_tvOSApp: App {
    let wasserflug = Wasserflug();
	
	var body: some Scene {
		WindowGroup {
            ContentView(viewModel: wasserflug.authViewModel)
                .environment(\.fpApiService, wasserflug.fpApiService)
                .environment(\.managedObjectContext, wasserflug.persistenceController.container.viewContext)
		}
	}
}

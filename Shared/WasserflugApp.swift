//
//  WasserflugApp.swift
//  Shared
//
//  Created by Nils Bergmann on 22.06.22.
//

import SwiftUI

@main
struct WasserflugApp: App {
    let wasserflug = Wasserflug();
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: wasserflug.authViewModel)
                .environment(\.fpApiService, wasserflug.fpApiService)
                .environment(\.managedObjectContext, wasserflug.persistenceController.container.viewContext)
        }
    }
}

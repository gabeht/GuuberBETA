//
//  GuuberBETAApp.swift
//  GuuberBETA
//
//  Created by Gabe Holte on 2/24/25.
//

import SwiftUI
import SwiftData



@main
struct GuuberBETAApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .accentColor(.green)
        }
        .modelContainer(sharedModelContainer)
    }
}

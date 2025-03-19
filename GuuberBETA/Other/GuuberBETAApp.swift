//
//  GuuberBETAApp.swift
//  GuuberBETA
//
//  Created by Gabe Holte on 2/24/25.
//

import SwiftUI
import SwiftData
import FirebaseCore



@main
struct GuuberBETAApp: App {
init(){
    FirebaseApp.configure()
}
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
            MainView()
                .accentColor(.green)
        }
        .modelContainer(sharedModelContainer)
    }
}

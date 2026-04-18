//
//  New_RecardApp.swift
//  New_Recard
//

import SwiftUI
import SwiftData

@main
struct New_RecardApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Book.self,
            Note.self,
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
            HomeView()
                .preferredColorScheme(.light)
        }
        .modelContainer(sharedModelContainer)
    }
}

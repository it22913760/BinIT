//
//  BinItApp.swift
//  BinIt
//
//  Created by STUDENT on 2025-11-19.
//

import SwiftUI
import SwiftData

@main
struct BinItApp: App {
    private var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            RecycledItem.self
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
        }
        .modelContainer(sharedModelContainer)
    }
}

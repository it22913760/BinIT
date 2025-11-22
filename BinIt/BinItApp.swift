//
//  BinItApp.swift
//  BinIt
//
//  Created by STUDENT on 2025-11-19.
//

import SwiftUI
import CoreData

@main
struct BinItApp: App {
    private let persistentContainer = CoreDataStack.shared.persistentContainer
    @StateObject private var profileStore = ProfileStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
                .environment(\.managedObjectContext, persistentContainer.viewContext)
                .environmentObject(profileStore)
        }
    }
}

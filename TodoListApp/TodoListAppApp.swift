//
//  TodoListAppApp.swift
//  TodoListApp
//
//  Created by Vipin Pahwa on 11/09/26.
//

import SwiftUI
import SwiftData
import os

@main
struct TodoListAppApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TodoItem.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // The on-disk store failed to open (e.g. a corrupted database).
            // Fall back to an in-memory store so the app still launches,
            // rather than crashing on every subsequent launch.
            Logger(subsystem: Bundle.main.bundleIdentifier ?? "TodoListApp", category: "Persistence")
                .error("Could not open persistent ModelContainer, falling back to in-memory store: \(error)")
            let fallbackConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            return try! ModelContainer(for: schema, configurations: [fallbackConfiguration])
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}

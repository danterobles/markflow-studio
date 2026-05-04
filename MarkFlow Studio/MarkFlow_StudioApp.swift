//
//  MarkFlow_StudioApp.swift
//  MarkFlow Studio
//
//  Created by Dante Robles on 04/05/26.
//

import SwiftUI
import SwiftData

@main
struct MarkFlow_StudioApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            MarkdownDocument.self,
            MarkdownFolder.self,
            MarkdownLink.self,
            WorkspaceSettings.self,
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
            RootAppView()
        }
        .modelContainer(sharedModelContainer)
    }
}

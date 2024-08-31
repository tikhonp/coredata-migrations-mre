//
//  CoreDataMigrationsMREApp.swift
//  CoreDataMigrationsMRE
//
//  Created by Tikhon on 31.08.2024.
//

import SwiftUI

@main
struct CoreDataMigrationsMREApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

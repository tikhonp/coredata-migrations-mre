//
//  CoreDataMigrationsMREApp.swift
//  CoreDataMigrationsMRE
//
//  Created by Tikhon on 31.08.2024.
//

import SwiftUI

let persistance = {
    PersistenceService()
}()

@main
struct CoreDataMigrationsMREApp: App {
    var body: some Scene {
        WindowGroup {
            Text("lol")
                .environment(\.managedObjectContext, persistance.container.viewContext)
        }
    }
}

//
//  PersistenceService.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 24.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData

private let modelName: String = "Medsenger"

public actor PersistenceService {
    
    public nonisolated let container: NSPersistentContainer
    
    public init(inMemory: Bool = false) {
        guard let objectModelURL = Bundle.main.url(forResource: modelName, withExtension: "momd"),
              let managedObjectModel =  NSManagedObjectModel(contentsOf: objectModelURL) else {
            fatalError("Failed to retrieve the object model")
        }
        
        container = NSPersistentContainer(name: modelName, managedObjectModel: managedObjectModel)
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        } else {
            let storeURL = URL.storeURL(for: "group.medsenger.core.data", databaseName: modelName)
            let storeDescription = NSPersistentStoreDescription(url: storeURL)
            storeDescription.shouldMigrateStoreAutomatically = true
            storeDescription.shouldInferMappingModelAutomatically = true
            container.persistentStoreDescriptions = [storeDescription]
        }
        
#if DEBUG && false
        // CHECK if two versions of model can be migrated
        let version1 = "Medsenger_7.mom"
        let version2 = "Medsenger_7_5.mom"
        
        do {
            guard let model1 =  NSManagedObjectModel(contentsOf: objectModelURL.appendingPathComponent(version1)),
                  let model2 =  NSManagedObjectModel(contentsOf: objectModelURL.appendingPathComponent(version2)) else {
                fatalError("Failed to retrieve the object models")
            }
            
            _ = try NSMappingModel.inferredMappingModel(forSourceModel: model1, destinationModel: model2)
            
            fatalError("TEST migration from `\(version1)` to `\(version2)`... OK")
        } catch let error as NSError {
            fatalError(
                """
                TEST migration from `\(version1)` to `\(version2)`... FAILED
                ---
                \(error.localizedDescription)
                \(error.userInfo)
                """
            )
        }
#endif
        
        container.loadPersistentStores { description, error in
            if let error, let url = description.url {
                
                let coordinator = self.container.persistentStoreCoordinator
                
                // Destroy
                try? coordinator.destroyPersistentStore(at: url, type: .sqlite)
                
                // Re-create
                _ =  try? coordinator.addPersistentStore(type: .sqlite, at: url)
            }
        }
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
}

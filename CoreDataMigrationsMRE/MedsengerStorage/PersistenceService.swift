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
        
#if DEBUG && true
        // CHECK if two versions of model can be migrated
        let version1 = "Medsenger_7.mom"
        let version2 = "Medsenger_8.mom"
        
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
        
        container.loadPersistentStores { _, error in
            if let error {
                fatalError(error.localizedDescription)
            }
        }
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    /// Clear database with optional clearing user
    ///
    /// Use it for sign out or changing user role
    ///
    /// - Parameter withUser: clear user or not
    public func clearDatabase(withUser: Bool) async throws {
        let moc = container.wrappedNewBackgroundContext()
        try await moc.perform { [weak self] in
            guard let self else {
                return
            }
            do {
                if withUser {
//                    annalist.log(.debug, "Calling erase on User")
                    try PersistenceService.erase(User.self, for: moc, contextsToNotify: [self.container.viewContext])
                }
                
                let modelsToErase = [
                    Contract.self,
                    Clinic.self,
                    Agent.self,
                    ClassLabel.self,
                    ClinicDoctor.self,
                    RelatedContract.self,
                    Scenario.self,
                    ContractAttachment.self,
                ]
                
                try modelsToErase.forEach { model in
//                    annalist.log(.debug, "Calling erase on \(model.self)")
                    try PersistenceService.erase(model.self, for: moc, contextsToNotify: [self.container.viewContext])
                }
                
            } catch {
//                annalist.capture(error: error, withMessage: "Clear database error")
                throw error
            }
        }
        
#if DEBUG
        // Check if all entities was cleanedup
        
        let entityNames = container.managedObjectModel.entities.map(\.managedObjectClassName!)
            .filter { name in
                if !withUser, name == "User" {
                    return false
                }
                return true
            }
        try await moc.perform {
            for entityName in entityNames {
                let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
                let count = try moc.fetch(fetchRequest).count
                assert(count == 0, "Entity \(entityName) was not cleaned up. \(count) rows left.")
            }
        }
#endif
    }
    
    /// Erases all raw for entity.
    /// - Parameter moc: Core Data context
    static func erase<T>(
        _ entity: T.Type,
        for moc: NSManagedObjectContext,
        contextsToNotify: [NSManagedObjectContext] = []
    ) throws where T: NSManagedObject {
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(
            entityName: String(describing: entity.self))
        
        let request = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        request.resultType = .resultTypeObjectIDs
        
        let deleteResult = try moc.execute(request) as? NSBatchDeleteResult
        
        if let objectIDs = deleteResult?.result as? [NSManagedObjectID] {
            NSManagedObjectContext.mergeChanges(
                fromRemoteContextSave: [NSDeletedObjectsKey: objectIDs],
                into: [moc] + contextsToNotify
            )
        }
    }
}

//
//  CoreDataIdGetable.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 20.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData

/// Implements functions for retrieving entity by id property
public protocol GetableById: NSManagedObject {
    var id: Int64 { get }
}

extension GetableById {
    
    /// Get entity by id in the managed context
    /// - Parameters:
    ///   - id: Id of the entity.
    ///   - moc: Managed object context.
    /// - Returns: Entity
    public static func get(id: Int, with context: NSManagedObjectContext) throws -> Self {
        let fetchRequest = NSFetchRequest<Self>(entityName: String(describing: Self.self))
        fetchRequest.predicate = NSPredicate(format: "id == %ld", id)
        fetchRequest.fetchLimit = 1
        let fetchedResults = try context.wrappedFetch(fetchRequest, detailsForLogging: "\(Self.self) get by id")
        guard let object = fetchedResults.first else {
            throw ObjectNotFoundError(entity: Self.self, functionName: "CoreDataIdGetable.get")
        }
        return object
    }
    
    /// Get entity by id
    ///
    /// Be careful! It returns entity which can be used only on main thread.
    /// - Parameter id: Id of the entity.
    /// - Returns: Entity
    @MainActor public static func get(id: Int) async throws -> Self {
        let viewContext = persistance.container.viewContext
        return try await viewContext.perform {
            try get(id: id, with: viewContext)
        }
    }
    
    public var intId: Int { Int(id) }
    
    public static func get<T>(id: Int, _ keyPath: KeyPath<Self, T>) async throws -> T {
        try await NSPersistentContainer.wrappedPerformBackgroundTask { context in
            try get(id: id, with: context)[keyPath: keyPath]
        }
    }
    
    public static func update<T>(id: Int, _ keyPath: KeyPath<Self, T>, with value: T) async throws {
        try await NSPersistentContainer.wrappedPerformBackgroundTask { context in
            let object = try get(id: id, with: context)
            object.setValue(value, forKeyPath: NSExpression(forKeyPath: keyPath).keyPath)
            try context.wrappedSave(detailsForLogging: "CoreDataIdGetable update")
        }
    }
    
}

//
//  GetableByNameAndContract.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 20.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData

/// Implements functions for retrieving entity by name property
public protocol GetableByNameAndContract: NSManagedObject {
    var name: String? { get }
    var contract: Contract? { get }
}

extension GetableByNameAndContract {
    
    /// Get entity by name and contract in the managed context
    /// - Parameters:
    ///   - name: Name of the entity.
    ///   - contractId: Related contract id.
    ///   - moc: Managed object context.
    /// - Returns: Entity
    static func get(name: String, contractId: Int, with context: NSManagedObjectContext) throws -> Self {
        let fetchRequest = NSFetchRequest<Self>(entityName: String(describing: Self.self))
        fetchRequest.predicate = NSPredicate(format: "name == %@ && contract.id = %ld", name, contractId)
        fetchRequest.fetchLimit = 1
        fetchRequest.resultType = .managedObjectResultType
        let fetchedResults = try context.wrappedFetch(fetchRequest, detailsForLogging: "\(Self.self) get by name and contract")
        guard let object = fetchedResults.first else {
            throw ObjectNotFoundError(entity: Self.self, functionName: "CoreDataStringContractGetable.get")
        }
        return object
    }
    
    var wrappedName: String {
        name ?? "Unknown name"
    }
    
}

//
//  CleanableByNameAndContract.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 20.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData

protocol CleanableByNameAndContract: NSManagedObject {
    var name: String? { get }
    var contract: Contract? { get }
}

extension CleanableByNameAndContract {
    /// Clean entities that was not got in incoming JSON from Medsenger
    /// - Parameters:
    ///   - validNames: The entities names that exists in JSON from Medsenger
    ///   - contractId: UserDoctorContract contract id for data filtering
    ///   - moc: Core Data context
    static func cleanRemoved(_ validNames: [String], contractId: Int, with context: NSManagedObjectContext) throws {
        let fetchRequest = NSFetchRequest<Self>(entityName: String(describing: Self.self))
        fetchRequest.predicate = NSPredicate(format: "contract.id = %ld AND NOT (name IN %@)", contractId, validNames)
        let fetchedResults = try context.wrappedFetch(fetchRequest, detailsForLogging: "CoreDataNameStringRemovedCleanable.cleanRemoved: \(Self.self)")
        try fetchedResults.forEach {
            context.delete($0)
            try context.wrappedSave(detailsForLogging: "CoreDataNameStringRemovedCleanable.cleanRemoved: \(Self.self)")
        }
    }
}

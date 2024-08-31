//
//  CleanableByIdAndContract.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 20.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData

protocol CleanableByIdAndContract: NSManagedObject {
    var id: Int64 { get }
    var contract: Contract? { get set }
}

extension CleanableByIdAndContract {
    /// Clean entities that was not got in incoming JSON from Medsenger
    /// - Parameters:
    ///   - validIds: The entities ids that exists in JSON from Medsenger
    ///   - contract: UserDoctorContract contract for data filtering
    ///   - context: Core Data context
    static func cleanRemoved(_ validIds: [Int], contractId: Int, with context: NSManagedObjectContext) throws {
        let fetchRequest = NSFetchRequest<Self>(entityName: String(describing: Self.self))
        fetchRequest.predicate = NSPredicate(format: "contract.id = %ld AND NOT (id IN %@)", contractId, validIds)
        let fetchedResults = try context.wrappedFetch(fetchRequest, detailsForLogging: "CoreDataIdIntRemovedCleanable.cleanRemoved: \(Self.self)")
        try fetchedResults.forEach {
            context.delete($0)
            try context.wrappedSave(detailsForLogging: "CoreDataIdIntRemovedCleanable.cleanRemoved: \(Self.self)")
        }
    }
}

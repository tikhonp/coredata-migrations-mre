//
//  NSPersistentContainer+.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 31.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData

extension NSPersistentContainer {
    func wrappedNewBackgroundContext(automaticallyMergesChangesFromParent: Bool = false) -> NSManagedObjectContext {
        let moc = newBackgroundContext()
        moc.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        moc.automaticallyMergesChangesFromParent = automaticallyMergesChangesFromParent
        return moc
    }
    
    static func wrappedPerformBackgroundTask<T>(
        _ block: @escaping (NSManagedObjectContext) throws -> T) async rethrows -> T {
            let context = persistance.container.wrappedNewBackgroundContext()
            return try await context.perform {
                try block(context)
            }
        }
}

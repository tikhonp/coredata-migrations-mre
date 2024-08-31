//
//  User+CoreDataClass.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 08.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData

@objc(User)
public class User: NSManagedObject {
    
    /// Get user form context
    /// - Parameter context: Core Data context
    /// - Returns: optional user instance
    static func get(with context: NSManagedObjectContext) throws -> User {
        let objects = try context.wrappedFetch(User.fetchRequest(), detailsForLogging: "User.get")
        guard let user = objects.first else {
            throw ObjectNotFoundError(entity: User.self, functionName: "User.get")
        }
        return user
    }
    
    public static func get() async throws -> (userId: Int, name: String?, email: String?) {
        try await NSPersistentContainer.wrappedPerformBackgroundTask { context in
            let user = try get(with: context)
            return (Int(user.id), user.fullName, user.email)
        }
    }
    
    public static func exists() async -> Bool {
        do {
            return try await NSPersistentContainer.wrappedPerformBackgroundTask { context in
                _ = try get(with: context)
                return true
            }
        } catch {
            return false
        }
    }
    
    public static func get<T>(_ keyPath: KeyPath<User, T>) async throws -> T {
        try await NSPersistentContainer.wrappedPerformBackgroundTask { context in
            try get(with: context)[keyPath: keyPath]
        }
    }
    
    public static func update<T>(_ keyPath: KeyPath<User, T>, with value: T) async throws {
        try await NSPersistentContainer.wrappedPerformBackgroundTask { context in
            let user = try get(with: context)
            user.setValue(value, forKeyPath: NSExpression(forKeyPath: keyPath).keyPath)
            try context.wrappedSave(detailsForLogging: "User save lastHealthSync")
        }
    }
    
}

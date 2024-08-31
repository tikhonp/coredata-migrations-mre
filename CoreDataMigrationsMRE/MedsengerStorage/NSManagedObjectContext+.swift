//
//  NSManagedObjectContext+.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 29.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData

extension NSManagedObjectContext {
    
    /// Save persistence store
    /// - Parameter detailsForLogging: if error appears while saving provide object that saved for logging and debugging
    public func wrappedSave(detailsForLogging: String? = nil) throws {
        if hasChanges {
            do {
                try save()
            } catch let nsError as NSError {
                var errorDescription = ""
                if let detailsForLogging = detailsForLogging {
                    errorDescription = "`\(detailsForLogging)`: \(nsError.localizedDescription)"
                } else {
                    errorDescription = "\(nsError.localizedDescription)"
                }
                if let detailed = nsError.userInfo["NSDetailedErrors"] as? NSMutableArray {
                    for nsError in detailed {
                        if let nsError = nsError as? NSError, let entity = nsError.userInfo["NSValidationErrorObject"] {
                            errorDescription += "\nCore Data: Detailed: \(nsError.localizedDescription) Entity: `\(type(of: entity))`."
                        }
                    }
                }
                if let conflicts = nsError.userInfo["conflictList"] as? NSMutableArray {
                    for conflict in conflicts {
                        errorDescription += "\n\(conflict)"
                    }
                }
                
                print(errorDescription)
                
                throw nsError
            }
        }
    }
    
    /// Perform fetch request with errors catching
    /// - Parameters:
    ///   - request: The fetch request that specifies the search criteria.
    ///   - detailsForLogging: if error appears while fetching provide object that saved for logging and debugging
    /// - Returns: Returns an array of items of the specified type that meet the fetch request’s
    /// criteria nil value returned if error
    public func wrappedFetch<T>(_ request: NSFetchRequest<T>,
                                detailsForLogging: String? = nil) throws -> [T] where T: NSFetchRequestResult {
        do {
            return try fetch(request)
        } catch let nsError as NSError {
//            if let detailsForLogging {
//                annalist.log(.error, "Core Data: Failed to perform fetch request `\(detailsForLogging)`: \(nsError.localizedDescription)")
//            } else {
//                annalist.log(.error, "Core Data: Failed to perform fetch request: \(nsError.localizedDescription)")
//            }
            throw nsError
        }
    }
}

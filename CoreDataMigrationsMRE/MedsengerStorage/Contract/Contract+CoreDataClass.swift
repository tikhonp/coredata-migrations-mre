//
//  Contract+CoreDataClass.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 08.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData

@objc(Contract)
public class Contract: NSManagedObject, GetableById {
    
    public static func updateOnlineStatusFromList(_ onlineIds: [Int]) async throws {
        try await NSPersistentContainer.wrappedPerformBackgroundTask { context in
            let fetchRequest = Contract.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "isArchived == NO")
            let fetchedResults = try context.wrappedFetch(
                fetchRequest,
                detailsForLogging: "Contract fetch by isArchived == NO for updating online status"
            )
            for contract in fetchedResults {
                contract.isOnline = onlineIds.contains(contract.intId)
            }
            try context.wrappedSave(detailsForLogging: "Contract save online status")
        }
    }
    
    public static func updateScenarioAsRemoved(id: Int) async throws {
        try await NSPersistentContainer.wrappedPerformBackgroundTask { context in
            let contract = try get(id: id, with: context)
            contract.scenario = nil
            try context.wrappedSave(detailsForLogging: "Contract save updateContractNotes")
        }
    }
    
    static func getSumBy(col: String, with context: NSManagedObjectContext) throws -> Int {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Self.self))
        
        let sumDesc = NSExpressionDescription()
        sumDesc.name = "sum"
        
        let keyPathExp1 = NSExpression(forKeyPath: col)
        let expression = NSExpression(forFunction: "\(sumDesc.name):", arguments: [keyPathExp1])
        sumDesc.expression = expression
        sumDesc.expressionResultType = .integer64AttributeType
        
        request.returnsObjectsAsFaults = false
        request.propertiesToFetch = [sumDesc]
        request.resultType = .dictionaryResultType
        
        let result = try context.wrappedFetch(request, detailsForLogging: "getSumBy") as? [[String: Any]]
        
        guard let sum = result?.first?[sumDesc.name] as? Int64 else {
            throw FailedToGetSum()
        }
        
        return Int(sum)
    }
    
    struct FailedToGetSum: LocalizedError { }
    
    /// Get count for all fetched contracts unread
    /// - Returns: The number of unread messages
    public static func getUnreadMessagesSum() async throws -> Int {
        try await NSPersistentContainer.wrappedPerformBackgroundTask { context in
            try Contract.getSumBy(col: "unreadMessageCount", with: context)
        }
    }
    
    /// Clean contract that was not got in incoming JSON from Medsenger
    /// - Parameters:
    ///   - validContractIds: The contract ids that exists in JSON from Medsenger
    ///   - isAssistant: Is contracts consilium
    ///   - moc: Core Data context
    static func cleanRemoved(validContractIds: [Int], isAssistant: Bool, with context: NSManagedObjectContext) throws {
        let fetchRequest = Contract.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "isAssistant == %@ AND NOT (id IN %@)",
            NSNumber(value: isAssistant), validContractIds
        )
        let fetchedResults = try context.wrappedFetch(fetchRequest, detailsForLogging: "Contract.cleanRemoved")
        try fetchedResults.forEach {
            context.delete($0)
            try context.wrappedSave(detailsForLogging: "Contract.cleanRemoved")
        }
    }
    
}

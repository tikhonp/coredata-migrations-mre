//
//  ContractSearchSuggestion+CoreDataClass.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 22.07.2023.
//  Copyright © 2023 TelePat ltd. All rights reserved.
//
//

import CoreData

@objc(ContractSearchSuggestion)
public class ContractSearchSuggestion: NSManagedObject {
    
    public static func add(for contractId: Int) async throws {
        try await NSPersistentContainer.wrappedPerformBackgroundTask { context in
            let fetchRequest = ContractSearchSuggestion.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "contract.id = %ld", contractId)
            fetchRequest.fetchLimit = 1
            let result = try context.wrappedFetch(
                fetchRequest,
                detailsForLogging: "ContractSearchSuggestion.addSuggestion"
            )
            if let suggestion = result.first {
                suggestion.isEnabled = true
                suggestion.lastUsedAt = Date()
            } else {
                let contract = try Contract.get(id: contractId, with: context)
                
                let suggestion = ContractSearchSuggestion(context: context)
                suggestion.createdAt = Date()
                suggestion.lastUsedAt = Date()
                suggestion.isEnabled = true
                suggestion.contract = contract
            }
            try context.wrappedSave(detailsForLogging: "ContractSearchSuggestion.addSuggestion")
        }
    }
    
    public static func markSuggestionAsDisabled(for contractId: Int) async throws {
        try await NSPersistentContainer.wrappedPerformBackgroundTask { context in
            let fetchRequest = ContractSearchSuggestion.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "contract.id = %ld", contractId)
            fetchRequest.fetchLimit = 1
            let result = try context.wrappedFetch(
                fetchRequest,
                detailsForLogging: "ContractSearchSuggestion.addSuggestion"
            )
            guard let suggestion = result.first else {
                return
            }
            suggestion.isEnabled = false
            try context.wrappedSave(detailsForLogging: "ContractSearchSuggestion.addSuggestion")
        }
    }
    
}

//
//  Scenario+CoreDataClass.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 02.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//
//

import CoreData

@objc(Scenario)
public class Scenario: NSManagedObject, GetableById {
    
    /// Fetches all categories for availible scenarios in specific clinic.
    public static func getAllCategories(clinicId: Int) async throws -> [String] {
        try await NSPersistentContainer.wrappedPerformBackgroundTask { context in
            let fetchRequest = Scenario.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "ANY clinics.id == %ld", clinicId)
            let scenarios = try context.wrappedFetch(
                fetchRequest, detailsForLogging: "ClinicScenario.getScenariosCategories")
            return Set(scenarios.compactMap(\.category)).sorted()
        }
    }
    
    public var systemNameIcon: String {
        if #available(iOS 16, *) {
            return "person.2.badge.gearshape"
        } else {
            return "person.badge.clock"
        }
    }
    
}

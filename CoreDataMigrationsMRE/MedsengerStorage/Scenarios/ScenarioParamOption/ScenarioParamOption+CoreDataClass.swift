//
//  ScenarioParamOption+CoreDataClass.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 06.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//
//

import CoreData

@objc(ScenarioParamOption)
public class ScenarioParamOption: NSManagedObject {
    static func get(code: String,
                    paramCode: String,
                    scenarioId: Int,
                    with context: NSManagedObjectContext) throws -> ScenarioParamOption {
        let fetchRequest = ScenarioParamOption.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "code == %@ AND param.code == %@ AND param.scenario.id == %ld", code, paramCode, scenarioId)
        fetchRequest.fetchLimit = 1
        let fetchedResults = try context.wrappedFetch(fetchRequest, detailsForLogging: "ClinicScenarioParamOption.get")
        guard let scenarioParamOption = fetchedResults.first else {
            throw ObjectNotFoundError(
                entity: ScenarioParamOption.self,
                functionName: "ClinicScenarioParamOption.get"
            )
        }
        return scenarioParamOption
    }
}

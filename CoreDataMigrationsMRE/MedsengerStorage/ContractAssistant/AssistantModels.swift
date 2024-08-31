//
//  AssistantModels.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 09.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData

protocol ContractAndIdGetable: NSManagedObject {
    var id: Int64 { get }
    var contract: Contract? { get }
}

extension ContractAndIdGetable {
    public static func get(id: Int, contractId: Int, with context: NSManagedObjectContext) throws -> Self {
        let fetchRequest = NSFetchRequest<Self>(entityName: String(describing: Self.self))
        fetchRequest.predicate = NSPredicate(format: "contract.id == %ld AND id == %ld", contractId, id)
        fetchRequest.fetchLimit = 1
        let fetchedResults = try context.wrappedFetch(fetchRequest, detailsForLogging: "\(Self.self) get by id")
        guard let object = fetchedResults.first else {
            throw ObjectNotFoundError(entity: Self.self, functionName: "CoreDataIdGetable.get")
        }
        return object
    }
}

@objc(DoctorAssistant)
public class DoctorAssistant: NSManagedObject, ContractAndIdGetable, CleanableByIdAndContract {
    
}

@objc(PatientAssistant)
public class PatientAssistant: NSManagedObject, ContractAndIdGetable, CleanableByIdAndContract {
    
}

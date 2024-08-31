//
//  ContractAttachment+CoreDataClass.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 24.01.2023.
//  Copyright © 2023 TelePat ltd. All rights reserved.
//
//

import CoreData

@objc(ContractAttachment)
public class ContractAttachment: NSManagedObject {
    public var iconAsSystemImageName: String { "doc" }
}

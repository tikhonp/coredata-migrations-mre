//
//  URL+storeURL.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 03.02.2023.
//  Copyright © 2023 TelePat ltd. All rights reserved.
//

import Foundation

extension URL {
    
    static func storeURL(for appGroup: String, databaseName: String) -> URL {
        guard let fileContainer = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            fatalError("Shared file container could not be created.")
        }
        
        return fileContainer.appendingPathComponent("\(databaseName).sqlite")
    }
    
}

//
//  ObjectNotFoundError.swift
//  
//
//  Created by Tikhon Petrishchev on 26.02.2023.
//

import Foundation

struct ObjectNotFoundError<T>: LocalizedError, CustomNSError {
    let entity: T.Type
    let functionName: String
    
    var errorDescription: String? {
        "Object \"\(String(describing: entity.self))\" not found in \"\(functionName)\""
    }
    
    var errorUserInfo: [String: Any] {
        [NSDebugDescriptionErrorKey: errorDescription ?? "\(self)"]
    }
}

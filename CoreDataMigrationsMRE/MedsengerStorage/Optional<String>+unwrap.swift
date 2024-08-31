//
//  Optional<String>+unwrap.swift
//
//
//  Created by Tikhon Petrishchev on 01.12.2023.
//

import Foundation

extension Optional where Wrapped == String {
    
    /// Unwrapped string: Can be used for getting Core Data optional string properties.
    ///
    /// Sometimes you couldn't pry a word out of him.
    @inlinable public var pry: String {
        (self ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    @inlinable public var isEmpty: Bool {
        self?.isEmpty ?? true
    }
    
}

extension Optional where Wrapped == NSSet {
    
    @inlinable public func array<T>(of objectType: T.Type) -> [T] where T: Hashable {
        let set = self as? Set<T> ?? []
        return Array(set)
    }
    
    @inlinable public var isEmpty: Bool {
        count == 0
    }
    
    @inlinable public var count: Int {
        self?.count ?? 0
    }
    
}

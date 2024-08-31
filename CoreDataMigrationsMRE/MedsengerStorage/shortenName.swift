//
//  shortenName.swift
//
//
//  Created by Tikhon Petrishchev on 01.12.2023.
//

import Foundation

extension String {
    func replacingRegex(
        matching pattern: String,
        findingOptions: NSRegularExpression.Options = .caseInsensitive,
        replacingOptions: NSRegularExpression.MatchingOptions = [],
        with template: String
    ) throws -> String {
        let regex = try NSRegularExpression(pattern: pattern, options: findingOptions)
        let range = NSRange(startIndex..., in: self)
        return regex.stringByReplacingMatches(in: self, options: replacingOptions, range: range, withTemplate: template)
    }
 }

private let MAX_INITIALS = 2

public func shortenName(fullName: String) -> String {
    let cleanedFullName = (try? fullName.replacingRegex(matching: "\\s+", with: " ")) ?? fullName
    
    let words = cleanedFullName
        .split(separator: " ", omittingEmptySubsequences: true)
        .filter { !$0.isEmpty }
        
    let initialsCount = min(MAX_INITIALS, words.count - 1)
    
    let surname = words
        .prefix(words.count - initialsCount)
        .joined(separator: " ")

    let initials = words
        .suffix(initialsCount)
        .map { $0.prefix(1) + "." }
        .joined()
    
    if initials.isEmpty {
        return surname
    } else {
        return "\(surname) \(initials)"
    }
}

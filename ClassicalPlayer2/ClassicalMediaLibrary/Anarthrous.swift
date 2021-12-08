//
//  Anarthrous.swift
//  ClassicalPlayer
//
//  Created by Frederick Kuhl on 1/14/19.
//  Copyright © 2019 TyndaleSoft LLC. All rights reserved.
//

import Foundation

extension NSString {
    
    //CoreData does NOT support use of this in a sort descriptor!
    func anarthrousCompare(_ string: String) -> ComparisonResult {
        let meCopy = removeArticle(from: self as String)
        let stringCopy = removeArticle(from: string)
        return meCopy.localizedCaseInsensitiveCompare(stringCopy)
    }
}

func removeArticle(from: String) -> String {
    let fromRange = NSRange(from.startIndex..., in: from)
    let checkingResult = articleExpression.matches(in: from, options: [], range: fromRange)
    if checkingResult.isEmpty { return from }
    let range = checkingResult[0].range(at: 0)
    let startIndex = from.index(from.startIndex, offsetBy: range.location)
    let endIndex = from.index(startIndex, offsetBy: range.length)
    return String(from[endIndex...])
}

fileprivate let articleExpression = try! NSRegularExpression(
    pattern: "^(A|An|The)\\s+",
    options: [.caseInsensitive])


public func anarthrousTitlePredicate(a: Piece, b: Piece) -> Bool {
    let aTitle = a.title ?? ""
    let bTitle = b.title ?? ""
    return aTitle.anarthrousCompare(bTitle) == .orderedAscending
}

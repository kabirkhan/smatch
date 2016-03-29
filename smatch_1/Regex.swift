//
//  Regex.swift
//  smatch_1
//
//  Created by Kabir Khan on 3/28/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//

import UIKit

struct Regex {
    var internalExpression: NSRegularExpression
    let pattern: String
    
    init(_ pattern: String) {
        self.pattern = pattern
        do {
            self.internalExpression = try NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
        } catch {
            print(error)
        }
        internalExpression = NSRegularExpression()
    }
    
    func test(input: String) -> Bool {
        let matches = self.internalExpression.matchesInString(input, options: .ReportCompletion, range:NSMakeRange(0, input.characters.count))
        return matches.count > 0
    }
}
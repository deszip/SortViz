//
//  InputParser.swift
//  SortViz
//
//  Created by Deszip on 16/05/2017.
//  Copyright © 2017 Deszip. All rights reserved.
//

import Foundation

class InputParser {
    
    private static let SeparatorsSet = CharacterSet(charactersIn: ",./: ")
    
    class func values(fromString input: String?) -> [Int64] {
        return input?.components(separatedBy: InputParser.SeparatorsSet).flatMap { $0.numberValue?.int64Value } ?? []
    }
    
}

//
//  SequenceGenerator.swift
//  SortViz
//
//  Created by Deszip on 18/05/2017.
//  Copyright © 2017 Deszip. All rights reserved.
//

import Foundation

class SequenceGenerator {
    
    class func randomSequence(length: Int64 = 10) -> [Int64] {
        var sequence = [Int64]()
        for _ in 0..<length {
            sequence.append(Int64(arc4random_uniform(100)))
        }
        
        return sequence
    }
    
}

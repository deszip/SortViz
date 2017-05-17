//
//  InsertSort.swift
//  SortViz
//
//  Created by Deszip on 17/05/2017.
//  Copyright © 2017 Deszip. All rights reserved.
//

import Foundation

class InsertSort {
    
    static func sort(_ array: Array<Int64>, progress:SortProgress) -> Array<Int64> {
        progress(array)
        if array.count <= 1 {
            return array
        }
        
        var array = array
        for i in 1...array.count - 1 {
            let element = array[i]
            for j in ((-1 + 1)...i).reversed() {
                let pair = array[j]
                if element < pair {
                    array.remove(at: j + 1)
                    array.insert(element, at: j)
                    
                    progress(array)
                }
            }
        }
        
        return array
    }
    
}

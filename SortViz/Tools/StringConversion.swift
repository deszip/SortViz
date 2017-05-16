//
//  StringConversion.swift
//  SortViz
//
//  Created by Deszip on 16/05/2017.
//  Copyright © 2017 Deszip. All rights reserved.
//

import Foundation

extension String {
    
    var numberValue: NSNumber? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.number(from: self)
    }
}

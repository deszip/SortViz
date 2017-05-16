//
//  SVElementDataSource.swift
//  SortViz
//
//  Created by Deszip on 14/05/2017.
//  Copyright © 2017 Deszip. All rights reserved.
//

import Foundation
import CoreData

class SVElementDataSource: FRCDataSource<Element> {
    
    init(context: NSManagedObjectContext) {
        let request = NSFetchRequest<Element>(entityName: "Element")
        request.sortDescriptors = [NSSortDescriptor(key: "currentIndex", ascending: true)]
        
        super.init(context: context, request: request)
    }
    
}

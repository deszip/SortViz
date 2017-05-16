//
//  SVContextProvider.swift
//  SortViz
//
//  Created by Deszip on 14/05/2017.
//  Copyright © 2017 Deszip. All rights reserved.
//

import Foundation
import CoreData

class SVContextProvider {
    
    let workingContext: NSManagedObjectContext
    let viewContext: NSManagedObjectContext
    
    init() {
        let persistentContainer = NSPersistentContainer(name: "SortViz")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        persistentContainer.persistentStoreDescriptions = [description]
        
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                print("Error loading persistent store: \(error)")
            }
        }
        
        self.workingContext = persistentContainer.newBackgroundContext()
        self.viewContext = persistentContainer.viewContext
    }
    
}

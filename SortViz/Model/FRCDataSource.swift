//
//  FRCDataSource.swift
//  SortViz
//
//  Created by Deszip on 14/05/2017.
//  Copyright © 2017 Deszip. All rights reserved.
//

import UIKit
import CoreData

protocol FRCDataHandling {
    func reloadData()
    func changeObject(_ anObject: AnyObject, atIndexPath indexPath: IndexPath?, changeType: NSFetchedResultsChangeType, newIndexPath: IndexPath?)
    func changeSection(_ sectionIndex: Int, changeType: NSFetchedResultsChangeType)
    
    func willChangeContent()
    func didChangeContent()
}

class FRCDataSourceAdapter <T: NSManagedObject> : NSObject, FRCDataHandling {
    var dataSource: FRCDataSource<T>?
    var dataUpdatesHandler: (() -> Void)?
    
    func reloadData() {}
    func changeObject(_ anObject: AnyObject, atIndexPath indexPath: IndexPath?, changeType: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {}
    func changeSection(_ sectionIndex: Int, changeType: NSFetchedResultsChangeType) {}
    func willChangeContent() {}
    func didChangeContent() {}
}

class FRCDataSource<T: NSManagedObject>: NSObject, NSFetchedResultsControllerDelegate {
    
    private let context: NSManagedObjectContext
    private var frc: NSFetchedResultsController<T>
    let request: NSFetchRequest<T>
    private let originalPredicate: NSPredicate?
    private let sectionKeyPath: String?
    
    private var adapter: FRCDataSourceAdapter<T>?
    
    /// If set to false data source will not call any adapters API on data update.
    var updatesAdapter: Bool = true {
        willSet {
            if newValue {
                adapter?.reloadData()
            }
        }
    }
    
    init(context: NSManagedObjectContext, request: NSFetchRequest<T>, sectionKeyPath: String? = nil) {
        self.context = context
        self.request = request
        self.originalPredicate = request.predicate
        self.sectionKeyPath = sectionKeyPath
        self.frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: sectionKeyPath, cacheName: nil)
        
        super.init()
        
        self.frc.delegate = self
    }
    
    deinit {
        self.frc.delegate = nil
    }
    
    func bind(_ adapter: FRCDataSourceAdapter<T>) throws {
        self.adapter = adapter
        self.adapter?.dataSource = self
        
        try fetch()
    }
    
    func setPredicate(_ predicate: NSPredicate) throws {
        request.predicate = predicate
        frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: sectionKeyPath, cacheName: nil)
        frc.delegate = self
        
        try fetch()
    }
    
    // MARK: - FRCDataProvider -
    
    func numberOfSections() -> Int {
        return frc.sections?.count ?? 0
    }
    
    func numberOfItems(_ section: Int) -> Int {
        return frc.sections?[section].numberOfObjects ?? 0
    }
    
    func sectionAtIndex(index: Int) -> NSFetchedResultsSectionInfo? {
        return frc.sections?[index]
    }
    
    func objectAtIndexPath(_ indexPath: IndexPath) -> T {
        return frc.object(at: indexPath)
    }
    
    func fetch() throws {
        try frc.performFetch()
        adapter?.reloadData()
        adapter?.dataUpdatesHandler?()
    }
    
    // MARK: - NSFetchedResultsControllerDelegate -

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        adapter?.willChangeContent()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        adapter?.didChangeContent()
        adapter?.dataUpdatesHandler?()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        adapter?.changeSection(sectionIndex, changeType: type)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if updatesAdapter {
            adapter?.changeObject(anObject as AnyObject, atIndexPath: indexPath, changeType: type, newIndexPath: newIndexPath)
        }
    }

}

//
//  CollectionAdapter.swift
//  SortViz
//
//  Created by Deszip on 12/05/2017.
//  Copyright © 2017 Deszip. All rights reserved.
//

import UIKit
import CoreData

class CollectionAdapter<T: NSManagedObject>: FRCDataSourceAdapter<T>, UICollectionViewDataSource {

    weak var collectionView: UICollectionView?
    var cellBuilder: CellBuilder<T>
    var cellBuildingHandler: ((UICollectionViewCell, T) -> Void)?
    
    private typealias SectionChange = (changeType: NSFetchedResultsChangeType, sectionIndex: Int)
    private typealias ObjectChange = (changeType: NSFetchedResultsChangeType, indexPaths: [IndexPath])
    private var sectionChanges = [SectionChange]()
    private var objectChanges = [ObjectChange]()
    
    init(collectionView: UICollectionView, cellBuilder: CellBuilder<T>) {
        self.collectionView = collectionView
        self.cellBuilder = cellBuilder
    
        super.init()
    
        self.collectionView?.dataSource = self
    }
    
    private func applyObjectChanges() {
        for (changeType, indexPaths) in objectChanges {
            switch (changeType) {
            case .insert: collectionView?.insertItems(at: indexPaths)
            case .delete: collectionView?.deleteItems(at: indexPaths)
            case .update: () // Tired fighting UICollectionView bugs...
            case .move:
                if let fromIndexPath = indexPaths.first, let toIndexPath = indexPaths.last {
                    if fromIndexPath != toIndexPath {
                        collectionView?.moveItem(at: fromIndexPath, to: toIndexPath)
                    }
                }
            }
        }
    }
    
    private func applySectionChanges() {
        for (changeType, sectionIndex) in sectionChanges {
            let section = IndexSet([sectionIndex])
            
            switch (changeType) {
            case .insert: collectionView?.insertSections(section)
            case .delete: collectionView?.deleteSections(section)
            default : break
            }
        }
    }
    
    override func reloadData() {
        self.collectionView?.reloadData()
    }
    
    override func willChangeContent() {
        sectionChanges.removeAll()
        objectChanges.removeAll()
    }
    
    override func changeObject(_ anObject: AnyObject, atIndexPath indexPath: IndexPath?, changeType: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch changeType {
            case .insert:
                if let insertIndexPath = newIndexPath {
                    objectChanges.append((changeType, [insertIndexPath]))
                }
            case .delete:
                if let deleteIndexPath = indexPath {
                    objectChanges.append((changeType, [deleteIndexPath]))
                }
            case .update:
                if let indexPath = indexPath {
                    objectChanges.append((changeType, [indexPath]))
                }
            case .move:
                if let old = indexPath, let new = newIndexPath {
                    objectChanges.append((changeType, [old, new]))
                }
        }
    }
    
    override func didChangeContent() {
        self.collectionView?.performBatchUpdates({ [weak self] in
            self?.applyObjectChanges()
            self?.applySectionChanges()
        }, completion: nil)
    }
    
    // MARK: - UICollectionViewDataSource -
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource?.numberOfSections() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.numberOfItems(section) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let asset = dataSource?.objectAtIndexPath(indexPath) else {
            return UICollectionViewCell()
        }
        
        let cell = cellBuilder.buildCell(entity: asset, indexPath: indexPath)
        cellBuildingHandler?(cell, asset)

        return cell
    }
    
}

//
//  CellBuilder.swift
//  SortViz
//
//  Created by Deszip on 12/05/2017.
//  Copyright © 2017 Deszip. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CellBuilder<Entity: NSManagedObject> {
    weak var collectionView: UICollectionView?
    
    private let cellIdentifier: String
    
    init(collectionView: UICollectionView, cellIdentifier: String) {
        self.collectionView = collectionView
        self.cellIdentifier = cellIdentifier
    }
    
    func buildCell(entity: Entity, indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView?.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) else {
            return UICollectionViewCell()
        }

        configureCell(cell: cell, entity: entity)
        
        return cell
    }
    
    func configureCell(cell: UICollectionViewCell, entity: Entity) {
        //...
    }
    
}

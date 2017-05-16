//
//  ViewController.swift
//  SortViz
//
//  Created by Deszip on 14/05/2017.
//  Copyright © 2017 Deszip. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private var sorter: Sorter?
    private var data: [Int64] = []
    
    // MARK: - View lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellNib = UINib(nibName: "ElementCell", bundle: Bundle.main)
        collectionView.register(cellNib, forCellWithReuseIdentifier: "ElementCell")
        
        // Test data
        data = [10,9,8,7,6,5,4,3,2,1]
        
        // Dependencies
        let contextProvider = SVContextProvider()
        let viewContext = contextProvider.viewContext
        viewContext.automaticallyMergesChangesFromParent = true
        
        // Collection view
        let ds = SVElementDataSource(context: contextProvider.viewContext)
        do {
            let cellBuilder = CellBuilder<Element>(collectionView: collectionView, cellIdentifier: "ElementCell")
            let adapter = CollectionAdapter(collectionView: collectionView, cellBuilder: cellBuilder)
            adapter.cellBuildingHandler = { cell, element in
                if let cell = cell as? ElementCell {
                    cell.setValue(element.value, maxValue: self.data.max() ?? 0)
                    print("Build cell: element: \(element.value), cell: \(cell)")
                }
            }
            try ds.bind(adapter)
        } catch {
            print("Error: \(error)")
        }
        
        // Sorter
        sorter = Sorter(context: contextProvider.workingContext)
        sorter?.loadData(data)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { context in
            self.collectionView.collectionViewLayout.invalidateLayout()
        })
    }
    
    // MARK: - Actions -
    
    @IBAction func run(_ sender: UIBarButtonItem) {
        
    }
    
    @IBAction func rewind(_ sender: UIBarButtonItem) {
        sorter?.stepBack()
    }
    
    @IBAction func forward(_ sender: UIBarButtonItem) {
        sorter?.stepForward()
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout -
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = ((collectionView.frame.size.width - (CGFloat(data.count - 1) * 10)) / CGFloat(data.count))
        let itemHeight = collectionView.frame.size.height - 20
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
}

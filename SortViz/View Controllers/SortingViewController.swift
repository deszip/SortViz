//
//  SortingViewController.swift
//  SortViz
//
//  Created by Deszip on 14/05/2017.
//  Copyright © 2017 Deszip. All rights reserved.
//

import UIKit

class SortingViewController: UIViewController, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var inputField: UITextField!
    
    private var sorter: Sorter?
    private var data: [Int64] = []
    
    // MARK: - View lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initial data
        loadRandomData()
        
        // Dependencies
        let contextProvider = SVContextProvider()
        let viewContext = contextProvider.viewContext
        viewContext.automaticallyMergesChangesFromParent = true
        
        // Collection view
        buildDataSource(contextProvider: contextProvider)
        
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
    
    // MARK: - Setup -
    
    private func buildDataSource(contextProvider: SVContextProvider) {
        let ds = SVElementDataSource(context: contextProvider.viewContext)
        do {
            let cellBuilder = CellBuilder<Element>(collectionView: collectionView, cellIdentifier: "ElementCell")
            let adapter = CollectionAdapter(collectionView: collectionView, cellBuilder: cellBuilder)
            adapter.cellBuildingHandler = { cell, element in
                if let cell = cell as? ElementCell {
                    cell.setValue(element.value, maxValue: self.data.max() ?? 0)
                }
            }
            try ds.bind(adapter)
        } catch {
            print("Error: \(error)")
        }
    }
    
    private func loadRandomData() {
        data = SequenceGenerator.randomSequence()
        sorter?.loadData(data)
        inputField.text = data.map({ String($0) }).joined(separator: ",")
    }
    
    // MARK: - Actions -
    
    @IBAction func loadRandomData(_ sender: UIButton) {
        inputField.resignFirstResponder()
        loadRandomData()
    }
    
    @IBAction func inputChanged(_ sender: UITextField) {
        let inputData = InputParser.values(fromString: sender.text)
        if inputData.count >= 0 {
            data = inputData
            sorter?.loadData(data)
        }
    }
    
    @IBAction func editingEnd(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    @IBAction func orderChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            case 0:
                sorter?.reverse()
                break
            case 1:
                sorter?.sort()
                break
            case 2:
                sorter?.stop()
                sorter?.randomize()
                break
            default: ()
        }
    }
    
    @IBAction func toggle(_ sender: Any) {
        // TODO: toggle icon depending on sorter state
        sorter?.run()
    }
    
    @IBAction func run(_ sender: UIBarButtonItem) {
        sorter?.run()
    }
    
    @IBAction func stop(_ sender: UIBarButtonItem) {
        sorter?.stop()
    }
    
    @IBAction func randomize(_ sender: UIBarButtonItem) {
        sorter?.stop()
        sorter?.randomize()
    }
    
    @IBAction func rewind(_ sender: Any) {
        sorter?.stop()
        sorter?.stepBack()
    }
    
    @IBAction func forward(_ sender: Any) {
        sorter?.stop()
        sorter?.stepForward()
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout -
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = collectionView.frame.size.width / CGFloat(data.count)
        let itemHeight = collectionView.frame.size.height
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}

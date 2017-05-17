//
//  Sorter.swift
//  SortViz
//
//  Created by Deszip on 12/05/2017.
//  Copyright © 2017 Deszip. All rights reserved.
//

import Foundation
import CoreData

protocol SorterDelegate: class {
    func didMoveItem(fromIndex: Int, toIndex: Int)
    func itemWasPlaced(atIndex: Int)
    func didStartMovingItem(index: Int)
    func didEndMovingItem(index: Int)
}

typealias Completion = (Bool, Error?) -> Void
typealias SortProgress = ([Int64]) -> Void

class Sorter {
    
    weak var delegate: SorterDelegate?
    private let workingContext: NSManagedObjectContext
    
    private var currentStep: Int64 = 0
    private var stepsCount: Int64 = 0
    private var timer: Timer?
    
    // MARK: - Initialization -
    
    class func defaultSorter() -> Sorter {
        let persistentContainer = NSPersistentContainer(name: "SortViz")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        persistentContainer.persistentStoreDescriptions = [description]
        
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                print("Error loading persistent store: \(error)")
            }
        }
        let workingContext = persistentContainer.newBackgroundContext()
        
        return Sorter(context: workingContext)
    }
    
    init(context: NSManagedObjectContext) {
        self.workingContext = context
    }
    
    // MARK: - Moving over the iterations -
    
    func run() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { [weak self] timer in
            self?.stepForward() { status, error in
                if !status {
                    timer.invalidate()
                }
            }
        })
        timer?.fire()
    }
    
    func stop() {
        timer?.invalidate()
    }
    
    func stepForward(_ completion: Completion? = nil) {
        if currentStep >= stepsCount - 1 {
            completion?(false, NSError(domain: "", code: 42, userInfo: nil))
            return
        }
        
        workingContext.perform {
            self.currentStep += 1
            self.transitionToStep(self.currentStep)
            self.save(completion: completion)
        }
    }
    
    func stepBack(_ completion: Completion? = nil) {
        if self.currentStep <= 0 {
            completion?(false, NSError(domain: "", code: 42, userInfo: nil))
            return
        }
        
        workingContext.perform {
            self.currentStep -= 1
            self.transitionToStep(self.currentStep)
            self.save(completion: completion)
        }
    }
    
    func goToStep(_ step: Int64) {
        if step >= 0 && step < stepsCount - 1 {
            currentStep = step
            workingContext.perform {
                self.transitionToStep(self.currentStep)
                self.save(completion: completion)
            }
        }
    }
    
    // MARK: - Data processing -
    
    func loadData(_ data: Array<Int64>, completion: Completion? = nil) {
        cleanElements()
        currentStep = 0
        
        workingContext.perform {
            let elements = self.buildElements(data)
            self.buildSortSteps(elements)
            self.save(completion: completion)
        }
    }
    
    func randomize() {
        loadData(getElements().map { $0.value }.shuffled())
    }
    
    func sort() {
        loadData(getElements().map { $0.value }.sorted())
    }
    
    func reverse() {
        loadData(getElements().map { $0.value }.sorted().reversed())
    }
    
    // MARK: - Tools -
    
    private func transitionToStep(_ stepIndex: Int64) {
        let elements = self.getElements()
        elements.forEach { element in
            if stepIndex < Int64(element.steps?.count ?? 0) {
                if let step = (element.steps as? Set<Step>)?.filter({ $0.order == stepIndex })[0] {
                    if element.currentIndex != step.index {
                        element.currentIndex = step.index
                    }
                }
            }
        }
    }
    
    // MARK: - Persistence -
    
    private func getElements() -> [Element] {
        let fetchRequest: NSFetchRequest<Element> = Element.fetchRequest()
        do {
            let elements = try self.workingContext.fetch(fetchRequest)
            return elements
        } catch {
            print("Failed to fetch elements: \(error)")
        }
        
        return []
    }
    
    private func cleanElements() {
        let fetchRequest: NSFetchRequest<Element> = Element.fetchRequest()
        do {
            let elements = try self.workingContext.fetch(fetchRequest)
            elements.forEach { self.workingContext.delete($0) }
        } catch {
            print("Failed to clean context: \(error)")
        }
    }
    
    private func buildElements(_ data: Array<Int64>) -> [Element] {
        var elements: [Element] = []
        for (index, elementValue) in data.enumerated() {
            let element = Element(context: self.workingContext)
            element.value = elementValue
            element.currentIndex = Int64(index)
            element.currentStep = 0
            
            elements.append(element)
        }
        
        return elements
    }
    
    private func buildSortSteps(_ elements: Array<Element>) {
        let data = elements.map { $0.value }
        self.stepsCount = 0
        let _ = InsertSort.sort(data) { values in
            elements.forEach { element in
                let step = Step(context: self.workingContext)
                step.order = stepsCount
                step.index = Int64(values.index(of: element.value) ?? 0)
                element.addToSteps(step)
            }
            
            stepsCount += 1
        }
    }
    
    private func save(completion: Completion? = nil) {
        if workingContext.hasChanges {
            do {
                try self.workingContext.save()
                completion?(true, nil)
            } catch {
                print("Sorter failed to save context: \(error)")
                completion?(false, error)
            }
        }
    }
    
}

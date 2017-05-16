//
//  SorterTests.swift
//  SortViz
//
//  Created by Deszip on 14/05/2017.
//  Copyright © 2017 Deszip. All rights reserved.
//

import XCTest
import CoreData
import Nimble

@testable import SortViz

class SorterTests: XCTestCase {
    
    private var persistentContainer: NSPersistentContainer!
    private var context: NSManagedObjectContext!
    
    private var sorter: Sorter?
    
    override func setUp() {
        super.setUp()
        
        buildStore()
        sorter = Sorter(context: context)
    }
    
    override func tearDown() {
        sorter = nil
        
        super.tearDown()
    }
    
    func testLoadDataInsertElements() {
        let expectation = self.expectation(description: "")
        
        sorter?.loadData([1, 2, 3]) { status, error in
            expect(self.getElements().count).to(equal(3))
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 0.5, handler: nil)
    }
    
    func testLoadDataCleanElements() {
        let expectation = self.expectation(description: "")
        
        sorter?.loadData([1, 2, 3]) { status, error in
            self.sorter?.loadData([4]) { status, error in
                expect(self.getElements().count).to(equal(1))
                expect(self.getElements()[0].value).to(equal(4))
                expectation.fulfill()
            }
        }
        
        self.waitForExpectations(timeout: 0.5, handler: nil)
    }
    
    func testLoadDataBuildSteps() {
        let expectation = self.expectation(description: "")
        
        sorter?.loadData([3, 2, 1]) { status, error in
            expect(self.getElements()[0].steps!.count).to(equal(3))
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 0.5, handler: nil)
    }
    
    func testLoadDataBuildStepsForSingleElement() {
        let expectation = self.expectation(description: "")
        
        sorter?.loadData([1]) { status, error in
            expect(self.getElements()[0].steps!.count).to(equal(1))
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 0.5, handler: nil)
    }
    
    func testStepsBuiltReflectSorting() {
        let expectation = self.expectation(description: "")
        
        sorter?.loadData([3, 2, 1]) { status, error in
            
            let elements = self.getElements()
            
            let element_1 = self.element(from: elements, withValue: 1)!
            let element_2 = self.element(from: elements, withValue: 2)!
            let element_3 = self.element(from: elements, withValue: 3)!
            
            self.validateSteps(element: element_1, indexes: [2, 2, 1, 0])
            self.validateSteps(element: element_2, indexes: [1, 0, 0, 1])
            self.validateSteps(element: element_3, indexes: [0, 1, 2, 2])
            
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 0.5, handler: nil)
    }
    
    func testMovingForward() {
        let expectation = self.expectation(description: "")
        
        sorter?.loadData([3, 2, 1]) { status, error in
            self.sorter?.stepForward()
            
            let elements = self.getElements()
            
            let element_1 = self.element(from: elements, withValue: 1)!
            let element_2 = self.element(from: elements, withValue: 2)!
            let element_3 = self.element(from: elements, withValue: 3)!
            
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 0.5, handler: nil)
    }
    
    // MARK: - Validators -
    
    private func validateSteps(element: Element, indexes: [Int64]) {
        indexes.enumerated().forEach { index, value in
            expect(self.step(from: element, withOrder: Int64(index))!.index).to(equal(value))
        }
    }
    
    // MARK: - Tools -
    
    private func buildStore() {
        persistentContainer = NSPersistentContainer(name: "SortViz")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        persistentContainer.persistentStoreDescriptions = [description]
        
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                print("Error loading persistent store: \(error)")
            }
        }
        
        context = persistentContainer.viewContext
    }
    
    private func getElements() -> [Element] {
        let fetchRequest: NSFetchRequest<Element> = Element.fetchRequest()
        let elements = try! self.persistentContainer.viewContext.fetch(fetchRequest)
        
        return elements
    }
    
    private func element(from: [Element], withValue value: Int64) -> Element? {
        return from.filter { $0.value == value }.first
    }
    
    private func step(from: Element, withOrder order: Int64) -> Step? {
        return (from.steps as? Set<Step>)?.filter { $0.order == order }.first
    }
    
}

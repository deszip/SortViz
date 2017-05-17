//
//  InputParserTests.swift
//  SortViz
//
//  Created by Deszip on 17/05/2017.
//  Copyright © 2017 Deszip. All rights reserved.
//

import XCTest
import Nimble

@testable import SortViz

class InputParserTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testEmptyStringIsEmptyArray() {
        expect(InputParser.values(fromString: "")).to(equal([]))
    }
    
    func testNilStringIsEmptyArray() {
        expect(InputParser.values(fromString: nil)).to(equal([]))
    }
    
    func testSeparationCharacters() {
        expect(InputParser.values(fromString: "1,2.3/4:5 6")).to(equal([1, 2, 3, 4, 5, 6]))
    }
    
    func testNegativesAreHandled() {
        expect(InputParser.values(fromString: "1, -1, 2, -2")).to(equal([1, -1, 2, -2]))
    }
    
    func testTrashIsIgnored() {
        expect(InputParser.values(fromString: "1, 2, 2f, _34")).to(equal([1, 2]))
    }
}

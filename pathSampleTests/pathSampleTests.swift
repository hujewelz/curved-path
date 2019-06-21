//
//  pathSampleTests.swift
//  pathSampleTests
//
//  Created by huluobo on 2019/6/21.
//  Copyright © 2019 jewelz. All rights reserved.
//

import XCTest
@testable import pathSample

class pathSampleTests: XCTestCase {

    
    override func setUp() {
    
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDistanceToLine() {
        let point = CGPoint(x: 0, y: 100)
        let distance = point.distanceToLine(Line(p1: .zero, p2: CGPoint(x: 100, y: 0)))
        XCTAssertEqual(distance, 100, "Distance should be 100")
    }

}

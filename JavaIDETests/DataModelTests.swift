//
//  DataModelTests.swift
//  JavaIDE
//
//  Created by Tobias Steinbrück on 24.01.17.
//  Copyright © 2017 Tobias Steinbrück. All rights reserved.
//

import XCTest
@testable import JavaIDE

class DataModelTests: XCTestCase {
    
    func testInitialization() {
        
        let test1 = JavaClass.init(name: "Test1", content: "Content1")
        XCTAssertNotNil(test1)
        
        let test2 = JavaClass.init(name: "", content: "Content1")
        XCTAssertNil(test2)

        let test3 = JavaClass.init(name: "Test3", content: "")
        XCTAssertNil(test3)
    }
    
}

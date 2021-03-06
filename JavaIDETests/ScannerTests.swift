//
//  ScannerTests.swift
//  ScannerTests
//
//  Created by Tobias Steinbrück on 23.10.16.
//  Copyright © 2016 Tobias Steinbrück. All rights reserved.
//

import XCTest
@testable import JavaIDE

class ScannerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        JavaIDE.Scanner.scanArray.removeAll()
    }
    
    
    func testScanner() {
        let input = "i = 5;"
        let scanArray = JavaIDE.Scanner.scanInput(input)
        let musterScanArray = [["Ident", "i"], ["Assign", "="], ["Number", "5"], ["Semicolon", ";"]]
        XCTAssert(scanArray.description == musterScanArray.description)
    }
    
    
    func testIfstatement() {
        let input = "if(i==5)"
        
        let result = JavaIDE.Scanner.getNextWord(input)
        let index = input.index(input.startIndex, offsetBy: result.characters.count)
        let newInput = input.substring(from: index).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        let type = JavaIDE.Scanner.scanArray[0][0]
        let value = JavaIDE.Scanner.scanArray[0][1]

        XCTAssert(type == "LoopOrCondition")
        XCTAssert(value == "if")
        XCTAssert(newInput == "(i==5)")
    }
    
    
    func testPerformanceScanner() {
        self.measure {
            let input = "public static void main(String[] args) {\n int i = 5;\n System.out.println(i);\ntest1();\n}\n\npublic static void test1(String arg1, int arg2) {\n int j = 5;\n System.out.println(j);\n}"
            _ = JavaIDE.Scanner.scanInput(input)
        }
    }
}


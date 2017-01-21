//
//  CodeGenerator.swift
//  JavaIDE
//
//  Created by Tobias Steinbrück on 13.01.17.
//  Copyright © 2017 Tobias Steinbrück. All rights reserved.
//

import Foundation

// Number: Check if number is integer or float... (remember: ".5" or "123." is float)
class CodeGenerator {
    
    static var varArray = [[String: Any]]()
    
    static func generateCode(_ parseArray: [[[String]]]) {
        varArray.removeAll()
        
        var newParseArray = parseArray
        while(newParseArray.indices.contains(0)) {
            switch(newParseArray[0][0][0]) {
            case "Declaration":
                print("Declaration")
            case "DeclarationAndAssignment":
                print("DeclarationAndAssignment")
            default:
                print("Default")
            }
            newParseArray.remove(at: 0)
        }
    }
    
    
    static func handleDeclaration(_ parseArray: [[String]]) {
        // check if Ident is already in varArray --> Error
        //for variable in varArray[0] {
            
        //}
    }
}

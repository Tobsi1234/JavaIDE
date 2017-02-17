//
//  CodeGenerator.swift
//  JavaIDE
//
//  Created by Tobias Steinbrück on 13.01.17.
//  Copyright © 2017 Tobias Steinbrück. All rights reserved.
//

import Foundation

// Number: Check if number is integer or float... (remember: ".5" or "123." is float)
class OutputGenerator {
    
    static var varArray = [[String: Any]]()
    
    static func generateOutput(_ parseArray: [[[String]]]) {
        varArray.removeAll()

        var newParseArray = parseArray
        while(newParseArray.indices.contains(0)) {
            if(newParseArray[0].indices.contains(0)) {
                switch(newParseArray[0][0][0]) {
                case "Declaration":
                    handleDeclaration(newParseArray[0])
                case "DeclarationAndAssignment":
                    handleDeclarationAndAssignment(newParseArray[0])
                case "Print":
                    handlePrint(newParseArray[0])
                default:
                    print("Default (CodeGenerator)")
                }
                newParseArray.remove(at: 0)
            } else {
                Scanner.errorMsgs.append("Error: No input.")
                break
            }
        }
    }
    
    
    static func handleDeclaration(_ parseArray: [[String]]) {
        // check if Ident is already in varArray --> Error
        let ident : String = parseArray[2][1]
        //let value : String = parseArray[4][1]
        var isIn = false
        //print(ident)
        if(varArray.indices.contains(0)) {
            for variable in varArray[0] {
                if(variable.key == ident) {
                    isIn = true
                }
            }
            if(!isIn) {
                varArray[0][ident] = "" // ToDo: how to save Datatype when no value?! if Num: 0 / 0.0, if Ident: type of ident
            } else {
                Scanner.errorMsgs.append("Error: Multiple Declaration of Variable: \(ident)")
            }
        } else {
            varArray.append([ident: ""]) // ToDo: how to save Datatype when no value?!
        }
        
    }
    
    
    static func handleDeclarationAndAssignment(_ parseArray: [[String]]) {
        // check if Ident is already in varArray --> Error
        let ident : String = parseArray[2][1]
        let value : String = parseArray[4][1]
        var isIn = false
        print(ident)
        if(varArray.indices.contains(0)) {
            for variable in varArray[0] {
                if(variable.key == ident) {
                    isIn = true
                }
            }
            if(!isIn) {
                varArray[0][ident] = value // ToDo: check Datatype and convert e.g. let a:Int? = Int(ident) ... what about ident = ident;? -> type of ident
            } else {
                Scanner.errorMsgs.append("Error: Multiple Declaration of Variable: \(ident)")
            }
        } else {
            varArray.append([ident: value]) // ToDo: check Datatype and convert e.g. let a:Int? = Int(ident) ... what about ident = ident;?!
        }
    }
    
    
    static func handlePrint (_ parseArray: [[String]]) {
        let printIdent : String = parseArray[3][1]
        var printValue = "" // ToDo: Datatype Any?
        var isIn = false
        if(varArray.indices.contains(0)) {
            for variable in varArray[0] {
                if(variable.key == printIdent) {
                    isIn = true
                    printValue = variable.value as! String // ToDo: Datatype Any?
                }
            }
            if(!isIn) {
                Scanner.errorMsgs.append("Error: Variable \(printIdent) is not declared.")
            }
        } else {
            Scanner.errorMsgs.append("Error: Variable \(printIdent) is not declared.")
        }

        
        print("Ergebnis: \(printValue)")
    }

}

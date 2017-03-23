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
    
    static var varArray = [[[String: Any]]]() // dimensions: function, scope, variable
    static var functionsArray = [String]()
    static var currentScope = 0 // ToDo
    static var currentFunction = 0 // die beiden variablen sind wichtig für scopes: [currentFunction][currentScope][varName: varValue]
    static var outputMsgs = [String]()
    
    static func generateOutput(_ parseArray: [[[[String]]]]) {
        varArray.removeAll()
        functionsArray.removeAll()
        outputMsgs.removeAll()
        var mainFunctionIndex = -1
        var index = 0
        for functions in parseArray {
            let functionName = functions[0][4][1]
            if(functionName == "main"){
                mainFunctionIndex = index
            }
            functionsArray.append(functionName)
            index += 1
        }
        if(mainFunctionIndex < 0) {
            Scanner.errorMsgs.append("Error: Main-Method is missing.")
        }
        else {
            var newParseArray = parseArray[mainFunctionIndex]
            while(newParseArray.indices.contains(0) && Scanner.errorMsgs.isEmpty) {
                if(newParseArray[0].indices.contains(0)) {
                    switch(newParseArray[0][0][0]) {
                    case "Declaration":
                        handleDeclaration(newParseArray[0])
                    case "DeclarationAndAssignment":
                        handleDeclarationAndAssignment(newParseArray[0])
                    case "Print":
                        handlePrint(newParseArray[0])
                    case "Functioncall":
                        handleFunctioncall(parseArray, functionName: newParseArray[0][1][1])
                        currentFunction = 0 // back to main-method
                    case "LoopOrCondition":
                        handleLoopOrCondition(newParseArray[0])
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
    }
    
    
    static func handleDeclaration(_ parseArray: [[String]]) {
        // check if Ident is already in varArray --> Error
        let ident : String = parseArray[2][1]
        //let value : String = parseArray[4][1]
        var isIn = false
        //print(ident)
        if(varArray.indices.contains(currentFunction)) {
            for variable in varArray[currentFunction][0] {
                if(variable.key == ident) {
                    isIn = true
                }
            }
            if(!isIn) {
                varArray[currentFunction][0][ident] = "" // ToDo: how to save Datatype when no value?! if Num: 0 / 0.0, if Ident: type of ident
            } else {
                Scanner.errorMsgs.append("Error: Multiple Declaration of Variable: \(ident)")
            }
        } else {
            varArray.append([[ident: ""]]) // ToDo: how to save Datatype when no value?!
        }
        
    }
    
    
    static func handleDeclarationAndAssignment(_ parseArray: [[String]]) {
        // ToDo: check if Ident is already in varArray --> Error
        let ident : String = parseArray[2][1]
        let assignment : String = parseArray[4][1]
        var value: Any
        var isIn = false
        if(parseArray[4][0] == "Ident") {
            if(varArray.indices.contains(currentFunction)) {
                for variable in varArray[currentFunction][0] {
                    if(variable.key == assignment) {
                        isIn = true
                    }
                }
                if(isIn) {
                    value = varArray[currentFunction][0][assignment]!
                } else {
                    Scanner.errorMsgs.append("Error: Undeclared Variable: \(assignment)")
                    value = ""
                }
            } else {
                Scanner.errorMsgs.append("Error: Undeclared Variable: \(assignment)")
                value = ""
            }
        } else {
            value = parseArray[4][1]
        }
        isIn = false
        print(ident)
        if(varArray.indices.contains(currentFunction)) {
            for variable in varArray[currentFunction][0] {
                if(variable.key == ident) {
                    isIn = true
                }
            }
            if(!isIn) {
                varArray[currentFunction][0][ident] = value // ToDo: check Datatype and convert e.g. let a:Int? = Int(ident) ... what about ident = ident;? -> type of ident
            } else {
                Scanner.errorMsgs.append("Error: Multiple Declaration of Variable: \(ident)")
            }
        } else {
            varArray.append([[ident: value]]) // ToDo: check Datatype and convert e.g. let a:Int? = Int(ident) ... what about ident = ident;?!
        }
    }
    
    
    static func handlePrint (_ parseArray: [[String]]) {
        let printIdent : String = parseArray[3][1]
        var printValue = "" // ToDo: Datatype Any?
        var isIn = false
        if(varArray.indices.contains(currentFunction)) {
            for variable in varArray[currentFunction][0] {
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

        outputMsgs.append(printValue)
        print("Ergebnis: \(printValue)")
    }
    
    
    static func handleFunctioncall (_ parseArray: [[[[String]]]], functionName: String) {
        // currentFunction wechseln, ansonsten wie oben (generateOutput)
        if(functionName.lowercased() == "main") {
            Scanner.errorMsgs.append("Error: Method name 'main' not possible here.")
        } else {
            var functionIndex = -1
            var i = 0
            for function in functionsArray {
                if(function == functionName) {
                    functionIndex = i
                }
                i += 1
            }
            
            if(functionIndex < 0) {
                Scanner.errorMsgs.append("Error: Method name \(functionName) does not exist.")
            } else {
                currentFunction += 1

                var newParseArray = parseArray[functionIndex]
                while(newParseArray.indices.contains(0)) {
                    if(newParseArray[0].indices.contains(0)) {
                        switch(newParseArray[0][0][0]) {
                        case "Declaration":
                            handleDeclaration(newParseArray[0])
                        case "DeclarationAndAssignment":
                            handleDeclarationAndAssignment(newParseArray[0])
                        case "Print":
                            handlePrint(newParseArray[0])
                        case "LoopOrCondition":
                            handleLoopOrCondition(newParseArray[0])
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
        }
    }
    
    
    // ToDo: Only 2 conditions possible right now
    static func handleLoopOrCondition(_ parseArray: [[String]]) {
        var newParseArray = parseArray
        
        let type = newParseArray[1][1] // "if", "while" or "for"
        var args = [newParseArray[3], newParseArray[5]]
        var operators = [newParseArray[4][0]] // "Eq", "Neq", "Lt", "Gt", "Leq" or "Geq"
        var conjunction = [String]() // "And" or "Or"

        for _ in 0..<6 {
            newParseArray.remove(at: 0)
        }
        if(newParseArray.indices.contains(0) && newParseArray[0][0] != "CloseBracket") {
            conjunction.append(newParseArray[0][0])
            args.append(newParseArray[1])
            args.append(newParseArray[3])
            operators.append(newParseArray[2][0])
            for _ in 0..<4 {
                newParseArray.remove(at: 0)
            }
        }
        newParseArray.remove(at: 0)
        newParseArray.remove(at: 0) // deletes close bracket and open curly, so only Inner-LoopOrCondition remains
        var argsValues = [String]()

        for arg in args {
            if(arg[0] == "Ident") {
                var varIsDeclared = false
                if(varArray.indices.contains(currentFunction)) {
                    for (key, value) in varArray[currentFunction][0] { // ToDo: Current Scope
                        if(key == arg[1]){
                            varIsDeclared = true
                            argsValues.append(value as! String) // ToDo: Any Datatype?
                        }
                    }
                    if(!varIsDeclared) {
                        Scanner.errorMsgs.append("Error: Variable \(arg[1]) is not declared")
                    }
                } else {
                    Scanner.errorMsgs.append("Error: Variable \(arg[1]) is not declared")
                }
            } else {
                argsValues.append(arg[1])
            }
        }

        var bool = false
        if(type == "if") {
            if(conjunction.isEmpty) {
                if(handleCondition(op: operators[0], argValue1: argsValues[0], argValue2: argsValues[1])) {
                    bool = true
                }
            } else if(conjunction[0] == "And") {
                if(handleCondition(op: operators[0], argValue1: argsValues[0], argValue2: argsValues[1])) {
                    bool = true
                }
                if(bool && !handleCondition(op: operators[1], argValue1: argsValues[2], argValue2: argsValues[3])) {
                    bool = false
                }
            } else if(conjunction[0] == "Or") {
                if(handleCondition(op: operators[0], argValue1: argsValues[0], argValue2: argsValues[1])) {
                    bool = true
                }
                if(!bool && handleCondition(op: operators[1], argValue1: argsValues[2], argValue2: argsValues[3])) {
                    bool = true
                }
            }
            
            
        }
        
        if(bool) {
            handleInnerLoopOrCondition(newParseArray)
        }
        print(bool)
        print(type, args, operators, conjunction, argsValues)
    }
    
    
    // handles different conditions in LoopOrCondition. Returns true if condition is true
    static func handleCondition(op: String, argValue1: String, argValue2: String) -> Bool {
        var bool = false
        if(op == "Eq") {
            if(argValue1 == argValue2) {
                bool = true
            }
        }
        else if(op == "Neq") {
            if(argValue1 != argValue2) {
                bool = true
            }
        }
        // ToDo: More Operations
        return bool
    }
    
    
    static func handleInnerLoopOrCondition(_ parseArray: [[String]]) {
        //ToDo: currentScope += 1
        var newParseArray = parseArray
        var index = 0
        while(newParseArray.indices.contains(0) && newParseArray[0][0] != "CloseCurly") {
            if(newParseArray[0].indices.contains(0)) {
                switch(newParseArray[0][0]) {
                case "Declaration":
                    handleDeclaration(newParseArray)
                    index = 4
                case "DeclarationAndAssignment":
                    handleDeclarationAndAssignment(newParseArray)
                    index = 6
                case "Print":
                    handlePrint(newParseArray)
                    index = 6
                    //case "LoopOrCondition":
                //    handleLoopOrCondition(newParseArray)
                default:
                    print("Default (LoopOrCondition)")
                    index = 1
                }
                for _ in 0..<index {
                    newParseArray.remove(at: 0)
                }
            } else {
                Scanner.errorMsgs.append("Error: No input.")
                break
            }
        }
    }

}

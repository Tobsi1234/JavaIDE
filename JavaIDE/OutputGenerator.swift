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
                    case "Assignment":
                        handleAssignment(newParseArray[0])
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
    
    // handles declaration like "String abc;"
    static func handleDeclaration(_ parseArray: [[String]]) {
        let ident : String = parseArray[2][1]
        var isIn = false
        let noValue = NoValue() // used for storing datatype of not assigned ident
        noValue.name = ident
        noValue.datatype = parseArray[1][1]
        if(varArray.indices.contains(currentFunction)) {
            for variable in varArray[currentFunction][0] {
                if(variable.key == ident) {
                    isIn = true
                }
            }
            if(!isIn) {
                varArray[currentFunction][0][ident] = noValue
            } else {
                Scanner.errorMsgs.append("Error: Multiple Declaration of Variable: \(ident)")
            }
        } else {
            varArray.append([[ident: noValue]])
        }
    }
    
    // handles declaration with assignment like "int i = 5;"
    static func handleDeclarationAndAssignment(_ parseArray: [[String]]) {
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
    
    // handles assignment of variables like "i = 5;"
    static func handleAssignment(_ parseArray: [[String]]) {
        let ident : String = parseArray[1][1]
        let assignment : String = parseArray[3][1] // ToDo: Should be Any because it also could be just a number --> check if it's convertible to Int, if not leave it as string... then if it's a string, it could be a ident
        var oldValue: Any = 0 // old Value of ident, used for "+="
        var value: Any // value of assignment (differs if assignment is ident)

        var isIn = false
        print(ident)

        if(varArray.indices.contains(currentFunction)) {
            // check if ident is declared, if not throw error
            for variable in varArray[currentFunction][0] {
                if(variable.key == ident) {
                    isIn = true
                    if let obj = variable.value as? NoValue {
                        if(obj.datatype == "String") {
                            oldValue = ""
                        } else if(obj.datatype == "Number") {
                            oldValue = 0
                        }
                    } else {
                        oldValue = variable.value
                    }
                }
            }
            
            // if ident is declared, check if assignment is a ident. If yes, store it's value and not ident name as value.
            if(isIn) {
                if(parseArray[3][0] == "Ident") {
                    isIn = false
                    
                    // check if ident (assignment) is already declared, if not throw error
                    if(varArray.indices.contains(currentFunction)) {
                        for variable in varArray[currentFunction][0] {
                            if(variable.key == assignment) {
                                isIn = true
                            }
                        }
                        // if ident is declared, save it's value
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
                } else if(parseArray[3][0] == "Number") {
                    value = Int(parseArray[3][1])! // save Number as Int
                } else if(parseArray[3][0] == "String") {
                    value = String(parseArray[3][1])! // save String as String
                } else {
                    value = ""
                }
                
                // if no errors occured save new value in varArray
                if(Scanner.errorMsgs.isEmpty) {
                    if let newValue = value as? String {
                        if(parseArray[2][0] == "PlusAssign") {
                            varArray[currentFunction][0][ident] = oldValue as! String + newValue
                        } else {
                            varArray[currentFunction][0][ident] = value
                        }
                    }else if let newValue = value as? Int {
                        if(parseArray[2][0] == "PlusAssign") {
                            varArray[currentFunction][0][ident] = oldValue as! Int + newValue
                        } else {
                            varArray[currentFunction][0][ident] = value
                        }
                    }
                }
                
                
 
            } else {
                Scanner.errorMsgs.append("Error: Variable not declared: \(ident)")
            }
        } else {
            Scanner.errorMsgs.append("Error: Variable not declared: \(ident)")
        }
    }
    
    
    static func handlePrint (_ parseArray: [[String]]) {
        
        var printValue = "" // ToDo: Datatype Any?
        if(parseArray[3][0] == "Ident") { // Print Variable
            let printIdent : String = parseArray[3][1] // ToDo: Print anything not just idents
            var isIn = false
            if(varArray.indices.contains(currentFunction)) {
                for variable in varArray[currentFunction][0] {
                    if(variable.key == printIdent) {
                        isIn = true
                        printValue = String(describing: variable.value)
                    }
                }
                if(!isIn) {
                    Scanner.errorMsgs.append("Error: Variable \(printIdent) is not declared.")
                }
            } else {
                Scanner.errorMsgs.append("Error: Variable \(printIdent) is not declared.")
            }
        } else { // Print String or Number
            printValue = parseArray[3][1]
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
                            print("Default (CodeGenerator)") // ToDo: Functioncall in other Function
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
    
    
    // ToDo: Only 1 (cond1) or 2 conditions (cond1 && or || cond2) possible right now
    static func handleLoopOrCondition(_ parseArray: [[String]]) {
        var newParseArray = parseArray
        
        // get conditions (eq, neq...)
        let type = newParseArray[1][1] // "if" or "while"
        var args = [newParseArray[3], newParseArray[5]]
        var operators = [newParseArray[4][0]] // "Eq", "Neq", "Lt", "Gt", "Leq" or "Geq"
        var conjunction = [String]() // "And" or "Or"

        for _ in 0..<6 {
            newParseArray.remove(at: 0)
        }
        
        // check if more than 1 condition (eq, neq...) and if yes get them, too.
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
        newParseArray.remove(at: 0) // deletes close bracket and open curly, so only Inner-LoopOrCondition remains. Used in handleInnerLoopOrCondition.

    
        // check if condition(s) is/are true and call handleInnerLoopOrCondition if true.
        if(Scanner.errorMsgs.isEmpty) {
            var bool = false
            if(type == "if") {
                var argsValues = [Any]()
                
                // Check type of Arguments. If Argument is a Ident (Variable) get value.
                for arg in args {
                    if(arg[0] == "Ident") {
                        var varIsDeclared = false
                        if(varArray.indices.contains(currentFunction)) {
                            for (key, value) in varArray[currentFunction][0] { // ToDo: Current Scope
                                if(key == arg[1]){
                                    varIsDeclared = true
                                    argsValues.append(value)
                                }
                            }
                            if(!varIsDeclared) {
                                Scanner.errorMsgs.append("Error: Variable \(arg[1]) is not declared")
                            }
                        } else {
                            Scanner.errorMsgs.append("Error: Variable \(arg[1]) is not declared")
                        }
                    } else {
                        if(arg[0] == "Number") {
                            argsValues.append(Int(arg[1])!) // save Number as Int
                            print("save Number as Int")
                        } else if(arg[0] == "String") {
                            argsValues.append(String(arg[1])!) // save String as String
                            print("save String as String")
                        } else {
                            argsValues.append(arg[1])
                        }
                    }
                }
                
                // handle Condition and execute actions if true
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
                if(bool) {
                    handleInnerLoopOrCondition(newParseArray)
                }
            } else if(type == "while") {
                bool = true
                var countLoops = 0
                while(Scanner.errorMsgs.isEmpty && bool) {
                    var argsValues = [Any]()

                    // Check type of Arguments. If Argument is a Ident (Variable) get value.
                    for arg in args {
                        if(arg[0] == "Ident") {
                            var varIsDeclared = false
                            if(varArray.indices.contains(currentFunction)) {
                                for (key, value) in varArray[currentFunction][0] { // ToDo: Current Scope
                                    if(key == arg[1]){
                                        varIsDeclared = true
                                        argsValues.append(value)
                                    }
                                }
                                if(!varIsDeclared) {
                                    Scanner.errorMsgs.append("Error: Variable \(arg[1]) is not declared")
                                }
                            } else {
                                Scanner.errorMsgs.append("Error: Variable \(arg[1]) is not declared")
                            }
                        } else {
                            if(arg[0] == "Number") {
                                argsValues.append(Int(arg[1])!) // save Number as Int
                                print("save Number as Int")
                            } else if(arg[0] == "String") {
                                argsValues.append(String(arg[1])!) // save String as String
                                print("save String as String")
                            } else {
                                argsValues.append(arg[1])
                            }
                        }
                    }
                    
                    // handle Condition and execute actions if true
                    bool = false
                    countLoops += 1
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
                    if(Scanner.errorMsgs.isEmpty && bool && countLoops < 10) {
                        handleInnerLoopOrCondition(newParseArray)
                    } else {
                        break
                    }
                }
            }
        }
    }
    
    
    // handles different conditions in LoopOrCondition. Returns true if condition is true.
    static func handleCondition(op: String, argValue1: Any, argValue2: Any) -> Bool {
        var bool = false
        
        if let newArgValue1 = argValue1 as? String {
            if let newArgValue2 = argValue2 as? String {
                print("String Condition")
                if(op == "Eq") {
                    if(newArgValue1 == newArgValue2) {
                        bool = true
                    }
                } else if(op == "Neq") {
                    if(newArgValue1 != newArgValue2) {
                        bool = true
                    }
                } else if(op == "Lt") {
                    if(newArgValue1 < newArgValue2) {
                        bool = true
                    }
                }
            } else {
                Scanner.errorMsgs.append("Error: Only variables of same type comparable.")
            }
        } else if let newArgValue1 = argValue1 as? Int {
            if let newArgValue2 = argValue2 as? Int {
                print("Int Condition: \(newArgValue1) \(op) \(newArgValue2)")
                if(op == "Eq") {
                    if(newArgValue1 == newArgValue2) {
                        bool = true
                    }
                } else if(op == "Neq") {
                    if(newArgValue1 != newArgValue2) {
                        bool = true
                    }
                } else if(op == "Lt") {
                    if(newArgValue1 < newArgValue2) {
                        bool = true
                    }
                }
            } else {
                Scanner.errorMsgs.append("Error: Only variables of same type comparable.")
            }
        } else {
            Scanner.errorMsgs.append("Error: Unknown types in Loop.")
        }
        
        return bool
    }
    
    
    // Called by LoopOrCondition if condition is true. Handles actions defined in curly brackets.
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
                case "Assignment":
                    handleAssignment(newParseArray)
                    index = 5
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


class NoValue {
    var name = ""
    var datatype = ""
}

//
//  Parser.swift
//  JavaIDE
//
//  Created by Tobias Steinbrück on 05.02.17.
//  Copyright © 2017 Tobias Steinbrück. All rights reserved.
//

import Foundation


/// Possible types: Declaration, DeclarationAndAssignment, Assignment, Functioncall, Print(?), Condition(?), Loop(?), Function(?), (Class and Instantiation)
class Parser {
    
    static var parseArray = [[[String]]]()
    static var index = 0
    
    static func parseInput(_ scanArray : [[String]]) -> [[[String]]] {
        parseArray.removeAll()
        index = 0 // used in getType() to remove parsed input
        
        var newScanArray = getType(scanArray)
        
        while(!newScanArray.isEmpty) {
            newScanArray = getType(newScanArray)
        }
        
        return parseArray
    }
    
    
    /// get Type of a sequence, like declaration, functioncall etc. 
    /// types: Declaration, Assignment, DeclarationAssignment, Assignment, Functioncall, Printstatement, Function, Loop, Condition
    /// newParseArray is the parseArray without the first type (functioncall etc.)
    static func getType(_ input : [[String]]) -> [[String]] {
        var newScanArray = input
        var typeArray = [[String]]()
        if(!input.isEmpty) {
            var scanArray = input
        
            switch(scanArray[0][0]) {
            case "Datatype":
                typeArray = handleDeclaration(scanArray) // Missing e.g.: String i, j, k; Am besten mit Funktion falls Komma kommt: handleMultipleDeclarations (Array) -> ? ... Wandelt in besser verarbeitbaren Inhalt um. Beachte auch: int i, j = 5; --> int i = 5; int j = 5; Beachte auch: i += 1
            case "Ident":
                typeArray = handleAssignOrFunctioncall(scanArray)
            case "LoopOrCondition":
                typeArray = handleLoopOrCondition(scanArray)
            case "Print":
                typeArray = handlePrint(scanArray)
            default:
                typeArray = [[""]]
                index = 1
            }
        }
        //print (index)
        parseArray.append(typeArray)
        
        for _ in 0..<index {
            newScanArray.remove(at: 0)
        }
        
        return newScanArray
    }
    
    
    static func handleDeclaration(_ input : [[String]]) -> [[String]] {
        index = 0
        var typeArray = [[String]]()
        typeArray.append(["DeclarationError"])
        if(input[0][0] == "Datatype") {
            typeArray.append(input[0])
            index += 1
            
            if(input.indices.contains(1) && input[1][0] == "Ident") {
                typeArray.append(input[1])
                index += 1
                if(input.indices.contains(2)) {
                    if(input[2][0] == "Semicolon") {
                        typeArray.append(input[2])
                        index += 1
                        typeArray[0] = ["Declaration"]
                    } else if(input[2][0] == "Assign") {
                        typeArray.append(input[2])
                        index += 1
                        if(input.indices.contains(3) && (input[3][0] == "Ident" || input[3][0] == "Number" || input[3][0] == "String")) {
                            typeArray.append(input[3])
                            index += 1
                            if (input.indices.contains(4) && input[4][0] == "Semicolon") {
                                typeArray.append(input[4])
                                index += 1
                                typeArray[0] = ["DeclarationAndAssignment"]
                            } else {
                                Scanner.errorMsgs.append("Error: An semicolon is expected.")
                            }
                        } else {
                            Scanner.errorMsgs.append("Error: An identifier, number or string is expected after the equals sign.")
                        }
                    } else {
                        Scanner.errorMsgs.append("Error: An semicolon or equal-sign is expected after the identifier (varibale name).")
                    }
                } else {
                    Scanner.errorMsgs.append("Error: An semicolon or equal-sign is expected after the identifier (varibale name).")
                }
            } else {
                Scanner.errorMsgs.append("Error: An identifier (variable name) is expected after the datatype.")
            }
            
        }
        return typeArray
    }

    
    static func handleAssignOrFunctioncall(_ input : [[String]]) -> [[String]] {
        index = 0
        var typeArray = [[String]]()
        typeArray.append(["AssignOrFunctionError"])
        if(input[0][0] == "Ident") {
            typeArray.append(input[0])
            index += 1
            
            if(input.indices.contains(1)) {
                if(input[1][0] == "Assign") {
                    typeArray.append(input[1])
                    index += 1
                    if(input.indices.contains(2) && (input[2][0] == "Ident" || input[2][0] == "Number" || input[2][0] == "String")) {
                        typeArray.append(input[2])
                        index += 1
                        if (input.indices.contains(3) && input[3][0] == "Semicolon") {
                            typeArray.append(input[3])
                            index += 1
                            typeArray[0] = ["Assignment"]
                        } else {
                            Scanner.errorMsgs.append("Error: An semicolon is expected.")
                        }
                    } else {
                        Scanner.errorMsgs.append("Error: An identifier, number or string is expected after the equals sign.")
                    }
                } else if(input[1][0] == "OpenBracket") {
                    typeArray.append(input[1])
                    index += 1
                    if(input[2][0] == "CloseBracket") { // ToDo: Parameter before CloseBracket
                        typeArray.append(input[2])
                        index += 1
                        if(input[3][0] == "Semicolon") {
                            typeArray.append(input[3])
                            index += 1
                            typeArray[0] = ["Functioncall"]
                        } else {
                            Scanner.errorMsgs.append("Error: An semicolon is expected.")
                        }
                    } else {
                        Scanner.errorMsgs.append("Error: An close bracket is expected.")
                    }
                } else {
                    Scanner.errorMsgs.append("Error: An semicolon or a Bracket is expected after the identifier: \(input[0][1]).")
                }
            } else {
                Scanner.errorMsgs.append("Error: An semicolon or a Bracket is expected after the identifier.")
            }
            
        }
        return typeArray
    }
    
    
    static func handlePrint (_ input : [[String]]) -> [[String]] {
        index = 0
        var typeArray = [[String]]()
        typeArray.append(["PrintError"])
        if(input[0][0] == "Print") {
            typeArray.append(input[0])
            index += 1
            if(input.indices.contains(1) && input[1][0] == "OpenBracket"){
                typeArray.append(input[1])
                index += 1
                if(input.indices.contains(2)) {
                    if(input[2][0] == "Ident") {
                        typeArray.append(input[2])
                        index += 1
                        if(input[3][0] == "CloseBracket") {
                            typeArray.append(input[3])
                            index += 1
                            if(input[4][0] == "Semicolon") {
                                typeArray.append(input[4])
                                index += 1
                                typeArray[0] = ["Print"]
                            } else {
                                Scanner.errorMsgs.append("Error: An semicolon is expected after close bracket.")
                            }
                        } else {
                            Scanner.errorMsgs.append("Error: An close bracket is expected after \(input[2][1]).")
                        }
                    } else {
                        Scanner.errorMsgs.append("Error: Missing Argument after open bracket.")
                    }
                } else {
                    Scanner.errorMsgs.append("Error: Missing Argument after open bracket.")
                }
            } else {
                Scanner.errorMsgs.append("Error: An open bracket is expected after System.out.println.")
            }
            
        }
        return typeArray
    }
    
    
    static func handleLoopOrCondition(_ input : [[String]]) -> [[String]] {
        index = 0
        var newIndex = 0
        var newInput = input
        var typeArray = [[String]]()
        typeArray.append(["LoopOrConditionError"])
        if(input[0][0] == "LoopOrCondition") {
            typeArray.append(input[0])
            index += 1; newIndex += 1
            newInput.remove(at: 0)
            if(input.indices.contains(1) && input[1][0] == "OpenBracket") {
                typeArray.append(input[1])
                index += 1; newIndex += 1
                newInput.remove(at: 0)
                if(input.indices.contains(2) && input[2][0] == "CloseBracket") { // ToDo: Expression
                    typeArray.append(input[2])
                    index += 1; newIndex += 1
                    newInput.remove(at: 0)
                    if(input.indices.contains(3) && input[3][0] == "OpenCurly") {
                        typeArray.append(input[3])
                        index += 1; newIndex += 1
                        newInput.remove(at: 0)
                        while(newInput.indices.contains(0) && newInput[0][0] != "CloseCurly") {
                            switch(newInput[0][0]) {
                            case "Datatype":
                                typeArray += handleDeclaration(newInput)
                            case "Ident":
                                typeArray += handleAssignOrFunctioncall(newInput)
                            case "LoopOrCondition":
                                typeArray += handleInnerLoopOrCondition(newInput)
                            default:
                                typeArray = [[""]]
                                index += 1
                            }
                            for _ in 0..<index {
                                newInput.remove(at: 0)
                            }
                            newIndex += index
                            index = newIndex
                        }
                        if(newInput.indices.contains(0) && newInput[0][0] == "CloseCurly") {
                            typeArray.append(newInput[0])
                            index += 1; newIndex += 1
                            newInput.remove(at: 0)
                            typeArray[0] = ["LoopOrCondition"]
                        } else {
                            Scanner.errorMsgs.append("Error: Close Bracket is expected after: \(input[3][1]).")
                        }
                    } else {
                        Scanner.errorMsgs.append("Error: Open Bracket is expected after: \(input[2][1]).")
                    }
                } else {
                    Scanner.errorMsgs.append("Error: Close Bracket is expected after: \(input[1][1]).")
                }
            } else {
                Scanner.errorMsgs.append("Error: Open Bracket is expected after: \(input[0][1]).")
            }
        }
        return typeArray
    }
    
    static func handleInnerLoopOrCondition(_ input : [[String]]) -> [[String]] {
        var newInput = input
        var typeArray = [[String]]()
        
        
        return typeArray
    }
    
}



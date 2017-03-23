//
//  Parser.swift
//  JavaIDE
//
//  Created by Tobias Steinbrück on 05.02.17.
//  Copyright © 2017 Tobias Steinbrück. All rights reserved.
//

import Foundation


/// Possible types: Declaration, DeclarationAndAssignment, Assignment, Functioncall, FunctionHead, EndOfFunction, Print, Condition(?), Loop(?), (Class and Instantiation)
class Parser {
    
    static var parseArray = [[[[String]]]]() // global array
    static var functionParseArray = [[[String]]]() // function array, part of global array
    static var index = 0
    
    static func parseInput(_ scanArray : [[String]]) -> [[[[String]]]] {
        parseArray.removeAll()
        functionParseArray.removeAll()
        index = 0 // used e.g. in handleFunction() to remove parsed input
        
        var newScanArray = handleFunction(scanArray)
        
        while(!newScanArray.isEmpty && Scanner.errorMsgs.isEmpty) {
            newScanArray = handleFunction(newScanArray)
        }
        
        return parseArray
    }
    
    
    // ToDo: Save functionnames with arguments in extra object/array for OutputGenerator
    
    static func handleFunction(_ input : [[String]]) -> [[String]] {
        functionParseArray.removeAll()
        index = 0
        var newScanArray = input
        var typeArray = [[String]]()
        typeArray.append(["FunctionHeadError"])
        if(input.indices.contains(0) && input[0][0] == "Scope") {
            typeArray.append(input[0])
            index += 1
            if(input.indices.contains(1) && input[1][0] == "Static") {
                typeArray.append(input[1])
                index += 1
                if(input.indices.contains(2) && (input[2][0] == "Void" || input[2][0] == "Datatype")) {
                    typeArray.append(input[2])
                    index += 1
                    if(input.indices.contains(3) && input[3][0] == "Ident") {
                        typeArray.append(input[3])
                        index += 1
                        if(input[3][1] == "main"){
                            if(input.indices.contains(4) && input[4][0] == "OpenBracket") {
                                typeArray.append(input[4])
                                index += 1
                                if(input.indices.contains(5) && input[5][0] == "Datatype") {
                                    typeArray.append(input[5])
                                    index += 1
                                    if(input.indices.contains(6) && input[6][0] == "OpenSquare") {
                                        typeArray.append(input[6])
                                        index += 1
                                        if(input.indices.contains(7) && input[7][0] == "CloseSquare") {
                                            typeArray.append(input[7])
                                            index += 1
                                            if(input.indices.contains(8) && input[8][0] == "Ident") {
                                                typeArray.append(input[8])
                                                index += 1
                                                if(input.indices.contains(9) && input[9][0] == "CloseBracket") {
                                                    typeArray.append(input[9])
                                                    index += 1
                                                    if(input.indices.contains(10) && input[10][0] == "OpenCurly") {
                                                        typeArray.append(input[10])
                                                        index += 1
                                                        typeArray[0] = ["FunctionHead"]
                                                        functionParseArray.append(typeArray)
                                                        for _ in 0..<index {
                                                            newScanArray.remove(at: 0)
                                                        }
                                                        newScanArray = handleFunctionBody(newScanArray)
                                                        while(!newScanArray.isEmpty && newScanArray[0][0] != "CloseCurly") {
                                                            newScanArray = handleFunctionBody(newScanArray)
                                                        }
                                                        
                                                        index = 0
                                                        if(newScanArray.indices.contains(0) && newScanArray[0][0] == "CloseCurly") {
                                                            typeArray.append(newScanArray[0])
                                                            index += 1
                                                            typeArray[0] = ["Function"]
                                                            functionParseArray.append([["EndOfFunction"], ["CloseCurly", "}"]])
                                                            parseArray.append(functionParseArray)
                                                        } else {
                                                            Scanner.errorMsgs.append("Error: A closing curly bracket is expected in the end of the \(input[3][1]) - function.")
                                                        }

                                                        for _ in 0..<index {
                                                            newScanArray.remove(at: 0)
                                                        }
                                                    } else {
                                                        Scanner.errorMsgs.append("Error: A open curly bracket is expected in the declaration of \(input[3][1]) - method.")
                                                    }
                                                } else {
                                                    Scanner.errorMsgs.append("Error: A close bracket is expected after the argument of \(input[3][1]) - method.")
                                                }
                                            } else {
                                                Scanner.errorMsgs.append("Error: A variable name is expected in the argument of \(input[3][1]) - method.")
                                            }
                                        } else {
                                            Scanner.errorMsgs.append("Error: A String Array is expected in the argument of \(input[3][1]) - method.")
                                        }
                                    } else {
                                        Scanner.errorMsgs.append("Error: A String Array is expected in the argument of \(input[3][1]) - method.")
                                    }
                                } else {
                                    Scanner.errorMsgs.append("Error: A String Array is expected in the argument of \(input[3][1]) - method.")
                                }
                            } else {
                                Scanner.errorMsgs.append("Error: A open bracket is expected after the method name of \(input[3][1]) - method.")
                            }
                        } else {
                            // ToDo: wie oben aber ohne "String[] args" . Argument in extra Methode parsen, z.B.: (String i, int j).. mit index array weiterzählen also input[index][0] anstatt input[42][0]
                            if(input.indices.contains(4) && input[4][0] == "OpenBracket") {
                                typeArray.append(input[4])
                                index += 1
                                while(input.indices.contains(index) && input[index][0] != "CloseBracket" && Scanner.errorMsgs.isEmpty) {
                                    if(input.indices.contains(index) && input[index][0] == "Datatype") {
                                        typeArray.append(input[index])
                                        index += 1
                                        if(input.indices.contains(index) && input[index][0] == "Ident") {
                                            typeArray.append(input[index])
                                            index += 1
                                            if(input.indices.contains(index) && input[index][0] == "Comma") {
                                                typeArray.append(input[index])
                                                index += 1
                                            } else {
                                                break
                                            }
                                        } else {
                                            Scanner.errorMsgs.append("Error: A variable name is expected after the datatype in the argument of \(input[3][1]) - method.")
                                        }
                                    } else {
                                        Scanner.errorMsgs.append("Error: A datatype is expected in the argument of \(input[3][1]) - method.")
                                    }
                                }
                                

                                if(input.indices.contains(index) && input[index][0] == "CloseBracket") {
                                    typeArray.append(input[index])
                                    index += 1
                                    if(input.indices.contains(index) && input[index][0] == "OpenCurly") {
                                        typeArray.append(input[index])
                                        index += 1
                                        typeArray[0] = ["FunctionHead"]
                                        functionParseArray.append(typeArray)
                                        for _ in 0..<index {
                                            newScanArray.remove(at: 0)
                                        }
                                        newScanArray = handleFunctionBody(newScanArray)
                                        while(!newScanArray.isEmpty && newScanArray[0][0] != "CloseCurly") {
                                            newScanArray = handleFunctionBody(newScanArray)
                                        }
                                        
                                        index = 0
                                        if(newScanArray.indices.contains(0) && newScanArray[0][0] == "CloseCurly") {
                                            typeArray.append(newScanArray[0])
                                            index += 1
                                            typeArray[0] = ["Function"]
                                            functionParseArray.append([["EndOfFunction"], ["CloseCurly", "}"]])
                                            parseArray.append(functionParseArray)
                                        } else {
                                            Scanner.errorMsgs.append("Error: A closing curly bracket is expected in the end of the \(input[3][1]) - method.")
                                        }
                                        
                                        for _ in 0..<index {
                                            newScanArray.remove(at: 0)
                                        }
                                    } else {
                                        Scanner.errorMsgs.append("Error: A open curly bracket is expected in the declaration of \(input[3][1]) - method.")
                                    }
                                } else {
                                    Scanner.errorMsgs.append("Error: A close bracket is expected after the argument of \(input[3][1]) - method.")
                                }
                            } else {
                                Scanner.errorMsgs.append("Error: A open bracket is expected after the function name of \(input[3][1]) - method.")
                            }
                        } // end of else
                    } else {
                        Scanner.errorMsgs.append("Error: A method name is expected after \(input[2][1]).")
                    }
                } else {
                    Scanner.errorMsgs.append("Error: A datatype or 'void' is expected after \(input[1][1]).")
                }
            } else {
                Scanner.errorMsgs.append("Error: The word 'static' is expected after \(input[0][1]).")
            }
        } else {
            Scanner.errorMsgs.append("Error: A Scope is expected.") // Should not happen.
        }
    
        return newScanArray
    }
    
    
    /// get Type of a sequence, like declaration, functioncall etc. 
    /// types: Declaration, Assignment, DeclarationAssignment, Assignment, Functioncall, Printstatement, Function, Loop, Condition
    /// newParseArray is the parseArray without the first type (functioncall etc.)
    static func handleFunctionBody(_ input : [[String]]) -> [[String]] {
        index = 0
        var newScanArray = input
        var typeArray = [[String]]()
        if(!input.isEmpty) {
            var scanArray = input
        
            switch(scanArray[0][0]) {
            case "Scope":
                typeArray = handleFunction(scanArray)
            case "Datatype":
                typeArray = handleDeclaration(scanArray) // Missing e.g.: String i, j, k; Am besten mit Funktion falls Komma kommt: handleMultipleDeclarations (Array) -> ? ... Wandelt in besser verarbeitbaren Inhalt um. Beachte auch: int i, j = 5; --> int i = 5; int j = 5; Beachte auch: i += 1
            case "Ident":
                typeArray = handleAssignOrFunctioncall(scanArray)
            case "Print":
                typeArray = handlePrint(scanArray)
            case "LoopOrCondition":
                typeArray = handleLoopOrCondition(scanArray)
            default:
                typeArray = [[""]]
                index = 1
            }
        }
        //print (index)
        functionParseArray.append(typeArray)
        
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
                                Scanner.errorMsgs.append("Error: A semicolon is expected.")
                            }
                        } else {
                            Scanner.errorMsgs.append("Error: An identifier, number or string is expected after the equals sign.")
                        }
                    } else {
                        Scanner.errorMsgs.append("Error: A semicolon or equal-sign is expected after the identifier: \(input[1][1]).")
                    }
                } else {
                    Scanner.errorMsgs.append("Error: A semicolon or equal-sign is expected after the identifier: \(input[1][1]).")
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
                            Scanner.errorMsgs.append("Error: A semicolon is expected.")
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
                            Scanner.errorMsgs.append("Error: A semicolon is expected.")
                        }
                    } else {
                        Scanner.errorMsgs.append("Error: A close bracket is expected.")
                    }
                } else {
                    Scanner.errorMsgs.append("Error: A semicolon or a Bracket is expected after the identifier: \(input[0][1]).")
                }
            } else {
                Scanner.errorMsgs.append("Error: A semicolon or a Bracket is expected after the identifier.")
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
                    if(input[2][0] == "Ident") { // ToDo: More options possible
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
                                Scanner.errorMsgs.append("Error: A semicolon is expected after close bracket.")
                            }
                        } else {
                            Scanner.errorMsgs.append("Error: A close bracket is expected after \(input[2][1]).")
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
    
    
    // Beachte das zwischen CurlyKlammern wieder types stehen. Daher Rekursion/Schleife. In Array z.B.: ...,["OpenCurly", "{"], ["DeclarationAndAssignment"], ["Datatype", "String"],...
    // ToDo: handle InnerLoopOrCondition
    // ToDo: ELSE
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
            if(input.indices.contains(1) && input[1][0] == "OpenBracket") { // ToDo: check if "for-loop", because it works different
                typeArray.append(input[1])
                index += 1; newIndex += 1
                newInput.remove(at: 0)
                if(input.indices.contains(index) && (input[index][0] == "Ident" || input[index][0] == "Number")) { // ToDo: String!
                    typeArray.append(input[index])
                    index += 1; newIndex += 1
                    newInput.remove(at: 0)
                    if(input.indices.contains(index) && (input[index][0] == "Eq" || input[index][0] == "Neq" || input[index][0] == "Lt" || input[index][0] == "Gt" || input[index][0] == "Leq" || input[index][0] == "Geq")) {
                        typeArray.append(input[index])
                        index += 1; newIndex += 1
                        newInput.remove(at: 0)
                        if(input.indices.contains(index) && (input[index][0] == "Ident" || input[index][0] == "Number")) {
                            typeArray.append(input[index])
                            index += 1; newIndex += 1
                            newInput.remove(at: 0)
                            
                            while(input.indices.contains(index) && input[index][0] != "CloseBracket") { // Parse Multiple Conditions
                                if(input.indices.contains(index) && (input[index][0] == "And" || input[index][0] == "Or")) {
                                    typeArray.append(input[index])
                                    index += 1; newIndex += 1
                                    newInput.remove(at: 0)
                                    if(input.indices.contains(index) && (input[index][0] == "Ident" || input[index][0] == "Number")) {
                                        typeArray.append(input[index])
                                        index += 1; newIndex += 1
                                        newInput.remove(at: 0)
                                        if(input.indices.contains(index) && (input[index][0] == "Eq" || input[index][0] == "Neq" || input[index][0] == "Lt" || input[index][0] == "Gt" || input[index][0] == "Leq" || input[index][0] == "Geq")) {
                                            typeArray.append(input[index])
                                            index += 1; newIndex += 1
                                            newInput.remove(at: 0)
                                            if(input.indices.contains(index) && (input[index][0] == "Ident" || input[index][0] == "Number")) {
                                                typeArray.append(input[index])
                                                index += 1; newIndex += 1
                                                newInput.remove(at: 0)
                                            } else {
                                                Scanner.errorMsgs.append("Error: A ident or number is expected after: \(input[index-1][1]) in the \(input[0][1]) - expression/loop.")
                                            }
                                        } else {
                                            Scanner.errorMsgs.append("Error: A comparison operator is expected after: \(input[index-1][1]) in the \(input[0][1]) - expression/loop.")
                                        }
                                    } else {
                                        Scanner.errorMsgs.append("Error: A ident or number is expected after: \(input[index-1][1]) in the \(input[0][1]) - expression/loop.")
                                    }
                                } else {
                                    Scanner.errorMsgs.append("Error: A '&&' or '||' is expected after: \(input[index-1][1]) in the \(input[0][1]) - expression/loop.")
                                    break
                                }
                            }
                            if(Scanner.errorMsgs.isEmpty) {
                                if(input.indices.contains(index) && input[index][0] == "CloseBracket") {
                                    typeArray.append(input[index])
                                    index += 1; newIndex += 1
                                    newInput.remove(at: 0)
                                    if(input.indices.contains(index) && input[index][0] == "OpenCurly") {
                                        typeArray.append(input[index])
                                        index += 1; newIndex += 1
                                        newInput.remove(at: 0)
                                        while(newInput.indices.contains(0) && newInput[0][0] != "CloseCurly" && Scanner.errorMsgs.isEmpty) {
                                            switch(newInput[0][0]) {
                                            case "Scope":
                                                typeArray += handleFunction(newInput)
                                            case "Datatype":
                                                typeArray += handleDeclaration(newInput)
                                            case "Ident":
                                                typeArray += handleAssignOrFunctioncall(newInput)
                                            case "Print":
                                                typeArray += handlePrint(newInput)
                                            case "LoopOrCondition":
                                                typeArray += handleInnerLoopOrCondition(newInput)
                                            default:
                                                typeArray += [[""]]
                                                index = 1
                                                Scanner.errorMsgs.append("Error: \(newInput[0][1]) is not known.")
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
                                            typeArray[0] = ["LoopOrCondition"] // ToDo: handle else
                                        } else {
                                            Scanner.errorMsgs.append("Error: Close curly bracket is expected after the \(input[0][1]) - expression/loop.")
                                        }
                                    } else {
                                        Scanner.errorMsgs.append("Error: Open curly bracket is expected after: \(input[index-1][1]) in the \(input[0][1]) - expression/loop.")
                                    }
                                } else {
                                    Scanner.errorMsgs.append("Error: Close bracket is expected after: \(input[index-1][1]) in the \(input[0][1]) - expression/loop.")
                                }
                            }
                        } else {
                            Scanner.errorMsgs.append("Error: A ident or number is expected after: \(input[index-1][1]) in the \(input[0][1]) - expression/loop.")
                        }
                    } else {
                        Scanner.errorMsgs.append("Error: A comparison operator is expected after: \(input[index-1][1]) in the \(input[0][1]) - expression/loop.")
                    }
                } else {
                    Scanner.errorMsgs.append("Error: A ident or number is expected after: \(input[index-1][1]) in the \(input[0][1]) - expression/loop.")
                }
            } else {
                Scanner.errorMsgs.append("Error: Open bracket is expected after: \(input[index-1][1]) in the \(input[0][1]) - expression/loop.")
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



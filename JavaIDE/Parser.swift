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
        index = 0
        
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
                typeArray = handleDeclaration(scanArray) // Missing e.g.: String i, j, k; Am besten mit Funktion falls Komma kommt: handleMultipleDeclarations (Array) -> ? ... Wandelt in besser verarbeitbaren Inhalt um. Beachte auch: int i, j = 5; --> int i = 5; int j = 5;
            case "Ident":
                typeArray = handleAssignOrFunctioncall(scanArray)
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
                                print("Error: An semicolon is expected.")
                            }
                        } else {
                            print("Error: An identifier, number or string is expected after the equals sign.")
                        }
                    } else {
                        print("Error: An semicolon or equal-sign is expected after the identifier (varibale name).")
                    }
                } else {
                    print("Error: An semicolon or equal-sign is expected after the identifier (varibale name).")
                }
            } else {
                print("Error: An identifier (variable name) is expected after the datatype.")
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
                            print("Error: An semicolon is expected.")
                        }
                    } else {
                        print("Error: An identifier, number or string is expected after the equals sign.")
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
                            print("Error: An semicolon is expected.")
                        }
                    } else {
                        print("Error: An close bracket is expected.")
                    }
                } else {
                    print("Error: An semicolon or a Bracket is expected after the identifier.")
                }
            } else {
                print("Error: An semicolon or a Bracket is expected after the identifier.")
            }
            
        }
        return typeArray
    }
        
        
}

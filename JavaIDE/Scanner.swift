//
//  Scanner.swift
//  JavaIDE
//
//  Created by Tobias Steinbrück on 31.10.16.
//  Copyright © 2016 Tobias Steinbrück. All rights reserved.
//

import Foundation

/// Possible types: String, Number, Datatype, LoopOrCondition, Else, Scope, Static, Void, Print, Ident, OpenBracket, CloseBracket, OpenCurly, CloseCurly, OpenSquare, CloseSquare, Semicolon, Comma
/// Assign, PlusAssign, Eq, Neq, Lt, Gt, Leq, Geq, Minus, Plus,  Multi, Div, And, Or, (Dot), (Default) Missing: Boolean (true, false), Switch, break
class Scanner {
    
    static var errorMsgs = [String]()
    
    /// [][0] : type, [][1] : value
    static var scanArray = [[String]]()
    
    static let javaDatatypes : [String] = ["String", "int", "double"]
    static let javaLoopsOrConditions : [String] = ["while", "if"] // ToDo: Switch, for
    static let javaScopes : [String] = ["private", "public", "protected"]
    
    static var currentChar = 0
    
    /// [][0] : Position, [][1] : Length
    static var errorInfos = [[Int]]()
        
    static func scanInput(_ input : String) -> [[String]] {
        currentChar = 0
        errorInfos.removeAll()
        scanArray.removeAll()
        var oldInput = input // needed to count whitespaces/newlines for underlining errors
        var newInput = trimLeadingWhitespaces(input)
        currentChar += oldInput.characters.count - newInput.characters.count
        oldInput = newInput
        
        var word = getNextWord(newInput)
        
        while(newInput.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) != word && errorMsgs.isEmpty) { //if newInput (rest of string) == word then the word is the last one.
            let index = newInput.index(newInput.startIndex, offsetBy: word.characters.count)
            oldInput = newInput.substring(from: index)
            newInput = trimLeadingWhitespaces(oldInput)
            currentChar += oldInput.characters.count - newInput.characters.count
            oldInput = newInput
            word = getNextWord(newInput)
            //print(word)
        }
        
        return scanArray
    }
    
    
    static func getNextWord(_ input : String) -> String {
        var type = ""
        var word = ""
        var inputCharacters = Array(input.characters)
        if(inputCharacters.indices.contains(0)) {
            switch inputCharacters[0] {
            case "\"":
                type = "String"
                word = handleString(input)
            case "0"..."9", "-", "+", ".":
                word = handleNumberOrOperator(input)
                if(word == "-") {
                    type = "Minus"
                } else if(word == "+"){
                    type = "Plus"
                } else if(word == "+="){
                    type = "PlusAssign"
                } else if(word == "."){
                    type = "Error"
                    errorMsgs.append("Error: '.' is not valid here.")
                } else {
                    type = "Number"
                }
            case "a"..."z", "A"..."Z":
                word = handleWord(input)
                if (javaDatatypes.contains(word)) {
                    type = "Datatype"
                } else if (javaLoopsOrConditions.contains(word)) {
                    type = "LoopOrCondition"
                } else if (javaScopes.contains(word)) {
                    type = "Scope"
                } else if (word == "static") {
                    type = "Static"
                } else if (word == "void") {
                    type = "Void"
                } else if (word == "System.out.println") {
                    type = "Print"
                } else if (word == "else") {
                    type = "Else"
                } else {
                    type = "Ident"
                }
            case "*":
                word = String(inputCharacters[0])
                type = "Multi"
            case "/":
                word = String(inputCharacters[0])
                type = "Div"
            case "(":
                word = String(inputCharacters[0])
                type = "OpenBracket"
            case ")":
                word = String(inputCharacters[0])
                type = "CloseBracket"
            case "{":
                word = String(inputCharacters[0])
                type = "OpenCurly"
            case "}":
                word = String(inputCharacters[0])
                type = "CloseCurly"
            case "[":
                word = String(inputCharacters[0])
                type = "OpenSquare"
            case "]":
                word = String(inputCharacters[0])
                type = "CloseSquare"
            case ";":
                word = String(inputCharacters[0])
                type = "Semicolon"
            case ",":
                word = String(inputCharacters[0])
                type = "Comma"
            case "=", "!":
                word = handleAssignOrCompare(input)
                if(word == "=") {
                    type = "Assign"
                } else if(word == "!="){
                    type = "Neq"
                } else {
                    type = "Eq"
                }
            case "<", ">":
                word = handleCompare(input)
                if(word == "<") {
                    type = "Lt"
                } else if(word == ">") {
                    type = "Gt"
                } else if(word == ">=") {
                    type = "Geq"
                } else {
                    type = "Leq"
                }
            case "&", "|":
                word = handleAndOr(input)
                if(word == "&&") {
                    type = "And"
                } else if(word == "||") {
                    type = "Or"
                } else {
                    type = "Error"
                    errorMsgs.append("Error: \(word) is not valid.")
                    errorInfos += [[currentChar, word.characters.count]]
                }
            default:
                type = "Error"
                errorMsgs.append("Error: Invalid identifier \(inputCharacters[0])")
                errorInfos += [[currentChar, 1]]
            }
            
            scanArray.append([type, word])
            if(type == "String") {
                word = "\"" + word + "\"" // for ScanInput method, to compare word with rest input correctly.
            }
            currentChar += word.characters.count
            print("\(word): \(currentChar)")
        } else {
                errorMsgs.append("Error: No input.")
            }
        return word
    }
    
    
    static func handleString (_ input : String) -> String {
        var word = ""
        var stringIsValid = false
        //word.append("\"")
        var positionOfSlash = -2 // dazu da, um \" zu erkennen. Problem bei \\" erkennt es ebenfalls \", obwohl hierbei das Backslash maskiert wird.
        for (index, element) in input.characters.enumerated() {
            if(index != 0) {
                if(element != "\"") {
                    if(element == "\\") {
                        positionOfSlash = index
                    }
                    word.append(element)
                } else {
                    if(positionOfSlash == index-1) {
                        word.append(element)
                    } else {
                        stringIsValid = true
                        break
                    }
                }
            }
        }
        if(!stringIsValid) {
            errorMsgs.append("Error: End of String is expected.")
        }
        return word
    }
    
    
    static func handleNumberOrOperator (_ input : String) -> String {
        var word = ""
        var inputString = input
        var inputCharacters = Array(inputString.characters)
        if(inputCharacters[0] == "+") {
            word.append(inputCharacters[0])
            inputString.remove(at: inputString.startIndex)
            if(inputCharacters[1] == "=") { // now 0, before it was [1]!
                word.append(inputCharacters[1])
                inputString.remove(at: inputString.startIndex)
                return word
            }
        } else if(inputCharacters[0] == "-") {
            word.append(inputCharacters[0])
            inputString.remove(at: inputString.startIndex)
        }
        var dotUsed = 0
        for (_, element) in input.characters.enumerated() {
            if(element >= "0" && element <= "9" && dotUsed <= 1) {
                word.append(element)
            } else if(element == "." && dotUsed == 0) {
                word.append(element)
                dotUsed += 1
            } else {
                break
            }
        }
        
        return word
    }
    
    
    static func handleWord (_ input : String) -> String {
        var word = ""
        
        var dotUsed = -2
        
        for (index, element) in input.characters.enumerated() {
            if((element >= "a" && element <= "z") || (element >= "A" && element <= "Z") || (element >= "0" && element <= "9") || element == "_") {
                word.append(element)
            } else if(element == "." && dotUsed != index-1 && (word == "System" || word == "System.out")) {
                word.append(element)
                dotUsed = index
            } else {
                if(element != " " && element != "=" && element != "," && element != ";" && element != "(" && element != ")" && element != "[" && element != "]") {
                    errorMsgs.append("Error: Invalid identifier \(element)")
                    errorInfos += [[currentChar+index, 1]]
                }
                if(dotUsed == index-1) {
                    errorMsgs.append("Error: '.' is not valid here.")
                    errorInfos += [[currentChar+index],[1]]
                }
                break
            }
        }
        
        return word
    }
    
    
    static func handleAssignOrCompare(_ input : String) -> String {
        var word = ""
        
        for (index, element) in input.characters.enumerated() {
            if(index<=1) {
                if(index == 0) {
                    word.append(element)
                } else {
                    if(element == "=") {
                        word.append(element)
                    } else {
                        break
                    }
                }
            } else {
                break
            }
        }
        
        return word
    }
    
    
    static func handleCompare(_ input : String) -> String {
        var word = ""
        
        for (index, element) in input.characters.enumerated() {
            if(index == 0) {
                word.append(element)
            } else if(index == 1) {
                if(element == "=") {
                    word.append(element)
                } else {
                    break
                }
            } else {
                break
            }
        }
        
        return word
    }

    
    static func handleAndOr(_ input : String) -> String {
        var word = ""
        
        for (index, element) in input.characters.enumerated() {
            if(index == 0) {
                word.append(element)
            } else if(index == 1) {
                if(element == "&" || element == "|") {
                    word.append(element)
                } else {
                    break
                }
            } else {
                break
            }
        }
        
        return word
    }
    
    
    static func trimLeadingWhitespaces(_ input: String) -> String {
        let newInput = input
        var countedWS = 0
        for element in input.characters {
            if(element == " " || element == "\n") {
                countedWS += 1
            } else {
                break
            }
        }
        let index = newInput.index(newInput.startIndex, offsetBy: countedWS)
        return newInput.substring(from: index)
    }
    
}

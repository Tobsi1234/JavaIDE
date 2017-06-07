//
//  Scanner.swift
//  JavaIDE
//
//  Created by Tobias Steinbrück on 31.10.16.
//  Copyright © 2016 Tobias Steinbrück. All rights reserved.
//

import Foundation

/// Possible types: String, Number, Datatype, LoopOrCondition, Else, Scope, Static, Void, Print, Ident, OpenBracket, CloseBracket, OpenCurly, CloseCurly, OpenSquare, CloseSquare, Semicolon, Comma, Assign, PlusAssign, Eq, Neq, Lt, Gt, Leq, Geq, Minus, Plus, Multi, Div, And, Or Missing: Boolean, true, false, break
class Scanner {
    
    //MARK: Properties
    
    static var errorMsgs = [String]()
    
    /// Global Scan Array
    /// Format: [][0] : type, [][1] : value
    static var scanArray = [[String]]()
    
    static let javaDatatypes : [String] = ["String", "int", "double"]
    static let javaLoopsOrConditions : [String] = ["while", "if"] // ToDo: Switch, for
    static let javaScopes : [String] = ["private", "public", "protected"]
    
    static var currentChar = 0
    
    /// Array that provides information about errors (Scanner-Errors)
    /// Format: [][0] : Position, [][1] : Length
    static var errorInfos = [[Int]]()
    
    //MARK: Functions
    
    /// main scanner method, called by EditorViewController when Run button is pressed. Returns global scanArray which is filled in getNextWord with tokens.
    static func scanInput(_ input : String) -> [[String]] {
        currentChar = 0
        errorInfos.removeAll()
        scanArray.removeAll()
        var oldInput = input // needed to count whitespaces/newlines for underlining errors
        var newInput = trimLeadingWhitespaces(input)
        currentChar += oldInput.characters.count - newInput.characters.count
        oldInput = newInput
        
        var word = getNextWord(newInput)
        
        // deletes next token out of input Array and calls getNextWord method with new Array as long as Array is not empty,
        while(newInput.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) != word && errorMsgs.isEmpty) { //if newInput (rest of string) == word then the word is the last one.
            let index = newInput.index(newInput.startIndex, offsetBy: word.characters.count)
            oldInput = newInput.substring(from: index)
            newInput = trimLeadingWhitespaces(oldInput)
            currentChar += oldInput.characters.count - newInput.characters.count
            oldInput = newInput
            word = getNextWord(newInput)
        }
        
        return scanArray
    }
    
    /// called by scanInput (main scanner method) and returns the next token of input.
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
    
    /// called by getNextWord method if next token seems to be a string. Returns the String.
    static func handleString (_ input : String) -> String {
        var word = ""
        var stringIsValid = false
        var positionOfSlash = -2 // position of backslash to detect masked quotation marks
        for (index, element) in input.characters.enumerated() {
            if(index != 0) {
                if(element != "\"") {
                    if(element == "\\" && positionOfSlash != index-1) { // if last index also have a backslash it would be a masked backslash
                        positionOfSlash = index
                    }
                    word.append(element)
                } else {
                    if(positionOfSlash == index-1) {
                        word.append(element) // masked quotation marks
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
    
    /// called by getNextWord method if next token seems to be a number or operator (+,-,.,0..9). Returns the token as String.
    static func handleNumberOrOperator (_ input : String) -> String {
        var word = ""
        var inputString = input
        var inputCharacters = Array(inputString.characters)
        if(inputCharacters[0] == "+") {
            word.append(inputCharacters[0])
            inputString.remove(at: inputString.startIndex)
            if(inputCharacters[1] == "=") {
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
    
    /// called by getNextWord method if next token seems to be a word (variable, datatype, if, loop etc.). Returns the token as String.
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
    
    /// called by getNextWord method if next token seems to be a assign or compare operator (=,!=,==). Returns the token as String.
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
    
    /// called by getNextWord method if next token seems to be a assign or compare operator (=,!=,==). Returns the token as String.
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

    /// called by getNextWord method if next token seems to be a And or Or (&&,||). Returns the token as String.
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
    
    /// called by scanInput (main scanner method) and returns the input String without leading whitespaces
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

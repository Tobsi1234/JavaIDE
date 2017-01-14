//
//  Scanner.swift
//  JavaIDE
//
//  Created by Tobias Steinbrück on 31.10.16.
//  Copyright © 2016 Tobias Steinbrück. All rights reserved.
//

import Foundation

class Scanner {
    
    static var scanArray = [[String]]()
    
    
    static func scanInput(_ input : String) -> [[String]] {
        scanArray.removeAll()
        var word = getNextWord(input)
        var newInput = input
        
        while(newInput.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) != word) { //wenn newInput (also Rest-String) == word dann ist word wohl das letzte.
            let index = newInput.index(newInput.startIndex, offsetBy: word.characters.count)
            newInput = newInput.substring(from: index).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            word = getNextWord(newInput)
            //print(word)
        }
        
        return scanArray
    }
    
    
    static func getNextWord(_ input : String) -> String {
        var type = ""
        var word = ""
        let javaDatatypes : [String] = ["String", "int", "double"]
        let javaLoopsOrConditions : [String] = ["for", "while", "if", "else", "switch"]
        let javaScopes : [String] = ["private", "public", "protected"]
        var inputCharacters = Array(input.characters)
        switch inputCharacters[0] {
        case "\"":
            type = "String"
            word = handleString(input)
        //print("String : " + word)
        case "0"..."9", "-", "+":
            type = "Number"
            word = handleNumber(input)
        //print("Zahl : " + word)
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
            } else if (word == "System.out.println") {
                type = "Print"
                //word = handlePrint(input)
            } else {
                type = "Ident"
            }
            
        //print("ident oder Schlüsselwort")
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
        case ";":
            word = String(inputCharacters[0])
            type = "Semicolon"
            
        case "=", "<" :
             //word = handleAssignOrCompare(input)
             //print("assign")
            word = String(inputCharacters[0])
            type = "Assign" // for now!
            
        default:
            type = "Default"
            for i in input.characters {
                if(i != " ") {
                    word.append(i)
                } else {
                    break
                }
            }
        }
        
        scanArray.append([type, word])
        if(type == "String") {
            word = "\"" + word + "\"" // for ScanInput method, to compare word with rest input correctly
        }
        return word
    }
    
    
    static func handleString (_ input : String) -> String {
        var word = ""
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
                        //word.append("\"")
                        break
                    }
                }
            }
        }
        
        
        return word
    }
    
    
    static func handleNumber (_ input : String) -> String {
        var word = ""
        var inputString = input
        var inputCharacters = Array(inputString.characters)
        if( inputCharacters[0] == "+" || inputCharacters[0] == "-") {
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
                if(element != " " && element != "=" && element != "," && element != ";" && element != "(") {
                    print("Error: Invalid identifier")
                }
                break
            }
        }
        
        return word
    }
    
    /*
     static func handlePrint (_ input : String) -> String {
     var word = ""
     
     var inputString = input
     
     let index = inputString.index(inputString.startIndex, offsetBy: 19)
     inputString = inputString.substring(from: index)
     
     // hier: Switch statement (String, +, Variable etc.)
     for (_, element) in inputString.characters.enumerated() {
     if(element != ")") {
     word.append(element)
     }
     else {
     break
     }
     }
     word = "System.out.println(" + word + ")"
     print (word)
     return word
     }
     */
    
}

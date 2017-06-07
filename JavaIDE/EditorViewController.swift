//
//  FirstViewController.swift
//  JavaIDE
//
//  Created by Tobias Steinbrück on 23.10.16.
//  Copyright © 2016 Tobias Steinbrück. All rights reserved.
//

import UIKit
import os.log

class EditorViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    //MARK: Properties
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var resultTextView: UITextView!
    @IBOutlet weak var titleTextField: UITextField!
    var oldTitle = ""

    
    /*
     This value is either passed by `JavaClassTableViewController` in `prepare(for:sender:)`
     or constructed as part of adding a new java class.
     */
    var javaClass: JavaClass?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field’s user input through delegate callbacks.
        self.inputTextView.delegate = self
        self.titleTextField.delegate = self
        
        // Set up views if editing an existing JavaClass.
        if let javaClass = javaClass {
            titleTextField.text = javaClass.name
            inputTextView.text = javaClass.content
            oldTitle = javaClass.name
        }
        
        //self.inputTextView.font = UIFont(name: (self.inputTextView.font?.fontName)!, size: 16)
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(EditorViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // Adds a border to the UITextView
        self.inputTextView.layer.borderWidth = 0.4
        self.inputTextView.layer.borderColor = UIColor.black.cgColor
        
        // Adds a border to the UITextView
        self.resultTextView.layer.borderWidth = 0.4
        self.resultTextView.layer.borderColor = UIColor.black.cgColor
        
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.titleTextField.resignFirstResponder() // dismiss keyboard of titleTextField
        // save new title if title changed
        if(oldTitle != titleTextField.text && titleTextField.text != "") {
            var classes = [String:JavaClass]()
            
            // Load any saved classes, delete old class, add the class with new name to the array and save it.
            if let savedClasses = loadJavaClasses() {
                classes = savedClasses
            }

            if let javaClass = classes[oldTitle] {
                javaClass.name = titleTextField.text!
                classes[titleTextField.text!] = javaClass
                classes.removeValue(forKey: oldTitle)
            }
            
            let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(classes, toFile: JavaClass.ArchiveURL.path)
            if isSuccessfulSave {
                os_log("Java Classes successfully saved.", log: OSLog.default, type: .debug)
            } else {
                os_log("Failed to save Java Classes...", log: OSLog.default, type: .error)
            }
        }
        return false
    }
    
    func textViewDidChange(_ textView: UITextView) {
        //autoCheck()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // This method lets you configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the save button is pressed.
        /*guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }*/
        
        let name = "Name"
        let content = "Test"
        
        // Set the class to be passed to JavaClassTableViewController after the unwind segue.
        javaClass = JavaClass(name: name, content: content)
    }
    
    
    //MARK: Actions

    @IBAction func run(_ sender: UIButton) {
        dismissKeyboard()
        Scanner.errorMsgs.removeAll()
        let scanArray = Scanner.scanInput(inputTextView.text)
        if(Scanner.errorMsgs.isEmpty) {
            let parseArray = Parser.parseInput(scanArray)
            print("\nParser: \n \(parseArray.description)\nEnd of Parser \n")

            if(Scanner.errorMsgs.isEmpty) {
                OutputGenerator.generateOutput(parseArray)
            }
        }
        
        
        print("\nErrors: \n")
        for msg in Scanner.errorMsgs {
            print(msg) // for debugging
        }
        print("\nEnd of Errors \n")
        
        var output = ""

        //inputString = scanArray.description
        //print(scanArray.description)
        //inputString = parseArray.description
        if(Scanner.errorMsgs.isEmpty) {
            for outputMsg in OutputGenerator.outputMsgs {
                output.append(outputMsg)
                output.append("\n")
            }
        } else {
            for errorMsg in Scanner.errorMsgs {
                output.append(errorMsg)
                output.append("\n")
            }
        }
        
        // error highlighting:
        if(Scanner.errorInfos.indices.contains(0)) {
            let attributedString:NSMutableAttributedString = NSMutableAttributedString(string: inputTextView.text)
            attributedString.addAttribute(NSUnderlineStyleAttributeName , value: NSUnderlineStyle.styleDouble.rawValue, range: NSRange(location: Scanner.errorInfos[0][0]-1, length: Scanner.errorInfos[0][1]+1))
            attributedString.addAttribute(NSUnderlineColorAttributeName , value: UIColor.red, range: NSRange(location: Scanner.errorInfos[0][0]-1, length: Scanner.errorInfos[0][1]+1))
            inputTextView.attributedText = attributedString
            //self.inputTextView.font = UIFont(name: (self.inputTextView.font?.fontName)!, size: 16)

            let attributedOutput:NSMutableAttributedString = NSMutableAttributedString(string: output)
            attributedOutput.addAttribute(NSForegroundColorAttributeName , value: UIColor.red, range: NSMakeRange(0, output.characters.count))

            resultTextView.attributedText = attributedOutput
        } else {
            let attributedOutput:NSMutableAttributedString = NSMutableAttributedString(string: output)
            attributedOutput.addAttribute(NSForegroundColorAttributeName , value: UIColor.black, range: NSMakeRange(0, output.characters.count))
            
            resultTextView.attributedText = attributedOutput
            
            let newJavaClass = JavaClass(name: titleTextField.text!, content: inputTextView.text)

            if(newJavaClass != nil){
                saveClasses(newJavaClass!)
            }
        }
        
        print(inputTextView.text.description) // for debugging

    }
    
    
    private func saveClasses(_ javaClass: JavaClass) {
        
        var classes = [String:JavaClass]()

        // Load any saved classes and add the new Class to the array and save it.
        if let savedClasses = loadJavaClasses() {
            classes = savedClasses
        }
        
        classes[javaClass.name] = javaClass
        
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(classes, toFile: JavaClass.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Java Classes successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save Java Classes...", log: OSLog.default, type: .error)
        }
        
        var classes2 = [String: JavaClass]()
        classes2 = loadJavaClasses()!
        for javaClassNew in classes2 {
            print(javaClassNew.key)
        }
    }
    
    private func loadJavaClasses() -> [String: JavaClass]?  {
        return NSKeyedUnarchiver.unarchiveObject(withFile: JavaClass.ArchiveURL.path) as? [String: JavaClass]
    }
    
    
    /*
    func autoCheck() {
        Scanner.errorMsgs.removeAll()
        let scanArray = Scanner.scanInput(inputTextView.text)
        if(Scanner.errorMsgs.isEmpty) {
            let parseArray = Parser.parseInput(scanArray)
            print("\nParser: \n \(parseArray.description)\nEnd of Parser \n")
            
            if(Scanner.errorMsgs.isEmpty) {
                OutputGenerator.generateOutput(parseArray)
            }
        }
        
        
        print("\nErrors: \n")
        for msg in Scanner.errorMsgs {
            print(msg)
        }
        print("\nEnd of Errors \n")
        
        var output = ""
        
        //inputString = scanArray.description
        //print(scanArray.description)
        //inputString = parseArray.description
        if(Scanner.errorMsgs.isEmpty) {
            for outputMsg in OutputGenerator.outputMsgs {
                output.append(outputMsg)
                output.append("\n")
            }
        } else {
            for errorMsg in Scanner.errorMsgs {
                output.append(errorMsg)
                output.append("\n")
            }
        }
        
        let attributedString:NSMutableAttributedString = NSMutableAttributedString(string: inputTextView.text)
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.red, range: (attributedString.string as NSString).range(of: "String"))
        inputTextView.attributedText = attributedString
        
        //inputString = OutputGenerator.outputMsgs.description
        resultTextView.text = output
        print(inputTextView.text.description)
    }
    */
    

}


//
//  FirstViewController.swift
//  JavaIDE
//
//  Created by Tobias Steinbrück on 23.10.16.
//  Copyright © 2016 Tobias Steinbrück. All rights reserved.
//

import UIKit
import os.log

class EditorViewController: UIViewController, UITextViewDelegate {
    
    //MARK: Properties
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var resultTextView: UITextView!
    var nameLabel = "" //notUsed
    
    /*
     This value is either passed by `JavaClassTableViewController` in `prepare(for:sender:)`
     or constructed as part of adding a new java class.
     */
    var javaClass: JavaClass?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field’s user input through delegate callbacks.
        inputTextView.delegate = self
        
        // Set up views if editing an existing JavaClass.
        if let javaClass = javaClass {
            nameLabel = javaClass.name //notUsed
            navigationItem.title = javaClass.name
            inputTextView.text = javaClass.content
        }
        
        
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
        
        let name = nameLabel
        let content = inputTextView.text ?? ""
        
        // Set the meal to be passed to MealTableViewController after the unwind segue.
        javaClass = JavaClass(name: name, content: content)
    }
    
    
    //MARK: Actions

    @IBAction func run(_ sender: UIButton) {
        Scanner.errorMsgs.removeAll()
        let scanArray = Scanner.scanInput(inputTextView.text)
        let parseArray = Parser.parseInput(scanArray)
        if(Scanner.errorMsgs.isEmpty) {
            OutputGenerator.generateOutput(parseArray)
        }
        
        print("\nErrors: \n")
        for msg in Scanner.errorMsgs {
            print(msg)
        }
        print("\nEnd of Errors \n")
        
        var inputString = ""
        for input in scanArray {
            inputString.append(input[0])
        }
        //inputString = scanArray.description
        //print(scanArray.description)
        inputString = parseArray.description
        resultTextView.text = inputString
    }

}


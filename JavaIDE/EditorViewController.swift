//
//  FirstViewController.swift
//  JavaIDE
//
//  Created by Tobias Steinbrück on 23.10.16.
//  Copyright © 2016 Tobias Steinbrück. All rights reserved.
//

import UIKit

class EditorViewController: UIViewController, UITextViewDelegate {
    
    //MARK: Properties
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var resultTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field’s user input through delegate callbacks.
        inputTextView.delegate = self
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(EditorViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
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

    
    //MARK: Actions

    @IBAction func run(_ sender: UIButton) {
        let scanArray = Scanner.scanInput(inputTextView.text)
        let parseArray = Parser.parseInput(scanArray)
        CodeGenerator.generateCode(parseArray)
        
        print("\nErrors: \n")
        for msg in Scanner.errorMsgs {
            print(msg)
        }
        print("\nEnd of Errors \n")
        
        var inputString = ""
        for input in scanArray {
            inputString.append(input[0])
        }
        //inputString = inputArray.description
        inputString = parseArray.description
        resultTextView.text = inputString
    }

}

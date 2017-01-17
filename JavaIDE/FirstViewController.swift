//
//  FirstViewController.swift
//  JavaIDE
//
//  Created by Tobias Steinbrück on 23.10.16.
//  Copyright © 2016 Tobias Steinbrück. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UITextViewDelegate {
    
    //MARK: Properties
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var resultTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field’s user input through delegate callbacks.
        inputTextView.delegate = self
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(FirstViewController.dismissKeyboard))
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
        
        var inputString = ""
        for input in scanArray {
            inputString.append(input[0])
        }
        //inputString = inputArray.description
        inputString = parseArray.description
        resultTextView.text = inputString
    }

}


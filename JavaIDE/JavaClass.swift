//
//  JavaClass.swift
//  JavaIDE
//
//  Created by Tobias Steinbrück on 24.01.17.
//  Copyright © 2017 Tobias Steinbrück. All rights reserved.
//

import UIKit

class JavaClass {
    
    //MARK: Properties
    
    var name: String
    var content: String
    
    
    //MARK: Initialization

    init?(name: String, content: String) {
        
        // The name must not be empty
        guard !name.isEmpty else {
            return nil
        }

        // The content must not be empty
        guard !content.isEmpty else {
            return nil
        }
        
        // Initialize stored properties.
        self.name = name
        self.content = content
        
    }
}

//
//  JavaClass.swift
//  JavaIDE
//
//  Created by Tobias Steinbrück on 24.01.17.
//  Copyright © 2017 Tobias Steinbrück. All rights reserved.
//

import UIKit
import os.log

class JavaClass: NSObject, NSCoding{
    
    //MARK: Properties
    
    struct PropertyKey {
        static let name = "name"
        static let content = "content"
    }
    
    var name: String
    var content: String
    
    
    //MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("javaClasses")
    
    
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
    
    
    // MARK: NSCoding
    
    required convenience init?(coder aDecoder: NSCoder) {
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a Class object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        guard let content = aDecoder.decodeObject(forKey: PropertyKey.content) as? String else {
            os_log("Unable to decode the content for a Class object.", log: OSLog.default, type: .debug)
            return nil
        }

        // Must call designated initializer.
        self.init(name: name, content: content)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(content, forKey: PropertyKey.content)
    }
}

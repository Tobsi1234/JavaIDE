//
//  JavaClassTableViewController.swift
//  JavaIDE
//
//  Created by Tobias Steinbrück on 25.01.17.
//  Copyright © 2017 Tobias Steinbrück. All rights reserved.
//

import UIKit
import os.log

class JavaClassTableViewController: UITableViewController {

    
    //MARK: Properties
    
    var classes = [JavaClass]()
    
    var javaClass: JavaClass?
    
    
    //MARK: Private Methods
    
    private func loadClasses() {
        classes.removeAll()
        // Load any saved classes, otherwise load sample data and save them.
        if let javaClasses = loadJavaClasses() {
            for (_, value) in javaClasses {
                classes.append(value)
            }
        } else {
            guard let class1 = JavaClass(name: "Example 1", content: "public static void main(String[] args) {\n int i = 5;\n System.out.println(i);\n}") else {
                fatalError("Unable to instantiate class1")
            }
            
            guard let class2 = JavaClass(name: "Example 2", content: "public static void main(String[] args) {\n  int i = 5;\n  if(i == 5 && 0 != 1) {\n    String abc = \"Test\";\n    System.out.println(abc);\n  }\n}") else {
                fatalError("Unable to instantiate class2")
            }
            
            guard let class3 = JavaClass(name: "Example 3", content: "public static void main(String[] args) {\n int i = 5;\n System.out.println(i);\ntest1();\n}\n\npublic static void test1(String arg1, int arg2) {\n int j = 5;\n System.out.println(j);\n}") else {
                fatalError("Unable to instantiate class3")
            }
            
            guard let class4 = JavaClass(name: "Example 4", content: "public static void main(String[] args) {\n  int i = 0;\n  i = 1;\n  while(i < 5 && 0 == 0) {\n    i += 1;\n    System.out.println(i);\n  }\n}") else {
                fatalError("Unable to instantiate class4")
            }
        
            guard let class5 = JavaClass(name: "Example 5", content: "public static void main(String[] args) {\n  int i;\n  i = 1;\n  i += 1;\n  System.out.println(i);\n}") else {
                fatalError("Unable to instantiate class4")
            }
        
            classes += [class1, class2, class3, class4, class5]
            
            // save sample classes
            var classesDict = [String: JavaClass]()
            for javaClass in classes {
                classesDict[javaClass.name] = javaClass
            }
            let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(classesDict, toFile: JavaClass.ArchiveURL.path)
            if isSuccessfulSave {
                os_log("Java Classes successfully saved.", log: OSLog.default, type: .debug)
            } else {
                os_log("Failed to save Java Classes...", log: OSLog.default, type: .error)
            }
        }
    }
    
    /// returns dictionary array of all saved classes
    private func loadJavaClasses() -> [String: JavaClass]?  {
        return NSKeyedUnarchiver.unarchiveObject(withFile: JavaClass.ArchiveURL.path) as? [String: JavaClass]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Load classes
        loadClasses()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("TableView did appear.")
        // reload classes after change
        loadClasses()
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return classes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "JavaClassTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? JavaClassTableViewCell  else {
            fatalError("The dequeued cell is not an instance of JavaClassTableViewCell.")
        }
        
        // Fetches the appropriate java class for the data source layout.
        let javaClass = classes[indexPath.row]
        
        cell.nameLabel.text = javaClass.name
        cell.content = javaClass.content
        
        return cell
    }
 

    //MARK: Actions
    
    /*
    // not used
    @IBAction func unwindToJavaClassList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? EditorViewController, let javaClass = sourceViewController.javaClass {
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing class.
                
                classes[selectedIndexPath.row] = javaClass
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
            else { //notUsed
                // Add a new class.
                let newIndexPath = IndexPath(row: classes.count, section: 0)
                
                classes.append(javaClass)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        }
    } 
    */
    
    
    //MARK: - Navigation
    
    // preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        //case "AddItem":
            //os_log("Adding a new class.", log: OSLog.default, type: .debug)
            
        case "ShowDetail":
            guard let javaClassDetailViewController = segue.destination as? EditorViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedJavaClassCell = sender as? JavaClassTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedJavaClassCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedJavaClass = classes[indexPath.row]
            javaClassDetailViewController.javaClass = selectedJavaClass
         
        case "AddItem":
            guard let javaClassDetailViewController = segue.destination as? EditorViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
  
            let newJavaClass = JavaClass(name: "New Class", content: "public static void main(String[] args) {\n  System.out.println(\"Hello World\");\n}")
            javaClassDetailViewController.javaClass = newJavaClass
            
        default:
            print("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }

}

//
//  JavaClassTableViewController.swift
//  JavaIDE
//
//  Created by Tobias Steinbrück on 25.01.17.
//  Copyright © 2017 Tobias Steinbrück. All rights reserved.
//

import UIKit

class JavaClassTableViewController: UITableViewController {

    
    //MARK: Properties
    
    var classes = [JavaClass]()
    
    
    //MARK: Private Methods
    
    private func loadSampleClasses() {
        
        guard let class1 = JavaClass(name: "Example 1", content: "int i = 0;") else {
            fatalError("Unable to instantiate class1")
        }
        
        guard let class2 = JavaClass(name: "Example 2", content: "String abc = \"Test\";") else {
            fatalError("Unable to instantiate class2")
        }
        
        classes += [class1, class2]
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Load the sample classes.
        loadSampleClasses()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        // Fetches the appropriate meal for the data source layout.
        let javaClass = classes[indexPath.row]
        
        cell.nameLabel.text = javaClass.name
        
        return cell
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

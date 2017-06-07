//
//  JavaClassTableViewCell.swift
//  JavaIDE
//
//  Created by Tobias Steinbrück on 24.01.17.
//  Copyright © 2017 Tobias Steinbrück. All rights reserved.
//

import UIKit

class JavaClassTableViewCell: UITableViewCell {

    //MARK: Properties
    
    @IBOutlet weak var nameLabel: UILabel!
    var content = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

//
//  CustomCategoryTableViewCell.swift
//  Botch
//
//  Created by Martin Velev on 8/20/20.
//

import UIKit

class CustomCategoryTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBOutlet var customButton: UIButton!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

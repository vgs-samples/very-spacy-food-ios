//
//  MenuItemCell.swift
//  Spacy Food
//
//  Created by Dima on 13.03.2020.
//  Copyright © 2020 Very Good Security. All rights reserved.
//

import Foundation
import UIKit

class MenuItemCell: UITableViewCell {
    
    var onAddItemClicked: (()-> Void)?
    
    override func awakeFromNib() {
        
    }
    @IBAction func addItemAction(_ sender: Any) {
        self.onAddItemClicked?()
    }
}

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
    
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var ingredients: UILabel!
    
    var onAddItemClicked: (()-> Void)?
    
    override func awakeFromNib() {
        
    }
    
    @IBAction func addItemAction(_ sender: Any) {
        self.onAddItemClicked?()
    }
}

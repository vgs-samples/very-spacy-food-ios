//
//  MenuItemDetailsViewController.swift
//  Spacy Food
//
//  Created by Dima on 17.03.2020.
//  Copyright © 2020 Very Good Security. All rights reserved.
//

import Foundation
import UIKit

struct MenuItem {
    let imgName: String
    let name: String
    let ingredients: String
    let weight: String
    let price: Double
    let associatedColor: UIColor
}

/// A class responsible to show available menu items
class MenuItemDetailsViewController: UIViewController {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var ingredients: UILabel!
    @IBOutlet weak var price: UILabel!
    
    var menuItem: MenuItem!
    var onItemAdded: ((MenuItem?) -> Void)?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        itemImageView.image = UIImage.init(named: menuItem.imgName)
        itemTitle.text = menuItem.name
        ingredients.text = menuItem.ingredients
        price.text = "$\(menuItem.price)"
        
        view.layoutIfNeeded()
        backgroundView.backgroundColor = menuItem.associatedColor
        backgroundView.layer.cornerRadius = 54
        backgroundView.layer.maskedCorners = [.layerMinXMaxYCorner]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    @IBAction func addToCardtAction(_ sender: Any) {
        onItemAdded?(menuItem)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

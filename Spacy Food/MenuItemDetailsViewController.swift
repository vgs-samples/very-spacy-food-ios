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
}

class MenuItemDetailsViewController: UIViewController {

    var menuItem: MenuItem?
    var onItemAdded: ((MenuItem?) -> Void)?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func addToCardtAction(_ sender: Any) {
        onItemAdded?(menuItem)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

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

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var ingredients: UILabel!
    @IBOutlet weak var price: UILabel!
    
    
    var menuItem: MenuItem?
    var onItemAdded: ((MenuItem?) -> Void)?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let item = menuItem {
            itemImageView.image = UIImage.init(named: item.imgName)
            itemTitle.text = item.name
            ingredients.text = item.ingredients
            price.text = "$\(item.price)"
        }
        
        view.layoutIfNeeded()
        backgroundView.backgroundColor = randomColor()
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
    
    func randomColor() -> UIColor {
        return [
            UIColor(red: 0.18, green: 0.69, blue: 0.569, alpha: 1),
            UIColor(red: 0.925, green: 0.655, blue: 0.365, alpha: 1),
            UIColor(red: 0.783, green: 0.345, blue: 0.32, alpha: 1),
            UIColor(red: 0.833, green: 0.483, blue: 0.609, alpha: 1),
            UIColor(red: 1, green: 0.773, blue: 0.371, alpha: 1)
            ].randomElement() ?? UIColor.red
    }
}

extension UIView {
   func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

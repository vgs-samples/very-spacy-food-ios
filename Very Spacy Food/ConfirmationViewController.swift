//
//  ConfirmationViewController.swift
//  Spacy Food
//
//  Created by Dima on 25.03.2020.
//  Copyright © 2020 Very Good Security. All rights reserved.
//

import Foundation
import UIKit

class ConfirmationViewController: UIViewController {
    
    @IBOutlet weak var cardNumberLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    var orderPrice: Double = 0
    var cardNumber = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cardNumberLabel.text = cardNumber
        priceLabel.text = "$\(orderPrice.truncate(places: 2))"
        view.addGradient(UIColor.midBlueColorsSet)
    }
    
    @IBAction func closeAction(_ sender: Any) {
        if let menuVC = navigationController?.viewControllers.first as? MenuViewController {
            menuVC.orderItemsCount = 0
            menuVC.orderPrice = 0
            menuVC.counterLabel.text = ""
            menuVC.securedCardData = nil
        }
        navigationController?.popToRootViewController(animated: true)
    }
}

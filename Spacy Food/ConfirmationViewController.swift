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
    
    var orderPrice: Double = 14.55
    var cardNumber = "4111 **** **** 1111"
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cardNumberLabel.text = cardNumber
        priceLabel.text = "$\(orderPrice.truncate(places: 2))"
    }
    
    @IBAction func closeAction(_ sender: Any) {
        if let menuVC = navigationController?.viewControllers.first as? MenuViewController {
            menuVC.orderItemsCount = 0
            menuVC.counterLabel.text = ""
            menuVC.securedCardData = nil
            menuVC.orderPrice = 0
        }
        navigationController?.popToRootViewController(animated: true)
    }
}

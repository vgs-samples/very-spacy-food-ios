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
    
    @IBAction func closeAction(_ sender: Any) {
        if let menuVC = navigationController?.viewControllers.first as? MenuViewController {
            menuVC.orderItemsCount = 0
            menuVC.counterLabel.text = ""
            menuVC.securedCardData = nil
        }
        navigationController?.popToRootViewController(animated: true)
    }
}

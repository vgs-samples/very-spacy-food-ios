//
//  CheckoutViewController.swift
//  Spacy Food
//
//  Created by Dima on 19.03.2020.
//  Copyright © 2020 Very Good Security. All rights reserved.
//

import Foundation
import UIKit

class CheckoutViewController: UIViewController {
    
    var orderItems = [Any]()
    var securedCardData: SecuredCardData!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
         return .lightContent
     }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func payAction(_ sender: Any) {
        
    }
    
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

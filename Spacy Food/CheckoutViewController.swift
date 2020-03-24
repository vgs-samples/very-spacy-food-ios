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
    
    @IBOutlet weak var payWithLabel: UILabel!
    @IBOutlet weak var cardNumberLabel: UILabel!
    
    lazy var loadingView: LoadingView = {
        return LoadingView.fromNib()!
    }()
    
    var orderItems = [Any]()
    var securedCardData: SecuredCardData!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
         return .lightContent
     }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cardBrand = securedCardData.cardBrand.isEmpty ? "credit" : securedCardData.cardBrand
        let first4 = securedCardData.cardNumberBin.prefix(4)
        payWithLabel.text = "Pay with your \(cardBrand) card"
        cardNumberLabel.text = "\(first4) **** **** \(securedCardData.cardNumberLast4)"
        
        loadingView.frame = self.view.bounds
        loadingView.isHidden = true
        view.addSubview(loadingView)
        
    }

    @IBAction func payAction(_ sender: Any) {
    
        loadingView.isHidden = false
        view.bringSubviewToFront(loadingView)
    }
    
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

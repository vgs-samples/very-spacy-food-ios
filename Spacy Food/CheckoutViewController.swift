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
    
        setLoadingView(hidden: false)
        
        let url = URL(string: "https://lu38a8wiw3.execute-api.us-west-2.amazonaws.com/demo-payment-processor")!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        session.dataTask(with: request, completionHandler: { [weak self](data: Data?, response: URLResponse?, error: Error?) in
            
            if error == nil, let httpResponse = response as? HTTPURLResponse  {
                if httpResponse.statusCode == 200 {
                    print("success")
                    DispatchQueue.main.async {
                        self?.showConfirmationScreen()
                    }
                    return
                }
            } else {
                print("Something goes wrong!")
            }
            self?.setLoadingView(hidden: true)
        }).resume()
    }
    
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func setLoadingView(hidden: Bool) {
        loadingView.isHidden = hidden
        hidden ? view.sendSubviewToBack(loadingView) : view.bringSubviewToFront(loadingView)
    }
    
    
    func showConfirmationScreen() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let confirmationVC = mainStoryboard.instantiateViewController(withIdentifier: "ConfirmationViewController") as! ConfirmationViewController
        navigationController?.pushViewController(confirmationVC, animated: true)
    }
}

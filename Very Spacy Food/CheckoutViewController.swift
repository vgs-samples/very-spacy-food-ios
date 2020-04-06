//
//  CheckoutViewController.swift
//  Spacy Food
//
//  Created by Dima on 19.03.2020.
//  Copyright © 2020 Very Good Security. All rights reserved.
//

import Foundation
import UIKit

let bakendUrl = "https://lu38a8wiw3.execute-api.us-west-2.amazonaws.com/demo-payment-processor"

class CheckoutViewController: UIViewController {
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var payWithLabel: UILabel!
    @IBOutlet weak var cardNumberLabel: UILabel!

    var orderPrice: Double = 0
    var securedCardData: SecuredCardData!
    lazy var loadingView: LoadingView = {
        return LoadingView.fromNib()!
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cardBrand = securedCardData.cardBrand.isEmpty ? "credit" : securedCardData.cardBrand
        let first4 = securedCardData.cardNumberBin.prefix(4)
        payWithLabel.text = "Pay with your \(cardBrand) card"
        cardNumberLabel.text = "\(first4) **** **** \(securedCardData.cardNumberLast4)"
        priceLabel.text = "$\(orderPrice.truncate(places: 2))"

        setupLoadingView()
        view.addGradient(UIColor.midBlueColorsSet)
    }

    @IBAction func payAction(_ sender: Any) {
        setLoadingView(hidden: false)
        
        var request = URLRequest(url: URL(string: bakendUrl)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request, completionHandler: { [weak self](data: Data?, response: URLResponse?, error: Error?) in
            
            if error == nil, let httpResponse = response as? HTTPURLResponse  {
                if (200..<300).contains(httpResponse.statusCode) {
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
}

//MARK: - UI settings
extension CheckoutViewController {
    
    func setupLoadingView() {
        loadingView.frame = self.view.bounds
        loadingView.isHidden = true
        view.addSubview(loadingView)
    }
    
    func setLoadingView(hidden: Bool) {
        loadingView.isHidden = hidden
        hidden ? view.sendSubviewToBack(loadingView) : view.bringSubviewToFront(loadingView)
        hidden ? loadingView.stopAnimation() : loadingView.startAnimation()
    }
    
    
    func showConfirmationScreen() {
        let confirmationVC = UIStoryboard.main.instantiateViewController(withIdentifier: "ConfirmationViewController") as! ConfirmationViewController
        confirmationVC.orderPrice = orderPrice
        confirmationVC.cardNumber = cardNumberLabel.text ?? ""
        navigationController?.pushViewController(confirmationVC, animated: true)
    }
}

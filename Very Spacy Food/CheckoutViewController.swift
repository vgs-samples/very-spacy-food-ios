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

/// A class responsible for handling payment requests.
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

    
    //MARK: - Payment request
    
    /**
    This is demo payment request where you will send alias card data to our demo server. It's dont do anything with the data you send, just return "Success" response if you reach the server.
    In real use cases, when make request to payment provider you should send card data throught VGS Outbound proxy, where the fields with alias data in request body can be revealed to original data. Then the proxy will redirect request to payment provider.
    Also to send requests through VGS Outbound proxy you should use proxy credentials. It's not secure to store them on device or in source code, your backend should handle it.

    However usual payment flow will look next:
        - you make payment request from mobile app to your backend.
        - optionally you can send card aliases data in request from mobile or your backend can get them from storage.
        - your backend will send paymend aliases to payment provider through VGS Outbound proxy.
        - when data goes through VGS Outbound proxy, aliases will be revealed to raw data and request will be redirected to payment provider that you choose.

        Check more about Outbound connection in Documentation: https://www.verygoodsecurity.com/docs/guides/outbound-connection
    */
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
                } else {
                    self?.showAlert(title: "Oooops!", text: error?.localizedDescription)
                }
            } else {
                self?.showAlert(title: "Request error!", text: "Something went wrong")
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

//
//  CollectCreditCardDataViewController.swift
//  Spacy Food
//
//  Created by Dima on 18.03.2020.
//  Copyright © 2020 Very Good Security. All rights reserved.
//

import Foundation
import UIKit
import VGSCollectSDK

class CollectCreditCardDataViewController: UIViewController {

    @IBOutlet weak var cardDataStackView: UIStackView!
    
    // Init VGS Collector
    var collector = VGSCollect(id: "vaultID", environment: .sandbox)
    
    var scanController: VGSCardIOScanController?
    
    // VGS UI Elements
    var cardNumber = VGSCardTextField()
    var expCardDate = VGSTextField()
    var cvcCardNum = VGSTextField()
    
    // Native UI Elements
    var cardHolderName = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupElementsConfiguration()
        UITextField.appearance().keyboardAppearance = UIKeyboardAppearance.dark
    }
    
    // MARK: - Setup UI
    private func setupUI() {

        cardDataStackView.addArrangedSubview(cardHolderName)
        cardDataStackView.addArrangedSubview(cardNumber)
        
        let bottomStackView = UIStackView.init(arrangedSubviews: [expCardDate, cvcCardNum, UIView()])
        bottomStackView.axis = .horizontal
        bottomStackView.alignment = .fill
        bottomStackView.distribution = .fillEqually
        bottomStackView.spacing = 20
        cardDataStackView.addArrangedSubview(bottomStackView)
    }
    
    private func setupElementsConfiguration() {
        let textColor = UIColor.white
        let textFont = UIFont.systemFont(ofSize: 22)
        let padding = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

        let cardConfiguration = VGSConfiguration(collector: collector, fieldName: "card_number")
        cardConfiguration.type = .cardNumber
        cardConfiguration.isRequiredValidOnly = true
        
        cardNumber.configuration = cardConfiguration
        cardNumber.textColor = textColor
        cardNumber.font = textFont
        cardNumber.padding = padding
        cardNumber.placeholder = "Card Number"
        cardNumber.textAlignment = .natural
        cardNumber.becomeFirstResponder()

        let expDateConfiguration = VGSConfiguration(collector: collector, fieldName: "card_expirationDate")
        expDateConfiguration.isRequiredValidOnly = true
        expDateConfiguration.type = .expDate

        expCardDate.configuration = expDateConfiguration
        expCardDate.textColor = textColor
        expCardDate.font = textFont
        expCardDate.padding = padding
        expCardDate.placeholder = "MM/YY"
        expCardDate.textAlignment = .center
        
        let cvcConfiguration = VGSConfiguration(collector: collector, fieldName: "card_cvc")
        cvcConfiguration.isRequired = true
        cvcConfiguration.type = .cvc

        cvcCardNum.configuration = cvcConfiguration
        cvcCardNum.textColor = textColor
        cvcCardNum.font = textFont
        cvcCardNum.padding = padding
        cvcCardNum.placeholder = "CVC"
        cvcCardNum.textAlignment = .center

        // Configure native UI elements
        cardHolderName.layer.borderWidth = 1
        cardHolderName.layer.borderColor = UIColor.lightGray.cgColor
        cardHolderName.layer.cornerRadius = 4
        
        cardHolderName.textColor = .white
        cardHolderName.placeholder = "Cardholder Name"
        cardHolderName.font = textFont
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: cardHolderName.frame.height))
        let actionButton = UIButton(frame: CGRect(x: cardHolderName.bounds.origin.x + 10, y: 0, width: 8, height: cardHolderName.frame.height))
        actionButton.backgroundColor = .red
        actionButton.addTarget(self, action: #selector(scan), for: .touchUpInside)
        cardHolderName.leftView = paddingView
        cardHolderName.leftViewMode = .always
        cardHolderName.rightView = actionButton
        cardHolderName.rightViewMode = .always
    }
    
    @objc func scan() {
        scanController = VGSCardIOScanController()
        scanController?.delegate = self
        scanController?.presentCardScanner(on: self, animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        collector.submit(path: "/post") { [weak self](data, error) in
            if let data = data {
                print(data)
                self?.dismiss(animated: true, completion: nil)
            } else {
                if let error = error as? NSError {
                    print(error.description)
                }
            }
        }
    }
    
    
}

extension CollectCreditCardDataViewController: VGSCardIOScanControllerDelegate {
    func textFieldForScannedData(type: CradIODataType) -> VGSTextField? {
        switch type {
        case .cardNumber:
            return cardNumber
        case .expirationDate:
            return expCardDate
        case .cvc:
            return cvcCardNum
        default:
            return nil
        }
    }
    
    func userDidCancelScan() {
        scanController?.dismissCardScanner(animated: true, completion: nil)
    }
    
    func userDidFinishScan() {
        scanController?.dismissCardScanner(animated: true, completion: nil)
    }
}

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

/// An object that store secured card data details
struct SecuredCardData {
    
    /// PCI data aliases
    let cardNumberAlias: String
    let cvcAlias: String
    let expDataAlias: String
    
    /// Available Card number details that you can reuse in the app
    var cardNumberBin: String = ""
    var cardNumberLast4: String = ""
    var cardBrand: String = ""
}

/// Your organization <vaultId>
let vaultId = "vaultId"


class CollectCreditCardDataViewController: UIViewController {

    @IBOutlet weak var cardDataStackView: UIStackView!
    @IBOutlet weak var bluredBackground: UIVisualEffectView!
    @IBOutlet weak var containerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var cardFieldsContainerView: UIView!
    
    /// Init VGS Collector
    ///
    /// - Parameters:
    ///
    ///  - id: your organization vaultid
    ///  - environment: your organization environment
    ///
    var collector = VGSCollect(id: vaultId, environment: .sandbox)
    
    // VGSCollectSDK UI Elements
    var cardHolderName = VGSTextField()
    var cardNumber = VGSCardTextField()
    var expCardDate = VGSTextField()
    var cvcCardNum = VGSTextField()
    var scanController: VGSCardIOScanController?
    
    // Helpers
    var isKeyboardVisible = false
    var maxLevel = 0 as CGFloat
    var initialTouchPoint = CGPoint.zero

    var onCompletion: ((SecuredCardData) -> Void )?
    
    // Track VGSTextFields with not valid input on Submit
    var notValidTextFields = Set<VGSTextField>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Add UI elements to ViewController
        arrangeTextFields()
        
        /// Setup UI attributes and configuration
        setupTextFieldConfigurations()
        
        /// Observe active vgs textfield's state when editing the field
        collector.observeFieldState = { (textfield) in
            if self.notValidTextFields.contains(textfield) {
                // Update textfield UI
                self.notValidTextFields.remove(textfield)
                textfield.layer.borderColor = UIColor.white.cgColor
            }
        }
        
        // Helpers
        addGestureRecognizer()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        cardFieldsContainerView.addGradient(UIColor.lightBlueColorsSet)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cardNumber.becomeFirstResponder()
    }
    
    // MARK: - Arrange Textfields
    private func arrangeTextFields() {
        cardDataStackView.addArrangedSubview(cardHolderName)
        cardDataStackView.addArrangedSubview(cardNumber)

        
        let scanButton = UIButton()
        scanButton.setImage(UIImage(named: "scan_icon.png"), for: .normal)
        scanButton.imageView?.contentMode = .scaleAspectFit
        scanButton.imageEdgeInsets = .init(top: 5, left: 10, bottom: 5, right: 10)
        scanButton.addTarget(self, action: #selector(scan), for: .touchUpInside)

        let bottomStackView = UIStackView.init(arrangedSubviews: [expCardDate, cvcCardNum, scanButton])
        bottomStackView.axis = .horizontal
        bottomStackView.alignment = .fill
        bottomStackView.distribution = .fillEqually
        bottomStackView.spacing = 20
        cardDataStackView.addArrangedSubview(bottomStackView)
    }
    
    private func setupTextFieldConfigurations() {
        let textColor = UIColor.white
        let tintColor = UIColor.white
        let placeholderColor = UIColor.init(white: 1, alpha: 0.8)
        let textFont = UIFont.systemFont(ofSize: 22)
        let padding = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        /// Init card number field configuration with VGSCollect instance.
        let cardConfiguration = VGSConfiguration(collector: collector, fieldName: "card_number")
        
        /// Setup field type. For each specific FieldType  built-in validation, default text format and other specific attributes will be applied.
        cardConfiguration.type = .cardNumber
        
        /// Set input should be .isRequiredValidOnly = true. Then user couldn't submit card number that is not valid. VGSCollect.submit(_:) will return specific VGSError in that case.
        cardConfiguration.isRequiredValidOnly = true
        
        /// Set preffered keyboard color
        cardConfiguration.keyboardAppearance = .dark
        
        /// Set configuration instance to textfield that will collect card number
        cardNumber.configuration = cardConfiguration
        
        /// Setup UI attributes
        cardNumber.textColor = textColor
        cardNumber.tintColor = tintColor
        cardNumber.font = textFont
        cardNumber.padding = padding
        cardNumber.attributedPlaceholder = NSAttributedString(string: "4111 1111 1111 1111", attributes: [NSAttributedString.Key.foregroundColor: placeholderColor])
        cardNumber.textAlignment = .natural
        
        /// Set expiration data field configuration with same collector but specific fieldName
        let expDateConfiguration = VGSConfiguration(collector: collector, fieldName: "card_expirationDate")
        
        /// Set input .isRequired = true if you need textfield input be not empty or nil.  Then user couldn't submit expiration date that is empty or nil. VGSCollect.submit(_:) will return specific VGSError in that case.
        expDateConfiguration.isRequired = true
        expDateConfiguration.type = .expDate
        expDateConfiguration.keyboardAppearance = .dark
        
        expCardDate.configuration = expDateConfiguration
        expCardDate.textColor = textColor
        expCardDate.tintColor = tintColor
        expCardDate.font = textFont
        expCardDate.padding = padding
        expCardDate.attributedPlaceholder = NSAttributedString(string: "11/22", attributes: [NSAttributedString.Key.foregroundColor: placeholderColor])
        expCardDate.textAlignment = .center
        
        /// Set cvc data field configuration with same collector but specific fieldName
        let cvcConfiguration = VGSConfiguration(collector: collector, fieldName: "card_cvc")
        cvcConfiguration.isRequired = true
        cvcConfiguration.type = .cvc
        cvcConfiguration.keyboardAppearance = .dark
        
        cvcCardNum.configuration = cvcConfiguration
        cvcCardNum.textColor = textColor
        cvcCardNum.tintColor = tintColor
        cvcCardNum.font = textFont
        cvcCardNum.padding = padding
        cvcCardNum.attributedPlaceholder = NSAttributedString(string: "CVC", attributes: [NSAttributedString.Key.foregroundColor: placeholderColor])
        cvcCardNum.textAlignment = .center

        /// Set cvc data field configuration with same collector but specific fieldName
        let cardHolderConfiguration = VGSConfiguration(collector: collector, fieldName: "cardholder_name")
        cardHolderConfiguration.type = .cardHolderName
        cardHolderConfiguration.keyboardAppearance = .dark
        
        cardHolderName.configuration = cardHolderConfiguration
        cardHolderName.textColor = textColor
        cardHolderName.tintColor = tintColor
        cardHolderName.font = textFont
        cardHolderName.padding = padding
        cardHolderName.attributedPlaceholder = NSAttributedString(string: "Cardholder Name", attributes: [NSAttributedString.Key.foregroundColor: placeholderColor])
    }
    
    //MARK: - Validation
    /// Check if VGSTextFields are valid and update UI for fields with errors.
    func validateInputData() -> Bool {
        notValidTextFields.removeAll()
        if !cardNumber.state.isValid {
            cardNumber.layer.borderColor = UIColor.red.cgColor
            notValidTextFields.insert(cardNumber)
        }
        if !expCardDate.state.isValid {
            expCardDate.layer.borderColor = UIColor.red.cgColor
            notValidTextFields.insert(expCardDate)
        }
        if !cvcCardNum.state.isValid {
            cvcCardNum.layer.borderColor = UIColor.red.cgColor
            notValidTextFields.insert(cvcCardNum)
        }
        return notValidTextFields.count == 0
    }
    
    //MARK: - Card Scan
    @objc func scan() {
        /// Init and present card.io scanner. If scanned data is valid it will be set automatically  into VGSTextFields, you should implement VGSCardIOScanControllerDelegate for this.
        scanController = VGSCardIOScanController()
        scanController?.delegate = self
        scanController?.presentCardScanner(on: self, animated: true, completion: nil)
    }
    
    //MARK: - Submit Data
    /// Send sensetive data to VGS and get alieses.
    @IBAction func save(_ sender: Any) {
        /// Before sending data to VGS, you should probably want to check if it's valid.
        guard validateInputData() else {
            return
        }
        
        /// Also you can grab not sensetive data form CardState attribures
        let cardState = cardNumber.state as? CardState
        let bin = cardState?.bin ?? ""
        let last4 = cardState?.last4 ?? ""
        let brand = cardState?.cardBrand.stringValue ?? ""
        
        /// Add any additional data to request
        let extraData = ["userId": "id12345",
                         "cardBrand": brand]
        /**
        Send data to VGS
        For this demo app we send data to our echo server.
        The data goes through VGS Inpound proxy, where you have your Routs setup.
        When the data reach VGS Inpound proxy, fields with sensitive data will be redacted to aliases, which you can store and use securely later.
        Our echo server will return response with same body structure as you send, but fields will have aliases as values instead of original data.

        However in your production app on submit(_:) request, the data will go through VGS Inpound proxy to your backend or any other url that you configure in your Organization vault. It's your backend responsibility to setup response structure.
         
         Check our Documentation to know more about Sending data to VGS: https://www.verygoodsecurity.com/docs/vgs-collect/ios-sdk/submit-data ,
         and Inbound connections: https://www.verygoodsecurity.com/docs/guides/inbound-connection
        */
        
        collector.submit(path: "/post", extraData: extraData) { [weak self](json, error) in
            
            /// Check response. If success, you should get aliases data that you can use later or store on your backend.
            /// If response return raw data - check the Routs configuration  for Inbound requests on Dashboard.
            if let data = json?["json"] as? [String: Any],
                let cardNumberAlias = data["card_number"] as? String,
                let cvcAlias = data["card_cvc"]  as? String,
                let expDataAlias = data["card_expirationDate"]  as? String  {
                
                let cardData = SecuredCardData(cardNumberAlias: cardNumberAlias, cvcAlias: cvcAlias, expDataAlias: expDataAlias, cardNumberBin: bin, cardNumberLast4: last4, cardBrand: brand)
                self?.onCompletion?(cardData)
                self?.dismiss(animated: false, completion: nil)
            } else {
                /// If data is not valid, VGSCollect can return VGSError
                if let error = error as? VGSError, error.type == VGSErrorType.inputDataIsNotValid {
                    print(error.description)
                    self?.showAlert(title: "Ooops!", text: "Seems your data is not valid...")
                } else {
                    /// Probably wrong vaultId or internet connection errors...
                    self?.showAlert(title: "Error", text: "Somethin went wrong!")
                }
                print(error ?? "submit error")
            }
        }
    }
}

// MARK: - VGSCardIOScanControllerDelegate
/// Handle Card Scanning Delegate
extension CollectCreditCardDataViewController: VGSCardIOScanControllerDelegate {
    
    /// Set in which VGSTextField scanned data with type should be set. Called after user select Done button, just before userDidFinishScan() delegate.
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
    
    /// Handle  Cancel button action on Card.io screen
    func userDidCancelScan() {
        scanController?.dismissCardScanner(animated: true, completion: nil)
    }
    
    /// Handle  Done button action on Card.io screen
    func userDidFinishScan() {
        scanController?.dismissCardScanner(animated: true, completion: nil)
    }
}

// MARK: - Helpers
extension CollectCreditCardDataViewController {
    
    func addGestureRecognizer() {
        let gestureRecognizer = UIPanGestureRecognizer(target: self,
                                                   action: #selector(panGestureRecognizerHandler(_:)))
        self.view.addGestureRecognizer(gestureRecognizer)
    }
    
    @IBAction func panGestureRecognizerHandler(_ sender: UIPanGestureRecognizer) {
        let touchPoint = sender.location(in: self.view?.window)
        switch sender.state {
        case .began:
            initialTouchPoint = touchPoint
        case .changed:
            if touchPoint.y - initialTouchPoint.y > 0 {
                changeContainerPosition(touchPoint.y - initialTouchPoint.y)
            }
            self.bluredBackground.alpha = 0.8 * initialTouchPoint.y / touchPoint.y
        case .ended, .cancelled:
            
             if touchPoint.y - initialTouchPoint.y > 100 {
                self.view.endEditing(true)

                UIView.animate(withDuration: 0.1, animations: {
                    self.containerViewBottomConstraint.constant = -100
                    self.bluredBackground.alpha = 0
                    self.view.layoutIfNeeded()
                }) { (bool) in
                     self.dismiss(animated: false, completion: nil)
                }
             } else {
                //to original
                containerViewBottomConstraint.constant = maxLevel
                view.layoutIfNeeded()
                self.bluredBackground.alpha = 0.8
            }
               
         default:
            return
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard isKeyboardVisible == false else {
            return
        }
        isKeyboardVisible = true
        
        let userInfo = notification.userInfo

        if let info = userInfo, let kbRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let height = kbRect.size.height - 40.0
            self.maxLevel = height
            self.containerViewBottomConstraint.constant = height
            UIView.animate(withDuration: 4, delay: 0, options: .curveEaseOut, animations: {
                self.bluredBackground.alpha = 0.9
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    func changeContainerPosition(_ delta: CGFloat) {
        containerViewBottomConstraint.constant = maxLevel - delta
        view.layoutIfNeeded()
    }
}

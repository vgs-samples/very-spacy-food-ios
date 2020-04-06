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

struct SecuredCardData {
    /// PCI data aliases
    let cardNumberAlias: String
    let cvcAlias: String
    let expDataAlias: String

    var cardNumberBin: String = ""
    var cardNumberLast4: String = ""
    var cardBrand: String = ""
}

let vaultId = "tnttftgwu66"

class CollectCreditCardDataViewController: UIViewController {

    @IBOutlet weak var cardDataStackView: UIStackView!
    @IBOutlet weak var bluredBackground: UIVisualEffectView!
    @IBOutlet weak var containerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var cardFieldsContainerView: UIView!
    
    // Init VGS Collector
    var collector = VGSCollect(id: vaultId, environment: .sandbox)
    
    // VGS Elements
    var cardNumber = VGSCardTextField()
    var expCardDate = VGSTextField()
    var cvcCardNum = VGSTextField()
    var scanController: VGSCardIOScanController?

    // Native UI Elements
    lazy var cardHolderName: CardHolderTextFieldView = {
        return CardHolderTextFieldView.fromNib()!
    }()
    
    // Helpers
    var isKeyboardVisible = false
    var maxLevel = 0 as CGFloat
    var initialTouchPoint = CGPoint.zero

    var onCompletion: ((SecuredCardData) -> Void )?
    
    // Track VGSTextFields with not valid input on Submit
    var notValidTextFields = Set<VGSTextField>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        arrangeTextFields()
        setupTextFieldConfigurations()
        
        // Observe active vgs textfields state when editing
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
        cardHolderName.textField.becomeFirstResponder()
    }
    
    // MARK: - Arrange Textfields
    private func arrangeTextFields() {
        cardHolderName.scanButton.addTarget(self, action: #selector(scan), for: .touchUpInside)
        cardDataStackView.addArrangedSubview(cardHolderName)
        cardDataStackView.addArrangedSubview(cardNumber)
        
        let bottomStackView = UIStackView.init(arrangedSubviews: [expCardDate, cvcCardNum, UIView()])
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

        let cardConfiguration = VGSConfiguration(collector: collector, fieldName: "card_number")
        cardConfiguration.type = .cardNumber
        cardConfiguration.isRequiredValidOnly = true
        cardConfiguration.keyboardAppearance = .dark
        
        cardNumber.configuration = cardConfiguration
        cardNumber.textColor = textColor
        cardNumber.tintColor = tintColor
        cardNumber.font = textFont
        cardNumber.padding = padding
        cardNumber.attributedPlaceholder = NSAttributedString(string: "Card Number", attributes: [NSAttributedString.Key.foregroundColor: placeholderColor])
        cardNumber.textAlignment = .natural
        
        let expDateConfiguration = VGSConfiguration(collector: collector, fieldName: "card_expirationDate")
        expDateConfiguration.isRequired = true
        expDateConfiguration.type = .expDate
        expDateConfiguration.keyboardAppearance = .dark
        
        expCardDate.configuration = expDateConfiguration
        expCardDate.textColor = textColor
        expCardDate.tintColor = tintColor
        expCardDate.font = textFont
        expCardDate.padding = padding
        expCardDate.attributedPlaceholder = NSAttributedString(string: "MM/YY", attributes: [NSAttributedString.Key.foregroundColor: placeholderColor])
        expCardDate.textAlignment = .center
        
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

        // Configure native UI elements
        cardHolderName.layer.borderWidth = 1
        cardHolderName.layer.borderColor = UIColor.lightGray.cgColor
        cardHolderName.layer.cornerRadius = 4
        
        cardHolderName.textField.autocorrectionType = .no
        cardHolderName.textField.textColor = textColor
        cardHolderName.textField.tintColor = tintColor
        cardHolderName.textField.attributedPlaceholder = NSAttributedString(string: "Cardholder Name", attributes: [NSAttributedString.Key.foregroundColor: placeholderColor])
        cardHolderName.textField.font = textFont
    }
    
    @objc func scan() {
        scanController = VGSCardIOScanController()
        scanController?.delegate = self
        scanController?.presentCardScanner(on: self, animated: true, completion: nil)
    }
    
    
    @IBAction func save(_ sender: Any) {
    
        guard validateInputData() else {
            return
        }
        
        //check CardState attribures
        let cardState = cardNumber.state as? CardState
        let bin = cardState?.bin ?? ""
        let last4 = cardState?.last4 ?? ""
        let brand = cardState?.cardBrand.stringValue() ?? ""
        
        collector.submit(path: "/post") { [weak self](json, error) in
            
            if let data = json?["json"] as? [String: Any],
                let cardNumberAlias = data["card_number"] as? String,
                let cvcAlias = data["card_cvc"]  as? String,
                let expDataAlias = data["card_expirationDate"]  as? String  {
                
                let cardData = SecuredCardData(cardNumberAlias: cardNumberAlias, cvcAlias: cvcAlias, expDataAlias: expDataAlias, cardNumberBin: bin, cardNumberLast4: last4, cardBrand: brand)
                self?.onCompletion?(cardData)
                self?.dismiss(animated: false, completion: nil)
            } else {
                if let error = error as? VGSError, error.type == VGSErrorType.inputDataIsNotValid {
                    print(error.description)
                    self?.showAlert(title: "Ooops!", text: "Seems your data is not valid...")
                } else {
                    self?.showAlert(title: "Error", text: "Somethin went wrong!")
                }
                print(error)
            }
        }
    }
    
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
}

// MARK: - VGSCardIOScanControllerDelegate
// Handle Card Scanning Delegate
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

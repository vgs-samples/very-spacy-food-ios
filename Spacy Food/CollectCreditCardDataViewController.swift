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
    let cardNumberAlias: String
    let cvcAlias: String
    let expDataAlias: String
    var cardNumberBin: String = ""
    var cardNumberLast4: String = ""
    var cardBrand: String = ""
}

class CollectCreditCardDataViewController: UIViewController {

    @IBOutlet weak var cardDataStackView: UIStackView!
    @IBOutlet weak var bluredBackground: UIVisualEffectView!
    @IBOutlet weak var containerViewBottomConstraint: NSLayoutConstraint!
    
    // Init VGS Collector
    var collector = VGSCollect(id: "tnttftgwu66", environment: .sandbox)
    
    // VGS Elements
    var cardNumber = VGSCardTextField()
    var expCardDate = VGSTextField()
    var cvcCardNum = VGSTextField()
    var scanController: VGSCardIOScanController?

    // Native UI Elements
    var cardHolderName = UITextField()
    
    // Helpers
    var keyboardVisible = false
    var maxLevel = 0 as CGFloat
    var initialTouchPoint = CGPoint.zero
    let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
    let impactFeedbackGenerator = UIImpactFeedbackGenerator()
    var onCompletion: ((SecuredCardData) -> Void )?
    
    // Track VGSTextFields with not valid input on Submit
    var notValidTextFields = Set<VGSTextField>()

    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
        setupElementsConfiguration()
        
        // Helpers
        addGestureRecognizer()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        
        collector.observeFieldState = { (textfield) in
            if self.notValidTextFields.contains(textfield) {
                self.notValidTextFields.remove(textfield)
                textfield.layer.borderColor = UIColor.white.cgColor
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cardHolderName.becomeFirstResponder()
    }
    
    // MARK: - Setup UI
    private func buildUI() {

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
        expDateConfiguration.isRequiredValidOnly = true
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
        
        cardHolderName.autocorrectionType = .no
        cardHolderName.textColor = textColor
        cardHolderName.tintColor = tintColor
        cardHolderName.attributedPlaceholder = NSAttributedString(string: "Cardholder Name", attributes: [NSAttributedString.Key.foregroundColor: placeholderColor])
        cardHolderName.font = textFont
        cardHolderName.keyboardAppearance = .dark
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: cardHolderName.frame.height))
        let actionButton = UIButton(frame: CGRect(x: cardHolderName.bounds.origin.x + 10, y: 0, width: 8, height: cardHolderName.frame.height))
        actionButton.imageView?.image = UIImage(named: "scan_icon")
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
        impactFeedbackGenerator.impactOccurred()
        
        guard validateInputData() else {
            return
        }
        
        //check card state attribures
        let cardState = cardNumber.state as? CardState
        let bin = cardState?.bin ?? "****"
        let last4 = cardState?.last4 ?? "****"
        let brand = cardState?.cardBrand.stringValue() ?? ""
        
        collector.submit(path: "/post") { [weak self](json, error) in
            
            if let data = json?["json"] as? [String: Any],
                let cardNumberAlias = data["card_number"] as? String,
                let cvcAlias = data["card_cvc"]  as? String,
                let expDataAlias = data["card_expirationDate"]  as? String  {
                
                let cardData = SecuredCardData(cardNumberAlias: cardNumberAlias, cvcAlias: cvcAlias, expDataAlias: expDataAlias, cardNumberBin: bin, cardNumberLast4: last4, cardBrand: brand)
                self?.onCompletion?(cardData)
                self?.dismiss(animated: false, completion: nil)
                
                self?.notificationFeedbackGenerator.notificationOccurred(.success)
            } else {

                if let error = error as? NSError {
                    print(error.description)
                } else {
                    // data not full
                }
                self?.notificationFeedbackGenerator.notificationOccurred(.error)
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
                let haptic = UIImpactFeedbackGenerator()
                haptic.impactOccurred()
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
    
    func changeContainerPosition(_ delta: CGFloat) {
        containerViewBottomConstraint.constant = maxLevel - delta
        view.layoutIfNeeded()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard keyboardVisible == false else {
            return
        }
        keyboardVisible = true
        
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
}

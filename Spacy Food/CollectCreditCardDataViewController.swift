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

    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
        setupElementsConfiguration()
        
        // Helpers
        addGestureRecognizer()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
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
        
        cardHolderName.autocorrectionType = .no
        cardHolderName.textColor = .white
        cardHolderName.placeholder = "Cardholder Name"
        cardHolderName.font = textFont
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
        
        //check card state attribures
        let cardState = cardNumber.state as? CardState
        let last4 = cardState?.last4 ?? ""
        let brand = cardState?.cardBrand.stringValue() ?? ""
        
        collector.submit(path: "/post") { [weak self](json, error) in
            
            if let data = json?["json"] as? [String: Any],
                let cardNumberAlias = data["card_number"] as? String,
                let cvcAlias = data["card_cvc"]  as? String,
                let expDataAlias = data["card_expirationDate"]  as? String  {
                
                let cardData = SecuredCardData.init(cardNumberAlias: cardNumberAlias, cvcAlias: cvcAlias, expDataAlias: expDataAlias, cardNumberLast4: last4, cardBrand: brand)
                self?.onCompletion?(cardData)
                self?.dismiss(animated: true, completion: nil)
                
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
        let userInfo = notification.userInfo
        
        guard keyboardVisible == false else {
            return
        }
        keyboardVisible = true
        
        if let info = userInfo, let kbRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let height = kbRect.size.height - 40.0
            self.maxLevel = height
            self.containerViewBottomConstraint.constant = height
            UIView.animate(withDuration: 10, delay: 0, options: .curveEaseInOut, animations: {
                self.bluredBackground.alpha = 0.9
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
}


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
    
    /// Sensitive data aliases
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
    var cardExpDate = VGSExpDateTextField()
    var cardCVCNumber = VGSTextField()
    var scanController: VGSCardScanController?
    
    // Helpers
    var isKeyboardVisible = false
    var maxLevel = 0 as CGFloat
    var initialTouchPoint = CGPoint.zero

    var onCompletion: ((SecuredCardData) -> Void )?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Add UI elements to ViewController
        arrangeTextFields()
        
        /// Setup UI attributes and configuration
        setupTextFieldConfigurations()
        
      /// Update and edit payment card brands
        updatePaymentCardBrands()
      
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

        let bottomStackView = UIStackView.init(arrangedSubviews: [cardExpDate, cardCVCNumber, scanButton])
        bottomStackView.axis = .horizontal
        bottomStackView.alignment = .fill
        bottomStackView.distribution = .fillEqually
        bottomStackView.spacing = 20
        cardDataStackView.addArrangedSubview(bottomStackView)
    }
    
    private func setupTextFieldConfigurations() {
        let placeholderColor = UIColor(white: 1, alpha: 0.8)
      
        // MARK: - Card Number Field
      
        /// Init card number field configuration with VGSCollect instance.
        let cardConfiguration = VGSConfiguration(collector: collector, fieldName: "card_number")
        
        /// Setup field type. For each specific FieldType  built-in validation, default text format and other specific attributes will be applied.
        cardConfiguration.type = .cardNumber
        
        /// Set input should be .isRequiredValidOnly = true. Then user couldn't send card number that is not valid. VGSCollect.sendData(_:) will return specific VGSError in that case.
        cardConfiguration.isRequiredValidOnly = true
        
        /// Set preffered keyboard color
        cardConfiguration.keyboardAppearance = .dark
      
        /// Enable unknown card brands validation with Luhn algorithm
        cardConfiguration.validationRules = VGSValidationRuleSet(rules: [
          VGSValidationRulePaymentCard.init(error: VGSValidationErrorType.cardNumber.rawValue, validateUnknownCardBrand: true)
        ])
        
        /// Set configuration instance to textfield that will collect card number
        cardNumber.configuration = cardConfiguration
        
        /// Setup UI attributes
        cardNumber.attributedPlaceholder = NSAttributedString(string: "4111 1111 1111 1111", attributes: [NSAttributedString.Key.foregroundColor: placeholderColor])
        
        // MARK: - Card Expiration Date Field
        /// Set expiration data field configuration with same collector but specific fieldName
        let expDateConfiguration = VGSConfiguration(collector: collector, fieldName: "card_expirationDate")
        
        /// Set input .isRequired = true if you need textfield input be not empty or nil.  Then user couldn't send expiration date that is empty or nil. VGSCollect.sendData(_:) will return specific VGSError in that case.
        expDateConfiguration.isRequired = true
        expDateConfiguration.type = .expDate
        expDateConfiguration.keyboardAppearance = .light
        
        cardExpDate.configuration = expDateConfiguration
      
        /// Add keyboard accessory view on top of UIPicker to handle actions
        cardExpDate.keyboardAccessoryView = makeAccessoryView()
        cardExpDate.attributedPlaceholder = NSAttributedString(string: "11/22", attributes: [NSAttributedString.Key.foregroundColor: placeholderColor])
        cardExpDate.textAlignment = .center
        
        // MARK: - Card CVC Field
        /// Set cvc data field configuration with same collector but specific fieldName
        let cvcConfiguration = VGSConfiguration(collector: collector, fieldName: "card_cvc")
        cvcConfiguration.isRequired = true
        cvcConfiguration.type = .cvc
        cvcConfiguration.keyboardAppearance = .dark
        
        cardCVCNumber.configuration = cvcConfiguration
        cardCVCNumber.isSecureTextEntry = true
        cardCVCNumber.attributedPlaceholder = NSAttributedString(string: "CVC", attributes: [NSAttributedString.Key.foregroundColor: placeholderColor])
        cardCVCNumber.textAlignment = .center

        // MARK: - Card Holder Name Field
        /// Set cvc data field configuration with same collector but specific fieldName
        let cardHolderConfiguration = VGSConfiguration(collector: collector, fieldName: "cardholder_name")
        cardHolderConfiguration.type = .cardHolderName
        cardHolderConfiguration.keyboardAppearance = .dark
        
        cardHolderName.configuration = cardHolderConfiguration
        cardHolderName.attributedPlaceholder = NSAttributedString(string: "Cardholder Name", attributes: [NSAttributedString.Key.foregroundColor: placeholderColor])
      
      
        // MARK: - Set Fields UI attributes
        collector.textFields.forEach({
          $0.textColor = .white
          $0.tintColor = .white
          $0.font = UIFont.systemFont(ofSize: 22)
          $0.padding = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
          $0.delegate = self
        })
      
       
    }
  
    /// Update and edit card brands. NOTE: this can be done once in AppDelegate
    func updatePaymentCardBrands() {
      
      /// Edit default card brand validation rules
      VGSPaymentCards.visa.cardNumberLengths = [16]
      VGSPaymentCards.visa.formatPattern = "#### #### #### ####"
    
      /// Add custom brand - Spacy Master. Test with "911 11111111 1111" number.
      let customCardBrandModel = VGSCustomPaymentCardModel(name: "Spacy Master",
                                                           regex: "^91\\d*$",
                                                           formatPattern: "### ######## ####",
                                                           cardNumberLengths: [15],
                                                           cvcLengths: [3, 4],
                                                           checkSumAlgorithm: .luhn,
                                                           brandIcon: UIImage(named: "spacy_master"))
      VGSPaymentCards.cutomPaymentCardModels.append(customCardBrandModel)
    }
    
    //MARK: - Card Scan
    @objc func scan() {
        /// Init and present card.io scanner. If scanned data is valid it will be set automatically  into VGSTextFields, you should implement VGSCardIOScanControllerDelegate for this.
        scanController = VGSCardScanController(apiKey: "YOUR_API_KET", delegate: self)
        scanController?.presentCardScanner(on: self, animated: true, completion: nil)
    }
    
    //MARK: - Send Data
    /// Send sensetive data to VGS and get alieses.
    @IBAction func save(_ sender: Any) {
        /// Before sending data to VGS, you should probably want to check if it's valid.
       
        let notValidFields = collector.textFields.filter({ $0.state.isValid == false })
        if notValidFields.count > 0 {
          notValidFields.forEach({
            $0.borderColor = .red
            print($0.state.validationErrors)
          })
          return
        }
        
        /// Also you can grab not sensetive data form CardState attribures
        let cardState = cardNumber.state as? CardState
        let bin = cardState?.bin ?? ""
        let last4 = cardState?.last4 ?? ""
        let brand = cardState?.cardBrand.stringValue ?? ""
        
        /// Add any additional data to request
        let extraData = ["customData": "customValue",
                         "cardBrand": brand]
        /**
        Send data to VGS
        For this demo app we send data to our echo server.
        The data goes through VGS Inpound proxy, where you have your Routs setup.
        When the data reach VGS Inpound proxy, fields with sensitive data will be redacted to aliases, which you can store and use securely later.
        Our echo server will return response with same body structure as you send, but fields will have aliases as values instead of original data.

        However in your production app on sendData(_:) request, the data will go through VGS Inpound proxy to your backend or any other url that you configure in your Organization vault. It's your backend responsibility to setup response structure.
         
         Check our Documentation to know more about Sending data to VGS: https://www.verygoodsecurity.com/docs/vgs-collect/ios-sdk/submit-data ,
         and Inbound connections: https://www.verygoodsecurity.com/docs/guides/inbound-connection
        */
        
      collector.sendData(path: "/post", extraData: extraData, completion: { [weak self](result) in
        /// Check response. If success, you should get aliases data that you can use later or store on your backend.
        /// If you see raw(not tokenized)  data in response  - check the Routs configuration  for Inbound requests on Dashboard.
        switch result {
          case .success(let code, let data, _):
            print("Success: \(code)")
            
            /// Parse response from echo server
            guard let data = data,
              let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let cardDataDict = jsonData["json"] as? [String: Any],
              let cardNumberAlias = cardDataDict["card_number"] as? String,
              let cvcAlias = cardDataDict["card_cvc"]  as? String,
              let expDataAlias = cardDataDict["card_expirationDate"]  as? String  else {
                  self?.showAlert(title: "Error", text: "Somethin went wrong!")
                  return
            }
            
            let cardData = SecuredCardData(cardNumberAlias: cardNumberAlias, cvcAlias: cvcAlias, expDataAlias: expDataAlias, cardNumberBin: bin, cardNumberLast4: last4, cardBrand: brand)
            self?.onCompletion?(cardData)
            self?.dismiss(animated: false, completion: nil)
            
          case .failure(let code, _, _, let error):
            switch code {
            case 400..<499:
              // Wrong request. This also can happend when your Routs not setup yet or your <vaultId> is wrong
              self?.showAlert(title: "Error - \(code)", text: "Wrong request!")
            case VGSErrorType.inputDataIsNotValid.rawValue:
              if let error = error as? VGSError {
                self?.showAlert(title: "Error - \(code)", text:  "Input data is not valid. Details:\n \(error)")
              }
            default:
              self?.showAlert(title: "Error - \(code)", text: "Somethin went wrong!")
            }
            print("Failure: \(code)")
        }
      })
  }
}

// MARK: - VGSTextFieldDelegate
/// Handle VGSTextField Delegate funtions
extension CollectCreditCardDataViewController: VGSTextFieldDelegate {
  
  /// Check active vgs textfield's state when editing the field
  func vgsTextFieldDidChange(_ textField: VGSTextField) {
    textField.borderColor = .white
    print(textField.state.description)
  }
}

// MARK: - VGSCardIOScanControllerDelegate
/// Handle Card Scanning Delegate
extension CollectCreditCardDataViewController: VGSCardScanControllerDelegate {
    
    /// Set in which VGSTextField scanned data with type should be set. Called after user select Done button, just before userDidFinishScan() delegate.
    func textFieldForScannedData(type: CradScanDataType) -> VGSTextField? {
        switch type {
        case .cardNumber:
            return cardNumber
        case .expirationDate:
            return cardExpDate
        case .name:
            return cardHolderName
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
      scanController?.dismissCardScanner(animated: true, completion: { [weak self] in
        self?.cardCVCNumber.becomeFirstResponder()
      })
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
  
    func makeAccessoryView() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
        view.backgroundColor = UIColor(red: 0.03, green: 0.04, blue: 0.09, alpha: 0.5)
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Next", for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.addTarget(self, action: #selector(expDateButtonAction), for: .touchUpInside)
        
        view.addSubview(doneButton)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        let views = ["button": doneButton]
        let h = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(>=15)-[button]-(15)-|",
                                               options: .alignAllCenterY,
                                               metrics: nil,
                                               views: views)
        NSLayoutConstraint.activate(h)
        let v = NSLayoutConstraint.constraints(withVisualFormat: "V:|[button]|",
                                               options: .alignAllCenterX,
                                               metrics: nil,
                                               views: views)
        NSLayoutConstraint.activate(v)
        return view
    }
  
  @objc func expDateButtonAction() {
      self.cardCVCNumber.becomeFirstResponder()
  }
}

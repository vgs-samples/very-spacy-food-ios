//
//  CardHolderTextFieldView.swift
//  Spacy Food
//
//  Created by Dima on 30.03.2020.
//  Copyright © 2020 Very Good Security. All rights reserved.
//

import Foundation
import UIKit

class CardHolderTextFieldView: UIView {
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    
    class func fromNib() -> CardHolderTextFieldView? {
        return Bundle.main.loadNibNamed(String(describing: "CardHolderTextFieldView"), owner: nil, options: nil)?.first as? CardHolderTextFieldView
    }
}

//
//  LoadingView.swift
//  Spacy Food
//
//  Created by Dima on 24.03.2020.
//  Copyright © 2020 Very Good Security. All rights reserved.
//

import Foundation
import UIKit

class LoadingView: UIView {
    
    class func fromNib() -> LoadingView? {
           return Bundle.main.loadNibNamed(String(describing: "LoadingView"), owner: nil, options: nil)?.first as? LoadingView
       }
}

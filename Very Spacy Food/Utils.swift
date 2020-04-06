//
//  Utils.swift
//  Spacy Food
//
//  Created by Dima on 30.03.2020.
//  Copyright © 2020 Very Good Security. All rights reserved.
//

import Foundation
import UIKit

extension Double {
    func truncate(places : Int)-> Double
    {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}

extension UIStoryboard {
    
    class var main: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: Bundle.main)
    }
}

extension UIColor {

    static var spacyGreen: UIColor {
        return UIColor(red: 0.18, green: 0.69, blue: 0.569, alpha: 1)
    }
    
    static var spacyOrange: UIColor {
        return UIColor(red: 0.925, green: 0.655, blue: 0.365, alpha: 1)
    }
    
    static var spacyRed: UIColor {
        return UIColor(red: 0.783, green: 0.345, blue: 0.32, alpha: 1)
    }
    
    static var spacyPink: UIColor {
        return UIColor(red: 0.833, green: 0.483, blue: 0.609, alpha: 1)
    }
    
    static var spacyYellow: UIColor {
        return UIColor(red: 1, green: 0.773, blue: 0.371, alpha: 1)
    }
    
    static var lightBlueColorsSet: [CGColor] {
        return [UIColor(red: 0.18, green: 0.34, blue: 0.70, alpha: 1).cgColor,
                UIColor(red: 0.04, green: 0.07, blue: 0.15, alpha: 1).cgColor]
    }
    
    static var midBlueColorsSet: [CGColor] {
        return [UIColor(red: 0.11, green: 0.16, blue: 0.27, alpha: 1).cgColor,
                UIColor(red: 0.03, green: 0.04, blue: 0.09, alpha: 1).cgColor]
    }
}

extension UIView {
    
    func addGradient(_ colors: [CGColor]) {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colors
        gradient.startPoint = CGPoint.init(x: 0, y: 0)
        gradient.endPoint = CGPoint.init(x: 1, y: 1)
        self.layer.insertSublayer(gradient, at: 0)
    }
}

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

}

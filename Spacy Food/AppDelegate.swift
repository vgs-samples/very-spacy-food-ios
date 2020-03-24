//
//  AppDelegate.swift
//  Spacy Food
//
//  Created by Dima on 11.03.2020.
//  Copyright © 2020 Very Good Security. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UITextField.appearance().keyboardAppearance = UIKeyboardAppearance.dark
        return true
    }

}


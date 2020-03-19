//
//  MenuViewController.swift
//  Spacy Food
//
//  Created by Dima on 13.03.2020.
//  Copyright © 2020 Very Good Security. All rights reserved.
//

import Foundation
import UIKit

class MenuViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackgroundView()
        //setup TableView
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.reloadData()
    }
    
    func setupBackgroundView() {
        let amount = 100

        let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontal.minimumRelativeValue = -amount
        horizontal.maximumRelativeValue = amount

        let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        vertical.minimumRelativeValue = -amount
        vertical.maximumRelativeValue = amount

        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontal, vertical]
        backgroundImageView.addMotionEffect(group)
    }
    
    @IBAction func addPaymentMethodAction(_ sender: UIButton) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let collectCardVC : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "CollectCreditCardDataViewController") as! CollectCreditCardDataViewController
        self.present(collectCardVC, animated: true, completion: nil)
    }
}

extension MenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemCell", for: indexPath)
        return cell
    }
}

extension MenuViewController: UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let detailsVC : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "MenuItemDetailsViewController") as! MenuItemDetailsViewController
        self.present(detailsVC, animated: true, completion: nil)
    }
}


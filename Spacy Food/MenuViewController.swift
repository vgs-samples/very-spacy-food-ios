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
    @IBOutlet weak var checkoutButton: UIButton!
    @IBOutlet weak var counterLabel: UILabel!
    
    var orderItemsCount: Int = 0 {
        didSet {
            counterLabel.text = "\(orderItemsCount)"
        }
    }
    
    var securedCardData: SecuredCardData? {
        didSet {
            let title = securedCardData == nil ? "Add payment method" : "Checkout"
            checkoutButton.setTitle(title, for: .normal)
        }
    }
    
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
        
        self.navigationController?.navigationBar.tintColor = .white
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
    
    
    
    @IBAction func checkoutAction(_ sender: UIButton) {
        if let securedCardData = securedCardData {
            proceedToCheckout([Any](), cardData: securedCardData)
        } else {
            showCollectCardDataView()
        }
    }
    
    private func showCollectCardDataView() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let collectCardVC = mainStoryboard.instantiateViewController(withIdentifier: "CollectCreditCardDataViewController") as! CollectCreditCardDataViewController
        collectCardVC.onCompletion = { [weak self] (cardData) in
            self?.securedCardData = cardData
        }
        self.present(collectCardVC, animated: true, completion: nil)
    }
    
    private func proceedToCheckout(_ orderItems: [Any], cardData: SecuredCardData) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let checkoutVC = mainStoryboard.instantiateViewController(withIdentifier: "CheckoutViewController") as! CheckoutViewController
        checkoutVC.orderItems = orderItems
        checkoutVC.securedCardData = cardData
        self.navigationController?.pushViewController(checkoutVC, animated: true)
    }
}

extension MenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemCell", for: indexPath) as? MenuItemCell
        cell?.onAddItemClicked = { [weak self] in
            self?.orderItemsCount += 1
        }
        return cell ?? UITableViewCell()
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
        let detailsVC = mainStoryboard.instantiateViewController(withIdentifier: "MenuItemDetailsViewController") as! MenuItemDetailsViewController
        detailsVC.onItemAdded = { [weak self] item in
            self?.orderItemsCount += 1
        }
        self.present(detailsVC, animated: true, completion: nil)
    }
}



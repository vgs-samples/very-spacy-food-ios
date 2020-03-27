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
    
    let haptic = UIImpactFeedbackGenerator()

    var orderItemsCount: Int = 0 {
        didSet {
            counterLabel.text = "\(orderItemsCount)"
            haptic.impactOccurred()
        }
    }
    
    var orderPrice: Double = 0.0
    
    lazy var menuItems: [MenuItem] = {
        return getAvailableMenuItems()
    }()
    
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
            haptic.impactOccurred()
        }
    }
    
    private func showCollectCardDataView() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let collectCardVC = mainStoryboard.instantiateViewController(withIdentifier: "CollectCreditCardDataViewController") as! CollectCreditCardDataViewController
        collectCardVC.modalPresentationStyle = .overCurrentContext
        collectCardVC.onCompletion = { [weak self] (cardData) in
            self?.securedCardData = cardData
        }
        self.present(collectCardVC, animated: false, completion: nil)
    }
    
    private func proceedToCheckout(_ orderItems: [Any], cardData: SecuredCardData) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let checkoutVC = mainStoryboard.instantiateViewController(withIdentifier: "CheckoutViewController") as! CheckoutViewController
        checkoutVC.orderPrice = orderPrice
        checkoutVC.securedCardData = cardData
        self.navigationController?.pushViewController(checkoutVC, animated: true)
    }
}

extension MenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemCell", for: indexPath) as? MenuItemCell
        let menuItem = menuItems[indexPath.row]
        cell?.name.text = menuItem.name
        cell?.ingredients.text = menuItem.ingredients
        cell?.price.text = "$\(menuItem.price)"
        cell?.itemImage.image = UIImage(named: menuItem.imgName)
        
        cell?.onAddItemClicked = { [weak self] in
            self?.orderItemsCount += 1
            self?.orderPrice += menuItem.price
        }
        return cell ?? UITableViewCell()
    }
}

extension MenuViewController: UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let selectedItem = menuItems[indexPath.row]
        let detailsVC = mainStoryboard.instantiateViewController(withIdentifier: "MenuItemDetailsViewController") as! MenuItemDetailsViewController
        detailsVC.menuItem = selectedItem
        detailsVC.onItemAdded = { [weak self] item in
            self?.orderItemsCount += 1
            self?.orderPrice += selectedItem.price
        }
        detailsVC.modalPresentationStyle = .overCurrentContext
        self.present(detailsVC, animated: true, completion: nil)
    }
}

extension MenuViewController {
    
    func getAvailableMenuItems() -> [MenuItem] {
        return [
            MenuItem(imgName: "menu_item_1", name: "Pluto roll", ingredients: "Fresh salmon with avocado, philadelphia, and cucumber, spruced with a pinch of sesame", weight: "360g", price: 14.49),
            MenuItem(imgName: "menu_item_2", name: "Mars Pizza", ingredients: "This pizza is topped with authentic Italian salami, peppers, Parmesan cheese, and spices", weight: "680g", price: 12.25),
            MenuItem(imgName: "menu_item_3", name: "Sunburger", ingredients: "Pure beef topped with a fresh tomato, chopped onions, ketchup, mustard, and a slice of melty cheddar", weight: "500g", price: 17.15),
            MenuItem(imgName: "menu_item_4", name: "Alien noodle", ingredients: "Buttery, garlicky noodles served with a boiled egg, green beans, and juicy jumbo shrimp", weight: "640g", price: 13.49),
            MenuItem(imgName: "menu_item_5", name: "Venus fries", ingredients: "Crunchy potato fries with tomato sauce dip is a nutrishious side dish", weight: "150", price: 8.99),
        ]
    }

}



extension Double
{
    func truncate(places : Int)-> Double
    {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}

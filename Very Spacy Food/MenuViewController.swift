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
    @IBOutlet weak var checkoutButton: UIButton!
    @IBOutlet weak var counterLabel: UILabel!
    
    var securedCardData: SecuredCardData? {
        didSet {
            let title = securedCardData == nil ? "Add payment method" : "Checkout"
            checkoutButton.setTitle(title, for: .normal)
        }
    }
    var orderPrice: Double = 0.0
    var orderItemsCount: Int = 0 {
        didSet {
            counterLabel.text = "\(orderItemsCount)"
        }
    }
    lazy var menuItems: [MenuItem] = {
        return getAvailableMenuItems()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        view.addGradient(UIColor.midBlueColorsSet)
    }
    
    @IBAction func checkoutAction(_ sender: UIButton) {
        if let securedCardData = securedCardData {
            guard orderItemsCount > 0 else {
                return
            }
            proceedToCheckout([Any](), cardData: securedCardData)
        } else {
            showCollectCardDataView()
        }
    }
}

//MARK: - UITableViewDataSource, UITableViewDelegate
extension MenuViewController: UITableViewDataSource, UITableViewDelegate {
    
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = menuItems[indexPath.row]
        let detailsVC = UIStoryboard.main.instantiateViewController(withIdentifier: "MenuItemDetailsViewController") as! MenuItemDetailsViewController
        detailsVC.menuItem = selectedItem
        detailsVC.onItemAdded = { [weak self] item in
            self?.orderItemsCount += 1
            self?.orderPrice += selectedItem.price
        }
        detailsVC.modalPresentationStyle = .overCurrentContext
        self.present(detailsVC, animated: true, completion: nil)
    }
}

//MARK: - Navigation
extension MenuViewController {
    
    private func showCollectCardDataView() {
        let collectCardVC = UIStoryboard.main.instantiateViewController(withIdentifier: "CollectCreditCardDataViewController") as! CollectCreditCardDataViewController
        collectCardVC.modalPresentationStyle = .overCurrentContext
        collectCardVC.onCompletion = { [weak self] (cardData) in
            self?.securedCardData = cardData
        }
        self.present(collectCardVC, animated: false, completion: nil)
    }
    
    private func proceedToCheckout(_ orderItems: [Any], cardData: SecuredCardData) {
        let checkoutVC = UIStoryboard.main.instantiateViewController(withIdentifier: "CheckoutViewController") as! CheckoutViewController
        checkoutVC.orderPrice = orderPrice
        checkoutVC.securedCardData = cardData
        self.navigationController?.pushViewController(checkoutVC, animated: true)
    }

}

//MARK: - Helpers
extension MenuViewController {
    
    func getAvailableMenuItems() -> [MenuItem] {
        return [
            MenuItem(imgName: "menu_item_1", name: "Pluto roll", ingredients: "Fresh salmon with avocado, philadelphia, and cucumber, spruced with a pinch of sesame", weight: "360g", price: 14.49, associatedColor: .spacyPink),
            MenuItem(imgName: "menu_item_2", name: "Mars Pizza", ingredients: "This pizza is topped with authentic Italian salami, peppers, Parmesan cheese, and spices", weight: "680g", price: 12.25, associatedColor: .spacyRed),
            MenuItem(imgName: "menu_item_3", name: "Sunburger", ingredients: "Pure beef topped with a fresh tomato, chopped onions, ketchup, mustard, and a slice of melty cheddar", weight: "500g", price: 17.15, associatedColor: .spacyOrange),
            MenuItem(imgName: "menu_item_4", name: "Alien noodle", ingredients: "Buttery, garlicky noodles served with a boiled egg, green beans, and juicy jumbo shrimp", weight: "640g", price: 13.49, associatedColor: .spacyGreen),
            MenuItem(imgName: "menu_item_5", name: "Venus fries", ingredients: "Crunchy potato fries with tomato sauce dip is a nutrishious side dish", weight: "150", price: 8.99, associatedColor: .spacyYellow)
        ]
    }
    
    func setupTableView() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.reloadData()
    }
}


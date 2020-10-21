//
//  Very_Very_Spacy_FoodUITests.swift
//  Very Very Spacy FoodUITests
//
//  Created by Dima on 30.07.2020.
//  Copyright © 2020 Very Good Security. All rights reserved.
//

import XCTest

class Very_Very_Spacy_FoodUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
      
      let app = XCUIApplication()
      app.launch()
      app.buttons["Add payment method"].tap()
      
      let expDateTextField = app.textFields["11/22"]
      let cvcTextField = app.secureTextFields["CVC"]
      let holderNameTextField = app.textFields["Cardholder Name"]
      let cardNumberTextField = app.textFields["4111 1111 1111 1111"]
      
      
      holderNameTextField.tap()
      holderNameTextField.typeText("Spacy K")
      
      cardNumberTextField.tap()
      cardNumberTextField.typeText("378282246310005")
      
      expDateTextField.tap()
      app.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "July")
      app.pickerWheels.element(boundBy: 0).tap()
      app.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: "2024")
      app.pickerWheels.element(boundBy: 1).tap()
      
      cvcTextField.tap()
      cvcTextField.typeText("1234")
      
      app.buttons["scan icon"].tap()
      let popup = app.alerts["“Very Spacy Food” Would Like to Access the Camera"]
      if popup.exists {
        popup.buttons["OK"].tap()
      }
      app.buttons["Back"].tap()
      
      app.buttons["Save"].tap()
    }
}

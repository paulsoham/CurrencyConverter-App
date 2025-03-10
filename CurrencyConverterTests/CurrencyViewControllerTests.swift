//
//  CurrencyViewControllerTests.swift
//  CurrencyConverterTests
//
//  Created by SOHAM PAUL on 26/01/25.
//

import XCTest

@testable import CurrencyConverter

class CurrencyViewControllerTests: XCTestCase {
    var sut: CurrencyViewController!
    var viewModel: CurrencyViewModel!
    
    override func setUp() {
        super.setUp()
        let apiService = MockAPIService()
        let persistenceService = MockPersistenceService()
        viewModel = CurrencyViewModel(apiService: apiService, persistenceService: persistenceService)
        sut = CurrencyViewController(viewModel: viewModel)
        sut.loadViewIfNeeded()
    }
    
    override func tearDown() {
        sut = nil
        viewModel = nil
        super.tearDown()
    }
    
    func testAmountTextFieldExists() {
        let textField = sut.view.viewWithTag(1) as? UITextField
        XCTAssertNotNil(textField, "Amount text field should exist.")
    }
    
    func testCurrencyButtonExists() {
        let button = sut.view.viewWithTag(2) as? UIButton
        XCTAssertNotNil(button, "Currency button should exist.")
    }
    
    func testCurrencyPickerExists() {
        let picker = sut.view.viewWithTag(3) as? UIPickerView
        XCTAssertNotNil(picker, "Currency picker should exist.")
    }
    
    func testConversionGridExists() {
        let collectionView = sut.view.viewWithTag(4) as? UICollectionView
        XCTAssertNotNil(collectionView, "Conversion grid should exist.")
    }
    
}

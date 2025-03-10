//
//  CurrencyViewModelTests.swift
//  CurrencyConverterTests
//
//  Created by SOHAM PAUL on 26/01/25.
//

// CurrencyViewModelTests.swift

import XCTest
import Combine

@testable import CurrencyConverter

class CurrencyViewModelTests: XCTestCase {
    
    var viewModel: CurrencyViewModel!
    var mockAPIService: MockAPIService!
    var mockPersistenceService: MockPersistenceService!
    
    override func setUp() {
        super.setUp()
        mockAPIService = MockAPIService()
        mockPersistenceService = MockPersistenceService()
        viewModel = CurrencyViewModel(apiService: mockAPIService, persistenceService: mockPersistenceService)
    }
    
    func testInit_SetsDefaultValues() {
        XCTAssertEqual(viewModel.baseCurrency, "USD")
        XCTAssertEqual(viewModel.lastUpdated, nil)
        XCTAssertEqual(viewModel.isLoading, false)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, "Failed to fetch exchange rates: The operation couldn’t be completed. (NSURLErrorDomain error -1100.)")
        XCTAssertEqual(viewModel.exchangeRates, [:])
    }
    
    func testSetup_SetsExchangeRates() {
        let exchangeRates = ["USD": 1.0, "EUR": 0.9]
        viewModel.setup(exchangeRates: exchangeRates)
        XCTAssertEqual(viewModel.exchangeRates, exchangeRates)
    }
    
    func testFetchExchangeRates_CachedRatesAreValid_ReturnsCachedRates() {
        let cachedRates = ExchangeRatesResponse(rates: ["USD": 1.0, "EUR": 0.9], base: "USD", timestamp: Date().timeIntervalSince1970)
        mockPersistenceService.stubFetch(forKey: "exchangeRates", value: cachedRates)
        viewModel.fetchExchangeRates()
        XCTAssertEqual(viewModel.exchangeRates, cachedRates.rates)
        XCTAssertEqual(viewModel.lastUpdated, Date(timeIntervalSince1970: cachedRates.timestamp))
    }
    
    func testFetchExchangeRates_CachedRatesAreInvalid_FetchesNewRates() {
        mockAPIService.fileName = "latest"
        let cachedRates = ExchangeRatesResponse(rates: ["USD": 1.0, "EUR": 0.9], base: "USD", timestamp: Date().timeIntervalSince1970 - 2000)
        mockPersistenceService.stubFetch(forKey: "exchangeRates", value: cachedRates)
        viewModel.fetchExchangeRates()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertNotNil(self.viewModel.exchangeRates)
            XCTAssertNotNil(self.viewModel.lastUpdated)
        }
        Thread.sleep(forTimeInterval: 0.2)
    }
    
    func testFetchExchangeRates_APIError_ReturnsError() {
        mockAPIService.fileName = nil
        viewModel.fetchExchangeRates()
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.exchangeRates, [:])
    }
    
    func testConvert_ValidInput_ReturnsConversions() {
        let exchangeRates = ["USD": 1.0, "EUR": 0.9, "GBP": 0.8]
        viewModel.exchangeRates = exchangeRates
        let conversions = viewModel.convert(amount: 100, from: "USD", to: "EUR,GBP")
        XCTAssertEqual(conversions, ["EUR": 90.0, "GBP": 80.0])
    }
    
    func testConvert_InvalidInput_ReturnsEmpty() {
        let exchangeRates = ["USD": 1.0, "EUR": 0.9, "GBP": 0.8]
        viewModel.exchangeRates = exchangeRates
        let conversions = viewModel.convert(amount: 100, from: "Invalid", to: "EUR,GBP")
        XCTAssertEqual(conversions, [:])
    }
}



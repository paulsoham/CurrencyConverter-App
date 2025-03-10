//
//  PersistenceServiceTests.swift
//  CurrencyConverterTests
//
//  Created by SOHAM PAUL on 26/01/25.
//

import XCTest

@testable import CurrencyConverter

class PersistenceServiceTests: XCTestCase {
    
    var persistenceService: PersistenceService!
    
    override func setUp() {
        super.setUp()
        persistenceService = PersistenceService()
    }
    
    override func tearDown() {
        super.tearDown()
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
    }
    
    func testSaveExchangeRates_ValidRates_Succeeds() {
        let exchangeRates = ["USD": 1.0, "EUR": 0.9]
        persistenceService.save(exchangeRates, forKey: "exchangeRates")
        let savedExchangeRates: [String: Double]? = persistenceService.fetch(forKey: "exchangeRates")
        XCTAssertNotNil(savedExchangeRates)
        XCTAssertEqual(savedExchangeRates?["USD"], 1.0)
        XCTAssertEqual(savedExchangeRates?["EUR"], 0.9)
    }
    
    func testSaveExchangeRates_NilRates_Fails() {
        persistenceService.save(nil as [String: Double]?, forKey: "exchangeRates")
        let savedExchangeRates: [String: Double]? = persistenceService.fetch(forKey: "exchangeRates")
        XCTAssertNil(savedExchangeRates)
    }
    
    func testFetchExchangeRates_ValidKey_ReturnsRates() {
        let exchangeRates = ["USD": 1.0, "EUR": 0.9]
        persistenceService.save(exchangeRates, forKey: "exchangeRates")
        let fetchedExchangeRates: [String: Double]? = persistenceService.fetch(forKey: "exchangeRates")
        XCTAssertNotNil(fetchedExchangeRates)
        XCTAssertEqual(fetchedExchangeRates?["USD"], 1.0)
        XCTAssertEqual(fetchedExchangeRates?["EUR"], 0.9)
    }
    
    func testFetchExchangeRates_InvalidKey_ReturnsNil() {
        let fetchedExchangeRates: [String: Double]? = persistenceService.fetch(forKey: "invalidKey")
        XCTAssertNil(fetchedExchangeRates)
    }
    
    func testFetchExchangeRates_InvalidData_ReturnsNil() {
        UserDefaults.standard.set("Invalid data".data(using: .utf8), forKey: "exchangeRates")
        let fetchedExchangeRates: [String: Double]? = persistenceService.fetch(forKey: "exchangeRates")
        XCTAssertNil(fetchedExchangeRates)
    }
}

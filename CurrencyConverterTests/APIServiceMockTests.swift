//
//  APIServiceMockTests.swift
//  CurrencyConverterTests
//
//  Created by SOHAM PAUL on 26/01/25.
//

import XCTest

@testable import CurrencyConverter

final class APIServiceMockTests: XCTestCase {
    
    var mockService: MockAPIService!
    
    override func setUp() {
        super.setUp()
        mockService = MockAPIService()
    }
    
    override func tearDown() {
        mockService = nil
        super.tearDown()
    }
    
    func testFetchDataSuccess() {
        mockService.fileName = "MockJson"
        
        let expectation = XCTestExpectation(description: "Fetch data from mock JSON")
        
        mockService.fetchData(endpoint: "latest") { (result: Result<CurrencyRatesResponse, Error>) in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.base, "USD")
                XCTAssertNotNil(response.rates["EUR"])
                XCTAssertEqual(response.rates["EUR"], 0.952744)
            case .failure(let error):
                XCTFail("Expected success but got failure with error: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testFetchDataFailure() {
        mockService.fileName = "InvalidFileName"
        
        let expectation = XCTestExpectation(description: "Fetch data from non-existent JSON file")
        
        mockService.fetchData(endpoint: "invalid") { (result: Result<CurrencyRatesResponse, Error>) in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertTrue(error is URLError, "Expected URLError but got \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
}


struct CurrencyRatesResponse: Decodable {
    let disclaimer: String
    let license: String
    let timestamp: Int
    let base: String
    let rates: [String: Double]
}

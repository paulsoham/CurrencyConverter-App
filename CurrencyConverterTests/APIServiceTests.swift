//
//  APIServiceTests.swift
//  CurrencyConverterTests
//
//  Created by SOHAM PAUL on 26/01/25.
//

import XCTest

@testable import CurrencyConverter

class APIServiceTests: XCTestCase {
    
    var apiService: APIService!
    
    override func setUp() {
        super.setUp()
        apiService = APIService()
    }
    
    override func tearDown() {
        apiService = nil
        super.tearDown()
    }
    
    func testFetchDataSuccess() {
        let expectation = self.expectation(description: "API call succeeds")
        let endpoint = "latest.json"
        apiService.fetchData(endpoint: endpoint) { (result: Result<ExchangeRatesResponse, Error>) in
            switch result {
            case .success(let response):
                XCTAssertNotNil(response.rates)
                XCTAssertEqual(response.base, "USD")
            case .failure:
                XCTFail("Expected success, but got failure.")
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testFetchDataFailure() {
        let expectation = self.expectation(description: "API call fails")
        let invalidEndpoint = "invalidEndpoint.json"
        apiService.fetchData(endpoint: invalidEndpoint) { (result: Result<ExchangeRatesResponse, Error>) in
            switch result {
            case .success:
                XCTFail("Expected failure, but got success.")
            case .failure(let error):
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
}



//
//  MockPersistenceService.swift
//  CurrencyConverterTests
//
//  Created by SOHAM PAUL on 26/01/25.
//

import Foundation
import XCTest

@testable import CurrencyConverter

class MockPersistenceService: PersistenceServiceProtocol {
    var stubFetchValue: Any?
    
    func save<T: Encodable>(_ value: T, forKey key: String) {
        // Not implemented for this unit test
    }
    
    func fetch<T: Decodable>(forKey key: String) -> T? {
        return stubFetchValue as? T
    }
    
    func stubFetch(forKey key: String, value: Any?) {
        stubFetchValue = value
    }
}

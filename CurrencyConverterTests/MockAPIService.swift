//
//  MockAPIService.swift
//  CurrencyConverterTests
//
//  Created by SOHAM PAUL on 26/01/25.
//

import Foundation
import XCTest

@testable import CurrencyConverter

class MockAPIService: APIServiceProtocol {
    var fileName: String?
    
    func fetchData<T: Decodable>(endpoint: String, completion: @escaping (Result<T, Error>) -> Void) {
        guard let fileName = fileName,
              let url = Bundle(for: MockAPIService.self).url(forResource: fileName, withExtension: "json") else {
            completion(.failure(URLError(.fileDoesNotExist)))
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            completion(.success(decodedData))
        } catch {
            completion(.failure(error))
        }
    }
}

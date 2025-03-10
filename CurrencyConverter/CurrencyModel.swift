//
//  CurrencyModel.swift
//  CurrencyConverter
//
//  Created by SOHAM PAUL on 26/01/25.
//

import Foundation

// MARK: - ExchangeRatesResponse Model
struct ExchangeRatesResponse: Codable {
    let rates: [String: Double]
    let base: String
    let timestamp: TimeInterval
}

// MARK: - Currency Model
struct Currency: Codable, Equatable {
    let code: String
    let rate: Double
}


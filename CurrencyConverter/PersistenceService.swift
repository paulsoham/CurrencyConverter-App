//
//  PersistenceService.swift
//  CurrencyConverter
//
//  Created by SOHAM PAUL on 26/01/25.
//

import Foundation

// MARK: - PersistenceService Protocol
protocol PersistenceServiceProtocol {
    func save<T: Encodable>(_ object: T, forKey key: String)
    func fetch<T: Decodable>(forKey key: String) -> T?
}

// MARK: - PersistenceService
class PersistenceService: PersistenceServiceProtocol {
    func save<T: Encodable>(_ object: T, forKey key: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(object) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    func fetch<T: Decodable>(forKey key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(T.self, from: data)
    }
}

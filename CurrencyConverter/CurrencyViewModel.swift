//
//  CurrencyViewModel.swift
//  CurrencyConverter
//
//  Created by SOHAM PAUL on 26/01/25.
//

import Foundation
import Combine

class CurrencyViewModel: ObservableObject {
    private let apiService: APIServiceProtocol
    private let persistenceService: PersistenceServiceProtocol
    private let refreshInterval: TimeInterval = 1800
    
    @Published var baseCurrency: String = "USD"
    @Published var lastUpdated: Date?
    @Published var isLoading: Bool = false
    @Published var exchangeRates: [String: Double] = [:]
    @Published var errorMessage: String?
    
    private var cancellables: [AnyCancellable] = []
    
    init(apiService: APIServiceProtocol, persistenceService: PersistenceServiceProtocol) {
        self.apiService = apiService
        self.persistenceService = persistenceService
        fetchExchangeRates()
    }
    
    func setup(exchangeRates: [String: Double]) {
        self.exchangeRates = exchangeRates
    }
    
    func fetchExchangeRates() {
        isLoading = true
        
        // MARK: - Cache Data
        if let cachedRates: ExchangeRatesResponse = persistenceService.fetch(forKey: "exchangeRates") {
            let lastUpdated = Date(timeIntervalSince1970: cachedRates.timestamp)
            if Date().timeIntervalSince(lastUpdated) < refreshInterval {
                exchangeRates = cachedRates.rates
                self.lastUpdated = lastUpdated
                self.isLoading = false
                return
            }
        }
        // MARK: - Fetch from Server
        apiService.fetchData(endpoint: "latest.json") { [weak self] (result: Result<ExchangeRatesResponse, Error>) in
            self?.isLoading = false
            switch result {
            case .success(let response):
                self?.exchangeRates = response.rates
                self?.lastUpdated = Date()
                self?.persistenceService.save(response, forKey: "exchangeRates")
            case .failure(let error):
                self?.errorMessage = String(format: NSLocalizedString("fetch_exchange_rates_error", comment: "Error message when fetching exchange rates"), error.localizedDescription)
                self?.exchangeRates = [:]
            }
        }
        
    }
    
    // MARK: - Convert Currency Value
    func convert(amount: Double, from currencyFrom: String, to currencyTo: String) -> [String: Double] {
        guard let baseRate = exchangeRates[currencyFrom] else { return [:] }
        let targetCurrencies = currencyTo.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        var conversions: [String: Double] = [:]
        for targetCurrency in targetCurrencies {
            if let targetRate = exchangeRates[String(targetCurrency)] {
                conversions[String(targetCurrency)] = (targetRate / baseRate) * amount
            }
        }
        return conversions
    }
}




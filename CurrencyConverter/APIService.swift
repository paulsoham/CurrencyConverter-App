//
//  APIService.swift
//  CurrencyConverter
//
//  Created by SOHAM PAUL on 26/01/25.
//

import Foundation

// MARK: - APIServiceProtocol
protocol APIServiceProtocol {
    func fetchData<T: Decodable>(endpoint: String, completion: @escaping (Result<T, Error>) -> Void)
}

// MARK: - APIService
class APIService: APIServiceProtocol {
    
    private let baseURL = "https://openexchangerates.org/api/"
    private let appID = "5f9b3d6c3870480c98e6318bd29a0b50"
    
    func fetchData<T: Decodable>(endpoint: String, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)\(endpoint)?app_id=\(appID)") else {
            completion(.failure(APIServiceError.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(APIServiceError.networkError(error)))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIServiceError.serverError))
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(APIServiceError.decodingError(error)))
            }
        }
        task.resume()
    }
}


enum APIServiceError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case serverError
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString("invalid_url_error", comment: "Error when the URL is invalid.")
        case .networkError(let error):
            return String(format: NSLocalizedString("network_error", comment: "Network error description."), error.localizedDescription)
        case .serverError:
            return NSLocalizedString("server_error", comment: "Error when the server cannot be reached.")
        case .decodingError(let error):
            return String(format: NSLocalizedString("decoding_error", comment: "Error when decoding fails."), error.localizedDescription)
        }
    }
}

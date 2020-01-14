/*
* Copyright (c) TRANZZO LTD - All Rights Reserved
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
*/

import Foundation

public struct TokenSuccessResponse: Codable {
    public let token: String
}

public struct TokenEncryptSuccessResponse: Codable {
    public let data: String
}

public class TranzzoTokenizer {
    // MARK: - Private Properties
    private let apiToken: String
    private let environment: Environment
    private let urlSession = URLSession.shared
    private let decoder = DataDecoder()
    private let encoder = DataEncoder()
    
    // MARK: - Init
    public init(apiToken: String, environment: Environment) {
        self.apiToken = apiToken
        self.environment = environment
    }
    
    // MARK: - Public Methods
    /// Sends encoded `card` to Tranzzo servers
    ///
    /// - parameter card:          The `CardRequestData` value, make sure `rich` is set to `false`.
    /// - parameter result:        Closure, called when token data or an error is received
    public func tokenize(card: CardRequestData,
                         result: @escaping (Result<TokenSuccessResponse, TranzzoError>) -> Void) {
        fetch(card: card, completionHandler: result)
    }
    
    /// Sends encoded and ecrypted `card` to Tranzzo servers
    ///
    /// - parameter card:          The `CardRequestData` value, make sure `rich` is set to `true`.
    /// - parameter result:        Closure, called when token data or an error is received
    public func tokenizeEncrypt(card: CardRequestData,
                                result: @escaping (Result<TokenEncryptSuccessResponse, TranzzoError>) -> Void) {
        var richCard = card
        richCard.rich = true
        fetch(card: richCard, completionHandler: result)
    }
    
    // MARK: - Private Methods
    private func fetch<T>(card: CardRequestData,
                          completionHandler: @escaping (Result<T, TranzzoError>) -> Void) where T: Codable {
        let sign = self.encoder.stringEncode(card)?.hmac(key: apiToken)
        
        if var request = URLRequestBuilder.createURLRequest(to: environment.baseURL, requestData: .tokenize(card: card)) {
            request.setValue(sign, forHTTPHeaderField: "X-Sign")
            request.setValue(apiToken, forHTTPHeaderField: "X-Widget-Id")
            request.httpBody = try? encoder.encode(card)
            
            urlSession.dataTask(with: request) { (result) in
                switch result {
                case .success(let (response, data)):
                    guard
                        let statusCode = (response as? HTTPURLResponse)?.statusCode,
                        200..<299 ~= statusCode
                    else {
                        if let error = self.parseApiError(data: data) {
                            completionHandler(.failure(error))
                        }
                        return
                    }
                    do {
                        completionHandler(.success(try self.decoder.decode(T.self, from: data)))
                    } catch {
                        let error = TranzzoError(message: error.localizedDescription)
                        completionHandler(.failure(error))
                    }
                case .failure(let error):
                    completionHandler(.failure(TranzzoError(message: error.localizedDescription)))
                }
            }.resume()
        }
    }
    
    private func parseApiError(data: Data?) -> TranzzoError? {
        if let jsonData = data {
            return try? self.decoder.decode(TranzzoError.self, from: jsonData)
        }
        return TranzzoError(message: Constants.genericErrorMessage)
    }
    
}

//
//  CurrencyAPI.swift
//  JustCurrencyConverter
//
//  Created by Daniil Vodenejev on 28.10.2025.
//

import Foundation

protocol CurrencyAPITyping {
    func fetchLatestRates(apiKey: String) async throws -> RatesResponse
    func fetchCurrencies() async throws -> CurrencyList
}

struct CurrencyAPI: CurrencyAPITyping {
    func fetchLatestRates(apiKey: String) async throws -> RatesResponse {
        let url = URL(string: "https://openexchangerates.org/api/latest.json?app_id=\(apiKey)")!
        let (data, resp) = try await URLSession.shared.data(from: url)
        guard (resp as? HTTPURLResponse)?.statusCode == 200 else { throw URLError(.badServerResponse) }
        return try JSONDecoder().decode(RatesResponse.self, from: data)
    }

    func fetchCurrencies() async throws -> CurrencyList {
        let url = URL(string: "https://openexchangerates.org/api/currencies.json")!
        let (data, resp) = try await URLSession.shared.data(from: url)
        guard (resp as? HTTPURLResponse)?.statusCode == 200 else { throw URLError(.badServerResponse) }
        return try JSONDecoder().decode(CurrencyList.self, from: data)
    }
}

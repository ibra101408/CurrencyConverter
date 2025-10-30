//
//  s.swift
//  JustCurrencyConverter
//
//  Created by Daniil Vodenejev on 28.10.2025.
//

import Foundation

final class CurrencyDataManager {
    private let ud = UserDefaults.standard
    private let currenciesKey = "savedCurrencies"
    private let ratesKey = "savedRates"
    private let ratesDateKey = "savedRatesDate"
    private let lastUpdateKey = "lastUpdateDate"

    func saveCurrencies(_ currencies: [String: String]) {
        if let data = try? JSONEncoder().encode(currencies) {
            ud.set(data, forKey: currenciesKey)
        }
    }
    func loadCurrencies() -> [String: String] {
        guard let data = ud.data(forKey: currenciesKey),
              let cur = try? JSONDecoder().decode([String: String].self, from: data) else {
            return Self.defaultCurrencies()
        }
        return cur
    }

    func saveRates(_ rates: [String: Double], date: String) {
        if let data = try? JSONEncoder().encode(rates) {
            ud.set(data, forKey: ratesKey)
            ud.set(date, forKey: ratesDateKey)
            ud.set(Date(), forKey: lastUpdateKey)
        }
    }
    func loadRates() -> (rates: [String: Double], date: String)? {
        guard let data = ud.data(forKey: ratesKey),
              let rates = try? JSONDecoder().decode([String: Double].self, from: data),
              let date = ud.string(forKey: ratesDateKey) else { return nil }
        return (rates, date)
    }
    func lastUpdateDate() -> Date? { ud.object(forKey: lastUpdateKey) as? Date }

    private static func defaultCurrencies() -> [String: String] {
        [
            "USD":"US Dollar","EUR":"Euro","GBP":"British Pound Sterling","JPY":"Japanese Yen",
            "AUD":"Australian Dollar","CAD":"Canadian Dollar","CHF":"Swiss Franc","CNY":"Chinese Yuan",
            "SEK":"Swedish Krona","NZD":"New Zealand Dollar","MXN":"Mexican Peso","SGD":"Singapore Dollar",
            "HKD":"Hong Kong Dollar","NOK":"Norwegian Krone","KRW":"South Korean Won","TRY":"Turkish Lira",
            "RUB":"Russian Ruble","INR":"Indian Rupee","BRL":"Brazilian Real","ZAR":"South African Rand"
        ]
    }
}

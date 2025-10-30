//
//  RatesResponse.swift
//  JustCurrencyConverter
//
//  Created by Daniil Vodenejev on 28.10.2025.
//

import Foundation

struct RatesResponse: Codable {
    let timestamp: Int
    let base: String
    let rates: [String: Double]

    var date: String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df.string(from: Date(timeIntervalSince1970: TimeInterval(timestamp)))
    }
}

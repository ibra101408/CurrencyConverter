//
//  CurrencyList.swift
//  JustCurrencyConverter
//
//  Created by Daniil Vodenejev on 28.10.2025.
//

import Foundation

struct CurrencyList: Codable {
    let codes: [String: String]
    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        self.codes = try c.decode([String: String].self)
    }
}

//
//  TargetCurrency.swift
//  JustCurrencyConverter
//
//  Created by Daniil Vodenejev on 28.10.2025.
//

import Foundation

struct TargetCurrency: Identifiable, Equatable {
    let id = UUID()
    var code: String
    var amount: String = ""
}

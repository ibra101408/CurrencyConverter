//
//  CurrencyIcon.swift
//  JustCurrencyConverter
//
//  Created by Daniil Vodenejev on 29.10.2025.
//

import Foundation

enum CurrencyIcon {
    /// Returns a display emoji for a currency code.
    /// Uses country flags for 2-letter country codes (from your `currencyFlags` map),
    /// and smart fallbacks for metals/crypto/specials.
    static func emoji(for code: String, flags: [String:String]) -> String {
        if let cc = flags[code], cc.count == 2 {
            return FlagHelper.flag(from: cc) // uses your existing helper
        }
        switch code {
        case "BTC": return "₿"
        case "XAU": return "🥇" // Gold
        case "XAG": return "🥈" // Silver
        case "XPT": return "🪙" // Platinum
        case "XPD": return "🪙" // Palladium
        case "XDR": return "💷" // SDR (generic money icon)
        default:    return "💵" // Safe fallback (prevents tofu boxes)
        }
    }
}

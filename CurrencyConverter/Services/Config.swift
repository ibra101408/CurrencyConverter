//
//  Config.swift
//  JustCurrencyConverter
//
//  Created by Daniil Vodenejev on 28.10.2025.
//

import Foundation

enum Config {
    static var apiKey: String {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let key = plist["OPENEXCHANGE_API_KEY"] as? String, !key.isEmpty else {
            print("API Key Error: 'OPENEXCHANGE_API_KEY' not found in Config.plist")
            return ""
        }
        return key
    }
}

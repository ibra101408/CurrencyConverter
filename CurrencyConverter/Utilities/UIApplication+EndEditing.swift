//
//  UIApplication+EndEditing.swift
//  JustCurrencyConverter
//
//  Created by Daniil Vodenejev on 28.10.2025.
//

import UIKit
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

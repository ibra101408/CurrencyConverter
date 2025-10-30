//
//  Theme.swift
//  JustCurrencyConverter
//
//  Created by Daniil Vodenejev on 28.10.2025.
//

import SwiftUI

enum Theme {
    // MARK: - Dark Theme
    enum Dark {
        static let bgTop    = Color(red: 8/255,  green: 12/255, blue: 20/255)   // #080C14
        static let bgBottom = Color(red: 11/255, green: 15/255, blue: 24/255)   // #0B0F18

        static let cardBG   = Color.white.opacity(0.04) // subtle glass card
        static let stroke   = Color.white.opacity(0.08) // hairline borders
        static let label    = Color.white               // primary text
        static let subLabel = Color.white.opacity(0.6)  // secondary text

        static let chipBG   = Color.orange.opacity(0.12)
        static let chipFG   = Color.orange

        static let accent   = Color.cyan                // one pop color
    }

    // MARK: - Light Theme
    enum Light {
        static let bgTop    = Color.white
        static let bgBottom = Color(red: 245/255, green: 246/255, blue: 250/255) // soft gray-white

        static let cardBG   = Color.black.opacity(0.03) // subtle contrast panels
        static let stroke   = Color.black.opacity(0.08)
        static let label    = Color.black
        static let subLabel = Color.black.opacity(0.6)

        static let chipBG   = Color.orange.opacity(0.1)
        static let chipFG   = Color.orange

        static let accent   = Color.blue
    }

    // MARK: - Dynamic accessors
    static func bgTop(for isDarkMode: Bool) -> Color {
        isDarkMode ? Dark.bgTop : Light.bgTop
    }

    static func bgBottom(for isDarkMode: Bool) -> Color {
        isDarkMode ? Dark.bgBottom : Light.bgBottom
    }

    static func cardBG(for isDarkMode: Bool) -> Color {
        isDarkMode ? Dark.cardBG : Light.cardBG
    }

    static func stroke(for isDarkMode: Bool) -> Color {
        isDarkMode ? Dark.stroke : Light.stroke
    }

    static func label(for isDarkMode: Bool) -> Color {
        isDarkMode ? Dark.label : Light.label
    }

    static func subLabel(for isDarkMode: Bool) -> Color {
        isDarkMode ? Dark.subLabel : Light.subLabel
    }

    static func chipBG(for isDarkMode: Bool) -> Color {
        isDarkMode ? Dark.chipBG : Light.chipBG
    }

    static func chipFG(for isDarkMode: Bool) -> Color {
        isDarkMode ? Dark.chipFG : Light.chipFG
    }

    static func accent(for isDarkMode: Bool) -> Color {
        isDarkMode ? Dark.accent : Light.accent
    }
}

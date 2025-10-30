//
//  CurrencyConverterApp.swift
//  CurrencyConverter
//
//  Created by Daniil Vodenejev on 20.08.2025.
//

import SwiftUI

@main
struct CurrencyConverterApp: App {
    @StateObject private var vm = CurrencyViewModel(
            currencyFlags: CurrencyFlags.map   // <-- inject the big dictionary here
        )
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(
                    CurrencyViewModel(currencyFlags: CurrencyFlags.map)
                    )
                .preferredColorScheme(vm.isDarkMode ? .dark : .light)
               // .tint(Theme.accent)

        }
    }
}

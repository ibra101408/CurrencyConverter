//
//  CurrencyPickerView.swift
//  JustCurrencyConverter
//
//  Created by Daniil Vodenejev on 28.10.2025.
//

import SwiftUI

struct CurrencyPickerView: View {
    @EnvironmentObject var vm: CurrencyViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // MARK: search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Theme.subLabel(for: vm.isDarkMode))
                    TextField("Search currency or code", text: $vm.searchText)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled(true)
                        .foregroundStyle(Theme.label(for: vm.isDarkMode))
                }
                .padding(12)
                .background(Theme.cardBG(for: vm.isDarkMode))
                .overlay(
                    Rectangle()
                        .frame(height: 0.6)
                        .foregroundStyle(Theme.stroke(for: vm.isDarkMode)),
                    alignment: .bottom
                )

                // MARK: list
                List(vm.filteredCurrencyCodes(), id: \.self) { code in
                    Button {
                        vm.applyCurrencySelection(code: code)
                    } label: {
                        HStack(spacing: 12) {
                            // flag
                            Text(CurrencyIcon.emoji(for: code, flags: vm.currencyFlags))

                            // currency name
                            VStack(alignment: .leading, spacing: 2) {
                                Text(code)
                                    .font(.headline)
                                    .foregroundStyle(Theme.label(for: vm.isDarkMode))
                                Text(vm.currencies[code] ?? "")
                                    .font(.caption)
                                    .foregroundStyle(Theme.subLabel(for: vm.isDarkMode))
                            }

                            Spacer()

                            // checkmark
                            if (vm.isSelectingBase && code == vm.baseCurrency) ||
                                (!vm.isSelectingBase && vm.targets.map(\.code).contains(code)) {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Theme.accent(for: vm.isDarkMode))
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .listRowBackground(Color.clear)       // <-- important
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)         // <-- hide system bg
                .background(Color.clear)
            }
            .background(
                LinearGradient(
                    colors: [
                        Theme.bgTop(for: vm.isDarkMode),
                        Theme.bgBottom(for: vm.isDarkMode)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle(vm.isSelectingBase ? "Select Base Currency" : "Select Currency")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { vm.showingCurrencyPicker = false }
                        .foregroundStyle(Theme.accent(for: vm.isDarkMode))
                }
            }
            // make nav bar text match theme
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(
                Theme.bgTop(for: vm.isDarkMode).opacity(0.95),
                for: .navigationBar
            )
            .tint(Theme.accent(for: vm.isDarkMode))
            .preferredColorScheme(vm.isDarkMode ? .dark : .light) 

        }
        .presentationDetents([.medium, .large])
    }
}

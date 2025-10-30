//
//  CurrencyViewModel.swift
//  JustCurrencyConverter
//
//  Created by Daniil Vodenejev on 28.10.2025.
//

import SwiftUI

@MainActor
final class CurrencyViewModel: ObservableObject {
    // UI state
    @Published var isDarkMode = false
    @Published var isOfflineMode = false
    @Published var ratesDate: String = ""
    @Published var baseAmount: String = "1"
    @Published var baseCurrency: String = "USD"
    @Published var currencies: [String: String] = [:]
    @Published var targets: [TargetCurrency] = [TargetCurrency(code: "EUR")]

    // picker state
    @Published var showingCurrencyPicker = false
    @Published var isSelectingBase = false
    @Published var searchText = ""
    @Published var editingTargetID: UUID? = nil

    // internals
    private var isProgrammaticUpdate = false
    private var offlineRates: [String: Double] = [:]

    let currencyFlags: [String: String] // inject your big dictionary
    private let api: CurrencyAPITyping
    private let store = CurrencyDataManager()

    init(api: CurrencyAPITyping = CurrencyAPI(), currencyFlags: [String:String] = [:]) {
        self.api = api
        self.currencyFlags = currencyFlags
        loadOfflineData()
        Task { await bootstrap() }
    }

    // MARK: bootstrap
    func bootstrap() async {
        do {
            let list = try await api.fetchCurrencies()
            currencies = list.codes
            store.saveCurrencies(list.codes)
            if currencies[baseCurrency] == nil { baseCurrency = "USD" }
            if targets.isEmpty { targets = [TargetCurrency(code: "EUR")] }
            await convertFromBase()
        } catch {
            // stay with offline defaults
        }
    }
    
    func normalized(_ value: String) -> String {
        value.replacingOccurrences(of: ",", with: ".")
    }

    // MARK: offline load
    func loadOfflineData() {
        currencies = store.loadCurrencies()
        if let saved = store.loadRates() {
            offlineRates = saved.rates
            if offlineRates["USD"] == nil { offlineRates["USD"] = 1.0 }
            ratesDate = saved.date
        }
    }

    // MARK: conversions (public, used by views)
    enum FocusedField: Hashable { case base, target(UUID) }

    func convertBasedOnFocus(_ focused: FocusedField?) {
        switch focused {
        case .base:      Task { await convertFromBase() }
        case .target(let id): Task { await convertFromTarget(id: id) }
        case .none:      Task { await convertFromBase() }
        }
    }

    func convertFromBase() async {
        if Config.apiKey.isEmpty { isOfflineMode = true; convertOfflineFromBase(); return }
        do {
            let resp = try await api.fetchLatestRates(apiKey: Config.apiKey)
            var rates = resp.rates; rates["USD"] = 1.0
            store.saveRates(rates, date: resp.date)
            offlineRates = rates
            isOfflineMode = false
            isProgrammaticUpdate = true
            ratesDate = resp.date
            guard let amountValue = Double(baseAmount), let baseRate = rates[baseCurrency] else {
                targets.indices.forEach { targets[$0].amount = "" }; isProgrammaticUpdate = false; return
            }
            for i in targets.indices {
                if let targetRate = rates[targets[i].code] {
                    let value = amountValue * (targetRate / baseRate)
                    targets[i].amount = String(format: "%.2f", value)
                } else { targets[i].amount = "" }
            }
            isProgrammaticUpdate = false
        } catch {
            isOfflineMode = true
            convertOfflineFromBase()
        }
    }

    func convertFromTarget(id: UUID) async {
        if Config.apiKey.isEmpty { isOfflineMode = true; convertOfflineFromTarget(id: id); return }
        do {
            let resp = try await api.fetchLatestRates(apiKey: Config.apiKey)
            var rates = resp.rates; rates["USD"] = 1.0
            store.saveRates(rates, date: resp.date)
            offlineRates = rates
            isOfflineMode = false

            guard let idx = targets.firstIndex(where: { $0.id == id }),
                  let amountValue = Double(targets[idx].amount),
                  let fromRate = rates[targets[idx].code],
                  let baseRate = rates[baseCurrency] else {
                baseAmount = ""; for i in targets.indices where targets[i].id != id { targets[i].amount = "" }; return
            }

            isProgrammaticUpdate = true
            ratesDate = resp.date
            baseAmount = String(format: "%.2f", amountValue * (baseRate / fromRate))
            for i in targets.indices where targets[i].id != id {
                let code = targets[i].code
                if let targetRate = rates[code] {
                    let v = amountValue * (targetRate / fromRate)
                    targets[i].amount = String(format: "%.2f", v)
                } else { targets[i].amount = "" }
            }
            isProgrammaticUpdate = false
        } catch {
            isOfflineMode = true
            convertOfflineFromTarget(id: id)
        }
    }

    // MARK: offline math
    private func convertOfflineFromBase() {
        guard let amountValue = Double(baseAmount) else {
            isProgrammaticUpdate = true; targets.indices.forEach { targets[$0].amount = "" }; isProgrammaticUpdate = false; return
        }
        isProgrammaticUpdate = true
        for i in targets.indices {
            let t = targets[i].code
            if baseCurrency == "USD" {
                if let r = offlineRates[t] { targets[i].amount = String(format: "%.2f", amountValue * r) }
                else { targets[i].amount = "" }
            } else if let br = offlineRates[baseCurrency], let tr = offlineRates[t] {
                targets[i].amount = String(format: "%.2f", amountValue * (tr / br))
            } else { targets[i].amount = "" }
        }
        isProgrammaticUpdate = false
    }

    private func convertOfflineFromTarget(id: UUID) {
        guard let idx = targets.firstIndex(where: { $0.id == id }),
              let amountValue = Double(targets[idx].amount) else {
            isProgrammaticUpdate = true; baseAmount = ""; for i in targets.indices where targets[i].id != id { targets[i].amount = "" }; isProgrammaticUpdate = false; return
        }
        let from = targets[idx].code
        isProgrammaticUpdate = true
        if from == "USD", let br = offlineRates[baseCurrency] {
            baseAmount = String(format: "%.2f", amountValue / br)
        } else if let fr = offlineRates[from], let br = offlineRates[baseCurrency] {
            baseAmount = String(format: "%.2f", amountValue * (br / fr))
        } else { baseAmount = "" }

        for i in targets.indices where targets[i].id != id {
            let code = targets[i].code
            if from == "USD", let tr = offlineRates[code] {
                targets[i].amount = String(format: "%.2f", amountValue * tr)
            } else if let fr = offlineRates[from], let tr = offlineRates[code] {
                targets[i].amount = String(format: "%.2f", amountValue * (tr / fr))
            } else { targets[i].amount = "" }
        }
        isProgrammaticUpdate = false
    }

    // MARK: picker helpers
    func filteredCurrencyCodes() -> [String] {
        let disallow: Set<String> = isSelectingBase ? Set(targets.map(\.code)) : Set([baseCurrency])
        let all = currencies.keys.sorted()
        let allowed = all.filter { !disallow.contains($0) || (!isSelectingBase && editingTargetID == nil) }
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return allowed }
        return allowed.filter { code in
            (currencies[code]?.lowercased().contains(q) ?? false) || code.lowercased().contains(q)
        }
    }

    func applyCurrencySelection(code: String) {
        if isSelectingBase {
            baseCurrency = code
            showingCurrencyPicker = false
            Task { await convertFromBase() }
            return
        }

        // Add a new target or change existing one
        if let idx = targets.firstIndex(where: { $0.id == editingTargetID }) {
            targets[idx].code = code
        } else if !targets.map(\.code).contains(code),
                  code != baseCurrency,
                  targets.count < 4 {
            targets.append(TargetCurrency(code: code))
        }

        showingCurrencyPicker = false
        Task { await convertFromBase() }
    }

}

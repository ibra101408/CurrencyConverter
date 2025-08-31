import SwiftUI

struct TargetCurrency: Identifiable {
    let id = UUID()
    var code: String
    var amount: String = ""
}

struct ContentView: View {
    @State private var baseAmount: String = ""
    @State private var baseCurrency: String = ""
    @State private var currencies: [String: String] = [:] // code -> name
    @State private var targets: [TargetCurrency] = []
    @State private var newCurrency: String = ""
    @State private var ratesDate: String = ""

    // Prevent feedback loops when we programmatically update fields
    @State private var isProgrammaticUpdate = false

    // Track which text field the user is editing
    enum FocusedField: Hashable {
        case base
        case target(UUID)
    }
    @FocusState private var focusedField: FocusedField?

    // Minimal mapping currency -> country code for flag. Add more as you like.
    let currencyFlags: [String: String] = [
        "AUD": "AU", "BGN": "BG", "BRL": "BR", "CAD": "CA", "CHF": "CH",
        "CNY": "CN", "CZK": "CZ", "DKK": "DK", "EUR": "EU", "GBP": "GB",
        "HKD": "HK", "HUF": "HU", "IDR": "ID", "ILS": "IL", "INR": "IN",
        "ISK": "IS", "JPY": "JP", "KRW": "KR", "MXN": "MX", "MYR": "MY",
        "NOK": "NO", "NZD": "NZ", "PHP": "PH", "PLN": "PL", "RON": "RO",
        "SEK": "SE", "SGD": "SG", "THB": "TH", "TRY": "TR", "USD": "US",
        "ZAR": "ZA"
    ]

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                
                VStack(spacing: 24) {
                    Text("Currency Converter")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    if !ratesDate.isEmpty {
                        Text("Rates as of \(ratesDate)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    VStack(spacing: 20) {
                        // Base row
                        VStack(spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(baseCurrency)
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                    Text(currencies[baseCurrency] ?? "")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Menu {
                                    ForEach(currencies.keys.sorted().filter { !targets.map(\.code).contains($0) }, id: \.self) { code in
                                        Button {
                                            baseCurrency = code
                                        } label: {
                                            Text("\(flag(from: currencyFlags[code] ?? "")) \(code) – \(currencies[code] ?? "")")
                                        }
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Text(flag(from: currencyFlags[baseCurrency] ?? ""))
                                            .font(.largeTitle)
                                        Image(systemName: "chevron.down")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .onChange(of: baseCurrency) { _ in
                                    guard !isProgrammaticUpdate else { return }
                                    convertBasedOnFocus()
                                }
                                // FLAG POSITION: Change the width value below to move flag left/right
                                // Smaller width = more left, larger width = more right
                                .frame(width: 110, alignment: .center)
                            }
                            
                            TextField("Enter amount", text: $baseAmount)
                                .keyboardType(.decimalPad)
                                .padding(16)
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .focused($focusedField, equals: .base)
                                .onChange(of: baseAmount) { _ in
                                    guard focusedField == .base, !isProgrammaticUpdate else { return }
                                    convertFromBase()
                                }
                        }
                        .padding(20)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .purple]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .opacity(0.5)
                        )
                        .cornerRadius(16)

                        // Target rows
                        ForEach($targets) { $target in
                            VStack(spacing: 12) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(target.code)
                                            .font(.title2)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.primary)
                                        Text(currencies[target.code] ?? "")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Menu {
                                        ForEach(currencies.keys.sorted().filter { $0 != baseCurrency && (!targets.map(\.code).contains($0) || $0 == target.code) }, id: \.self) { code in
                                            Button {
                                                target.code = code
                                            } label: {
                                                Text("\(flag(from: currencyFlags[code] ?? "")) \(code) – \(currencies[code] ?? "")")
                                            }
                                        }
                                    } label: {
                                        HStack(spacing: 4) {
                                            Text(flag(from: currencyFlags[target.code] ?? ""))
                                                .font(.largeTitle)
                                            Image(systemName: "chevron.down")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .onChange(of: target.code) { _ in
                                        guard !isProgrammaticUpdate else { return }
                                        convertBasedOnFocus()
                                    }
                                    // FLAG POSITION: Change the width value below to move flag left/right
                                    // Smaller width = more left, larger width = more right
                                    .frame(width: 110, alignment: .center)
                                }
                                .overlay(
                                    Button {
                                        if let index = targets.firstIndex(where: { $0.id == target.id }) {
                                            targets.remove(at: index)
                                        }
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.red)
                                            .font(.caption)
                                    }
                                    .buttonStyle(.borderless),
                                    alignment: .topTrailing
                                )
                                
                                TextField("Enter amount", text: $target.amount)
                                    .keyboardType(.decimalPad)
                                    .padding(16)
                                    .background(Color(.systemBackground))
                                    .cornerRadius(12)
                                    .focused($focusedField, equals: .target(target.id))
                                    .onChange(of: target.amount) { _ in
                                        guard focusedField == .target(target.id), !isProgrammaticUpdate else { return }
                                        convertFromTarget(id: target.id)
                                    }
                            }
                            .padding(20)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [.blue, .purple]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                .opacity(0.5)
                            )
                            .cornerRadius(16)
                        }

                        // Add new currency
                        if targets.count < 4 {
                            Menu {
                                ForEach(currencies.keys.sorted().filter { $0 != baseCurrency && !targets.map(\.code).contains($0) }, id: \.self) { code in
                                    Button {
                                        targets.append(TargetCurrency(code: code))
                                        convertBasedOnFocus()
                                    } label: {
                                        Text("\(flag(from: currencyFlags[code] ?? "")) \(code) – \(currencies[code] ?? "")")
                                    }
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.blue)
                                        .font(.title2)
                                    Text("Add Currency")
                                        .foregroundColor(.blue)
                                    Spacer()
                                }
                            }
                            .padding(20)
                            .background(Color(.systemGray6))
                            .cornerRadius(16)
                        }
                    }
                    .frame(maxWidth: min(400, geometry.size.width - 40))
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .onAppear { fetchCurrencies() }
    }

    // MARK: - Conversion Helpers
    private func convertBasedOnFocus() {
        if let focused = focusedField {
            switch focused {
            case .base:
                convertFromBase()
            case .target(let id):
                convertFromTarget(id: id)
            }
        } else {
            convertFromBase()
        }
    }

    private func convertFromBase() {
        guard !baseCurrency.isEmpty, let amountValue = Double(baseAmount) else {
            isProgrammaticUpdate = true
            ratesDate = ""
            for i in targets.indices {
                targets[i].amount = ""
            }
            isProgrammaticUpdate = false
            return
        }

        let urlStr = "https://api.frankfurter.app/latest?amount=\(amountValue)&from=\(baseCurrency)"
        guard let url = URL(string: urlStr) else { return }
        print("🌐 GET: \(urlStr)")

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error { print("❌ Network error:", error.localizedDescription); return }
            guard let data = data else { print("❌ No data"); return }

            do {
                let decoded = try JSONDecoder().decode(RatesResponse.self, from: data)
                let rates = decoded.rates
                DispatchQueue.main.async {
                    self.isProgrammaticUpdate = true
                    self.ratesDate = decoded.date
                    for i in self.targets.indices {
                        let code = self.targets[i].code
                        if let converted = rates[code] {
                            self.targets[i].amount = String(format: "%.2f", converted)
                        } else {
                            self.targets[i].amount = ""
                        }
                    }
                    self.isProgrammaticUpdate = false
                }
            } catch {
                print("❌ Decode error:", error)
            }
        }.resume()
    }

    private func convertFromTarget(id: UUID) {
        guard let index = targets.firstIndex(where: { $0.id == id }),
              !targets[index].code.isEmpty,
              let amountValue = Double(targets[index].amount) else {
            isProgrammaticUpdate = true
            ratesDate = ""
            baseAmount = ""
            for i in targets.indices where targets[i].id != id {
                targets[i].amount = ""
            }
            isProgrammaticUpdate = false
            return
        }

        let fromCode = targets[index].code
        let urlStr = "https://api.frankfurter.app/latest?amount=\(amountValue)&from=\(fromCode)"
        guard let url = URL(string: urlStr) else { return }
        print("🌐 GET: \(urlStr)")

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error { print("❌ Network error:", error.localizedDescription); return }
            guard let data = data else { print("❌ No data"); return }

            do {
                let decoded = try JSONDecoder().decode(RatesResponse.self, from: data)
                let rates = decoded.rates
                DispatchQueue.main.async {
                    self.isProgrammaticUpdate = true
                    self.ratesDate = decoded.date
                    // Update base
                    if let converted = rates[self.baseCurrency] {
                        self.baseAmount = String(format: "%.2f", converted)
                    } else {
                        self.baseAmount = ""
                    }
                    // Update other targets
                    for i in self.targets.indices where self.targets[i].id != id {
                        let code = self.targets[i].code
                        if let converted = rates[code] {
                            self.targets[i].amount = String(format: "%.2f", converted)
                        } else {
                            self.targets[i].amount = ""
                        }
                    }
                    self.isProgrammaticUpdate = false
                }
            } catch {
                print("❌ Decode error:", error)
            }
        }.resume()
    }

    // MARK: - Flags
    func flag(from countryCode: String) -> String {
        guard countryCode.count == 2 else { return "" }
        let base: UInt32 = 127397
        var result = ""
        for scalar in countryCode.uppercased().unicodeScalars {
            if let flagScalar = UnicodeScalar(base + scalar.value) {
                result.unicodeScalars.append(flagScalar)
            }
        }
        return result
    }

    // MARK: - Data
    func fetchCurrencies() {
        guard let url = URL(string: "https://api.frankfurter.app/currencies") else { return }
        print("🌐 GET: /currencies")

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error { print("❌ Error:", error.localizedDescription); return }
            guard let data = data else { print("❌ No data"); return }

            do {
                let decoded = try JSONDecoder().decode(CurrencyList.self, from: data)
                DispatchQueue.main.async {
                    self.currencies = decoded.codes
                    print("✅ Loaded \(self.currencies.count) currencies")

                    // Set sensible defaults if needed
                    if self.baseCurrency.isEmpty || self.currencies[self.baseCurrency] == nil {
                        self.isProgrammaticUpdate = true
                        self.baseCurrency = "USD"
                        self.isProgrammaticUpdate = false
                    }
                    if self.targets.isEmpty {
                        self.targets = [TargetCurrency(code: "EUR")]
                    }

                    // Set initial amount and convert
                    if self.baseAmount.isEmpty {
                        self.baseAmount = "1"
                    }
                    self.convertFromBase()
                }
            } catch {
                print("❌ Decode error:", error)
            }
        }.resume()
    }
}

// MARK: - Models
struct RatesResponse: Codable {
    let amount: Double
    let base: String
    let date: String
    let rates: [String: Double]
}

struct CurrencyList: Codable {
    let codes: [String: String]

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.codes = try container.decode([String: String].self)
    }
}

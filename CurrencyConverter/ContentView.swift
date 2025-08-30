import SwiftUI

struct ContentView: View {
    @State private var amountFrom: String = ""
    @State private var amountTo: String = ""
    @State private var fromCurrency: String = ""
    @State private var toCurrency: String = ""
    @State private var currencies: [String: String] = [:] // code -> name

    // Prevent feedback loops when we programmatically update fields
    @State private var isProgrammaticUpdate = false

    // Track which text field the user is editing
    @FocusState private var focusedField: Field?

    enum Field { case from, to }
    enum ConversionDirection { case from, to }

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
        VStack(spacing: 0) {
            // Header
            Text("Currency Converter")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .padding(.top, 20)
                .padding(.bottom, 40)
            
            Spacer()
            
            VStack(spacing: 30) {
                // FROM currency container
                VStack(spacing: 12) {
                    Text("From")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 15) {
                        Picker("From", selection: $fromCurrency) {
                            ForEach(currencies.keys.sorted(), id: \.self) { code in
                                Text("\(flag(from: currencyFlags[code] ?? "")) \(code) – \(currencies[code] ?? "")")
                                    .tag(code)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .onChange(of: fromCurrency) { _ in
                            guard !isProgrammaticUpdate else { return }
                            let dir: ConversionDirection = (focusedField == .to) ? .from : .to
                            convertCurrency(direction: dir)
                        }
                        
                        TextField("0.00", text: $amountFrom)
                            .keyboardType(.decimalPad)
                            .font(.title2)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(Color(.systemBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(focusedField == .from ? Color.blue : Color(.systemGray4), lineWidth: 1.5)
                            )
                            .cornerRadius(12)
                            .focused($focusedField, equals: .from)
                            .onChange(of: amountFrom) { _ in
                                guard focusedField == .from, !isProgrammaticUpdate else { return }
                                convertCurrency(direction: .to)
                            }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                .background(Color(.systemGray6).opacity(0.3))
                .cornerRadius(16)
                
                // Arrow indicator
                Image(systemName: "arrow.down")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 5)
                
                // TO currency container
                VStack(spacing: 12) {
                    Text("To")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 15) {
                        Picker("To", selection: $toCurrency) {
                            ForEach(currencies.keys.sorted(), id: \.self) { code in
                                Text("\(flag(from: currencyFlags[code] ?? "")) \(code) – \(currencies[code] ?? "")")
                                    .tag(code)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .onChange(of: toCurrency) { _ in
                            guard !isProgrammaticUpdate else { return }
                            let dir: ConversionDirection = (focusedField == .to) ? .from : .to
                            convertCurrency(direction: dir)
                        }
                        
                        TextField("0.00", text: $amountTo)
                            .keyboardType(.decimalPad)
                            .font(.title2)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(Color(.systemBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(focusedField == .to ? Color.blue : Color(.systemGray4), lineWidth: 1.5)
                            )
                            .cornerRadius(12)
                            .focused($focusedField, equals: .to)
                            .onChange(of: amountTo) { _ in
                                guard focusedField == .to, !isProgrammaticUpdate else { return }
                                convertCurrency(direction: .from)
                            }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                .background(Color(.systemGray6).opacity(0.3))
                .cornerRadius(16)
            }
            .padding(.horizontal, 30)
            
            Spacer()
        }
        .background(Color(.systemGroupedBackground))
        .onAppear { fetchCurrencies() }
    }

    // MARK: - Conversion
    func convertCurrency(direction: ConversionDirection) {
        // Ensure selections exist first
        guard !fromCurrency.isEmpty, !toCurrency.isEmpty else {
            print("⚠️ Select currencies first")
            return
        }

        let fromCode: String
        let toCode: String
        let amountStr: String

        switch direction {
        case .to:
            guard let amountValue = Double(amountFrom) else {
                isProgrammaticUpdate = true; amountTo = ""; isProgrammaticUpdate = false
                return
            }
            fromCode = fromCurrency
            toCode = toCurrency
            amountStr = String(amountValue)

        case .from:
            guard let amountValue = Double(amountTo) else {
                isProgrammaticUpdate = true; amountFrom = ""; isProgrammaticUpdate = false
                return
            }
            fromCode = toCurrency
            toCode = fromCurrency
            amountStr = String(amountValue)
        }

        let urlStr = "https://api.frankfurter.app/latest?amount=\(amountStr)&from=\(fromCode)&to=\(toCode)"
        guard let url = URL(string: urlStr) else { return }
        print("🌐 GET: \(urlStr)")

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error { print("❌ Network error:", error.localizedDescription); return }
            guard let data = data else { print("❌ No data"); return }

            do {
                let decoded = try JSONDecoder().decode(RatesResponse.self, from: data)
                if let converted = decoded.rates[toCode] {
                    DispatchQueue.main.async {
                        self.isProgrammaticUpdate = true
                        let formatted = String(format: "%.2f", converted)
                        if direction == .to {
                            self.amountTo = formatted
                        } else {
                            self.amountFrom = formatted
                        }
                        self.isProgrammaticUpdate = false
                    }
                } else {
                    print("❌ Missing rate for \(toCode)")
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
                    if self.fromCurrency.isEmpty || self.currencies[self.fromCurrency] == nil {
                        self.isProgrammaticUpdate = true
                        self.fromCurrency = "USD"
                        self.isProgrammaticUpdate = false
                    }
                    if self.toCurrency.isEmpty || self.currencies[self.toCurrency] == nil {
                        self.isProgrammaticUpdate = true
                        self.toCurrency = "EUR"
                        self.isProgrammaticUpdate = false
                    }

                    // If user typed before currencies arrived, do an initial conversion
                    if !self.amountFrom.isEmpty {
                        self.convertCurrency(direction: .to)
                    }
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

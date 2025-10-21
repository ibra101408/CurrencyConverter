import SwiftUI

// No changes to TargetCurrency, UIApplication extension, or CurrencyDataManager
struct TargetCurrency: Identifiable {
    let id = UUID()
    var code: String
    var amount: String = ""
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

class CurrencyDataManager: ObservableObject {
    private let userDefaults = UserDefaults.standard
    private let currenciesKey = "savedCurrencies"
    private let ratesKey = "savedRates"
    private let ratesDateKey = "savedRatesDate"
    private let lastUpdateKey = "lastUpdateDate"
    
    func saveCurrencies(_ currencies: [String: String]) {
        if let data = try? JSONEncoder().encode(currencies) {
            userDefaults.set(data, forKey: currenciesKey)
        }
    }
    
    func loadCurrencies() -> [String: String] {
        guard let data = userDefaults.data(forKey: currenciesKey),
              let currencies = try? JSONDecoder().decode([String: String].self, from: data) else {
            return defaultCurrencies()
        }
        return currencies
    }
    
    func saveRates(_ rates: [String: Double], date: String) {
        if let data = try? JSONEncoder().encode(rates) {
            userDefaults.set(data, forKey: ratesKey)
            userDefaults.set(date, forKey: ratesDateKey)
            userDefaults.set(Date(), forKey: lastUpdateKey)
        }
    }
    
    func loadRates() -> (rates: [String: Double], date: String)? {
        guard let data = userDefaults.data(forKey: ratesKey),
              let rates = try? JSONDecoder().decode([String: Double].self, from: data),
              let date = userDefaults.string(forKey: ratesDateKey) else {
            return nil
        }
        return (rates, date)
    }
    
    func getLastUpdateDate() -> Date? {
        return userDefaults.object(forKey: lastUpdateKey) as? Date
    }
    
    private func defaultCurrencies() -> [String: String] {
        return [
            "USD": "US Dollar",
            "EUR": "Euro",
            "GBP": "British Pound Sterling",
            "JPY": "Japanese Yen",
            "AUD": "Australian Dollar",
            "CAD": "Canadian Dollar",
            "CHF": "Swiss Franc",
            "CNY": "Chinese Yuan",
            "SEK": "Swedish Krona",
            "NZD": "New Zealand Dollar",
            "MXN": "Mexican Peso",
            "SGD": "Singapore Dollar",
            "HKD": "Hong Kong Dollar",
            "NOK": "Norwegian Krone",
            "KRW": "South Korean Won",
            "TRY": "Turkish Lira",
            "RUB": "Russian Ruble",
            "INR": "Indian Rupee",
            "BRL": "Brazilian Real",
            "ZAR": "South African Rand"
        ]
    }
}

struct ContentView: View {
    @StateObject private var dataManager = CurrencyDataManager()
    @State private var baseAmount: String = ""
    @State private var baseCurrency: String = ""
    @State private var currencies: [String: String] = [:]
    @State private var targets: [TargetCurrency] = []
    @State private var newCurrency: String = ""
    @State private var ratesDate: String = ""
    @State private var isDarkMode: Bool = false
    @State private var isOfflineMode: Bool = false
    @State private var offlineRates: [String: Double] = [:]

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
        "AED": "AE", // United Arab Emirates Dirham
        "AFN": "AF", // Afghan Afghani
        "ALL": "AL", // Albanian Lek
        "AMD": "AM", // Armenian Dram
        "ANG": "CW", // Netherlands Antillean Guilder (Curaçao and Sint Maarten)
        "AOA": "AO", // Angolan Kwanza
        "ARS": "AR", // Argentine Peso
        "AUD": "AU", // Australian Dollar
        "AWG": "AW", // Aruban Florin
        "AZN": "AZ", // Azerbaijani Manat
        "BAM": "BA", // Bosnia-Herzegovina Convertible Mark
        "BBD": "BB", // Barbadian Dollar
        "BDT": "BD", // Bangladeshi Taka
        "BGN": "BG", // Bulgarian Lev
        "BHD": "BH", // Bahraini Dinar
        "BIF": "BI", // Burundian Franc
        "BMD": "BM", // Bermudian Dollar
        "BND": "BN", // Brunei Dollar
        "BOB": "BO", // Bolivian Boliviano
        "BRL": "BR", // Brazilian Real
        "BSD": "BS", // Bahamian Dollar
        "BTC": "rsb.button.angledbottom.horizontal.right",   // Bitcoin (no country, no flag)
        "BTN": "BT", // Bhutanese Ngultrum
        "BWP": "BW", // Botswanan Pula
        "BYN": "BY", // Belarusian Rubles
        "BZD": "BZ", // Belize Dollar
        "CAD": "CA", // Canadian Dollar
        "CDF": "CD", // Congolese Franc
        "CHF": "CH", // Swiss Franc
        "CLF": "CL",   // Chilean Unit of Account (UF, no country-specific flag)
        "CLP": "CL", // Chilean Peso
        "CNH": "CN", // Chinese Yuan (offshore)
        "CNY": "CN", // Chinese Yuan
        "COP": "CO", // Colombian Peso
        "CRC": "CR", // Costa Rican Colón
        "CUC": "CU", // Cuban Convertible Peso
        "CUP": "CU", // Cuban Peso
        "CVE": "CV", // Cape Verdean Escudo
        "CZK": "CZ", // Czech Koruna
        "DJF": "DJ", // Djiboutian Franc
        "DKK": "DK", // Danish Krone
        "DOP": "DO", // Dominican Peso
        "DZD": "DZ", // Algerian Dinar
        "EGP": "EG", // Egyptian Pound
        "ERN": "ER", // Eritrean Nakfa
        "ETB": "ET", // Ethiopian Birr
        "EUR": "EU", // Euro (European Union, not a country but common usage)
        "FJD": "FJ", // Fijian Dollar
        "FKP": "FK", // Falkland Islands Pound
        "GBP": "GB", // British Pound Sterling
        "GEL": "GE", // Georgian Lari
        "GGP": "GG", // Guernsey Pound
        "GHS": "GH", // Ghanaian Cedi
        "GIP": "GI", // Gibraltar Pound
        "GMD": "GM", // Gambian Dalasi
        "GNF": "GN", // Guinean Franc
        "GTQ": "GT", // Guatemalan Quetzal
        "GYD": "GY", // Guyanaese Dollar
        "HKD": "HK", // Hong Kong Dollar
        "HNL": "HN", // Honduran Lempira
        "HRK": "HR", // Croatian Kuna (deprecated, but included for compatibility)
        "HTG": "HT", // Haitian Gourde
        "HUF": "HU", // Hungarian Forint
        "IDR": "ID", // Indonesian Rupiah
        "ILS": "IL", // Israeli New Shekel
        "IMP": "IM", // Manx Pound
        "INR": "IN", // Indian Rupee
        "IQD": "IQ", // Iraqi Dinar
        "IRR": "IR", // Iranian Rial
        "ISK": "IS", // Icelandic Króna
        "JEP": "JE", // Jersey Pound
        "JMD": "JM", // Jamaican Dollar
        "JOD": "JO", // Jordanian Dinar
        "JPY": "JP", // Japanese Yen
        "KES": "KE", // Kenyan Shilling
        "KGS": "KG", // Kyrgyzstani Som
        "KHR": "KH", // Cambodian Riel
        "KMF": "KM", // Comorian Franc
        "KPW": "KP", // North Korean Won
        "KRW": "KR", // South Korean Won
        "KWD": "KW", // Kuwaiti Dinar
        "KYD": "KY", // Cayman Islands Dollar
        "KZT": "KZ", // Kazakhstani Tenge
        "LAK": "LA", // Laotian Kip
        "LBP": "LB", // Lebanese Pound
        "LKR": "LK", // Sri Lankan Rupee
        "LRD": "LR", // Liberian Dollar
        "LSL": "LS", // Lesotho Loti
        "LYD": "LY", // Libyan Dinar
        "MAD": "MA", // Moroccan Dirham
        "MDL": "MD", // Moldovan Leu
        "MGA": "MG", // Malagasy Ariary
        "MKD": "MK", // Macedonian Denar
        "MMK": "MM", // Myanmar Kyat
        "MNT": "MN", // Mongolian Tugrik
        "MOP": "MO", // Macanese Pataca
        "MRU": "MR", // Mauritanian Ouguiya
        "MUR": "MU", // Mauritian Rupee
        "MVR": "MV", // Maldivian Rufiyaa
        "MWK": "MW", // Malawian Kwacha
        "MXN": "MX", // Mexican Peso
        "MYR": "MY", // Malaysian Ringgit
        "MZN": "MZ", // Mozambican Metical
        "NAD": "NA", // Namibian Dollar
        "NGN": "NG", // Nigerian Naira
        "NIO": "NI", // Nicaraguan Córdoba
        "NOK": "NO", // Norwegian Krone
        "NPR": "NP", // Nepalese Rupee
        "NZD": "NZ", // New Zealand Dollar
        "OMR": "OM", // Omani Rial
        "PAB": "PA", // Panamanian Balboa
        "PEN": "PE", // Peruvian Sol
        "PGK": "PG", // Papua New Guinean Kina
        "PHP": "PH", // Philippine Peso
        "PKR": "PK", // Pakistani Rupee
        "PLN": "PL", // Polish Zloty
        "PYG": "PY", // Paraguayan Guarani
        "QAR": "QA", // Qatari Rial
        "RON": "RO", // Romanian Leu
        "RSD": "RS", // Serbian Dinar
        "RUB": "RU", // Russian Rubles
        "RWF": "RW", // Rwandan Franc
        "SAR": "SA", // Saudi Riyal
        "SBD": "SB", // Solomon Islands Dollar
        "SCR": "SC", // Seychellois Rupee
        "SDG": "SD", // Sudanese Pound
        "SEK": "SE", // Swedish Krona
        "SGD": "SG", // Singapore Dollar
        "SHP": "SH", // Saint Helena Pound
        "SLE": "SL", // Sierra Leonean Leone
        "SLL": "SL", // Sierra Leonean Leone (old code, included for compatibility)
        "SOS": "SO", // Somali Shilling
        "SRD": "SR", // Surinamese Dollar
        "SSP": "SS", // South Sudanese Pound
        "STD": "ST", // São Tomé and Príncipe Dobra (pre-2018)
        "STN": "ST", // São Tomé and Príncipe Dobra
        "SVC": "SV", // Salvadoran Colón
        "SYP": "SY", // Syrian Pound
        "SZL": "SZ", // Swazi Lilangeni
        "THB": "TH", // Thai Baht
        "TJS": "TJ", // Tajikistani Somoni
        "TMT": "TM", // Turkmenistani Manat
        "TND": "TN", // Tunisian Dinar
        "TOP": "TO", // Tongan Paʻanga
        "TRY": "TR", // Turkish Lira
        "TTD": "TT", // Trinidad and Tobago Dollar
        "TWD": "TW", // New Taiwan Dollar
        "TZS": "TZ", // Tanzanian Shilling
        "UAH": "UA", // Ukrainian Hryvnia
        "UGX": "UG", // Ugandan Shilling
        "USD": "US", // United States Dollar
        "UYU": "UY", // Uruguayan Peso
        "UZS": "UZ", // Uzbekistani Som
        "VES": "VE", // Venezuelan Bolívar
        "VND": "VN", // Vietnamese Dong
        "VUV": "VU", // Vanuatu Vatu
        "WST": "WS", // Samoan Tala
        "XAF": "CM", // Central African CFA Franc (Cameroon as representative)
        "XAG": "XAG", // Silver (special key for 🪙 emoji)
        "XAU": "XAU", // Gold (special key for 💰 emoji)
        "XCD": "AG", // East Caribbean Dollar (Antigua and Barbuda as representative)
        "XCG": "XCG", // Unknown/invalid (special key for 💵 emoji)
       "XDR": "XDR", // IMF Special Drawing Rights (special key for 💷 emoji)
        "XOF": "SN", // West African CFA Franc (Senegal as representative)
        "XPD": "🪙", // Palladium (special key for 🪙 emoji)
        "XPF": "PF", // CFP Franc (French Polynesia as representative)
        "XPT": "🪙", // Platinum (special key for 🪙 emoji)
        "YER": "YE", // Yemeni Rial
        "ZAR": "ZA", // South African Rand
        "ZMW": "ZM", // Zambian Kwacha
        "ZWG": "ZW", // Zimbabwe Gold
        "ZWL": "ZW"  // Zimbabwean Dollar
    ]

    // Replace YOUR_API_KEY with your actual Open Exchange Rates API key
    private var apiKey: String {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let key = plist["OPENEXCHANGE_API_KEY"] as? String, !key.isEmpty else {
            print("API Key Error: 'OPENEXCHANGE_API_KEY' not found in Config.plist")
            return ""
        }
        return key
    }
    
    var body: some View {
        ScrollView {
            VStack {
                // Top bar with dark mode toggle and offline indicator
                HStack {
                    
                    // Offline indicator
                    if isOfflineMode {
                        HStack(spacing: 6) {
                            Image(systemName: "wifi.slash")
                                .font(.caption)
                                .foregroundColor(.orange)
                            Text("Offline")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isDarkMode.toggle()
                        }
                    }) {
                        Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                            .font(.title2)
                            .foregroundColor(isDarkMode ? .yellow : .blue)
                            .padding(12)
                            .background(
                                Circle()
                                    .fill(isDarkMode ? Color.black.opacity(0.2) : Color.white.opacity(0.2))
                                    .shadow(color: isDarkMode ? .white.opacity(0.1) : .black.opacity(0.1), radius: 2, x: 0, y: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                VStack(spacing: 24) {
                    Text("Currency Converter")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: isDarkMode ? [.cyan, .purple] : [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    if !ratesDate.isEmpty {
                        HStack(spacing: 4) {
                            Text("Rates as of \(ratesDate)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            if isOfflineMode {
                                Text("(Cached)")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }
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
                                .frame(width: 110, alignment: .center)
                            }
                            
                            TextField("Enter amount", text: $baseAmount)
                                .keyboardType(.decimalPad)
                                .padding(16)
                                .background(isDarkMode ? Color(.systemGray6) : Color(.systemBackground))
                                .foregroundColor(.primary)
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
                                gradient: Gradient(colors: isDarkMode ? [.cyan.opacity(0.3), .purple.opacity(0.3)] : [.blue.opacity(0.5), .purple.opacity(0.5)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(isDarkMode ? Color.white.opacity(0.1) : Color.clear, lineWidth: 1)
                        )
                        
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
                                    .background(isDarkMode ? Color(.systemGray6) : Color(.systemBackground))
                                    .foregroundColor(.primary)
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
                                    gradient: Gradient(colors: isDarkMode ? [.cyan.opacity(0.3), .purple.opacity(0.3)] : [.blue.opacity(0.5), .purple.opacity(0.5)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(isDarkMode ? Color.white.opacity(0.1) : Color.clear, lineWidth: 1)
                            )
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
                                        .foregroundColor(isDarkMode ? .cyan : .blue)
                                        .font(.title2)
                                    Text("Add Currency")
                                        .foregroundColor(isDarkMode ? .cyan : .blue)
                                    Spacer()
                                }
                            }
                            .padding(20)
                            .background(isDarkMode ? Color(.systemGray5) : Color(.systemGray6))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(isDarkMode ? Color.white.opacity(0.1) : Color.clear, lineWidth: 1)
                            )
                        }
                    }
                    .frame(maxWidth: 400)
                    .padding(.horizontal)
                }
                .padding(.bottom, 50)
            }
            .frame(maxWidth: .infinity)
            .scrollDismissesKeyboard(.interactively)
        }
        .background(
            isDarkMode ?
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color(.systemGray6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ) :
                LinearGradient(
                    gradient: Gradient(colors: [Color(.systemBackground), Color(.systemGray6)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
        )
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .onTapGesture {
            focusedField = nil
            UIApplication.shared.endEditing()
        }
        .onAppear {
            loadOfflineData()
            fetchCurrencies()
        }
    }
    
    // MARK: - Offline Data Management
    private func loadOfflineData() {
            currencies = dataManager.loadCurrencies()
            
            if let savedData = dataManager.loadRates() {
                offlineRates = savedData.rates
                // Ensure USD is always present (Open Exchange Rates uses USD as base)
                if offlineRates["USD"] == nil {
                    offlineRates["USD"] = 1.0
                }
                ratesDate = savedData.date
                print("📦 Loaded offline rates: \(offlineRates.count) currencies")
            }
            
            if baseCurrency.isEmpty {
                baseCurrency = "USD"
            }
            if targets.isEmpty {
                targets = [TargetCurrency(code: "EUR")]
            }
            if baseAmount.isEmpty {
                baseAmount = "1"
            }
        }
        
        private func convertOffline() {
            guard !baseCurrency.isEmpty, let amountValue = Double(baseAmount) else {
                isProgrammaticUpdate = true
                for i in targets.indices {
                    targets[i].amount = ""
                }
                isProgrammaticUpdate = false
                return
            }
            
            print("🔄 Offline conversion - Base: \(baseCurrency), Amount: \(amountValue)")
            print("📊 Available rates: \(offlineRates)")
            
            isProgrammaticUpdate = true
            for i in targets.indices {
                let targetCode = targets[i].code
                print("🎯 Converting to: \(targetCode)")
                
                if baseCurrency == targetCode {
                    targets[i].amount = String(format: "%.2f", amountValue)
                    print("✅ Same currency, amount: \(targets[i].amount)")
                    continue
                }
                
                // Handle USD as base currency (Open Exchange Rates uses USD as base)
                if baseCurrency == "USD" {
                    if let targetRate = offlineRates[targetCode] {
                        let convertedAmount = amountValue * targetRate
                        targets[i].amount = String(format: "%.2f", convertedAmount)
                        print("✅ USD base conversion: \(amountValue) * \(targetRate) = \(convertedAmount)")
                    } else {
                        targets[i].amount = ""
                        print("❌ Cannot convert - missing target rate for \(targetCode)")
                    }
                } else if let baseRate = offlineRates[baseCurrency], let targetRate = offlineRates[targetCode] {
                    // Cross conversion for non-USD base
                    let convertedAmount = amountValue * (targetRate / baseRate)
                    targets[i].amount = String(format: "%.2f", convertedAmount)
                    print("✅ Cross conversion: \(amountValue) * (\(targetRate) / \(baseRate)) = \(convertedAmount)")
                } else {
                    targets[i].amount = ""
                    print("❌ Cannot convert - missing rates for base (\(baseCurrency)) or target (\(targetCode))")
                }
            }
            isProgrammaticUpdate = false
        }
        
        private func convertOfflineFromTarget(id: UUID) {
            guard let index = targets.firstIndex(where: { $0.id == id }),
                  !targets[index].code.isEmpty,
                  let amountValue = Double(targets[index].amount) else {
                isProgrammaticUpdate = true
                baseAmount = ""
                for i in targets.indices where targets[i].id != id {
                    targets[i].amount = ""
                }
                isProgrammaticUpdate = false
                return
            }
            
            let fromCode = targets[index].code
            print("🔄 Offline conversion from target - From: \(fromCode), Amount: \(amountValue)")
            
            isProgrammaticUpdate = true
            
            // Convert to base currency
            if fromCode == baseCurrency {
                baseAmount = String(format: "%.2f", amountValue)
            } else if fromCode == "USD" {
                if let baseRate = offlineRates[baseCurrency] {
                    let convertedToBase = amountValue / baseRate
                    baseAmount = String(format: "%.2f", convertedToBase)
                    print("✅ USD to base: \(amountValue) / \(baseRate) = \(convertedToBase)")
                } else {
                    baseAmount = ""
                    print("❌ Cannot convert - missing base rate for \(baseCurrency)")
                }
            } else if let fromRate = offlineRates[fromCode], let baseRate = offlineRates[baseCurrency] {
                let convertedToBase = amountValue * (baseRate / fromRate)
                baseAmount = String(format: "%.2f", convertedToBase)
                print("✅ Cross to base: \(amountValue) * (\(baseRate) / \(fromRate)) = \(convertedToBase)")
            } else {
                baseAmount = ""
                print("❌ Cannot convert - missing rates for from (\(fromCode)) or base (\(baseCurrency))")
            }
            
            // Convert to other target currencies
            for i in targets.indices where targets[i].id != id {
                let targetCode = targets[i].code
                if fromCode == targetCode {
                    targets[i].amount = String(format: "%.2f", amountValue)
                    print("✅ Same currency, amount: \(targets[i].amount)")
                    continue
                }
                
                if fromCode == "USD" {
                    if let targetRate = offlineRates[targetCode] {
                        let convertedAmount = amountValue * targetRate
                        targets[i].amount = String(format: "%.2f", convertedAmount)
                        print("✅ USD to target: \(amountValue) * \(targetRate) = \(convertedAmount)")
                    } else {
                        targets[i].amount = ""
                        print("❌ Cannot convert - missing target rate for \(targetCode)")
                    }
                } else if let fromRate = offlineRates[fromCode], let targetRate = offlineRates[targetCode] {
                    let convertedAmount = amountValue * (targetRate / fromRate)
                    targets[i].amount = String(format: "%.2f", convertedAmount)
                    print("✅ Cross to target: \(amountValue) * (\(targetRate) / \(fromRate)) = \(convertedAmount)")
                } else {
                    targets[i].amount = ""
                    print("❌ Cannot convert - missing rates for from (\(fromCode)) or target (\(targetCode))")
                }
            }
            
            isProgrammaticUpdate = false
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
            if !isOfflineMode {
                convertFromBaseOnline()
            } else {
                convertOffline()
            }
        }
        
        private func convertFromTarget(id: UUID) {
            if !isOfflineMode {
                convertFromTargetOnline(id: id)
            } else {
                convertOfflineFromTarget(id: id)
            }
        }

        private func convertFromBaseOnline() {
            guard !baseCurrency.isEmpty, let amountValue = Double(baseAmount) else {
                isProgrammaticUpdate = true
                ratesDate = ""
                for i in targets.indices {
                    targets[i].amount = ""
                }
                isProgrammaticUpdate = false
                return
            }

            // Validate API key
            guard !apiKey.isEmpty else {
                print("❌ API Key Error: No API key provided")
                DispatchQueue.main.async {
                    self.isOfflineMode = true
                    self.convertOffline()
                }
                return
            }

            let urlStr = "https://openexchangerates.org/api/latest.json?app_id=\(apiKey)"
            guard let url = URL(string: urlStr) else {
                print("❌ Invalid URL: \(urlStr)")
                DispatchQueue.main.async {
                    self.isOfflineMode = true
                    self.convertOffline()
                }
                return
            }

            print("🌐 Fetching rates from: \(urlStr)")

            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("❌ Network error: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.isOfflineMode = true
                        self.convertOffline()
                    }
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ Invalid response")
                    DispatchQueue.main.async {
                        self.isOfflineMode = true
                        self.convertOffline()
                    }
                    return
                }

                print("🌐 HTTP Status: \(httpResponse.statusCode)")

                if httpResponse.statusCode != 200 {
                    print("❌ API Error: HTTP \(httpResponse.statusCode)")
                    if httpResponse.statusCode == 401 {
                        print("❌ Unauthorized: Invalid API key")
                    } else if httpResponse.statusCode == 429 {
                        print("❌ Rate limit exceeded")
                    }
                    DispatchQueue.main.async {
                        self.isOfflineMode = true
                        self.convertOffline()
                    }
                    return
                }

                guard let data = data else {
                    print("❌ No data received")
                    DispatchQueue.main.async {
                        self.isOfflineMode = true
                        self.convertOffline()
                    }
                    return
                }

                do {
                    let decoded = try JSONDecoder().decode(RatesResponse.self, from: data)
                    var rates = decoded.rates
                    // Add USD rate explicitly since Open Exchange Rates doesn't include it
                    rates["USD"] = 1.0
                    print("✅ Fetched rates: \(rates)")
                    DispatchQueue.main.async {
                        self.dataManager.saveRates(rates, date: decoded.date)
                        self.offlineRates = rates
                        self.isOfflineMode = false
                        
                        self.isProgrammaticUpdate = true
                        self.ratesDate = decoded.date
                        for i in self.targets.indices {
                            let code = self.targets[i].code
                            if let targetRate = rates[code], let baseRate = rates[self.baseCurrency] {
                                let convertedAmount = amountValue * (targetRate / baseRate)
                                self.targets[i].amount = String(format: "%.2f", convertedAmount)
                                print("✅ Converted \(self.baseCurrency) to \(code): \(amountValue) * (\(targetRate) / \(baseRate)) = \(convertedAmount)")
                            } else {
                                self.targets[i].amount = ""
                                print("❌ Missing rate for \(code) or \(self.baseCurrency)")
                            }
                        }
                        self.isProgrammaticUpdate = false
                    }
                } catch {
                    print("❌ Decode error: \(error)")
                    DispatchQueue.main.async {
                        self.isOfflineMode = true
                        self.convertOffline()
                    }
                }
            }.resume()
        }

        private func convertFromTargetOnline(id: UUID) {
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

            // Validate API key
            guard !apiKey.isEmpty else {
                print("❌ API Key Error: No API key provided")
                DispatchQueue.main.async {
                    self.isOfflineMode = true
                    self.convertOfflineFromTarget(id: id)
                }
                return
            }

            let urlStr = "https://openexchangerates.org/api/latest.json?app_id=\(apiKey)"
            guard let url = URL(string: urlStr) else {
                print("❌ Invalid URL: \(urlStr)")
                DispatchQueue.main.async {
                    self.isOfflineMode = true
                    self.convertOfflineFromTarget(id: id)
                }
                return
            }

            print("🌐 Fetching rates from: \(urlStr)")

            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("❌ Network error: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.isOfflineMode = true
                        self.convertOfflineFromTarget(id: id)
                    }
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ Invalid response")
                    DispatchQueue.main.async {
                        self.isOfflineMode = true
                        self.convertOfflineFromTarget(id: id)
                    }
                    return
                }

                print("🌐 HTTP Status: \(httpResponse.statusCode)")

                if httpResponse.statusCode != 200 {
                    print("❌ API Error: HTTP \(httpResponse.statusCode)")
                    if httpResponse.statusCode == 401 {
                        print("❌ Unauthorized: Invalid API key")
                    } else if httpResponse.statusCode == 429 {
                        print("❌ Rate limit exceeded")
                    }
                    DispatchQueue.main.async {
                        self.isOfflineMode = true
                        self.convertOfflineFromTarget(id: id)
                    }
                    return
                }

                guard let data = data else {
                    print("❌ No data received")
                    DispatchQueue.main.async {
                        self.isOfflineMode = true
                        self.convertOfflineFromTarget(id: id)
                    }
                    return
                }

                do {
                    let decoded = try JSONDecoder().decode(RatesResponse.self, from: data)
                    var rates = decoded.rates
                    rates["USD"] = 1.0
                    print("✅ Fetched rates: \(rates)")
                    DispatchQueue.main.async {
                        self.dataManager.saveRates(rates, date: decoded.date)
                        self.offlineRates = rates
                        self.isOfflineMode = false
                        
                        self.isProgrammaticUpdate = true
                        self.ratesDate = decoded.date
                        if let fromRate = rates[fromCode], let baseRate = rates[self.baseCurrency] {
                            let convertedToBase = amountValue * (baseRate / fromRate)
                            self.baseAmount = String(format: "%.2f", convertedToBase)
                            print("✅ Converted \(fromCode) to \(self.baseCurrency): \(amountValue) * (\(baseRate) / \(fromRate)) = \(convertedToBase)")
                        } else {
                            self.baseAmount = ""
                            print("❌ Missing rate for \(fromCode) or \(self.baseCurrency)")
                        }
                        for i in self.targets.indices where self.targets[i].id != id {
                            let code = self.targets[i].code
                            if let fromRate = rates[fromCode], let targetRate = rates[code] {
                                let convertedAmount = amountValue * (targetRate / fromRate)
                                self.targets[i].amount = String(format: "%.2f", convertedAmount)
                                print("✅ Converted \(fromCode) to \(code): \(amountValue) * (\(targetRate) / \(fromRate)) = \(convertedAmount)")
                            } else {
                                self.targets[i].amount = ""
                                print("❌ Missing rate for \(fromCode) or \(code)")
                            }
                        }
                        self.isProgrammaticUpdate = false
                    }
                } catch {
                    print("❌ Decode error: \(error)")
                    DispatchQueue.main.async {
                        self.isOfflineMode = true
                        self.convertOfflineFromTarget(id: id)
                    }
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
            guard let url = URL(string: "https://openexchangerates.org/api/currencies.json") else {
                print("❌ Invalid currencies URL")
                return
            }

            print("🌐 Fetching currencies from: \(url)")

            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("❌ Error fetching currencies: \(error.localizedDescription)")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("❌ Invalid response for currencies: \(String(describing: (response as? HTTPURLResponse)?.statusCode))")
                    return
                }

                guard let data = data else {
                    print("❌ No data for currencies")
                    return
                }

                do {
                    let decoded = try JSONDecoder().decode(CurrencyList.self, from: data)
                    DispatchQueue.main.async {
                        self.currencies = decoded.codes
                        self.dataManager.saveCurrencies(decoded.codes)
                        print("✅ Loaded \(decoded.codes.count) currencies")

                        if self.baseCurrency.isEmpty || self.currencies[self.baseCurrency] == nil {
                            self.isProgrammaticUpdate = true
                            self.baseCurrency = "USD"
                            self.isProgrammaticUpdate = false
                        }
                        if self.targets.isEmpty {
                            self.targets = [TargetCurrency(code: "EUR")]
                        }

                        if self.baseAmount.isEmpty {
                            self.baseAmount = "1"
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.convertFromBase()
                        }
                    }
                } catch {
                    print("❌ Decode error for currencies: \(error)")
                }
            }.resume()
        }
    }

    // MARK: - Models
    struct RatesResponse: Codable {
        let timestamp: Int
        let base: String
        let rates: [String: Double]
        
        var date: String {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    return dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(timestamp)))
                }
        
        enum CodingKeys: String, CodingKey {
            case timestamp
            case base
            case rates
        }
    }

    struct CurrencyList: Codable {
        let codes: [String: String]

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.codes = try container.decode([String: String].self)
        }
    }

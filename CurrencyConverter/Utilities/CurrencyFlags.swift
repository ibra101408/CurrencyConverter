//
//  CurrencyFlags.swift
//  JustCurrencyConverter
//
//  Created by Daniil Vodenejev on 28.10.2025.
//

enum CurrencyFlags {
    static let map: [String:String] = [
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
}

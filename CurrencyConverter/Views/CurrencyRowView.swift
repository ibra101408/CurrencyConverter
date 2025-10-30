//
//  CurrencyRowView.swift
//  JustCurrencyConverter
//
//  Created by Daniil Vodenejev on 28.10.2025.
//
import SwiftUI

struct CurrencyRowView: View {
    let code: String
    let name: String
    @Binding var amount: String
    var isDark: Bool = true
    var flagText: String
    var chevronTap: () -> Void
    var removeTap: (() -> Void)? = nil
    @EnvironmentObject var vm: CurrencyViewModel

    var body: some View {
        VStack(spacing: 12) {

            // MARK: Header
            HStack(spacing: 12) {
                Text(flagText)
                    .font(.largeTitle)

                VStack(alignment: .leading, spacing: 4) {
                    Text(code)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Theme.label(for: isDark))
                    Text(name)
                        .font(.caption)
                        .foregroundStyle(Theme.subLabel(for: isDark))
                }

                Spacer()

                Button(action: chevronTap) {
                    Image(systemName: "chevron.down")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.subLabel(for: isDark))
                        .frame(width: 32, height: 32)
                        .background(Theme.cardBG(for: isDark))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Theme.stroke(for: isDark), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
            .overlay(alignment: .topTrailing) {
                if let removeTap {
                    Button(action: removeTap) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.red)
                    }
                    .buttonStyle(.plain)
                }
            }

            // MARK: Text field
            TextField("Enter amount", text: $amount)
                .keyboardType(.decimalPad)
                .onChange(of: amount) { newValue in
                        let normalized = vm.normalized(newValue)
                        if normalized != newValue {
                            amount = normalized
                        }
                    }
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .padding(14)
                .background(Theme.cardBG(for: isDark))
                .foregroundStyle(Theme.label(for: isDark))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Theme.stroke(for: isDark), lineWidth: 1)
                )
        }
        .padding(16)
        .background(Theme.cardBG(for: isDark))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Theme.stroke(for: isDark), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

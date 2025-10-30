import SwiftUI

struct ContentView: View {
    @EnvironmentObject var vm: CurrencyViewModel
    @FocusState private var focusedField: CurrencyViewModel.FocusedField?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {

                // MARK: Top bar
                HStack {
                    if vm.isOfflineMode {
                        HStack(spacing: 6) {
                            Image(systemName: "wifi.slash")
                                .font(.caption)
                            Text("Offline")
                                .font(.caption.weight(.medium))
                        }
                        .foregroundStyle(Theme.chipFG(for: vm.isDarkMode))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Theme.chipBG(for: vm.isDarkMode))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Theme.stroke(for: vm.isDarkMode), lineWidth: 1)
                        )
                    }
                    Spacer()

                    // MARK: Dark/light toggle
                    Button {
                        withAnimation(.snappy(duration: 0.25)) { vm.isDarkMode.toggle() }
                    } label: {
                        Image(systemName: vm.isDarkMode ? "sun.max.fill" : "moon.fill")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(Theme.label(for: vm.isDarkMode))
                            .frame(width: 36, height: 36)
                            .background(Theme.cardBG(for: vm.isDarkMode))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Theme.stroke(for: vm.isDarkMode), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
                .padding(.top, 10)

                // MARK: Title
                VStack(alignment: .leading, spacing: 8) {
                    Text("Currency Converter")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.label(for: vm.isDarkMode))

                    if !vm.ratesDate.isEmpty {
                        HStack(spacing: 6) {
                            Text("Rates as of \(vm.ratesDate)")
                            if vm.isOfflineMode { Text("(cached)") }
                        }
                        .font(.footnote)
                        .foregroundStyle(Theme.subLabel(for: vm.isDarkMode))
                    }
                }
                .padding(.horizontal)

                // MARK: Base row
                CurrencyRowView(
                    code: vm.baseCurrency,
                    name: vm.currencies[vm.baseCurrency] ?? "",
                    amount: $vm.baseAmount,
                    isDark: vm.isDarkMode,
                    flagText: CurrencyIcon.emoji(for: vm.baseCurrency, flags: vm.currencyFlags),
                    chevronTap: {
                        vm.isSelectingBase = true
                        vm.editingTargetID = nil
                        vm.searchText = ""
                        vm.showingCurrencyPicker = true
                    }
                )
                .focused($focusedField, equals: .base)
                .onChange(of: vm.baseAmount) { _ in
                    if focusedField == .base { vm.convertBasedOnFocus(.base) }
                }
                .onChange(of: vm.baseCurrency) { _ in
                    vm.convertBasedOnFocus(focusedField)
                }

                // MARK: Target rows
                ForEach($vm.targets) { $target in
                    CurrencyRowView(
                        code: target.code,
                        name: vm.currencies[target.code] ?? "",
                        amount: $target.amount,
                        isDark: vm.isDarkMode,
                        flagText: CurrencyIcon.emoji(for: target.code, flags: vm.currencyFlags),
                        chevronTap: {
                            vm.isSelectingBase = false
                            vm.editingTargetID = target.id
                            vm.searchText = ""
                            vm.showingCurrencyPicker = true
                        },
                        removeTap: {
                            vm.targets.removeAll { $0.id == target.id }
                            Task { await vm.convertFromBase() }
                        }
                    )
                    .focused($focusedField, equals: .target(target.id))
                    .onChange(of: target.amount) { _ in
                        if focusedField == .target(target.id) {
                            vm.convertBasedOnFocus(.target(target.id))
                        }
                    }
                    .onChange(of: target.code) { _ in
                        vm.convertBasedOnFocus(focusedField)
                    }
                }

                // MARK: Add button
                if vm.targets.count < 4 {
                    Button {
                        vm.isSelectingBase = false
                        vm.editingTargetID = nil
                        vm.searchText = ""
                        vm.showingCurrencyPicker = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "plus.circle")
                            Text("Add Currency")
                            Spacer()
                        }
                        .font(.callout.weight(.medium))
                        .foregroundStyle(Theme.label(for: vm.isDarkMode))
                        .padding(16)
                        .background(Theme.cardBG(for: vm.isDarkMode))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Theme.stroke(for: vm.isDarkMode), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal)
                }

                Spacer(minLength: 40)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        // MARK: Background gradient (dynamic)
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
        .tint(Theme.accent(for: vm.isDarkMode))
        .onTapGesture {
            focusedField = nil
            UIApplication.shared.endEditing()
        }
        .sheet(isPresented: $vm.showingCurrencyPicker) {
            CurrencyPickerView()
                .presentationDetents([.medium, .large])
                .background(
                    LinearGradient(
                        colors: [
                            Theme.bgTop(for: vm.isDarkMode),
                            Theme.bgBottom(for: vm.isDarkMode)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .scrollContentBackground(.hidden)
        }
    }
}

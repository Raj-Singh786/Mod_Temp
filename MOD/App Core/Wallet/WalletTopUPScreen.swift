//
//  WalletTopUPScreen.swift
//  MOD
//
//  Created by Rajpal singh on 10/11/26.
//

import SwiftUI

// MARK: - Models

struct QuickTopUpOption: Identifiable {
    let id = UUID()
    let amount: Double
    let label: String
    let subtitle: String
    let bonusTag: String?
    let isPopular: Bool
}

enum TopUpPaymentMethod: String, CaseIterable, Identifiable {
    case applePay = "Apple Pay"
    case visa = "Visa •• 4219"
    case mastercard = "Mastercard •• 8820"
    case payPal = "PayPal Express"

    var id: String { rawValue }

    var subtitle: String {
        switch self {
        case .applePay: return "Default Device Wallet"
        case .visa: return "Expires 09/27"
        case .mastercard: return "Expires 11/26"
        case .payPal: return "Connected account"
        }
    }

    var isPrimary: Bool {
        return self == .visa
    }
}

// MARK: - Wallet Top Up Screen

struct WalletTopUPScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) private var presentationMode

    // Wallet & Points State
    @State private var currentBalance: Double = 48.50
    @State private var hutPoints: Int = 420

    // Selected Top Up Value
    @State private var selectedAmount: Double = 50.00
    @State private var isCustomAmount: Bool = false
    @State private var customAmountInput: String = ""

    // Auto-reload & Payment States
    @State private var isAutoReloadEnabled: Bool = true
    @State private var selectedPaymentMethod: TopUpPaymentMethod = .applePay

    // Sheet & Alert States
    @State private var showCustomAmountSheet: Bool = false
    @State private var showAddPaymentSheet: Bool = false
    @State private var showReceiptScreen: Bool = false
    @State private var lastPreviousBalance: Double = 48.50
    @State private var showSupportAlert: Bool = false
    @State private var showSuccessAlert: Bool = false
    @State private var isProcessing: Bool = false

    // Theme Colors
    private let modRed = Color(red: 0.88, green: 0.12, blue: 0.18)
    private let darkBgStart = Color(red: 0.09, green: 0.11, blue: 0.18)
    private let darkBgEnd = Color(red: 0.13, green: 0.15, blue: 0.24)
    private let screenBg = Color(red: 0.98, green: 0.98, blue: 0.99)
    private let borderGray = Color(red: 0.91, green: 0.91, blue: 0.93)
    private let tealBonus = Color(red: 0.08, green: 0.60, blue: 0.55)
    private let tealBonusBg = Color(red: 0.90, green: 0.97, blue: 0.96)
    private let amberBonus = Color(red: 0.98, green: 0.62, blue: 0.12)
    private let textDark = Color(red: 0.10, green: 0.12, blue: 0.18)

    // Quick Denominations matching snapshot
    private let quickOptions: [QuickTopUpOption] = [
        QuickTopUpOption(
            amount: 10.0,
            label: "$10",
            subtitle: "Quick Slice",
            bonusTag: nil,
            isPopular: false
        ),
        QuickTopUpOption(
            amount: 25.0,
            label: "$25",
            subtitle: "Combo Meal",
            bonusTag: nil,
            isPopular: false
        ),
        QuickTopUpOption(
            amount: 50.0,
            label: "$50",
            subtitle: "Family Feast",
            bonusTag: "★ POPULAR • +5% BONUS",
            isPopular: true
        ),
        QuickTopUpOption(
            amount: 100.0,
            label: "$100",
            subtitle: "Party Saver",
            bonusTag: "+10% BONUS",
            isPopular: false
        )
    ]

    // Computed Values
    private var newBalance: Double {
        currentBalance + selectedAmount
    }

    private var bonusPointsEarned: Int {
        if selectedAmount >= 100.0 {
            return Int(selectedAmount * 0.5) // +50 pts
        } else if selectedAmount >= 50.0 {
            return Int(selectedAmount * 0.5) // +25 pts
        } else {
            return Int(selectedAmount * 0.2) // Standard reload points
        }
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // 1. Navigation Header
            navigationHeader

            // 2. Scrollable Body
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    // Dark Wallet Balance Card
                    currentBalanceCard
                        .padding(.top, 14)

                    // 1. Choose Top Up Amount Section
                    chooseAmountSection

                    // 2. Pay With Section
                    payWithSection

                    // Clearance for sticky footer
                    Color.clear.frame(height: 110)
                }
                .padding(.horizontal, 16)
            }
            .background(screenBg)

            // 3. Sticky Bottom Bar
            stickyBottomBar
        }
        .background(screenBg.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
        .sheet(isPresented: $showCustomAmountSheet) {
            customAmountSheetView
        }
        .sheet(isPresented: $showAddPaymentSheet) {
            addPaymentMethodSheetView
        }
        .fullScreenCover(isPresented: $showReceiptScreen) {
            TopUpReceiptScreen(
                transactionId: "TXN-MOD-\(Int.random(in: 100000...999999))",
                reloadAmount: selectedAmount,
                previousBalance: lastPreviousBalance,
                newBalance: currentBalance,
                paymentMethodName: selectedPaymentMethod.rawValue,
                pointsEarned: bonusPointsEarned,
                isAutoReloadEnabled: isAutoReloadEnabled,
                dateString: "Today, 10:15 AM",
                onDone: {
                    showReceiptScreen = false
                    dismiss()
                }
            )
        }
        .alert(isPresented: $showSupportAlert) {
            Alert(
                title: Text("Wallet Support"),
                message: Text("Need help with your MOD Wallet or reload? Our 24/7 care team is ready to assist."),
                primaryButton: .default(Text("Call Support")),
                secondaryButton: .cancel()
            )
        }
        .alert(isPresented: $showSuccessAlert) {
            Alert(
                title: Text("Top Up Successful! ⚡"),
                message: Text("$\(String(format: "%.2f", selectedAmount)) has been added to your MOD Wallet. Your new balance is $\(String(format: "%.2f", newBalance))!"),
                dismissButton: .default(Text("Awesome!")) {
                    currentBalance = newBalance
                    hutPoints += bonusPointsEarned
                    UserDefaults.standard.set(newBalance, forKey: "walletBalance")
                    dismiss()
                }
            )
        }
        .onAppear {
            if let saved = UserDefaults.standard.object(forKey: "walletBalance") as? Double, saved > 0 {
                currentBalance = saved
            }
        }
    }

    // MARK: - 1. Navigation Header

    private var navigationHeader: some View {
        HStack {
            // Back Button
            Button(action: {
                dismiss()
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(Font.appFont(.jakartaBold, size: 15))
                    .foregroundColor(.black)
                    .frame(width: 38, height: 38)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
            }

            Spacer()

            Text("Top Up Wallet")
                .font(Font.appFont(.jakartaBold, size: 18))
                .foregroundColor(.black)

            Spacer()

            // Support Headset Button
            Button(action: {
                showSupportAlert = true
            }) {
                Image(systemName: "headphones")
                    .font(Font.appFont(.jakartaSemiBold, size: 15))
                    .foregroundColor(.black)
                    .frame(width: 38, height: 38)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 2)
    }

    // MARK: - Top Card: Current Wallet Balance

    private var currentBalanceCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Top Row: Label & Points Badge
            HStack(alignment: .center) {
                HStack(spacing: 8) {
                    // Orange Wallet Icon Box
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(red: 0.95, green: 0.58, blue: 0.15))
                            .frame(width: 22, height: 22)

                        Image(systemName: "wallet.pass.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.white)
                    }

                    Text("Current Wallet Balance")
                        .font(Font.appFont(.jakartaMedium, size: 13))
                        .foregroundColor(Color.white.opacity(0.78))
                }

                Spacer()

                // Points Badge (🍕 420 pts)
                HStack(spacing: 5) {
                    Text("🍕")
                        .font(.system(size: 12))

                    Text("\(hutPoints) pts")
                        .font(Font.appFont(.jakartaBold, size: 12))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.white.opacity(0.14))
                .clipShape(Capsule())
            }

            // Big Balance Text ($48.50 USD)
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("$\(String(format: "%.2f", currentBalance))")
                    .font(Font.appFont(.jakartaExtraBold, size: 34))
                    .foregroundColor(.white)

                Text("USD")
                    .font(Font.appFont(.jakartaBold, size: 13))
                    .foregroundColor(Color.white.opacity(0.65))
            }

            // Bottom Promo Banner Strip
            HStack(alignment: .center, spacing: 8) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 0.98, green: 0.75, blue: 0.15))

                Text("Earn +5% extra Hut Points & instant cashback on every reload of $50 or more.")
                    .font(Font.appFont(.jakartaMedium, size: 12))
                    .foregroundColor(.white.opacity(0.92))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.08))
            .cornerRadius(12)
        }
        .padding(18)
        .background(
            LinearGradient(
                colors: [darkBgStart, darkBgEnd],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .shadow(color: darkBgStart.opacity(0.3), radius: 10, x: 0, y: 5)
    }

    // MARK: - Section 1: Choose Top Up Amount

    private var chooseAmountSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header Titles
            VStack(alignment: .leading, spacing: 3) {
                Text("1. Choose Top Up Amount")
                    .font(Font.appFont(.jakartaBold, size: 16.5))
                    .foregroundColor(textDark)

                Text("Select a quick denomination or enter custom amount")
                    .font(Font.appFont(.jakartaRegular, size: 13))
                    .foregroundColor(.gray)
            }

            // Top Up Value Display Card
            VStack(spacing: 8) {
                Text("TOP UP VALUE")
                    .font(Font.appFont(.jakartaBold, size: 11))
                    .foregroundColor(Color(red: 0.35, green: 0.38, blue: 0.44))
                    .tracking(0.5)

                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("$")
                        .font(Font.appFont(.jakartaBold, size: 26))
                        .foregroundColor(textDark)

                    Text(String(format: "%.2f", selectedAmount))
                        .font(Font.appFont(.jakartaExtraBold, size: 36))
                        .foregroundColor(textDark)
                }

                HStack(spacing: 5) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 13))
                        .foregroundColor(Color(red: 0.12, green: 0.65, blue: 0.38))

                    Text("Min $5.00 • Max $500.00")
                        .font(Font.appFont(.jakartaMedium, size: 12))
                        .foregroundColor(Color(red: 0.35, green: 0.38, blue: 0.44))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(borderGray, lineWidth: 1)
            )

            // 2x2 Grid of Quick Denominations
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(quickOptions) { option in
                    quickDenominationCard(option: option)
                }
            }

            // Custom Amount Row Card
            customAmountRowCard

            // Auto-Reload Card
            autoReloadCard
        }
    }

    // MARK: Quick Denomination Card

    private func quickDenominationCard(option: QuickTopUpOption) -> some View {
        let isSelected = !isCustomAmount && selectedAmount == option.amount

        return Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                selectedAmount = option.amount
                isCustomAmount = false
            }
        }) {
            ZStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    // Amount
                    Text(option.label)
                        .font(Font.appFont(.jakartaExtraBold, size: 20))
                        .foregroundColor(isSelected ? modRed : textDark)

                    // Subtitle
                    Text(option.subtitle)
                        .font(Font.appFont(.jakartaMedium, size: 12))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 14)
                .padding(.vertical, 16)
                .background(Color.white)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(isSelected ? modRed : borderGray, lineWidth: isSelected ? 1.8 : 1)
                )
                .shadow(color: isSelected ? modRed.opacity(0.12) : Color.black.opacity(0.02), radius: 4, x: 0, y: 2)

                // Attached Badge for Popular / Bonus
                if let tag = option.bonusTag {
                    Text(tag)
                        .font(Font.appFont(.jakartaBold, size: 9.5))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3.5)
                        .background(option.isPopular ? modRed : amberBonus)
                        .cornerRadius(6)
                        .offset(y: -8)
                        .shadow(color: (option.isPopular ? modRed : amberBonus).opacity(0.3), radius: 3, x: 0, y: 2)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: Custom Amount Row Card

    private var customAmountRowCard: some View {
        HStack(spacing: 12) {
            // Pencil Icon
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(red: 1.0, green: 0.93, blue: 0.94))
                    .frame(width: 40, height: 40)

                Image(systemName: "pencil")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(modRed)
            }

            // Labels
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text("Custom Amount")
                        .font(Font.appFont(.jakartaBold, size: 14.5))
                        .foregroundColor(textDark)

                    Text("Any")
                        .font(Font.appFont(.jakartaBold, size: 10.5))
                        .foregroundColor(Color(red: 0.25, green: 0.45, blue: 0.85))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(Color(red: 0.90, green: 0.94, blue: 0.99))
                        .cornerRadius(6)
                }

                Text("Min $5.00 • Max $500.00")
                    .font(Font.appFont(.jakartaRegular, size: 11.5))
                    .foregroundColor(.gray)
            }

            Spacer()

            // "Enter $" Button
            Button(action: {
                customAmountInput = isCustomAmount ? String(format: "%.2f", selectedAmount) : ""
                showCustomAmountSheet = true
            }) {
                Text(isCustomAmount ? "$\(String(format: "%.2f", selectedAmount))" : "Enter $")
                    .font(Font.appFont(.jakartaBold, size: 13))
                    .foregroundColor(modRed)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(Color(red: 1.0, green: 0.94, blue: 0.95))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(modRed, lineWidth: 1)
                    )
            }
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isCustomAmount ? modRed : borderGray, lineWidth: isCustomAmount ? 1.5 : 1)
        )
    }

    // MARK: Auto-Reload Card

    private var autoReloadCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                // Reload Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(red: 1.0, green: 0.93, blue: 0.94))
                        .frame(width: 40, height: 40)

                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(modRed)
                }

                // Title + Smart Tag
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text("Enable Auto-Reload")
                            .font(Font.appFont(.jakartaBold, size: 14.5))
                            .foregroundColor(textDark)

                        Text("SMART")
                            .font(Font.appFont(.jakartaBold, size: 10))
                            .foregroundColor(modRed)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(red: 1.0, green: 0.92, blue: 0.94))
                            .cornerRadius(5)
                    }
                }

                Spacer()

                // Toggle Switch
                Toggle("", isOn: $isAutoReloadEnabled)
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle(tint: modRed))
            }

            Text("Automatically reload $25 when balance drops below $10. Never run out during checkout.")
                .font(Font.appFont(.jakartaRegular, size: 12))
                .foregroundColor(.gray)
                .lineSpacing(2)
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(borderGray, lineWidth: 1)
        )
    }

    // MARK: - Section 2: Pay With

    private var payWithSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header Row
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("2. Pay With")
                        .font(Font.appFont(.jakartaBold, size: 16.5))
                        .foregroundColor(textDark)

                    Text("Choose your instant reload source")
                        .font(Font.appFont(.jakartaRegular, size: 13))
                        .foregroundColor(.gray)
                }

                Spacer()

                Button(action: {
                    showAddPaymentSheet = true
                }) {
                    Text("+ Add New")
                        .font(Font.appFont(.jakartaBold, size: 13))
                        .foregroundColor(modRed)
                }
            }

            // Payment Options List
            VStack(spacing: 10) {
                ForEach(TopUpPaymentMethod.allCases) { method in
                    paymentMethodRow(method: method)
                }
            }
        }
    }

    // MARK: Payment Method Row

    private func paymentMethodRow(method: TopUpPaymentMethod) -> some View {
        let isSelected = selectedPaymentMethod == method

        return Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedPaymentMethod = method
            }
        }) {
            HStack(spacing: 12) {
                // Payment Method Brand Icon
                paymentMethodIcon(method: method)

                // Title + Tag + Subtitle
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(method.rawValue)
                            .font(Font.appFont(.jakartaBold, size: 14.5))
                            .foregroundColor(textDark)

                        if method.isPrimary {
                            Text("Primary")
                                .font(Font.appFont(.jakartaBold, size: 10))
                                .foregroundColor(Color(red: 0.25, green: 0.45, blue: 0.85))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(red: 0.90, green: 0.94, blue: 0.99))
                                .cornerRadius(5)
                        }
                    }

                    Text(method.subtitle)
                        .font(Font.appFont(.jakartaRegular, size: 12))
                        .foregroundColor(.gray)
                }

                Spacer()

                // Radio Button
                ZStack {
                    Circle()
                        .stroke(isSelected ? modRed : Color.gray.opacity(0.35), lineWidth: 1.5)
                        .frame(width: 20, height: 20)

                    if isSelected {
                        Circle()
                            .fill(modRed)
                            .frame(width: 10, height: 10)
                    }
                }
            }
            .padding(14)
            .background(Color.white)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? modRed : borderGray, lineWidth: isSelected ? 1.5 : 1)
            )
            .shadow(color: isSelected ? modRed.opacity(0.08) : Color.clear, radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: Brand Icon Component

    @ViewBuilder
    private func paymentMethodIcon(method: TopUpPaymentMethod) -> some View {
        switch method {
        case .applePay:
            // Apple Pay Black Box
            ZStack {
                RoundedRectangle(cornerRadius: 7)
                    .fill(Color.black)
                    .frame(width: 44, height: 28)

                HStack(spacing: 2) {
                    Image(systemName: "applelogo")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                    Text("Pay")
                        .font(Font.appFont(.jakartaBold, size: 10.5))
                        .foregroundColor(.white)
                }
            }

        case .visa:
            // Visa Blue Box
            ZStack {
                RoundedRectangle(cornerRadius: 7)
                    .fill(Color(red: 0.08, green: 0.18, blue: 0.45))
                    .frame(width: 44, height: 28)

                Text("VISA")
                    .font(.system(size: 11, weight: .black, design: .serif))
                    .italic()
                    .foregroundColor(.white)
            }

        case .mastercard:
            // Mastercard Dark Box with Overlapping Circles
            ZStack {
                RoundedRectangle(cornerRadius: 7)
                    .fill(Color(red: 0.14, green: 0.16, blue: 0.20))
                    .frame(width: 44, height: 28)

                HStack(spacing: -6) {
                    Circle()
                        .fill(Color(red: 0.92, green: 0.18, blue: 0.14))
                        .frame(width: 14, height: 14)
                    Circle()
                        .fill(Color(red: 0.98, green: 0.65, blue: 0.10).opacity(0.95))
                        .frame(width: 14, height: 14)
                }
            }

        case .payPal:
            // PayPal Blue Box
            ZStack {
                RoundedRectangle(cornerRadius: 7)
                    .fill(Color(red: 0.0, green: 0.25, blue: 0.58))
                    .frame(width: 44, height: 28)

                Text("PayPal")
                    .font(.system(size: 8.5, weight: .bold, design: .rounded))
                    .italic()
                    .foregroundColor(.white)
            }
        }
    }

    // MARK: - 3. Sticky Bottom Bar

    private var stickyBottomBar: some View {
        VStack(spacing: 12) {
            // New Balance Row + Bonus Pill
            HStack {
                HStack(spacing: 4) {
                    Text("New Balance will be:")
                        .font(Font.appFont(.jakartaMedium, size: 13))
                        .foregroundColor(.gray)

                    Text("$\(String(format: "%.2f", newBalance))")
                        .font(Font.appFont(.jakartaBold, size: 15))
                        .foregroundColor(textDark)
                }

                Spacer()

                // +25 pts Bonus Pill
                HStack(spacing: 4) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 11))
                        .foregroundColor(tealBonus)

                    Text("+\(bonusPointsEarned) pts Bonus")
                        .font(Font.appFont(.jakartaBold, size: 11))
                        .foregroundColor(tealBonus)
                }
                .padding(.horizontal, 9)
                .padding(.vertical, 4.5)
                .background(tealBonusBg)
                .cornerRadius(12)
            }

            // Big Red Primary Top-Up Button
            Button(action: {
                isProcessing = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    isProcessing = false
                    lastPreviousBalance = currentBalance
                    currentBalance = newBalance
                    hutPoints += bonusPointsEarned
                    UserDefaults.standard.set(newBalance, forKey: "walletBalance")
                    showReceiptScreen = true
                }
            }) {
                HStack(spacing: 8) {
                    if isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 14, weight: .bold))

                        Text("Top Up $\(String(format: "%.2f", selectedAmount)) Now")
                            .font(Font.appFont(.jakartaBold, size: 15))

                        Image(systemName: "arrow.right")
                            .font(.system(size: 13, weight: .bold))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(modRed)
                .cornerRadius(14)
                .shadow(color: modRed.opacity(0.35), radius: 8, x: 0, y: 4)
            }
            .disabled(isProcessing)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 24)
        .background(
            Color.white
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: -3)
                .edgesIgnoringSafeArea(.bottom)
        )
    }

    // MARK: - Custom Amount Sheet View

    private var customAmountSheetView: some View {
        VStack(spacing: 20) {
            // Drag Indicator
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 10)

            Text("Enter Custom Amount")
                .font(Font.appFont(.jakartaBold, size: 18))
                .foregroundColor(textDark)

            Text("Enter any amount between $5.00 and $500.00")
                .font(Font.appFont(.jakartaRegular, size: 13))
                .foregroundColor(.gray)

            // Input Field
            HStack(spacing: 4) {
                Text("$")
                    .font(Font.appFont(.jakartaBold, size: 32))
                    .foregroundColor(textDark)

                TextField("0.00", text: $customAmountInput)
                    .font(Font.appFont(.jakartaExtraBold, size: 36))
                    .keyboardType(.decimalPad)
                    .foregroundColor(textDark)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(Color(red: 0.96, green: 0.96, blue: 0.98))
            .cornerRadius(14)
            .padding(.horizontal, 20)

            // Quick Amount Chips
            HStack(spacing: 8) {
                ForEach([15.0, 35.0, 75.0, 150.0], id: \.self) { chip in
                    Button(action: {
                        customAmountInput = String(format: "%.2f", chip)
                    }) {
                        Text("$\(Int(chip))")
                            .font(Font.appFont(.jakartaBold, size: 13))
                            .foregroundColor(textDark)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(borderGray, lineWidth: 1))
                    }
                }
            }

            Spacer()

            // Confirm Button
            Button(action: {
                if let val = Double(customAmountInput), val >= 5.0 && val <= 500.0 {
                    selectedAmount = val
                    isCustomAmount = true
                    showCustomAmountSheet = false
                }
            }) {
                Text("Confirm Amount")
                    .font(Font.appFont(.jakartaBold, size: 15))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(modRed)
                    .cornerRadius(14)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .presentationDetents([.height(360)])
    }

    // MARK: - Add Payment Method Sheet View

    @State private var newCardNumber: String = ""
    @State private var newCardExpiry: String = ""
    @State private var newCardCvv: String = ""

    private var addPaymentMethodSheetView: some View {
        VStack(spacing: 18) {
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 10)

            Text("Add New Card")
                .font(Font.appFont(.jakartaBold, size: 18))
                .foregroundColor(textDark)

            VStack(spacing: 12) {
                TextField("Card Number (16 digits)", text: $newCardNumber)
                    .font(Font.appFont(.jakartaMedium, size: 14))
                    .keyboardType(.numberPad)
                    .padding(12)
                    .background(Color(red: 0.96, green: 0.96, blue: 0.98))
                    .cornerRadius(10)

                HStack(spacing: 12) {
                    TextField("MM/YY", text: $newCardExpiry)
                        .font(Font.appFont(.jakartaMedium, size: 14))
                        .keyboardType(.numbersAndPunctuation)
                        .padding(12)
                        .background(Color(red: 0.96, green: 0.96, blue: 0.98))
                        .cornerRadius(10)

                    TextField("CVV", text: $newCardCvv)
                        .font(Font.appFont(.jakartaMedium, size: 14))
                        .keyboardType(.numberPad)
                        .padding(12)
                        .background(Color(red: 0.96, green: 0.96, blue: 0.98))
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal, 20)

            Spacer()

            Button(action: {
                showAddPaymentSheet = false
            }) {
                Text("Save Card")
                    .font(Font.appFont(.jakartaBold, size: 15))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(modRed)
                    .cornerRadius(14)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .presentationDetents([.height(360)])
    }
}

// MARK: - Preview

#Preview {
    WalletTopUPScreen()
}

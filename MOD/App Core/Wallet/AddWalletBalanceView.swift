//
//  AddWalletBalanceView.swift
//  MOD
//
//  Created by Rajpal singh on 18/11/26.
//

import SwiftUI

// MARK: - AddWalletBalanceView

struct AddWalletBalanceView: View {
    
    // MARK: - Configuration & Callbacks
    
    var showHeader: Bool = true
    var onBack: (() -> Void)? = nil
    var onAllActivityTap: (() -> Void)? = nil
    var onCartTap: (() -> Void)? = nil
    var onStarTap: (() -> Void)? = nil
    
    // MARK: - Observed State
    
    @ObservedObject private var walletManager = WalletManager.shared
    
    // MARK: - Local State
    
    @State private var customAmountInput: String = ""
    @State private var giftCardCodeInput: String = ""
    @State private var selectedPresetAmount: Double? = nil
    
    // Alerts & Feedback
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var showAllActivitySheet: Bool = false
    
    // MARK: - Body
    
    var body: some View {
        if showHeader {
            ZStack {
                Color("app_background")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top Custom Navigation Bar
                    customNavigationBar
                    
                    // Scrollable Main Content
                    ScrollView(showsIndicators: false) {
                        contentStack
                            .padding(.horizontal, 16)
                            .padding(.top, 10)
                            .padding(.bottom, 36)
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .sheet(isPresented: $showAllActivitySheet) {
                AllWalletActivityView(
                    showHeader: true,
                    onBack: {
                        showAllActivitySheet = false
                    },
                    onCartTap: onCartTap,
                    onStarTap: onStarTap
                )
            }
        } else {
            contentStack
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text(alertTitle),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
                .sheet(isPresented: $showAllActivitySheet) {
                    AllWalletActivityView(
                        showHeader: true,
                        onBack: {
                            showAllActivitySheet = false
                        },
                        onCartTap: onCartTap,
                        onStarTap: onStarTap
                    )
                }
        }
    }
    
    // MARK: - 0. Custom Top Navigation Bar
    
    private var customNavigationBar: some View {
        HStack(alignment: .center) {
            // Left: Back Button
            Button(action: {
                if let onBack = onBack {
                    onBack()
                } else if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                          let rootNav = windowScene.windows.first?.rootViewController as? UINavigationController {
                    rootNav.popViewController(animated: true)
                }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 15, weight: .bold))
                    
                    Text("Back")
                        .font(.barlowBold(size: 16))
                }
                .foregroundColor(Color("Button_red"))
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            // Center: Title
            Text("Wallet")
                .font(.oswaldMedium(size: 18))
                .foregroundColor(Color("app_black"))
            
            Spacer()
            
            // Right: Star & Cart Icons
            HStack(spacing: 16) {
                Button(action: {
                    if let onStarTap = onStarTap {
                        onStarTap()
                    } else {
                        AccountSheetManager.shared.handleStarTap()
                    }
                }) {
                    Image(systemName: "star")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(Color("app_black"))
                }
                .buttonStyle(PlainButtonStyle())
                
                TopCartButton(action: onCartTap)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
        .padding(.bottom, 10)
        .background(Color("app_background"))
    }
    
    // MARK: - Content Stack
    
    private var contentStack: some View {
        VStack(alignment: .leading, spacing: 18) {
            // 1. Header: Title & Subtitle
            headerSection
            
            // 2. Gift-Wallet Funds Card (Burgundy)
            giftWalletFundsCard
            
            // 3. Service Credit Card (White with Olive Green)
            serviceCreditCard
            
            // 4. Top Up & Redeem Gift Card Section
            topUpAndRedeemCard
            
            // 5. Recent Wallet Activity Card
            recentActivityCard
        }
    }
    
    // MARK: - 1. Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("MOD WALLET")
                .font(.oswaldMedium(size: 32))
                .tracking(0.8)
                .foregroundColor(Color("app_black"))
            
            Text("Gift funds and service credit are kept separate. All payments are simulated.")
                .font(.barlowRegular(size: 14))
                .foregroundColor(Color("text_gary"))
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 4)
    }
    
    // MARK: - 2. Gift-Wallet Funds Card (Burgundy)
    
    private var giftWalletFundsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Eyebrow Row
            HStack(spacing: 6) {
                Image(systemName: "creditcard")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.white.opacity(0.9))
                
                Text("GIFT-WALLET FUNDS")
                    .font(.oswaldMedium(size: 12.5))
                    .tracking(1.0)
                    .foregroundColor(Color.white.opacity(0.9))
            }
            
            // Balance Amount
            Text(walletManager.formattedGiftFunds)
                .font(.oswaldBold(size: 46))
                .foregroundColor(.white)
                .padding(.vertical, -2)
            
            // Footnote
            Text("Use in full or alongside another payment method")
                .font(.barlowRegular(size: 13))
                .foregroundColor(Color.white.opacity(0.85))
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(red: 0x76 / 255.0, green: 0x1E / 255.0, blue: 0x2A / 255.0))
                .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 3)
        )
    }
    
    // MARK: - 3. Service Credit Card (White with Olive Green)
    
    private var serviceCreditCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Eyebrow Row
            HStack(spacing: 6) {
                Image(systemName: "gift")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(red: 0x4D / 255.0, green: 0x62 / 255.0, blue: 0x1C / 255.0))
                
                Text("SERVICE CREDIT")
                    .font(.oswaldMedium(size: 12.5))
                    .tracking(1.0)
                    .foregroundColor(Color(red: 0x4D / 255.0, green: 0x62 / 255.0, blue: 0x1C / 255.0))
            }
            
            // Balance Amount
            Text(walletManager.formattedServiceCredit)
                .font(.oswaldBold(size: 44))
                .foregroundColor(Color("app_black"))
                .padding(.vertical, -2)
            
            // Footnote
            Text("Applied before gift funds when selected at checkout")
                .font(.barlowRegular(size: 13))
                .foregroundColor(Color("text_gary"))
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.2)
                )
                .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
        )
    }
    
    // MARK: - 4. Top Up & Redeem Gift Card Section
    
    private var topUpAndRedeemCard: some View {
        VStack(alignment: .leading, spacing: 22) {
            // Top Up Section
            VStack(alignment: .leading, spacing: 14) {
                // Title & Subtitle
                VStack(alignment: .leading, spacing: 4) {
                    Text("TOP UP")
                        .font(.oswaldMedium(size: 18))
                        .tracking(0.6)
                        .foregroundColor(Color("app_black"))
                    
                    Text("Choose an amount. A simulated card payment adds funds instantly.")
                        .font(.barlowRegular(size: 13.5))
                        .foregroundColor(Color("text_gary"))
                        .lineSpacing(2)
                }
                
                // Quick Select Amount Buttons
                VStack(alignment: .leading, spacing: 10) {
                    // Row 1: + $10.00 & + $25.00
                    HStack(spacing: 12) {
                        amountPillButton(amount: 10.00, text: "+ $10.00")
                        amountPillButton(amount: 25.00, text: "+ $25.00")
                    }
                    
                    // Row 2: + $50.00
                    amountPillButton(amount: 50.00, text: "+ $50.00")
                }
                
                // Custom Amount Input + TOP UP Button
                HStack(spacing: 10) {
                    HStack(spacing: 4) {
                        Text("$")
                            .font(.barlowRegular(size: 15))
                            .foregroundColor(customAmountInput.isEmpty ? Color("text_gary") : Color("app_black"))
                        
                        TextField("Other amount", text: $customAmountInput)
                            .font(.barlowRegular(size: 15))
                            .foregroundColor(Color("app_black"))
                            .keyboardType(.decimalPad)
                    }
                    .padding(.horizontal, 14)
                    .frame(height: 46)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0), lineWidth: 1.2)
                            .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.white))
                    )
                    
                    Button(action: {
                        topUpCustomAmount()
                    }) {
                        Text("TOP UP")
                            .font(.oswaldMedium(size: 14))
                            .tracking(0.8)
                            .foregroundColor(.white)
                            .padding(.horizontal, 22)
                            .frame(height: 46)
                            .background(
                                Capsule()
                                    .fill(Color("app_black"))
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.top, 2)
                
                // Custom Amount Footnote
                Text("Custom amount: $5.00–$500.00.")
                    .font(.barlowRegular(size: 12))
                    .foregroundColor(Color("text_gary"))
            }
            
            // Redeem A Gift Card Section
            VStack(alignment: .leading, spacing: 14) {
                Text("REDEEM A GIFT CARD")
                    .font(.oswaldMedium(size: 18))
                    .tracking(0.6)
                    .foregroundColor(Color("app_black"))
                
                // Input Code + REDEEM Button
                HStack(spacing: 10) {
                    TextField("Gift card code", text: $giftCardCodeInput)
                        .font(.barlowRegular(size: 15))
                        .foregroundColor(Color("app_black"))
                        .autocapitalization(.allCharacters)
                        .disableAutocorrection(true)
                        .padding(.horizontal, 14)
                        .frame(height: 46)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0), lineWidth: 1.2)
                                .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.white))
                        )
                    
                    Button(action: {
                        redeemGiftCard()
                    }) {
                        Text("REDEEM")
                            .font(.oswaldMedium(size: 14))
                            .tracking(0.8)
                            .foregroundColor(.white)
                            .padding(.horizontal, 22)
                            .frame(height: 46)
                            .background(
                                Capsule()
                                    .fill(Color("app_black"))
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Sample Code Footnote
                HStack(spacing: 4) {
                    Text("One-time sample code:")
                        .font(.barlowRegular(size: 12))
                        .foregroundColor(Color("text_gary"))
                    
                    Button(action: {
                        giftCardCodeInput = "MODGIFT25"
                    }) {
                        Text("MODGIFT25")
                            .font(.system(size: 11.5, weight: .medium, design: .monospaced))
                            .foregroundColor(Color("app_black"))
                            .underline()
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Text("($25.00). No real gift-card validation.")
                        .font(.barlowRegular(size: 12))
                        .foregroundColor(Color("text_gary"))
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.2)
                )
                .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
        )
    }
    
    // MARK: - Amount Pill Button Component
    
    private func amountPillButton(amount: Double, text: String) -> some View {
        Button(action: {
            topUpAmount(amount)
        }) {
            HStack(spacing: 4) {
                Text(text)
                    .font(.barlowSemiBold(size: 15))
                    .foregroundColor(Color("app_black"))
            }
            .padding(.horizontal, 18)
            .frame(height: 42)
            .background(
                Capsule()
                    .stroke(Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0), lineWidth: 1.2)
                    .background(Capsule().fill(Color.white))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - 5. Recent Wallet Activity Card
    
    private var recentActivityCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header Row: Title & "All activity"
            HStack {
                Text("RECENT WALLET ACTIVITY")
                    .font(.oswaldMedium(size: 18))
                    .tracking(0.6)
                    .foregroundColor(Color("app_black"))
                
                Spacer()
                
                Button(action: {
                    if let onAllActivityTap = onAllActivityTap {
                        onAllActivityTap()
                    } else {
                        showAllActivitySheet = true
                    }
                }) {
                    Text("All activity")
                        .font(.barlowSemiBold(size: 13.5))
                        .foregroundColor(Color("Button_red"))
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // List of Activity Items
            VStack(spacing: 12) {
                ForEach(walletManager.activities.prefix(5)) { item in
                    VStack(spacing: 12) {
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(item.title)
                                    .font(.barlowBold(size: 14.5))
                                    .foregroundColor(Color("app_black"))
                                
                                Text(item.dateString)
                                    .font(.barlowRegular(size: 12.5))
                                    .foregroundColor(Color("text_gary"))
                            }
                            
                            Spacer()
                            
                            Text(item.formattedAmount)
                                .font(.barlowBold(size: 15))
                                .foregroundColor(Color(red: 0x4D / 255.0, green: 0x62 / 255.0, blue: 0x1C / 255.0))
                        }
                        
                        if item.id != walletManager.activities.prefix(5).last?.id {
                            Rectangle()
                                .fill(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0))
                                .frame(height: 1)
                        }
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.2)
                )
                .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
        )
    }
    
    // MARK: - Actions
    
    private func topUpAmount(_ amount: Double) {
        walletManager.addGiftFunds(amount: amount)
        alertTitle = "Funds Added"
        alertMessage = "Successfully added $\(String(format: "%.2f", amount)) to your MOD Wallet funds."
        showAlert = true
    }
    
    private func topUpCustomAmount() {
        let cleaned = customAmountInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let amount = Double(cleaned), amount >= 5.0, amount <= 500.0 else {
            alertTitle = "Invalid Amount"
            alertMessage = "Please enter an amount between $5.00 and $500.00."
            showAlert = true
            return
        }
        
        walletManager.addGiftFunds(amount: amount)
        customAmountInput = ""
        alertTitle = "Funds Added"
        alertMessage = "Successfully added $\(String(format: "%.2f", amount)) to your MOD Wallet funds."
        showAlert = true
    }
    
    private func redeemGiftCard() {
        let result = walletManager.redeemGiftCard(code: giftCardCodeInput)
        giftCardCodeInput = ""
        alertTitle = result.success ? "Gift Card Redeemed" : "Redeem Failed"
        alertMessage = result.message
        showAlert = true
    }
}

// MARK: - SwiftUI Preview

struct AddWalletBalanceView_Previews: PreviewProvider {
    static var previews: some View {
        AddWalletBalanceView(showHeader: true)
    }
}

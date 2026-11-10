//
//  CheckoutScreen.swift
//  MOD
//
//  Created by Rajpal singh on 09/11/26.
//

import SwiftUI

// MARK: - Payment Method Enums

enum PaymentMethodType: String, CaseIterable, Identifiable {
    case modWallet = "MOD Wallet"
    case digitalPay = "Digital Pay / UPI"
    case creditDebit = "Credit / Debit Cards"
    case giftCard = "Pay with Gift Card"
    case cashOnDelivery = "Cash On Delivery"

    var id: String { rawValue }
}

enum DigitalPayApp: String, CaseIterable, Identifiable {
    case gpay = "GPay"
    case applePay = "Apple Pay"
    case paypal = "PayPal"
    case moreApps = "More Apps"

    var id: String { rawValue }
}

enum ActiveCheckoutAlert: Identifiable {
    case success
    case changeAddress
    case validation(String)

    var id: String {
        switch self {
        case .success: return "success"
        case .changeAddress: return "changeAddress"
        case .validation(let msg): return "validation_\(msg)"
        }
    }
}

// MARK: - Checkout Screen

struct CheckoutScreen: View {
    @Environment(\.dismiss) private var dismiss

    // MARK: - Properties & State
    var cartItems: [CartItem] = [
        CartItem(
            name: "Pepperoni & Cream Cheese",
            subtitle: "Medium • Original Pan Crust",
            price: 17.90,
            quantity: 1,
            imageName: "pizza2",
            customizations: []
        ),
        CartItem(
            name: "Pepperoni Breadsticks",
            subtitle: "Marinara Dip incl.",
            price: 5.90,
            quantity: 1,
            imageName: "pizza1",
            customizations: []
        ),
        CartItem(
            name: "Coca-Cola Original Can",
            subtitle: "12 fl oz • 2 units • Chilled",
            price: 4.80,
            quantity: 1,
            imageName: "coke",
            customizations: []
        )
    ]

    var orderType: CartOrderType = .delivery
    var scheduledTime: String = "Today, Oct 24 • 5:30 PM"

    @State private var appliedPromoCode: String? = "WELCOME10"
    @State private var selectedPaymentMethod: PaymentMethodType = .modWallet
    @State private var selectedDigitalApp: DigitalPayApp = .gpay
    @State private var isContactless: Bool = false

    // Gift Card State
    @State private var giftCardNumber: String = ""
    @State private var giftCardPin: String = ""
    @State private var isGiftCardApplied: Bool = false
    @State private var giftCardBalance: Double = 25.00

    // More payment options expansion
    @State private var showMorePaymentOptions: Bool = false
    @State private var selectedMoreOption: String? = nil

    // User / Guest State & Recipient Details
    @State private var isGuest: Bool = (UserDefaults.standard.object(forKey: "isGuestUser") as? Bool) ?? true
    @State private var customerName: String = ""
    @State private var contactNumber: String = ""
    @State private var activeAlert: ActiveCheckoutAlert? = nil
    @State private var deliveryAddress: String = "450 Sutter St, Apt 8B, San Francisco, CA 94108"
    @State private var showConfirmOrderScreen: Bool = false

    // Colors
    private let modRed = Color(red: 0.78, green: 0.08, blue: 0.18)
    private let screenBg = Color(red: 0.98, green: 0.98, blue: 0.99)
    private let borderGray = Color(red: 0.90, green: 0.90, blue: 0.92)
    private let successGreen = Color(red: 0.12, green: 0.65, blue: 0.38)
    private let pillPink = Color(red: 1.0, green: 0.92, blue: 0.93)

    // MARK: - Calculations

    private var itemsSubtotal: Double {
        if !cartItems.isEmpty {
            return cartItems.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
        }
        return 28.60
    }

    private var deliveryFee: Double {
        orderType == .pickup ? 0.0 : 2.99
    }

    private var promoDiscount: Double {
        if appliedPromoCode == "WELCOME10" {
            return 5.00
        } else if appliedPromoCode == "MOD 50" {
            return min(itemsSubtotal * 0.5, 10.0)
        }
        return 0.0
    }

    private var onlinePaymentDiscount: Double {
        selectedPaymentMethod != .cashOnDelivery ? 1.00 : 0.0
    }

    private var totalDiscount: Double {
        promoDiscount + onlinePaymentDiscount
    }

    private var totalToPay: Double {
        var total = itemsSubtotal + deliveryFee - promoDiscount - onlinePaymentDiscount
        if selectedPaymentMethod == .giftCard && isGiftCardApplied {
            total = max(total - giftCardBalance, 0.0)
        }
        return max(total, 0.0)
    }

    // Dynamic Pay Button Title
    private var payButtonTitle: String {
        let formatted = String(format: "%.2f", totalToPay)
        switch selectedPaymentMethod {
        case .modWallet:
            return "PAY $\(formatted) WITH MOD WALLET"
        case .digitalPay:
            return "PAY $\(formatted) WITH \(selectedDigitalApp.rawValue.uppercased())"
        case .creditDebit:
            return "PAY $\(formatted) WITH VISA"
        case .giftCard:
            return isGiftCardApplied ? "PAY $\(formatted) WITH GIFT CARD" : "APPLY & PAY $\(formatted)"
        case .cashOnDelivery:
            return "PLACE ORDER • $\(formatted)"
        }
    }

    // Display Name for Payment Method on Confirmation Screen
    private var paymentMethodDisplayName: String {
        switch selectedPaymentMethod {
        case .modWallet:
            return "MOD Wallet"
        case .digitalPay:
            return selectedDigitalApp.rawValue
        case .creditDebit:
            return "Visa"
        case .giftCard:
            return "Gift Card"
        case .cashOnDelivery:
            return "Cash On Delivery"
        }
    }

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // 1. Navigation Header
                navigationHeader

                // 2. Scrollable Checkout Content
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        // Section 1: Order Items
                        orderItemsSection

                        // Section 2: Delivery / Pickup Address
                        fulfillmentAddressSection

                        // Section 3: Order Summary
                        orderSummarySection

                        // Section 4: Payment Method
                        paymentMethodSection

                        // Section 5: Contactless Delivery Toggle
                        contactlessRow

                        // Bottom Space so content isn't covered by bottom sticky bar
                        Color.clear.frame(height: 100)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .background(screenBg)
            }

            // 3. Sticky Bottom Action Bar
            stickyBottomBar
        }
        .edgesIgnoringSafeArea(.bottom)
        .fullScreenCover(isPresented: $showConfirmOrderScreen) {
            ConfirmOrderScreen(
                orderNumber: "PH-89421",
                customerName: customerName.isEmpty ? "Alex" : customerName,
                contactNumber: contactNumber,
                deliveryAddress: deliveryAddress,
                orderType: orderType,
                itemCount: cartItems.count,
                paymentMethod: paymentMethodDisplayName,
                totalAmount: totalToPay,
                estimatedArrival: orderType == .pickup ? "5:45 PM" : "10:15 PM",
                pointsEarned: 140
            )
        }
        .alert(item: $activeAlert) { alert in
            switch alert {
            case .success:
                return Alert(
                    title: Text("🎉 Order Placed Successfully!"),
                    message: Text("Thank you\(customerName.isEmpty ? "" : ", " + customerName)! Your order has been placed and is being prepared. You can track it in the Orders tab."),
                    dismissButton: .default(Text("View Order Status")) {
                        dismiss()
                    }
                )
            case .changeAddress:
                return Alert(
                    title: Text("Change Address"),
                    message: Text("To update your address or store location, select Location on the Home screen."),
                    dismissButton: .default(Text("OK"))
                )
            case .validation(let message):
                return Alert(
                    title: Text("Missing Information"),
                    message: Text(message),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .onAppear {
            let guest = (UserDefaults.standard.object(forKey: "isGuestUser") as? Bool) ?? true
            self.isGuest = guest
            if !guest {
                if customerName.isEmpty {
                    customerName = "Alex Morgan"
                }
                if contactNumber.isEmpty {
                    contactNumber = "(555) 234-5678"
                }
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - 1. Navigation Header

    private var navigationHeader: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                    .frame(width: 38, height: 38)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 2)
            }

            Spacer()

            // Header Title: Checkout (Changed from Review Order as requested)
            Text("Checkout")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)

            Spacer()

            Color.clear
                .frame(width: 38, height: 38)
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 10)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 2)
    }

    // MARK: - Section 1: Order Items

    private var orderItemsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header Row
            HStack {
                HStack(spacing: 8) {
                    Text("Order Items")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.black)

                    Text("\(cartItems.count) items")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(modRed)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(pillPink)
                        .cornerRadius(10)
                }

                Spacer()

                Button(action: {
                    dismiss()
                }) {
                    Text("+ Add more")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(modRed)
                }
            }

            // Items List
            VStack(spacing: 10) {
                ForEach(cartItems) { item in
                    orderItemRow(item: item)
                }
            }
        }
    }

    private func orderItemRow(item: CartItem) -> some View {
        HStack(alignment: .top, spacing: 12) {
            // Image
            ZStack {
                if let _ = UIImage(named: item.imageName) {
                    Image(item.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 58, height: 58)
                        .cornerRadius(12)
                        .clipped()
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.12))
                        .frame(width: 58, height: 58)
                    Text("🍕")
                        .font(.system(size: 24))
                }
            }

            // Info
            VStack(alignment: .leading, spacing: 3) {
                Text(item.name)
                    .font(.system(size: 14.5, weight: .bold))
                    .foregroundColor(.black)
                    .lineLimit(1)

                // Subtitle / Badge
                HStack(spacing: 4) {
                    if item.name.contains("Breadsticks") {
                        Text("8 pcs")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color(red: 0.65, green: 0.45, blue: 0.1))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(red: 0.98, green: 0.94, blue: 0.82))
                            .cornerRadius(4)
                        Text("• " + item.subtitle)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    } else {
                        Text(item.subtitle)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }

                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("$\(String(format: "%.2f", item.price))")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(modRed)

                    if item.name.contains("Cream") {
                        Text("$19.90")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                            .strikethrough()
                    } else if item.name.contains("Coca-Cola") {
                        Text("($2.40 ea)")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                    }
                }
            }

            Spacer()

            // Pencil Edit Icon
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "pencil")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(modRed)
                    .padding(8)
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(borderGray, lineWidth: 1)
        )
    }

    // MARK: - Section 2: Delivery / Pickup Address

    private var fulfillmentAddressSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header Row
            HStack {
                Text(orderType == .pickup ? "Pickup Location" : "Delivery Address")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.black)

                Spacer()

                HStack(spacing: 4) {
                    Circle()
                        .fill(successGreen)
                        .frame(width: 6, height: 6)
                    Text("Selected")
                        .font(.system(size: 11.5, weight: .bold))
                        .foregroundColor(successGreen)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color(red: 0.90, green: 0.98, blue: 0.94))
                .cornerRadius(12)
            }

            // Address Card
            VStack(alignment: .leading, spacing: 12) {
                // Top Row: Icon + Label + Change
                HStack(alignment: .top, spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(pillPink)
                            .frame(width: 36, height: 36)

                        Image(systemName: orderType == .pickup ? "storefront.fill" : "house.fill")
                            .font(.system(size: 16))
                            .foregroundColor(modRed)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Text(orderType == .pickup ? "Downtown Hut #1204" : "Home")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.black)

                            Text(orderType == .pickup ? "STORE" : "DEFAULT")
                                .font(.system(size: 9.5, weight: .heavy))
                                .foregroundColor(modRed)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(pillPink)
                                .cornerRadius(4)

                            if isGuest {
                                Text("GUEST")
                                    .font(.system(size: 9.5, weight: .heavy))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.gray.opacity(0.12))
                                    .cornerRadius(4)
                            }
                        }

                        Text(orderType == .pickup ? "452 Market St, San Francisco, CA (0.8 mi away)" : deliveryAddress)
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }

                    Spacer()

                    Button(action: {
                        activeAlert = .changeAddress
                    }) {
                        HStack(spacing: 3) {
                            Image(systemName: "pencil")
                                .font(.system(size: 11, weight: .bold))
                            Text("Change")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundColor(modRed)
                    }
                }

                Divider()

                // Two Rows Below Address: Name & Contact Number (Optional for Guest User)
                VStack(spacing: 10) {
                    // Row 1: Full Name (Required)
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(pillPink)
                                .frame(width: 32, height: 32)
                            Image(systemName: "person.fill")
                                .font(.system(size: 13))
                                .foregroundColor(modRed)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 4) {
                                Text("Name")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.gray)
                                Text("*")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(modRed)
                            }

                            TextField("Enter your full name", text: $customerName)
                                .font(.system(size: 13.5, weight: .medium))
                                .foregroundColor(.black)
                                .autocapitalization(.words)
                                .disableAutocorrection(true)
                        }

                        if !customerName.isEmpty {
                            Button(action: { customerName = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray.opacity(0.5))
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Color(red: 0.98, green: 0.98, blue: 0.99))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(borderGray.opacity(0.8), lineWidth: 1)
                    )

                    // Row 2: Contact Number (Optional for Guest User)
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(pillPink)
                                .frame(width: 32, height: 32)
                            Image(systemName: "phone.fill")
                                .font(.system(size: 13))
                                .foregroundColor(modRed)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 5) {
                                Text("Contact Number")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.gray)

                                if isGuest {
                                    Text("(Optional)")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(Color.gray)
                                        .padding(.horizontal, 5)
                                        .padding(.vertical, 1)
                                        .background(Color.black.opacity(0.05))
                                        .cornerRadius(4)
                                } else {
                                    Text("*")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(modRed)
                                }
                            }

                            TextField(isGuest ? "Enter contact number (optional)" : "Enter contact number", text: $contactNumber)
                                .font(.system(size: 13.5, weight: .medium))
                                .foregroundColor(.black)
                                .keyboardType(.phonePad)
                        }

                        if !contactNumber.isEmpty {
                            Button(action: { contactNumber = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray.opacity(0.5))
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Color(red: 0.98, green: 0.98, blue: 0.99))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(borderGray.opacity(0.8), lineWidth: 1)
                    )
                }

                Divider()

                // Bottom Timing & Fee Strip
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 12))
                            .foregroundColor(successGreen)

                        Text(orderType == .pickup ? "Estimated Ready: 10–15 min • Hot & Fresh" : "Estimated 25–35 min • Hot & Fresh")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(successGreen)
                    }

                    Spacer()

                    HStack(spacing: 2) {
                        Text("Fee:")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        Text(orderType == .pickup ? "FREE" : "$2.99")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(orderType == .pickup ? successGreen : .black)
                    }
                }
            }
            .padding(14)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(modRed.opacity(0.35), lineWidth: 1.2)
            )
        }
    }

    // MARK: - Section 3: Order Summary

    private var orderSummarySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Order Summary")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.black)

            VStack(spacing: 12) {
                // Subtotal
                HStack {
                    Text("Items Subtotal (\(cartItems.count))")
                        .font(.system(size: 13.5))
                        .foregroundColor(.gray)
                    Spacer()
                    Text("$\(String(format: "%.2f", itemsSubtotal))")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                }

                // Delivery Fee
                HStack {
                    HStack(spacing: 4) {
                        Text(orderType == .pickup ? "Pickup Fee" : "Delivery Fee")
                            .font(.system(size: 13.5))
                            .foregroundColor(.gray)
                        Image(systemName: "info.circle")
                            .font(.system(size: 11))
                            .foregroundColor(.gray.opacity(0.6))
                    }
                    Spacer()
                    if orderType == .pickup {
                        Text("FREE")
                            .font(.system(size: 13.5, weight: .bold))
                            .foregroundColor(successGreen)
                    } else {
                        Text("$\(String(format: "%.2f", deliveryFee))")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.black)
                    }
                }

                // Promo Code Row
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "ticket.fill")
                            .font(.system(size: 13))
                            .foregroundColor(successGreen)
                        Text("Promo Code")
                            .font(.system(size: 13.5))
                            .foregroundColor(.black)
                    }

                    Spacer()

                    if let promo = appliedPromoCode {
                        HStack(spacing: 4) {
                            Text("\(promo) -$\(String(format: "%.2f", promoDiscount))")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(successGreen)

                            Button(action: {
                                withAnimation {
                                    appliedPromoCode = nil
                                }
                            }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(successGreen)
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color(red: 0.90, green: 0.98, blue: 0.94))
                        .cornerRadius(12)
                    } else {
                        Button(action: {
                            withAnimation {
                                appliedPromoCode = "WELCOME10"
                            }
                        }) {
                            Text("Apply Promo")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(modRed)
                        }
                    }
                }

                Divider()

                // Total to Pay
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Total to Pay")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)

                        HStack(spacing: 4) {
                            Image(systemName: "gift.fill")
                                .font(.system(size: 11))
                                .foregroundColor(successGreen)
                            Text("You saved $7.00 today")
                                .font(.system(size: 11.5, weight: .semibold))
                                .foregroundColor(successGreen)
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("$\(String(format: "%.2f", totalToPay))")
                            .font(.system(size: 19, weight: .heavy))
                            .foregroundColor(.black)

                        Text("All taxes included")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(borderGray, lineWidth: 1)
            )
        }
    }

    // MARK: - Section 4: Payment Method

    private var paymentMethodSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header Row
            HStack {
                Text("Payment Method")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.black)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "tag.fill")
                        .font(.system(size: 11))
                        .foregroundColor(successGreen)
                    Text("Save $1.00 online")
                        .font(.system(size: 11.5, weight: .bold))
                        .foregroundColor(successGreen)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color(red: 0.90, green: 0.98, blue: 0.94))
                .cornerRadius(12)
            }

            // Payment Options List
            VStack(spacing: 12) {
                // 1. MOD Wallet (Selected Card Style)
                modWalletCard

                // 2. Digital Pay / UPI
                digitalPayCard

                // 3. Credit / Debit Cards
                creditDebitCard

                // 4. Pay with Gift Card (Added below Credit Card as requested!)
                giftCardOptionCard

                // 5. Cash On Delivery
                cashOnDeliveryCard

                // 6. More payment options
                morePaymentOptionsRow
            }
        }
    }

    // MARK: - Payment Cards

    // 1. MOD Wallet Card
    private var modWalletCard: some View {
        let isSelected = selectedPaymentMethod == .modWallet
        return VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(modRed)
                        .frame(width: 40, height: 40)

                    Image(systemName: "wallet.pass.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text("MOD Wallet")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.black)

                        Text("RECOMMENDED • BEST BENEFIT")
                            .font(.system(size: 9, weight: .heavy))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2.5)
                            .background(modRed)
                            .cornerRadius(4)
                    }

                    HStack(spacing: 4) {
                        Image(systemName: "gift.fill")
                            .font(.system(size: 10))
                            .foregroundColor(modRed)
                        Text("Flat 15% Cashback (Save $4.50) + 2x Points.")
                            .font(.system(size: 11.5, weight: .medium))
                            .foregroundColor(modRed)
                    }
                }

                Spacer()

                // Radio
                radioIndicator(isSelected: isSelected)
            }

            // Balance Container Inside Wallet
            HStack {
                HStack(spacing: 5) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 0.7, green: 0.45, blue: 0.1))

                    Text("Balance: ")
                        .font(.system(size: 12))
                        .foregroundColor(.black)
                    + Text("$45.00 available")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.black)
                }

                Spacer()

                Text("Instant 1-Click Pay")
                    .font(.system(size: 10.5, weight: .bold))
                    .foregroundColor(successGreen)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3.5)
                    .background(Color(red: 0.90, green: 0.98, blue: 0.94))
                    .cornerRadius(8)
            }
            .padding(10)
            .background(Color(red: 0.99, green: 0.97, blue: 0.94))
            .cornerRadius(10)
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? modRed : borderGray, lineWidth: isSelected ? 1.5 : 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedPaymentMethod = .modWallet
            }
        }
    }

    // 2. Digital Pay / UPI Card
    private var digitalPayCard: some View {
        let isSelected = selectedPaymentMethod == .digitalPay
        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(pillPink)
                        .frame(width: 40, height: 40)

                    Image(systemName: "bolt.fill")
                        .font(.system(size: 18))
                        .foregroundColor(modRed)
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text("Digital Pay / UPI")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.black)

                        Text("FAST")
                            .font(.system(size: 9, weight: .heavy))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(modRed)
                            .cornerRadius(4)
                    }

                    Text("Save $1.00 • Instant refund on online payment")
                        .font(.system(size: 11.5))
                        .foregroundColor(.gray)
                }

                Spacer()

                radioIndicator(isSelected: isSelected)
            }

            // 4 Digital Pay Button Options (GPay, Apple Pay, PayPal, More Apps)
            HStack(spacing: 8) {
                ForEach(DigitalPayApp.allCases) { app in
                    let isAppSelected = (selectedPaymentMethod == .digitalPay && selectedDigitalApp == app)
                    Button(action: {
                        withAnimation {
                            selectedPaymentMethod = .digitalPay
                            selectedDigitalApp = app
                        }
                    }) {
                        VStack(spacing: 4) {
                            switch app {
                            case .gpay:
                                Text("GP")
                                    .font(.system(size: 13, weight: .heavy))
                                    .foregroundColor(.blue)
                            case .applePay:
                                Image(systemName: "applelogo")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.black)
                            case .paypal:
                                Text("P")
                                    .font(.system(size: 14, weight: .heavy))
                                    .foregroundColor(.blue)
                            case .moreApps:
                                Image(systemName: "square.grid.2x2")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                            }

                            Text(app.rawValue)
                                .font(.system(size: 10, weight: isAppSelected ? .bold : .medium))
                                .foregroundColor(isAppSelected ? modRed : .black)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isAppSelected ? modRed : borderGray, lineWidth: isAppSelected ? 1.5 : 1)
                        )
                    }
                }
            }
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? modRed : borderGray, lineWidth: isSelected ? 1.5 : 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedPaymentMethod = .digitalPay
            }
        }
    }

    // 3. Credit / Debit Cards
    private var creditDebitCard: some View {
        let isSelected = selectedPaymentMethod == .creditDebit
        return HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 40, height: 40)

                Image(systemName: "creditcard.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color.black.opacity(0.75))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Credit / Debit Cards")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.black)

                Text("Visa, Mastercard, Amex, Discover")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }

            Spacer()

            radioIndicator(isSelected: isSelected)
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? modRed : borderGray, lineWidth: isSelected ? 1.5 : 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedPaymentMethod = .creditDebit
            }
        }
    }

    // 4. Pay with Gift Card (Placed below Credit/Debit cards as requested!)
    private var giftCardOptionCard: some View {
        let isSelected = selectedPaymentMethod == .giftCard
        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(pillPink)
                        .frame(width: 40, height: 40)

                    Image(systemName: "giftcard.fill")
                        .font(.system(size: 18))
                        .foregroundColor(modRed)
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text("Pay with Gift Card")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.black)

                        if isGiftCardApplied {
                            Text("APPLIED")
                                .font(.system(size: 9, weight: .heavy))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(successGreen)
                                .cornerRadius(4)
                        }
                    }

                    Text("Redeem your MOD Gift Card balance")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }

                Spacer()

                radioIndicator(isSelected: isSelected)
            }

            // Expanded input area when selected
            if isSelected {
                VStack(spacing: 10) {
                    Divider()
                        .padding(.vertical, 2)

                    if isGiftCardApplied {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(successGreen)
                            Text("Gift Card Applied • $\(String(format: "%.2f", giftCardBalance)) redeemed")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(successGreen)
                            Spacer()
                            Button("Remove") {
                                withAnimation {
                                    isGiftCardApplied = false
                                }
                            }
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(modRed)
                        }
                        .padding(10)
                        .background(Color(red: 0.90, green: 0.98, blue: 0.94))
                        .cornerRadius(8)
                    } else {
                        HStack(spacing: 8) {
                            TextField("16-digit card number", text: $giftCardNumber)
                                .font(.system(size: 13))
                                .keyboardType(.numberPad)
                                .padding(10)
                                .background(Color(red: 0.97, green: 0.97, blue: 0.98))
                                .cornerRadius(8)

                            SecureField("PIN", text: $giftCardPin)
                                .font(.system(size: 13))
                                .keyboardType(.numberPad)
                                .frame(width: 60)
                                .padding(10)
                                .background(Color(red: 0.97, green: 0.97, blue: 0.98))
                                .cornerRadius(8)

                            Button(action: {
                                withAnimation {
                                    isGiftCardApplied = true
                                }
                            }) {
                                Text("Apply")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(modRed)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? modRed : borderGray, lineWidth: isSelected ? 1.5 : 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedPaymentMethod = .giftCard
            }
        }
    }

    // 5. Cash On Delivery Card
    private var cashOnDeliveryCard: some View {
        let isSelected = selectedPaymentMethod == .cashOnDelivery
        return HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 40, height: 40)

                Image(systemName: "banknote.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color.black.opacity(0.75))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Cash On Delivery")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.black)

                Text("Pay cash or card upon delivery")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }

            Spacer()

            radioIndicator(isSelected: isSelected)
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? modRed : borderGray, lineWidth: isSelected ? 1.5 : 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedPaymentMethod = .cashOnDelivery
            }
        }
    }

    // 6. More Payment Options Dropdown
    private var morePaymentOptionsRow: some View {
        VStack(spacing: 8) {
            Button(action: {
                withAnimation {
                    showMorePaymentOptions.toggle()
                }
            }) {
                HStack {
                    Text("More payment options (Netbanking, Pay later)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))

                    Spacer()

                    Image(systemName: showMorePaymentOptions ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.gray)
                }
                .padding(14)
                .background(Color.white)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(borderGray, lineWidth: 1)
                )
            }

            if showMorePaymentOptions {
                VStack(spacing: 8) {
                    ForEach(["Netbanking (All Major Banks)", "Klarna / Afterpay (Pay in 4)", "Venmo"], id: \.self) { option in
                        Button(action: {
                            selectedMoreOption = option
                        }) {
                            HStack {
                                Text(option)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.black)
                                Spacer()
                                if selectedMoreOption == option {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(modRed)
                                }
                            }
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(borderGray, lineWidth: 1)
                            )
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    // MARK: - Section 5: Contactless Delivery Toggle

    private var contactlessRow: some View {
        HStack(spacing: 12) {
            Image(systemName: "shield.lefthalf.filled")
                .font(.system(size: 16))
                .foregroundColor(.gray)

            Text("Leave order at my door (Contactless)")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.black)

            Spacer()

            Toggle("", isOn: $isContactless)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: modRed))
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(borderGray, lineWidth: 1)
        )
    }

    // MARK: - Radio Indicator Helper

    private func radioIndicator(isSelected: Bool) -> some View {
        ZStack {
            if isSelected {
                Circle()
                    .fill(modRed)
                    .frame(width: 22, height: 22)

                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
            } else {
                Circle()
                    .stroke(Color.gray.opacity(0.4), lineWidth: 1.5)
                    .frame(width: 22, height: 22)
            }
        }
    }

    // MARK: - Sticky Bottom Bar

    private var stickyBottomBar: some View {
        VStack(spacing: 8) {
            // Big Red Pay Button
            Button(action: {
                validateAndProceedOrder()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 14))

                    Text(payButtonTitle)
                        .font(.system(size: 15, weight: .bold))

                    Image(systemName: "arrow.right")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(modRed)
                .cornerRadius(14)
                .shadow(color: modRed.opacity(0.35), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal, 16)

            // Trust Footer
            HStack(spacing: 5) {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 12))
                    .foregroundColor(successGreen)

                Text("256-bit encrypted • 100% Satisfaction Guarantee")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 22)
        }
        .padding(.top, 10)
        .background(
            Color.white
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: -4)
        )
    }

    // MARK: - Order Validation & Placement

    private func validateAndProceedOrder() {
        let trimmedName = customerName.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName.isEmpty {
            activeAlert = .validation("Please enter your full name to proceed with the order.")
            return
        }

        // Contact number is required for logged-in users, but optional for guest users
        if !isGuest {
            let trimmedPhone = contactNumber.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedPhone.isEmpty {
                activeAlert = .validation("Please enter your contact phone number to proceed with the order.")
                return
            }
        }

        showConfirmOrderScreen = true
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        CheckoutScreen()
    }
}

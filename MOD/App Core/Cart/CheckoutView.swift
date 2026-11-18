//
//  CheckoutView.swift
//  MOD
//
//  Created by Rajpal singh on 17/11/26.
//

import SwiftUI

// MARK: - Pickup Option Enum

enum CheckoutPickupOption: String, CaseIterable, Identifiable {
    case inStore = "In-store pickup"
    case curbside = "Curbside pickup"
    case driveThru = "Drive-thru"
    
    var id: String { rawValue }
    
    var subtitle: String {
        switch self {
        case .inStore:
            return "Head to the pickup bay inside"
        case .curbside:
            return "We'll bring it to your car"
        case .driveThru:
            return "Pick up at the window"
        }
    }
    
    var systemIcon: String {
        switch self {
        case .inStore:
            return "building.2.crop.circle"
        case .curbside:
            return "car.fill"
        case .driveThru:
            return "clock.arrow.circlepath"
        }
    }
}

// MARK: - Payment Method Enum

enum CheckoutPaymentMethod: String, CaseIterable, Identifiable {
    case card = "Card"
    case applePay = "Apple Pay"
    case googlePay = "Google Pay"
    
    var id: String { rawValue }
    
    var subtitle: String {
        switch self {
        case .card:
            return "Visa •••• 4242 (Sample)"
        case .applePay:
            return "Simulated sheet"
        case .googlePay:
            return "Simulated sheet"
        }
    }
    
    var systemIcon: String {
        switch self {
        case .card:
            return "creditcard.fill"
        case .applePay:
            return "applelogo"
        case .googlePay:
            return "g.circle.fill"
        }
    }
}

// MARK: - Tip Option Enum

enum CheckoutTipSelection: Hashable {
    case noTip
    case percent(Int)
    case custom(Double)
    
    var label: String {
        switch self {
        case .noTip: return "No tip"
        case .percent(let p): return "\(p)%"
        case .custom(let val): return String(format: "$%.2f", val)
        }
    }
}

// MARK: - CheckoutView

struct CheckoutView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var cartManager = CartManager.shared
    
    // Callbacks
    var onBack: (() -> Void)? = nil
    var onOrderPlaced: (() -> Void)? = nil
    
    // Group Checkout Options
    var customNavTitle: String? = nil
    var customHeaderTitle: String? = nil
    var groupOrder: GroupOrderItem? = nil
    
    // MARK: - Form States
    
    // Contact
    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    
    // Pickup
    @State private var storeName: String = "Capitol Hill · 1302 19th Ave"
    @State private var storeCityZip: String = "Seattle, WA 98122"
    @State private var selectedPickup: CheckoutPickupOption = .inStore
    @State private var showStoreSetupSheet: Bool = false
    
    // Allergies & Kitchen Note
    let allergenOptions: [String] = [
        "None", "Milk", "Eggs", "Wheat",
        "Soy", "Peanuts", "Treenuts", "Sesame",
        "Fish", "Shellfish"
    ]
    @State private var selectedAllergens: Set<String> = []
    @State private var kitchenNote: String = ""
    
    // Tip
    @State private var selectedTip: CheckoutTipSelection = .percent(18)
    @State private var customTipAmount: Double = 0.0
    @State private var showCustomTipInput: Bool = false
    @State private var customTipString: String = ""
    
    // MOD Rewards Opt-Out Checkboxes
    @State private var optOutFreePizza: Bool = false
    @State private var optOutFullPrice: Bool = false
    @State private var optOutSecretDeals: Bool = false
    
    // Payment
    @State private var selectedPayment: CheckoutPaymentMethod = .card
    
    // Promo Code
    @State private var showPromoSection: Bool = false
    @State private var promoCodeInput: String = ""
    @State private var appliedDiscount: Double = 0.0
    @State private var promoSuccessMessage: String? = nil
    
    // Order Placement & Feedback
    @State private var isPlacingOrder: Bool = false
    @State private var showSuccessModal: Bool = false
    @State private var showTrackingView: Bool = false
    @State private var placedOrderId: String = "MOD-628250"
    @State private var capturedCartItems: [CartItem] = []
    
    // MARK: - Computed Pricing
    
    private var subtotal: Double {
        if let group = groupOrder, group.totalFoodSubtotal > 0 {
            return group.totalFoodSubtotal
        }
        return cartManager.totalPrice > 0 ? cartManager.totalPrice : 11.99
    }
    
    private var estimatedTax: Double {
        subtotal * 0.0875
    }
    
    private var calculatedTip: Double {
        switch selectedTip {
        case .noTip:
            return 0.0
        case .percent(let p):
            return subtotal * (Double(p) / 100.0)
        case .custom(let val):
            return max(0.0, val)
        }
    }
    
    private var totalAmount: Double {
        max(0.0, subtotal - appliedDiscount + estimatedTax + calculatedTip)
    }
    
    private var rewardsEarnedPoints: Int {
        max(10, Int(subtotal * 10))
    }
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                Color("app_background")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 1. Navigation Bar
                    customNavigationBar
                        .frame(width: geometry.size.width)
                    
                    // 2. Scrollable Checkout Content
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 20) {
                            // Big Screen Title: CHECKOUT / GROUP CHECKOUT
                            Text(customHeaderTitle ?? "CHECKOUT")
                                .font(.oswaldBold(size: customHeaderTitle != nil ? 22 : 28))
                                .tracking(0.6)
                                .foregroundColor(Color("app_black"))
                                .padding(.horizontal, 16)
                                .padding(.top, 4)
                            
                            // 1. CONTACT Card
                            contactCard
                                .padding(.horizontal, 16)
                            
                            // 2. PICKUP Card
                            pickupCard
                                .padding(.horizontal, 16)
                            
                            // 3. ALLERGIES & KITCHEN NOTE Card
                            allergiesCard
                                .padding(.horizontal, 16)
                            
                            // 4. TIP THE TEAM Card
                            tipCard
                                .padding(.horizontal, 16)
                            
                            // 5. MOD REWARDS Card
                            rewardsCard
                                .padding(.horizontal, 16)
                            
                            // 6. PAYMENT Card
                            paymentCard
                                .padding(.horizontal, 16)
                            
                            // 7. ORDER SUMMARY Card
                            orderSummaryCard
                                .padding(.horizontal, 16)
                            
                            // Bottom Spacer
                            Spacer()
                                .frame(height: 60)
                        }
                        .frame(width: geometry.size.width, alignment: .leading)
                    }
                    .frame(width: geometry.size.width)
                    .clipped()
                }
                
                // Success Confirmation Overlay
                if showSuccessModal {
                    successOverlay
                        .transition(.opacity)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .sheet(isPresented: $showStoreSetupSheet) {
            OrderSetupView(
                currentStoreName: "Capitol Hill",
                currentDeliveryAddress: "Seattle, WA 98122",
                onDone: { _, newStore, _, newAddress, _ in
                    storeName = "\(newStore) · 1302 19th Ave"
                    storeCityZip = newAddress
                    showStoreSetupSheet = false
                }
            )
        }
        .fullScreenCover(isPresented: $showTrackingView) {
            OrderTrackingView(
                orderId: placedOrderId,
                storeName: "Capitol Hill",
                storeAddress: "1302 Pine St, Seattle, WA 98101",
                fulfillmentText: selectedPickup.rawValue,
                scheduledTimeText: "Tue, Nov 17, 9:15\nPM PST",
                preparationTimeText: "Tue, Nov 17, 9:00 PM PST",
                customerName: fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Logan" : fullName,
                customerPhone: phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "7580880463" : phone,
                customerEmail: email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "risabhputta213@gmail.com" : email,
                allergensText: selectedAllergens.isEmpty ? "Peanuts" : selectedAllergens.joined(separator: ", "),
                items: capturedCartItems.isEmpty ? [
                    TrackOrderItem(title: "Build Your Pizza", quantity: 1, price: 11.99)
                ] : capturedCartItems.map {
                    TrackOrderItem(title: $0.title, quantity: $0.quantity, price: $0.price)
                },
                subtotal: subtotal,
                tax: estimatedTax,
                tip: calculatedTip > 0 ? calculatedTip : 2.40,
                total: totalAmount,
                earnedPoints: rewardsEarnedPoints,
                onBack: {
                    showTrackingView = false
                    if let onOrderPlaced = onOrderPlaced {
                        onOrderPlaced()
                    } else {
                        dismiss()
                    }
                }
            )
        }
    }
    
    // MARK: - Navigation Bar
    
    private var customNavigationBar: some View {
        HStack(alignment: .center) {
            // Left: Red < Back Button
            Button(action: {
                if let onBack = onBack {
                    onBack()
                } else {
                    dismiss()
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
            
            // Center: Screen Title
            Text(customNavTitle ?? "Checkout")
                .font(.oswaldMedium(size: customNavTitle != nil ? 16 : 18))
                .foregroundColor(Color("app_black"))
                .lineLimit(1)
            
            Spacer()
            
            // Right: Profile & Cart Icons
            HStack(spacing: 16) {
                Image(systemName: "person")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(Color("app_black"))
                
                TopCartButton(action: {})
            }
            .frame(width: 70, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
        .padding(.bottom, 10)
        .background(Color("app_background"))
    }
    
    // MARK: - 1. CONTACT Card
    
    private var contactCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header Row
            HStack(spacing: 8) {
                Image(systemName: "person.crop.circle")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color("Button_red"))
                
                Text("CONTACT")
                    .font(.oswaldMedium(size: 16))
                    .tracking(0.8)
                    .foregroundColor(Color("app_black"))
            }
            
            // Description
            Text("Ordering as a guest. We'll remember these details on this device for next time.")
                .font(.barlowRegular(size: 13))
                .foregroundColor(Color("text_gary"))
                .lineSpacing(2)
            
            // Input Fields
            VStack(alignment: .leading, spacing: 12) {
                // Full name
                VStack(alignment: .leading, spacing: 5) {
                    Text("Full name")
                        .font(.barlowSemiBold(size: 13.5))
                        .foregroundColor(Color("app_black"))
                    
                    TextField("", text: $fullName)
                        .font(.barlowRegular(size: 14))
                        .foregroundColor(Color("app_black"))
                        .padding(.horizontal, 12)
                        .frame(height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.2)
                                .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.white))
                        )
                }
                
                // Email
                VStack(alignment: .leading, spacing: 5) {
                    Text("Email")
                        .font(.barlowSemiBold(size: 13.5))
                        .foregroundColor(Color("app_black"))
                    
                    TextField("", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .font(.barlowRegular(size: 14))
                        .foregroundColor(Color("app_black"))
                        .padding(.horizontal, 12)
                        .frame(height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.2)
                                .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.white))
                        )
                }
                
                // Phone (10-11 digits)
                VStack(alignment: .leading, spacing: 5) {
                    Text("Phone (10-11 digits)")
                        .font(.barlowSemiBold(size: 13.5))
                        .foregroundColor(Color("app_black"))
                    
                    TextField("", text: $phone)
                        .keyboardType(.phonePad)
                        .font(.barlowRegular(size: 14))
                        .foregroundColor(Color("app_black"))
                        .padding(.horizontal, 12)
                        .frame(height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.2)
                                .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.white))
                        )
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.2)
                )
                .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
        )
    }
    
    // MARK: - 2. PICKUP Card
    
    private var pickupCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header Row
            HStack(spacing: 8) {
                Image(systemName: "bag")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color("Button_red"))
                
                Text("PICKUP")
                    .font(.oswaldMedium(size: 16))
                    .tracking(0.8)
                    .foregroundColor(Color("app_black"))
            }
            
            // Store Location Details Box
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(storeName)
                        .font(.barlowBold(size: 14))
                        .foregroundColor(Color("app_black"))
                    
                    Text(storeCityZip)
                        .font(.barlowRegular(size: 12.5))
                        .foregroundColor(Color("text_gary"))
                    
                    Text("ASAP unavailable · When chosen in previous step")
                        .font(.barlowRegular(size: 11.5))
                        .foregroundColor(Color("text_gary"))
                        .padding(.top, 1)
                }
                
                Spacer()
                
                Button(action: {
                    showStoreSetupSheet = true
                }) {
                    Text("CHANGE")
                        .font(.barlowBold(size: 11))
                        .tracking(0.6)
                        .foregroundColor(Color("app_black"))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .stroke(Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0), lineWidth: 1.0)
                                .background(Capsule().fill(Color.white))
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(red: 0xFA / 255.0, green: 0xF7 / 255.0, blue: 0xF2 / 255.0))
            )
            
            // Pickup option label
            Text("Pickup option")
                .font(.barlowSemiBold(size: 13.5))
                .foregroundColor(Color("app_black"))
            
            // Pickup Option List
            VStack(spacing: 8) {
                ForEach(CheckoutPickupOption.allCases) { option in
                    let isSelected = selectedPickup == option
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                            selectedPickup = option
                        }
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: option.systemIcon)
                                .font(.system(size: 18))
                                .foregroundColor(isSelected ? Color("Button_red") : Color("app_black"))
                                .frame(width: 28)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(option.rawValue)
                                    .font(.barlowBold(size: 14))
                                    .foregroundColor(Color("app_black"))
                                
                                Text(option.subtitle)
                                    .font(.barlowRegular(size: 12))
                                    .foregroundColor(Color("text_gary"))
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(isSelected ? Color(red: 0xFD / 255.0, green: 0xF2 / 255.0, blue: 0xF4 / 255.0) : Color.white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(isSelected ? Color("Button_red") : Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: isSelected ? 1.6 : 1.2)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            // Blue Pickup Instruction Info Banner
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "info.circle")
                    .font(.system(size: 15))
                    .foregroundColor(Color(red: 0x3E / 255.0, green: 0x86 / 255.0, blue: 0x9E / 255.0))
                    .padding(.top, 1)
                
                Text("Pickup instruction: For all the ordering sources, tell us your order name at counter.")
                    .font(.barlowRegular(size: 12.5))
                    .foregroundColor(Color(red: 0x24 / 255.0, green: 0x58 / 255.0, blue: 0x6E / 255.0))
                    .lineSpacing(2)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(red: 0xEE / 255.0, green: 0xF6 / 255.0, blue: 0xFA / 255.0))
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.2)
                )
                .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
        )
    }
    
    // MARK: - 3. ALLERGIES & KITCHEN NOTE Card
    
    private var allergiesCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header Row
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color("Button_red"))
                
                Text("ALLERGIES & KITCHEN NOTE")
                    .font(.oswaldMedium(size: 16))
                    .tracking(0.8)
                    .foregroundColor(Color("app_black"))
            }
            
            // Subtitle 1: Allergens to flag
            HStack(spacing: 6) {
                Text("Allergens to flag")
                    .font(.barlowSemiBold(size: 13.5))
                    .foregroundColor(Color("app_black"))
                
                Text("optional")
                    .font(.barlowRegular(size: 12))
                    .foregroundColor(Color("text_gary"))
            }
            
            // Allergen Pills Flow (Rows 1, 2, 3 matching snapshot)
            VStack(alignment: .leading, spacing: 8) {
                // Row 1: None, Milk, Eggs, Wheat
                HStack(spacing: 6) {
                    ForEach(["None", "Milk", "Eggs", "Wheat"], id: \.self) { allergen in
                        allergenPill(allergen)
                    }
                }
                
                // Row 2: Soy, Peanuts, Treenuts, Sesame
                HStack(spacing: 6) {
                    ForEach(["Soy", "Peanuts", "Treenuts", "Sesame"], id: \.self) { allergen in
                        allergenPill(allergen)
                    }
                }
                
                // Row 3: Fish, Shellfish
                HStack(spacing: 6) {
                    ForEach(["Fish", "Shellfish"], id: \.self) { allergen in
                        allergenPill(allergen)
                    }
                }
            }
            
            // Subtitle 2: Kitchen note
            HStack(spacing: 6) {
                Text("Kitchen note")
                    .font(.barlowSemiBold(size: 13.5))
                    .foregroundColor(Color("app_black"))
                
                Text("optional")
                    .font(.barlowRegular(size: 12))
                    .foregroundColor(Color("text_gary"))
            }
            
            // Multiline Kitchen Note Input
            ZStack(alignment: .topLeading) {
                if kitchenNote.isEmpty {
                    Text("e.g. Please change gloves for my order")
                        .font(.barlowRegular(size: 13.5))
                        .foregroundColor(Color("text_gary").opacity(0.8))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                }
                
                TextEditor(text: $kitchenNote)
                    .font(.barlowRegular(size: 13.5))
                    .foregroundColor(Color("app_black"))
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .frame(minHeight: 74)
            }
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.2)
                    .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.white))
            )
            
            // Orange Disclaimer Row
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "exclamationmark.circle")
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 0xC8 / 255.0, green: 0x6E / 255.0, blue: 0x24 / 255.0))
                    .padding(.top, 1)
                
                Text("Always notice here our team take care like our kitchens share equipment and ingredients. We can't guarantee an allergen free meal.")
                    .font(.barlowRegular(size: 12))
                    .foregroundColor(Color(red: 0x9B / 255.0, green: 0x58 / 255.0, blue: 0x1E / 255.0))
                    .lineSpacing(2)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.2)
                )
                .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
        )
    }
    
    private func allergenPill(_ name: String) -> some View {
        let isSelected = selectedAllergens.contains(name)
        
        return Button(action: {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                if name == "None" {
                    selectedAllergens.removeAll()
                    selectedAllergens.insert("None")
                } else {
                    selectedAllergens.remove("None")
                    if isSelected {
                        selectedAllergens.remove(name)
                    } else {
                        selectedAllergens.insert(name)
                    }
                }
            }
        }) {
            Text(name)
                .font(isSelected ? .barlowBold(size: 13) : .barlowMedium(size: 13))
                .foregroundColor(isSelected ? Color("Button_red") : Color("app_black"))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    Capsule()
                        .fill(isSelected ? Color(red: 0xFD / 255.0, green: 0xF2 / 255.0, blue: 0xF4 / 255.0) : Color.white)
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color("Button_red") : Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: isSelected ? 1.4 : 1.0)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - 4. TIP THE TEAM Card
    
    private var tipCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header Row
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color("Button_red"))
                
                Text("TIP THE TEAM")
                    .font(.oswaldMedium(size: 16))
                    .tracking(0.8)
                    .foregroundColor(Color("app_black"))
            }
            
            // Tip Segmented Container
            VStack(spacing: 6) {
                // Top Row: No tip | 15% | 18% | 20% | 25%
                HStack(spacing: 3) {
                    tipOptionButton(.noTip, title: "No tip")
                    tipOptionButton(.percent(15), title: "15%")
                    tipOptionButton(.percent(18), title: "18%")
                    tipOptionButton(.percent(20), title: "20%")
                    tipOptionButton(.percent(25), title: "25%")
                }
                
                // Bottom Row: Custom Button
                HStack {
                    tipCustomButton
                    Spacer()
                }
            }
            .padding(4)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(red: 0xF3 / 255.0, green: 0xEE / 255.0, blue: 0xE4 / 255.0))
            )
            
            // Custom Tip Input if active
            if showCustomTipInput {
                HStack(spacing: 8) {
                    Text("$")
                        .font(.barlowBold(size: 15))
                        .foregroundColor(Color("app_black"))
                    
                    TextField("0.00", text: $customTipString)
                        .keyboardType(.decimalPad)
                        .font(.barlowMedium(size: 14))
                        .foregroundColor(Color("app_black"))
                        .onChange(of: customTipString) { newValue in
                            if let val = Double(newValue.replacingOccurrences(of: "$", with: "")) {
                                customTipAmount = val
                                selectedTip = .custom(val)
                            }
                        }
                    
                    Spacer()
                }
                .padding(.horizontal, 12)
                .frame(height: 42)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color("Button_red"), lineWidth: 1.2)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                )
            }
            
            // Caption
            Text("Percentages figure calculated on menu order subtotal, before tax and delivery fees.")
                .font(.barlowRegular(size: 12))
                .foregroundColor(Color("text_gary"))
                .lineSpacing(2)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.2)
                )
                .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
        )
    }
    
    private func tipOptionButton(_ tip: CheckoutTipSelection, title: String) -> some View {
        let isSelected: Bool = {
            switch (selectedTip, tip) {
            case (.noTip, .noTip): return true
            case (.percent(let a), .percent(let b)): return a == b
            default: return false
            }
        }()
        
        return Button(action: {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                selectedTip = tip
                showCustomTipInput = false
            }
        }) {
            Text(title)
                .font(isSelected ? .barlowBold(size: 13) : .barlowMedium(size: 13))
                .foregroundColor(Color("app_black"))
                .frame(maxWidth: .infinity)
                .frame(height: 38)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.white : Color.clear)
                        .shadow(color: isSelected ? Color.black.opacity(0.08) : Color.clear, radius: 2, x: 0, y: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var tipCustomButton: some View {
        let isSelected: Bool = {
            if case .custom = selectedTip { return true }
            return showCustomTipInput
        }()
        
        return Button(action: {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                showCustomTipInput.toggle()
                if showCustomTipInput {
                    selectedTip = .custom(customTipAmount)
                }
            }
        }) {
            Text("Custom")
                .font(isSelected ? .barlowBold(size: 13) : .barlowMedium(size: 13))
                .foregroundColor(Color("app_black"))
                .padding(.horizontal, 16)
                .frame(height: 34)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.white : Color.clear)
                        .shadow(color: isSelected ? Color.black.opacity(0.08) : Color.clear, radius: 2, x: 0, y: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - 5. MOD REWARDS Card
    
    private var rewardsCard: some View {
        ZStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 14) {
                // Header Row
                HStack(spacing: 8) {
                    Image(systemName: "star")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color("Button_red"))
                    
                    Text("MOD REWARDS")
                        .font(.oswaldMedium(size: 16))
                        .tracking(0.8)
                        .foregroundColor(Color("app_black"))
                }
                
                // Description
                Text("You're in. This order earns you pts. 10 pts per $1, and a free pizza at 1,000 pts. Your contact details above become your rewards account.")
                    .font(.barlowRegular(size: 13.5))
                    .foregroundColor(Color("app_black"))
                    .lineSpacing(2)
                
                // 3 Opt-Out Checkboxes
                VStack(alignment: .leading, spacing: 10) {
                    checkboxRow(title: "No thanks, I'll pass on free pizza.", isChecked: $optOutFreePizza)
                    checkboxRow(title: "No thanks, I love paying full price.", isChecked: $optOutFullPrice)
                    checkboxRow(title: "No thanks, I'd rather miss the secret deals.", isChecked: $optOutSecretDeals)
                }
                .padding(.top, 2)
            }
            .padding(16)
            .padding(.leading, 6)
            
            // Red Accent Strip along the left border
            RoundedRectangle(cornerRadius: 3)
                .fill(Color("Button_red"))
                .frame(width: 4)
                .padding(.vertical, 8)
                .padding(.leading, 0)
        }
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.2)
                )
                .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
    
    private func checkboxRow(title: String, isChecked: Binding<Bool>) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                isChecked.wrappedValue.toggle()
            }
        }) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 3.5)
                        .stroke(Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0), lineWidth: 1.4)
                        .frame(width: 18, height: 18)
                        .background(RoundedRectangle(cornerRadius: 3.5).fill(Color.white))
                    
                    if isChecked.wrappedValue {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color("Button_red"))
                    }
                }
                
                Text(title)
                    .font(.barlowRegular(size: 13))
                    .foregroundColor(Color("app_black"))
                    .lineLimit(1)
                
                Spacer()
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - 6. PAYMENT Card
    
    private var paymentCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header Row
            HStack(spacing: 8) {
                Image(systemName: "creditcard")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color("Button_red"))
                
                Text("PAYMENT")
                    .font(.oswaldMedium(size: 16))
                    .tracking(0.8)
                    .foregroundColor(Color("app_black"))
                
                // SIMULATED Tag
                Text("SIMULATED")
                    .font(.barlowBold(size: 10))
                    .tracking(0.6)
                    .foregroundColor(Color("text_gary"))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 2.5)
                    .background(
                        Capsule()
                            .fill(Color(red: 0xF3 / 255.0, green: 0xEE / 255.0, blue: 0xE4 / 255.0))
                    )
            }
            
            // Description
            Text("Select a simulated payment method. Card, Apple Pay, or Google Pay. For testing purposes this screen uses simulated checkout for members.")
                .font(.barlowRegular(size: 13))
                .foregroundColor(Color("text_gary"))
                .lineSpacing(2)
            
            // 3 Payment Option Cells
            VStack(spacing: 8) {
                ForEach(CheckoutPaymentMethod.allCases) { method in
                    let isSelected = selectedPayment == method
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                            selectedPayment = method
                        }
                    }) {
                        HStack(spacing: 12) {
                            // Method Icon
                            if method == .card {
                                Image(systemName: "creditcard")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color("Button_red"))
                                    .frame(width: 24)
                            } else if method == .applePay {
                                Image(systemName: "applelogo")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color("app_black"))
                                    .frame(width: 24)
                            } else {
                                Image(systemName: "g.circle")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color("app_black"))
                                    .frame(width: 24)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(method.rawValue)
                                    .font(.barlowBold(size: 14))
                                    .foregroundColor(Color("app_black"))
                                
                                Text(method.subtitle)
                                    .font(.barlowRegular(size: 12))
                                    .foregroundColor(Color("text_gary"))
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(isSelected ? Color(red: 0xFD / 255.0, green: 0xF2 / 255.0, blue: 0xF4 / 255.0) : Color.white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(isSelected ? Color("Button_red") : Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: isSelected ? 1.6 : 1.2)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            // Caption
            Text("No real charges will be made. This prototype never collects real card numbers.")
                .font(.barlowRegular(size: 11.5))
                .foregroundColor(Color("text_gary"))
                .lineSpacing(2)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.2)
                )
                .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
        )
    }
    
    // MARK: - 7. ORDER SUMMARY Card
    
    private var orderSummaryCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            Text("ORDER SUMMARY")
                .font(.oswaldMedium(size: 18))
                .tracking(0.6)
                .foregroundColor(Color("app_black"))
            
            // Dynamic Item Rows
            VStack(spacing: 8) {
                if let group = groupOrder, !group.participants.flatMap({ $0.items }).isEmpty {
                    ForEach(group.participants) { participant in
                        if !participant.items.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(participant.name.uppercased()) (\(participant.isHost ? "Host" : "Member"))")
                                    .font(.barlowBold(size: 12))
                                    .foregroundColor(Color("Button_red"))
                                    .padding(.top, 4)
                                
                                ForEach(participant.items) { food in
                                    HStack {
                                        HStack(spacing: 6) {
                                            Circle()
                                                .fill(Color("Button_red"))
                                                .frame(width: 6, height: 6)
                                            
                                            Text(food.title)
                                                .font(.barlowSemiBold(size: 14))
                                                .foregroundColor(Color("app_black"))
                                        }
                                        
                                        Spacer()
                                        
                                        Text(String(format: "$%.2f", food.price))
                                            .font(.barlowBold(size: 14))
                                            .foregroundColor(Color("app_black"))
                                    }
                                }
                            }
                        }
                    }
                } else if cartManager.items.isEmpty {
                    // Fallback matching snapshot
                    HStack {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color("Button_red"))
                                .frame(width: 6, height: 6)
                            
                            Text("Build Your Pizza")
                                .font(.barlowSemiBold(size: 14))
                                .foregroundColor(Color("app_black"))
                        }
                        
                        Spacer()
                        
                        Text("$11.99")
                            .font(.barlowBold(size: 14))
                            .foregroundColor(Color("app_black"))
                    }
                } else {
                    ForEach(cartManager.items) { item in
                        HStack {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(Color("Button_red"))
                                    .frame(width: 6, height: 6)
                                
                                Text(item.quantity > 1 ? "\(item.quantity)× \(item.title)" : item.title)
                                    .font(.barlowSemiBold(size: 14))
                                    .foregroundColor(Color("app_black"))
                            }
                            
                            Spacer()
                            
                            Text(item.formattedItemTotal)
                                .font(.barlowBold(size: 14))
                                .foregroundColor(Color("app_black"))
                        }
                    }
                }
            }
            
            // Promo code accordion
            VStack(alignment: .leading, spacing: 8) {
                Button(action: {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                        showPromoSection.toggle()
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "tag")
                            .font(.system(size: 14))
                            .foregroundColor(Color("Button_red"))
                        
                        Text("Add promo code or reward")
                            .font(.barlowSemiBold(size: 14))
                            .foregroundColor(Color("app_black"))
                        
                        Spacer()
                        
                        Image(systemName: showPromoSection ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color("text_gary"))
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                if showPromoSection {
                    HStack(spacing: 8) {
                        TextField("Enter code", text: $promoCodeInput)
                            .font(.barlowRegular(size: 13.5))
                            .autocapitalization(.allCharacters)
                            .padding(.horizontal, 10)
                            .frame(height: 38)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.0)
                            )
                        
                        Button(action: {
                            if !promoCodeInput.isEmpty {
                                withAnimation {
                                    appliedDiscount = 2.00
                                    promoSuccessMessage = "Promo applied! (-$2.00)"
                                }
                            }
                        }) {
                            Text("APPLY")
                                .font(.oswaldMedium(size: 13))
                                .foregroundColor(.white)
                                .padding(.horizontal, 14)
                                .frame(height: 38)
                                .background(Capsule().fill(Color("Button_red")))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.top, 4)
                    
                    if let msg = promoSuccessMessage {
                        Text(msg)
                            .font(.barlowMedium(size: 12))
                            .foregroundColor(Color(red: 0x2E / 255.0, green: 0x7D / 255.0, blue: 0x32 / 255.0))
                    }
                }
            }
            .padding(.vertical, 4)
            
            Divider()
                .background(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0))
            
            // Price Breakdown Table
            VStack(spacing: 8) {
                summaryRow(title: "Subtotal", amount: String(format: "$%.2f", subtotal))
                
                if appliedDiscount > 0 {
                    summaryRow(title: "Discount", amount: String(format: "-$%.2f", appliedDiscount), isDiscount: true)
                }
                
                summaryRow(title: "Estimated tax", amount: String(format: "$%.2f", estimatedTax))
                
                summaryRow(title: "Tip", amount: String(format: "$%.2f", calculatedTip))
            }
            
            Divider()
                .background(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0))
            
            // Total Row
            HStack {
                Text("Total")
                    .font(.barlowBold(size: 15))
                    .foregroundColor(Color("app_black"))
                
                Spacer()
                
                Text(String(format: "$%.2f", totalAmount))
                    .font(.oswaldBold(size: 16))
                    .foregroundColor(Color("app_black"))
            }
            
            // Remaining due Row
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Remaining due")
                        .font(.barlowBold(size: 14.5))
                        .foregroundColor(Color("app_black"))
                    
                    Text(selectedPayment.rawValue)
                        .font(.barlowRegular(size: 12))
                        .foregroundColor(Color("text_gary"))
                }
                
                Spacer()
                
                Text(String(format: "$%.2f", totalAmount))
                    .font(.oswaldBold(size: 16))
                    .foregroundColor(Color("app_black"))
            }
            .padding(.top, 2)
            
            // Rewards Points Banner
            HStack(spacing: 8) {
                Image(systemName: "star")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(red: 0x8C / 255.0, green: 0x64 / 255.0, blue: 0x1E / 255.0))
                
                Text("You'll earn about \(rewardsEarnedPoints) pts with MOD Rewards once this order is completed.")
                    .font(.barlowMedium(size: 12.5))
                    .foregroundColor(Color(red: 0x5C / 255.0, green: 0x44 / 255.0, blue: 0x14 / 255.0))
                    .lineSpacing(1.5)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(red: 0xFD / 255.0, green: 0xF6 / 255.0, blue: 0xE2 / 255.0))
            )
            .padding(.top, 4)
            
            // PLACE ORDER Button
            Button(action: {
                handlePlaceOrder()
            }) {
                HStack {
                    if isPlacingOrder {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding(.trailing, 6)
                    }
                    
                    Text("PLACE ORDER — $\(String(format: "%.2f", totalAmount))")
                        .font(.oswaldBold(size: 16))
                        .tracking(0.8)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    Capsule()
                        .fill(Color("Button_red"))
                        .shadow(color: Color("Button_red").opacity(0.35), radius: 6, x: 0, y: 3)
                )
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(isPlacingOrder)
            .padding(.top, 6)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.2)
                )
                .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
        )
    }
    
    private func summaryRow(title: String, amount: String, isDiscount: Bool = false) -> some View {
        HStack {
            Text(title)
                .font(.barlowRegular(size: 13.5))
                .foregroundColor(Color("app_black"))
            
            Spacer()
            
            Text(amount)
                .font(.barlowMedium(size: 13.5))
                .foregroundColor(isDiscount ? Color(red: 0x2E / 255.0, green: 0x7D / 255.0, blue: 0x32 / 255.0) : Color("app_black"))
        }
    }
    
    // MARK: - Place Order Action
    
    private func handlePlaceOrder() {
        withAnimation {
            isPlacingOrder = true
        }
        
        capturedCartItems = cartManager.items
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                isPlacingOrder = false
                showSuccessModal = true
            }
            
            // Clear cart
            cartManager.clearCart()
            
            // Post order placed notification
            NotificationCenter.default.post(name: NSNotification.Name("OrderPlacedNotification"), object: nil)
            
            // Transition directly to the Order Tracking screen after brief confirmation
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                showSuccessModal = false
                showTrackingView = true
            }
        }
    }
    
    // MARK: - Success Modal Overlay
    
    private var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0x2E / 255.0, green: 0x7D / 255.0, blue: 0x32 / 255.0))
                        .frame(width: 68, height: 68)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.top, 10)
                
                Text("ORDER PLACED!")
                    .font(.oswaldBold(size: 24))
                    .foregroundColor(Color("app_black"))
                
                Text("Your order has been sent to Capitol Hill.\nEstimated pickup: 15–20 mins.")
                    .font(.barlowRegular(size: 14))
                    .foregroundColor(Color("text_gary"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .padding(.horizontal, 16)
                
                Text("Total Paid: $\(String(format: "%.2f", totalAmount))")
                    .font(.oswaldMedium(size: 16))
                    .foregroundColor(Color("Button_red"))
                    .padding(.top, 4)
            }
            .padding(.vertical, 28)
            .padding(.horizontal, 24)
            .frame(maxWidth: 320)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 16, x: 0, y: 8)
            )
        }
    }
}

// MARK: - Preview

struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutView()
    }
}

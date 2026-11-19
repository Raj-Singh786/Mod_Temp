//
//  CartView.swift
//  MOD
//
//  Created by Rajpal singh on 17/11/26.
//

import SwiftUI

// MARK: - Cart Promo Item Model

struct CartPromoItem: Identifiable, Equatable {
    let id: String
    let code: String
    let discount: Double
    let description: String
}

// MARK: - CartView

struct CartView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var cartManager = CartManager.shared
    
    // MARK: - State
    
    @State private var showEditPizza: Bool = false
    @State private var itemToEdit: CartItem? = nil
    @State private var showCheckoutSuccess: Bool = false
    @State private var showStoreFulfillmentSheet: Bool = false
    @State private var showCheckoutView: Bool = false
    
    // Store & Fulfillment States
    @State private var selectedOrderType: Int = 0 // 0: Pickup, 1: Delivery
    @State private var selectedStoreName: String = "Capitol Hill, Seattle"
    @State private var selectedPickupOption: String = "In-store pickup"
    @State private var deliveryAddress: String = "1302 Pine St, Seattle, WA 98101"
    @State private var selectedWhenText: String = "ASAP · ~15 min"
    
    // Promo / Rewards States
    @State private var isPromoExpanded: Bool = false
    @State private var promoCodeInput: String = ""
    @State private var appliedPromo: String? = nil
    @State private var appliedPromoDiscount: Double = 0.0
    @State private var showAllOffersSheet: Bool = false
    
    // Available Promos (matches snap & deals)
    private let availablePromos: [CartPromoItem] = [
        CartPromoItem(id: "1", code: "SWEETDEAL", discount: 3.99, description: "Free dessert with any pizza"),
        CartPromoItem(id: "2", code: "2PIZZA25", discount: 0.98, description: "Any 2 pizzas for $25"),
        CartPromoItem(id: "3", code: "WELCOME20", discount: 7.99, description: "20% off welcome deal"),
        CartPromoItem(id: "4", code: "PICKUP5", discount: 5.00, description: "$5 off pickup orders")
    ]
    
    // MARK: - Computed Totals
    
    private var subtotal: Double {
        cartManager.totalPrice
    }
    
    private var discount: Double {
        appliedPromoDiscount
    }
    
    private var discountedSubtotal: Double {
        max(0.0, subtotal - discount)
    }
    
    private var estimatedTax: Double {
        discountedSubtotal * 0.0875
    }
    
    private var estimatedTotal: Double {
        discountedSubtotal + estimatedTax
    }
    
    private var earnedRewardsPoints: Int {
        max(10, Int(discountedSubtotal * 10))
    }
    
    private var displayStoreName: String {
        selectedStoreName.components(separatedBy: ",").first ?? selectedStoreName
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Color("app_background")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Custom Navigation Bar
                customNavigationBar
                
                if cartManager.items.isEmpty {
                    // Empty Cart View
                    emptyCartState
                } else {
                    // Main Scrollable Cart Content
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 18) {
                            // 1. Header: YOUR CART + Item Count + Selected Store
                            headerSection
                            
                            // 2. Cart Items List Cards
                            ForEach(cartManager.items) { item in
                                cartItemCard(item)
                            }
                            
                            // 3. "+ ADD MORE" & "CHANGE STORE OR FULFILLMENT" Actions
                            cartActionsSection
                            
                            // 4. Upsell Card: "GOES GREAT WITH YOUR ORDER" (No Name Cake)
                            goesGreatWithOrderCard
                            
                            // 5. SUMMARY Card
                            orderSummaryCard
                            
                            // Bottom padding
                            Spacer()
                                .frame(height: 40)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 24)
                    }
                }
            }
            
            // Checkout Success Notification
            if showCheckoutSuccess {
                VStack {
                    Spacer()
                    Text("Order placed successfully!")
                        .font(.barlowBold(size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 14)
                        .background(
                            Capsule()
                                .fill(Color("app_black").opacity(0.95))
                                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                        )
                        .padding(.bottom, 60)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .animation(.easeInOut(duration: 0.25), value: showCheckoutSuccess)
            }
        }
        .fullScreenCover(isPresented: $showEditPizza) {
            if let item = itemToEdit {
                let isBuildYourPizza = item.title.uppercased().contains("BUILD YOUR PIZZA")
                MenuCustomizationView(
                    pizzaTitle: item.title,
                    pizzaCategory: "PIZZAS",
                    pizzaDescription: item.details ?? "Customized pizza recipe",
                    pizzaImageName: item.imageName ?? "PizzaOn",
                    showRecipeStyle: isBuildYourPizza,
                    onBack: {
                        showEditPizza = false
                        itemToEdit = nil
                    }
                )
            } else {
                MenuCustomizationView(onBack: {
                    showEditPizza = false
                })
            }
        }
        .fullScreenCover(isPresented: $showCheckoutView) {
            CheckoutView(
                onBack: {
                    showCheckoutView = false
                },
                onOrderPlaced: {
                    showCheckoutView = false
                    dismiss()
                },
                initialStoreName: "\(displayStoreName) · 1302 19th Ave"
            )
        }
        .sheet(isPresented: $showStoreFulfillmentSheet) {
            StoreLocationView(
                initialOrderType: selectedOrderType,
                currentStoreName: selectedStoreName,
                currentDeliveryAddress: deliveryAddress,
                currentPickupOption: selectedPickupOption,
                currentWhenText: selectedWhenText,
                onDone: { newOrderType, newStoreName, newPickupOption, newAddress, newWhen in
                    selectedOrderType = newOrderType
                    selectedStoreName = newStoreName
                    selectedPickupOption = newPickupOption
                    deliveryAddress = newAddress
                    selectedWhenText = newWhen
                    showStoreFulfillmentSheet = false
                }
            )
        }
        .sheet(isPresented: $showAllOffersSheet) {
            SaveDealsView(
                showHeader: true,
                onBack: {
                    showAllOffersSheet = false
                },
                onApplyDeal: { deal in
                    appliedPromo = deal.code
                    if let matched = availablePromos.first(where: { $0.code.uppercased() == deal.code.uppercased() }) {
                        appliedPromoDiscount = matched.discount
                    } else {
                        appliedPromoDiscount = 3.99
                    }
                    promoCodeInput = deal.code
                    showAllOffersSheet = false
                }
            )
        }
    }
    
    // MARK: - Top Navigation Bar
    
    private var customNavigationBar: some View {
        HStack(alignment: .center) {
            // Left: Red < Back Button
            Button(action: {
                dismiss()
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
            Text("Cart")
                .font(.barlowBold(size: 18))
                .foregroundColor(Color("app_black"))
            
            Spacer()
            
            // Right: Profile + Cart with Live Badge
            HStack(spacing: 16) {
                Image(systemName: "person")
                    .font(.system(size: 19, weight: .regular))
                    .foregroundColor(Color("app_black"))
                    .frame(width: 32, height: 32)
                
                TopCartButton(action: nil)
            }
            .frame(width: 75, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
        .padding(.bottom, 10)
        .background(Color("app_background"))
    }
    
    // MARK: - 1. Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("YOUR CART")
                .font(.oswaldBold(size: 28))
                .tracking(0.6)
                .foregroundColor(Color("app_black"))
            
            Text("\(cartManager.totalItemCount) \(cartManager.totalItemCount == 1 ? "item" : "items") · \(displayStoreName)")
                .font(.barlowRegular(size: 14))
                .foregroundColor(Color("text_gary"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - 2. Cart Item Card
    
    private func cartItemCard(_ item: CartItem) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            // Row 1: Image + Title + Stepper + Price
            HStack(alignment: .top, spacing: 12) {
                // Item Image in Light Tan Container
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color("pizza_found"))
                        .frame(width: 60, height: 60)
                    
                    Image(item.imageName ?? "PizzaOn")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    // Item Title
                    Text(item.title)
                        .font(.oswaldBold(size: 17))
                        .tracking(0.4)
                        .foregroundColor(Color("app_black"))
                        .lineLimit(1)
                    
                    // Stepper: [ - 1 + ] + "$11.99 each"
                    HStack(spacing: 10) {
                        // Capsule Stepper
                        HStack(spacing: 8) {
                            Button(action: {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                    cartManager.updateQuantity(for: item.id, quantity: item.quantity - 1)
                                }
                            }) {
                                Image(systemName: "minus")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color("app_black"))
                                    .frame(width: 24, height: 32)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Text("\(item.quantity)")
                                .font(.barlowBold(size: 15))
                                .foregroundColor(Color("app_black"))
                                .frame(minWidth: 20, alignment: .center)
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                    cartManager.updateQuantity(for: item.id, quantity: item.quantity + 1)
                                }
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color("app_black"))
                                    .frame(width: 24, height: 32)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal, 8)
                        .background(
                            Capsule()
                                .stroke(Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0), lineWidth: 1.0)
                                .background(Capsule().fill(Color.white))
                        )
                        
                        // Price each label
                        Text("$\(String(format: "%.2f", item.price)) each")
                            .font(.barlowRegular(size: 13))
                            .foregroundColor(Color("text_gary"))
                    }
                }
                
                Spacer()
                
                // Total Price on Top Right
                Text(item.formattedItemTotal)
                    .font(.oswaldBold(size: 17))
                    .foregroundColor(Color("app_black"))
            }
            
            // Row 2: EDIT and REMOVE Action Buttons with Leading Space like Snap
            HStack(spacing: 28) {
                // EDIT Button
                Button(action: {
                    itemToEdit = item
                    showEditPizza = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "pencil")
                            .font(.system(size: 13, weight: .semibold))
                        Text("EDIT")
                            .font(.oswaldMedium(size: 14))
                            .tracking(0.8)
                    }
                    .foregroundColor(Color("app_black"))
                }
                .buttonStyle(PlainButtonStyle())
                
                // REMOVE Button
                Button(action: {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                        cartManager.removeItem(id: item.id)
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "trash")
                            .font(.system(size: 13, weight: .semibold))
                        Text("REMOVE")
                            .font(.oswaldMedium(size: 14))
                            .tracking(0.8)
                    }
                    .foregroundColor(Color("Button_red"))
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
            }
            .padding(.leading, 72)
            .padding(.top, 2)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.2)
                )
                .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 1)
        )
    }
    
    // MARK: - 3. "+ ADD MORE" & "CHANGE STORE" Section
    
    private var cartActionsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            // "+ ADD MORE" Capsule Button
            Button(action: {
                dismiss()
                NotificationCenter.default.post(name: .selectMenuTabWithCategory, object: nil)
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .bold))
                    Text("ADD MORE")
                        .font(.oswaldMedium(size: 13.5))
                        .tracking(0.8)
                }
                .foregroundColor(Color("app_black"))
                .padding(.horizontal, 18)
                .frame(height: 38)
                .background(
                    Capsule()
                        .stroke(Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0), lineWidth: 1.2)
                        .background(Capsule().fill(Color.white))
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // "CHANGE STORE OR FULFILLMENT" Link
            Button(action: {
                showStoreFulfillmentSheet = true
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "storefront")
                        .font(.system(size: 13))
                    Text("CHANGE STORE OR FULFILLMENT")
                        .font(.oswaldMedium(size: 13))
                        .tracking(0.8)
                }
                .foregroundColor(Color("app_black"))
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 2)
        }
    }
    
    // MARK: - 4. "GOES GREAT WITH YOUR ORDER" Upsell Card
    
    private var goesGreatWithOrderCard: some View {
        HStack(alignment: .center, spacing: 12) {
            // Dessert Thumbnail in Tan Box
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color("pizza_found"))
                    .frame(width: 64, height: 64)
                
                Image("Desert")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 52, height: 52)
                    .clipShape(Circle())
            }
            
            // Middle Details
            VStack(alignment: .leading, spacing: 3) {
                // Red 2-line Subtitle
                Text("GOES GREAT WITH\nYOUR ORDER")
                    .font(.oswaldMedium(size: 11))
                    .tracking(0.6)
                    .foregroundColor(Color("Button_red"))
                    .lineSpacing(1.5)
                
                // Product Title
                Text("NO NAME CAKE")
                    .font(.oswaldBold(size: 15.5))
                    .tracking(0.4)
                    .foregroundColor(Color("app_black"))
                
                // Description
                Text("Chocolate cake with a vanilla buttercream center and chocolate glaze.")
                    .font(.barlowRegular(size: 11.5))
                    .foregroundColor(Color("text_gary"))
                    .lineLimit(3)
                    .lineSpacing(1.5)
            }
            
            Spacer(minLength: 4)
            
            // "+ ADD $3.99" Red Capsule Button
            Button(action: {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                    cartManager.addItem(
                        id: "no_name_cake",
                        title: "NO NAME CAKE",
                        price: 3.99,
                        quantity: 1,
                        details: "Chocolate cake with vanilla buttercream center",
                        calories: 380,
                        imageName: "Desert"
                    )
                }
            }) {
                Text("+ ADD $3.99")
                    .font(.oswaldMedium(size: 13))
                    .tracking(0.6)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .frame(height: 36)
                    .background(
                        Capsule()
                            .fill(Color("Button_red"))
                            .shadow(color: Color("Button_red").opacity(0.35), radius: 5, x: 0, y: 2)
                    )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color(red: 0xF5 / 255.0, green: 0xEE / 255.0, blue: 0xF0 / 255.0), lineWidth: 1.2)
                )
                .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 1)
        )
    }
    
    // MARK: - 5. SUMMARY Card
    
    private var orderSummaryCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            Text("SUMMARY")
                .font(.oswaldLight(size: 18))
                .tracking(0.8)
                .foregroundColor(Color("app_black"))
            
            // Pickup / Delivery Info Row
            HStack(spacing: 10) {
                Image(systemName: selectedOrderType == 0 ? "bag" : "car.fill")
                    .font(.system(size: 15))
                    .foregroundColor(Color("Button_red"))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(selectedOrderType == 0 ? "Pickup" : "Delivery") · \(displayStoreName)")
                        .font(.barlowSemiBold(size: 13.5))
                        .foregroundColor(Color("app_black"))
                    
                    Text(selectedWhenText)
                        .font(.barlowRegular(size: 12))
                        .foregroundColor(Color("text_gary"))
                }
                
                Spacer()
                
                Button(action: {
                    showStoreFulfillmentSheet = true
                }) {
                    Text("Change")
                        .font(.barlowBold(size: 13))
                        .foregroundColor(Color("Button_red"))
                        .underline()
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(red: 0xFA / 255.0, green: 0xF7 / 255.0, blue: 0xF2 / 255.0))
            )
            
            Divider()
                .background(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0))
            
            // Collapsible Promo Section Header Row
            Button(action: {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isPromoExpanded.toggle()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "tag")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color("Button_red"))
                    
                    Text(appliedPromo != nil ? "Promo applied: \(appliedPromo!)" : "Add promo code or reward")
                        .font(.barlowBold(size: 15))
                        .foregroundColor(Color("app_black"))
                    
                    Spacer()
                    
                    Image(systemName: isPromoExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color("app_black"))
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Collapsible Promo View (Matches Snap)
            if isPromoExpanded {
                promoCollapsibleSection
            }
            
            Divider()
                .background(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0))
            
            // Subtotal, Discount & Tax Rows
            VStack(spacing: 8) {
                HStack {
                    Text("Subtotal")
                        .font(.barlowRegular(size: 14))
                        .foregroundColor(Color("app_black"))
                    Spacer()
                    Text(String(format: "$%.2f", subtotal))
                        .font(.barlowMedium(size: 14))
                        .foregroundColor(Color("app_black"))
                }
                
                if appliedPromoDiscount > 0, let promo = appliedPromo {
                    HStack {
                        Text("Discount (\(promo))")
                            .font(.barlowRegular(size: 14))
                            .foregroundColor(Color(red: 0x3E / 255.0, green: 0x59 / 255.0, blue: 0x18 / 255.0))
                        Spacer()
                        Text(String(format: "-$%.2f", appliedPromoDiscount))
                            .font(.barlowMedium(size: 14))
                            .foregroundColor(Color(red: 0x3E / 255.0, green: 0x59 / 255.0, blue: 0x18 / 255.0))
                    }
                }
                
                HStack {
                    Text("Estimated tax")
                        .font(.barlowRegular(size: 14))
                        .foregroundColor(Color("app_black"))
                    Spacer()
                    Text(String(format: "$%.2f", estimatedTax))
                        .font(.barlowMedium(size: 14))
                        .foregroundColor(Color("app_black"))
                }
            }
            
            Divider()
                .background(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0))
            
            // Estimated Total Row
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Estimated total")
                        .font(.barlowBold(size: 15))
                        .foregroundColor(Color("app_black"))
                    
                    Text("before tip")
                        .font(.barlowRegular(size: 11.5))
                        .foregroundColor(Color("text_gary"))
                }
                
                Spacer()
                
                Text(String(format: "$%.2f", estimatedTotal))
                    .font(.oswaldBold(size: 20))
                    .foregroundColor(Color("app_black"))
            }
            
            // Rewards Points Earned Card
            HStack(spacing: 10) {
                Image(systemName: "star")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color(red: 0x73 / 255.0, green: 0x2C / 255.0, blue: 0x1A / 255.0))
                
                Text("You'll earn about ")
                    .font(.barlowRegular(size: 12.5))
                    .foregroundColor(Color("app_black"))
                + Text("\(earnedRewardsPoints) pts")
                    .font(.barlowBold(size: 12.5))
                    .foregroundColor(Color("app_black"))
                + Text(" with MOD Rewards once this order is completed.")
                    .font(.barlowRegular(size: 12.5))
                    .foregroundColor(Color("app_black"))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(red: 0xF9 / 255.0, green: 0xF4 / 255.0, blue: 0xE3 / 255.0))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color(red: 0xEE / 255.0, green: 0xE2 / 255.0, blue: 0xC6 / 255.0), lineWidth: 1.0)
                    )
            )
            .padding(.top, 2)
            
            // Big Red CHECKOUT Button
            Button(action: {
                showCheckoutView = true
            }) {
                HStack(spacing: 6) {
                    Text("CHECKOUT")
                        .font(.oswaldBold(size: 16))
                        .tracking(0.8)
                    
                    Image(systemName: "chevron.forward")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    Capsule()
                        .fill(Color("Button_red"))
                        .shadow(color: Color("Button_red").opacity(0.35), radius: 8, x: 0, y: 4)
                )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 4)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.2)
                )
                .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 1)
        )
    }
    
    // MARK: - Collapsible Promo Section (Matches Snap)
    
    private var promoCollapsibleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // ENTER CODE + APPLY Row
            HStack(spacing: 10) {
                HStack {
                    TextField("ENTER CODE", text: $promoCodeInput)
                        .font(.oswaldMedium(size: 15))
                        .tracking(0.5)
                        .foregroundColor(Color("app_black"))
                        .autocapitalization(.allCharacters)
                        .disableAutocorrection(true)
                    
                    if !promoCodeInput.isEmpty {
                        Button(action: {
                            promoCodeInput = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Color("text_gary"))
                                .font(.system(size: 14))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 14)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0), lineWidth: 1.2)
                        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.white))
                )
                
                // APPLY Button
                Button(action: {
                    applyTypedPromo()
                }) {
                    Text("APPLY")
                        .font(.oswaldBold(size: 14.5))
                        .tracking(0.8)
                        .foregroundColor(.white)
                        .padding(.horizontal, 22)
                        .frame(height: 48)
                        .background(
                            Capsule()
                                .fill(Color("app_black"))
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.top, 4)
            
            // "Eligible right now:"
            Text("Eligible right now:")
                .font(.barlowRegular(size: 13.5))
                .foregroundColor(Color("text_gary"))
                .padding(.top, 2)
            
            // Eligible Promo Pills (2x2 Grid matching snap)
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                ForEach(availablePromos) { promo in
                    let isSelected = appliedPromo == promo.code
                    Button(action: {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                            if isSelected {
                                appliedPromo = nil
                                appliedPromoDiscount = 0.0
                            } else {
                                appliedPromo = promo.code
                                appliedPromoDiscount = promo.discount
                                promoCodeInput = promo.code
                            }
                        }
                    }) {
                        HStack(spacing: 6) {
                            Text(promo.code)
                                .font(.oswaldBold(size: 13.5))
                                .tracking(0.3)
                                .foregroundColor(Color("app_black"))
                            
                            Text("-\(String(format: "$%.2f", promo.discount))")
                                .font(.oswaldBold(size: 13.5))
                                .tracking(0.3)
                                .foregroundColor(Color(red: 0x3E / 255.0, green: 0x59 / 255.0, blue: 0x18 / 255.0))
                        }
                        .padding(.horizontal, 10)
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background(
                            Capsule()
                                .stroke(
                                    isSelected
                                        ? Color(red: 0x3E / 255.0, green: 0x59 / 255.0, blue: 0x18 / 255.0)
                                        : Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0),
                                    lineWidth: isSelected ? 1.5 : 1.2
                                )
                                .background(
                                    Capsule()
                                        .fill(isSelected ? Color(red: 0xF3 / 255.0, green: 0xF8 / 255.0, blue: 0xEE / 255.0) : Color.white)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            // Footer: "One deal, coupon or points reward per order. See all offers"
            HStack(spacing: 0) {
                Text("One deal, coupon ")
                    .font(.barlowRegular(size: 12))
                    .foregroundColor(Color("text_gary"))
                + Text("or")
                    .font(.barlowItalic(size: 12))
                    .foregroundColor(Color("text_gary"))
                + Text(" points reward per order. ")
                    .font(.barlowRegular(size: 12))
                    .foregroundColor(Color("text_gary"))
                
                Button(action: {
                    showAllOffersSheet = true
                }) {
                    Text("See all offers")
                        .font(.barlowRegular(size: 12))
                        .foregroundColor(Color("Button_red"))
                        .underline()
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
            }
            .padding(.top, 4)
        }
    }
    
    // MARK: - Promo Action Helper
    
    private func applyTypedPromo() {
        let code = promoCodeInput.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !code.isEmpty else { return }
        
        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
            if let matched = availablePromos.first(where: { $0.code.uppercased() == code }) {
                appliedPromo = matched.code
                appliedPromoDiscount = matched.discount
            } else {
                appliedPromo = code
                appliedPromoDiscount = 3.99
            }
        }
    }
    
    // MARK: - Empty Cart State
    
    private var emptyCartState: some View {
        VStack(spacing: 16) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color(red: 0xF3 / 255.0, green: 0xEE / 255.0, blue: 0xE4 / 255.0))
                    .frame(width: 90, height: 90)
                
                Image(systemName: "cart")
                    .font(.system(size: 38, weight: .light))
                    .foregroundColor(Color("text_gary"))
            }
            
            Text("Your cart is empty")
                .font(.oswaldBold(size: 22))
                .foregroundColor(Color("app_black"))
            
            Text("Add pizzas, salads, sides, and drinks from our menu to get started.")
                .font(.barlowRegular(size: 14))
                .foregroundColor(Color("text_gary"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 36)
            
            Button(action: {
                dismiss()
                NotificationCenter.default.post(name: .selectMenuTabWithCategory, object: nil)
            }) {
                Text("BROWSE MENU")
                    .font(.oswaldMedium(size: 15))
                    .tracking(0.8)
                    .foregroundColor(.white)
                    .padding(.horizontal, 28)
                    .frame(height: 46)
                    .background(
                        Capsule()
                            .fill(Color("Button_red"))
                            .shadow(color: Color("Button_red").opacity(0.3), radius: 6, x: 0, y: 3)
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 8)
            
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
    }
}

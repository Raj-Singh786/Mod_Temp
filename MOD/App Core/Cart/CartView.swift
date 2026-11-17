//
//  CartView.swift
//  MOD
//
//  Created by Rajpal singh on 17/11/26.
//

import SwiftUI

struct CartView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var cartManager = CartManager.shared
    
    // MARK: - State
    
    @State private var showEditPizza: Bool = false
    @State private var showPromoSheet: Bool = false
    @State private var promoCodeInput: String = ""
    @State private var appliedPromo: String? = nil
    @State private var showCheckoutSuccess: Bool = false
    @State private var showStoreFulfillmentSheet: Bool = false
    
    // MARK: - Computed Totals
    
    private var subtotal: Double {
        cartManager.totalPrice
    }
    
    private var estimatedTax: Double {
        subtotal * 0.0875
    }
    
    private var estimatedTotal: Double {
        subtotal + estimatedTax
    }
    
    private var earnedRewardsPoints: Int {
        max(10, Int(subtotal * 10))
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
                            // 1. Header: YOUR CART + Item Count
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
            MenuCustomizationView(onBack: {
                showEditPizza = false
            })
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
            
            Text("\(cartManager.totalItemCount) \(cartManager.totalItemCount == 1 ? "item" : "items") · Capitol Hill")
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
                        HStack(spacing: 12) {
                            Button(action: {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                    cartManager.updateQuantity(for: item.id, quantity: item.quantity - 1)
                                }
                            }) {
                                Image(systemName: "minus")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color("app_black"))
                                    .frame(width: 24, height: 32)
                            }
                            
                            Text("\(item.quantity)")
                                .font(.barlowBold(size: 14))
                                .foregroundColor(Color("app_black"))
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                    cartManager.updateQuantity(for: item.id, quantity: item.quantity + 1)
                                }
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color("app_black"))
                                    .frame(width: 24, height: 32)
                            }
                        }
                        .padding(.horizontal, 6)
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
            
            // Row 2: EDIT and REMOVE Action Buttons
            HStack(spacing: 24) {
                // EDIT Button
                Button(action: {
                    showEditPizza = true
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: "pencil")
                            .font(.system(size: 13, weight: .semibold))
                        Text("EDIT")
                            .font(.oswaldMedium(size: 13.5))
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
                    HStack(spacing: 5) {
                        Image(systemName: "trash")
                            .font(.system(size: 13, weight: .semibold))
                        Text("REMOVE")
                            .font(.oswaldMedium(size: 13.5))
                            .tracking(0.8)
                    }
                    .foregroundColor(Color("Button_red"))
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
            }
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
            
            // Pickup Info Row
            HStack(spacing: 10) {
                Image(systemName: "bag")
                    .font(.system(size: 15))
                    .foregroundColor(Color("Button_red"))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Pickup · Capitol Hill")
                        .font(.barlowSemiBold(size: 13.5))
                        .foregroundColor(Color("app_black"))
                    
                    Text("ASAP unavailable")
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
            
            // Promo Code Row
            Button(action: {
                showPromoSheet.toggle()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "tag.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color("Button_red"))
                    
                    Text(appliedPromo ?? "Add promo code or reward")
                        .font(.barlowSemiBold(size: 14))
                        .foregroundColor(Color("app_black"))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color("app_black"))
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Divider()
                .background(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0))
            
            // Subtotal & Tax Rows
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
                showCheckoutSuccess = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                    cartManager.clearCart()
                    dismiss()
                }
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

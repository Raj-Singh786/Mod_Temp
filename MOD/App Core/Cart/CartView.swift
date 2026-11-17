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
    
    @State private var showCheckoutSuccess: Bool = false
    
    var body: some View {
        ZStack {
            Color("app_background")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header Bar
                headerBar
                
                if cartManager.items.isEmpty {
                    // Empty Cart View
                    emptyCartView
                } else {
                    // Items List & Summary
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 16) {
                            // Store & Pickup Info Pill
                            storeInfoPill
                            
                            // Cart Items List
                            itemsListSection
                            
                            // Order Summary
                            orderSummarySection
                            
                            // Add more items button
                            Button(action: {
                                dismiss()
                                NotificationCenter.default.post(name: .selectMenuTabWithCategory, object: nil)
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 13, weight: .bold))
                                    Text("Add more items")
                                        .font(.barlowBold(size: 14))
                                }
                                .foregroundColor(Color("Button_red"))
                                .padding(.vertical, 8)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Spacer().frame(height: 100)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                    }
                }
            }
            
            // Bottom Fixed Checkout Button (Visible when cart has items)
            if !cartManager.items.isEmpty {
                VStack {
                    Spacer()
                    bottomCheckoutBar
                }
            }
            
            // Checkout Success Toast
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
                        .padding(.bottom, 100)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .animation(.easeInOut(duration: 0.25), value: showCheckoutSuccess)
            }
        }
    }
    
    // MARK: - Header Bar
    
    private var headerBar: some View {
        HStack(alignment: .center) {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color("app_black"))
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color(red: 0xF2 / 255.0, green: 0xEE / 255.0, blue: 0xE4 / 255.0)))
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            VStack(spacing: 2) {
                Text("YOUR CART")
                    .font(.oswaldBold(size: 19))
                    .tracking(0.6)
                    .foregroundColor(Color("app_black"))
                
                if cartManager.totalItemCount > 0 {
                    Text("\(cartManager.totalItemCount) \(cartManager.totalItemCount == 1 ? "item" : "items")")
                        .font(.barlowRegular(size: 12.5))
                        .foregroundColor(Color("text_gary"))
                }
            }
            
            Spacer()
            
            if !cartManager.items.isEmpty {
                Button(action: {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                        cartManager.clearCart()
                    }
                }) {
                    Text("Clear")
                        .font(.barlowBold(size: 14))
                        .foregroundColor(Color("Button_red"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                Spacer().frame(width: 36)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .padding(.bottom, 12)
        .background(Color("app_background"))
    }
    
    // MARK: - Store Info Pill
    
    private var storeInfoPill: some View {
        HStack(spacing: 10) {
            Image(systemName: "storefront.fill")
                .font(.system(size: 14))
                .foregroundColor(Color("Button_red"))
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Capitol Hill, Seattle")
                    .font(.barlowBold(size: 13.5))
                    .foregroundColor(Color("app_black"))
                
                Text("In-store pickup · ASAP")
                    .font(.barlowRegular(size: 11.5))
                    .foregroundColor(Color("text_gary"))
            }
            
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.0)
                )
        )
    }
    
    // MARK: - Items List Section
    
    private var itemsListSection: some View {
        VStack(spacing: 10) {
            ForEach(cartManager.items) { item in
                itemCard(item)
            }
        }
    }
    
    private func itemCard(_ item: CartItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                // Pizza Icon / Thumbnail
                ZStack {
                    Circle()
                        .fill(Color("pizza_found"))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "circle.grid.cross.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color("Button_red"))
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.title)
                        .font(.oswaldMedium(size: 16))
                        .tracking(0.4)
                        .foregroundColor(Color("app_black"))
                    
                    if let details = item.details, !details.isEmpty {
                        Text(details)
                            .font(.barlowRegular(size: 12))
                            .foregroundColor(Color("text_gary"))
                            .lineLimit(2)
                    }
                    
                    if let calories = item.calories {
                        Text("\(calories) cal")
                            .font(.barlowRegular(size: 11))
                            .foregroundColor(Color("Button_red"))
                    }
                }
                
                Spacer()
                
                // Item Total Price
                Text(item.formattedItemTotal)
                    .font(.oswaldBold(size: 16))
                    .foregroundColor(Color("app_black"))
            }
            
            Divider()
                .background(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0))
            
            // Stepper and Remove
            HStack {
                Button(action: {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                        cartManager.removeItem(id: item.id)
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "trash")
                            .font(.system(size: 12))
                        Text("Remove")
                            .font(.barlowMedium(size: 12))
                    }
                    .foregroundColor(Color("text_gary"))
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                // Quantity Stepper: [-] qty [+]
                HStack(spacing: 12) {
                    Button(action: {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                            cartManager.updateQuantity(for: item.id, quantity: item.quantity - 1)
                        }
                    }) {
                        Image(systemName: "minus")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color("app_black"))
                            .frame(width: 28, height: 28)
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
                            .frame(width: 28, height: 28)
                    }
                }
                .padding(.horizontal, 4)
                .background(
                    Capsule()
                        .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.0)
                        .background(Capsule().fill(Color(red: 0xF9 / 255.0, green: 0xF7 / 255.0, blue: 0xF2 / 255.0)))
                )
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.0)
                )
                .shadow(color: Color.black.opacity(0.02), radius: 3, x: 0, y: 1)
        )
    }
    
    // MARK: - Order Summary Section
    
    private var orderSummarySection: some View {
        let subtotal = cartManager.totalPrice
        let tax = subtotal * 0.085
        let total = subtotal + tax
        
        return VStack(alignment: .leading, spacing: 10) {
            Text("ORDER SUMMARY")
                .font(.oswaldLight(size: 16))
                .tracking(0.8)
                .foregroundColor(Color("app_black"))
            
            VStack(spacing: 8) {
                summaryRow(title: "Subtotal", amount: String(format: "$%.2f", subtotal))
                summaryRow(title: "Estimated tax (8.5%)", amount: String(format: "$%.2f", tax))
                Divider()
                summaryRow(title: "Total", amount: String(format: "$%.2f", total), isBold: true)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.0)
                    )
            )
        }
    }
    
    private func summaryRow(title: String, amount: String, isBold: Bool = false) -> some View {
        HStack {
            Text(title)
                .font(isBold ? .barlowBold(size: 15) : .barlowRegular(size: 13.5))
                .foregroundColor(Color("app_black"))
            
            Spacer()
            
            Text(amount)
                .font(isBold ? .oswaldBold(size: 17) : .barlowMedium(size: 13.5))
                .foregroundColor(isBold ? Color("Button_red") : Color("app_black"))
        }
    }
    
    // MARK: - Bottom Fixed Checkout Bar
    
    private var bottomCheckoutBar: some View {
        let subtotal = cartManager.totalPrice
        let tax = subtotal * 0.085
        let total = subtotal + tax
        
        return VStack(spacing: 0) {
            Button(action: {
                showCheckoutSuccess = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                    cartManager.clearCart()
                    dismiss()
                }
            }) {
                HStack {
                    Text("CHECKOUT")
                        .font(.oswaldMedium(size: 16))
                        .tracking(0.8)
                    
                    Spacer()
                    
                    Text(String(format: "$%.2f", total))
                        .font(.oswaldBold(size: 17))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 22)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    Capsule()
                        .fill(Color("Button_red"))
                        .shadow(color: Color("Button_red").opacity(0.35), radius: 8, x: 0, y: 4)
                )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 22)
        }
        .background(
            Color.white
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: -4)
                .ignoresSafeArea(edges: .bottom)
        )
    }
    
    // MARK: - Empty Cart View
    
    private var emptyCartView: some View {
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

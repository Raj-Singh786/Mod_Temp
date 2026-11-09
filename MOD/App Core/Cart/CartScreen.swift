//
//  CartScreen.swift
//  MOD
//
//  Created by Rajpal singh on 07/11/26.
//

import SwiftUI

struct CartScreen: View {
    @Environment(\.presentationMode) private var presentationMode
    
    // MARK: - Cart State
    @State private var cartItems: [CartItem] = [
        CartItem(
            name: "Pepperoni & Cream",
            subtitle: "Medium (6 slices)",
            price: 17.90,
            quantity: 1,
            imageName: "pizza2",
            customizations: [
                CartCustomization(text: "Extra Bacon", isPositive: true),
                CartCustomization(text: "No Onions", isPositive: false)
            ]
        ),
        CartItem(
            name: "Pepperoni Breadstic",
            subtitle: "8 pieces",
            price: 6.99,
            quantity: 1,
            imageName: "pizza1",
            customizations: [
                CartCustomization(text: "Add Marinara Sauce", isPositive: true)
            ]
        ),
        CartItem(
            name: "Coca-Cola Can",
            subtitle: "12 fl oz (355ml) • Chilled",
            price: 2.49,
            quantity: 1,
            imageName: "coke",
            customizations: []
        )
    ]
    
    // Order Type (read from UserDefaults; defaults to .delivery)
    @State var orderType: CartOrderType = .delivery
    @State private var designatedVehicle: String = "White Honda Civic • CA 8XYZ123"
    @State private var curbsideBay: String = "Curbside (Bay #1– 4)"
    @State private var showVehicleEditSheet: Bool = false
    @State private var showTimeOptionsSheet: Bool = false

    @State private var appliedCoupon: String? = nil
    @State private var scheduledTime: String = "Today, Oct 24 • 5:30 PM"
    @State private var showClearAlert: Bool = false
    @State private var showCouponAlert: Bool = false
    @State private var couponAlertMsg: String = ""

    // Calculations
    private var subtotal: Double {
        cartItems.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }
    
    private var discount: Double {
        if appliedCoupon == "MOD 50" {
            return min(subtotal * 0.5, 10.0)
        }
        return 0.0
    }
    
    private var deliveryFee: Double {
        if orderType == .pickup { return 0.0 }
        return cartItems.isEmpty ? 0.0 : 2.99
    }
    
    private var grandTotal: Double {
        max(subtotal - discount + deliveryFee, 0.0)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    
                    // 1. Navigation Header
                    HStack {
                     
                        
                        Spacer()
                        Spacer()
                        
                        VStack(spacing: 2) {
                            Text("My Cart")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                            Text("\(cartItems.reduce(0, { $0 + $1.quantity })) delicious items")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        // Clear Cart Button
                        Button(action: { showClearAlert = true }) {
                            Text("Clear")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.red)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .background(Color.red.opacity(0.08))
                                .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)

                    // 2. Fulfillment Details (Adjusted per Order Type: Pickup vs Delivery)
                    VStack(alignment: .leading, spacing: 12) {
                        // Location Header Row (Pickup at / Delivery to)
                        HStack {
                            HStack(spacing: 6) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.system(size: 15))
                                    .foregroundColor(.red)
                                Text(orderType == .pickup ? "Pickup at" : "Delivery to")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                                Text("Downtown Hut")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.black)
                            }
                            
                            Spacer()
                            
                            Text("Standard")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Color(red: 0.12, green: 0.65, blue: 0.38))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color(red: 0.90, green: 0.98, blue: 0.94))
                                .cornerRadius(12)
                        }
                        
                        // Scheduled Time Container (Snap design)
                        HStack {
                            HStack(spacing: 10) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.red.opacity(0.08))
                                        .frame(width: 32, height: 32)
                                    Image(systemName: "calendar")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.red)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("SCHEDULED TIME")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.gray)
                                    Text(scheduledTime)
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.black)
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: { showTimeOptionsSheet = true }) {
                                Text("Change")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(12)
                        .background(Color.white)
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.gray.opacity(0.12), lineWidth: 1)
                        )

                        // Pickup Details Card (Snap-based UI for Pickup)
                        if orderType == .pickup {
                            pickupLocationCard
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    .padding(.horizontal, 16)

                    // 3. Cart Items List
                    if cartItems.isEmpty {
                        EmptyCartView()
                            .padding(.vertical, 30)
                    } else {
                        VStack(spacing: 14) {
                            ForEach(cartItems) { item in
                                if let index = cartItems.firstIndex(where: { $0.id == item.id }) {
                                    CartItemCard(
                                        item: $cartItems[index],
                                        onDelete: {
                                            withAnimation {
                                                cartItems.removeAll { $0.id == item.id }
                                            }
                                        }
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }

                    // 4. Coupons & Offers Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            HStack(spacing: 6) {
                                Image(systemName: "tag.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.red)
                                VStack(alignment: .leading, spacing: 1) {
                                    Text("Coupons & Offers")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(.black)
                                    Text("Save extra on your feast")
                                        .font(.system(size: 11))
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: {}) {
                                HStack(spacing: 2) {
                                    Text("View all")
                                        .font(.system(size: 13, weight: .semibold))
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 10, weight: .semibold))
                                }
                                .foregroundColor(.red)
                            }
                        }
                        .padding(.horizontal, 16)

                        // Coupons Horizontal Carousel
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                CouponCard(
                                    code: "MOD 50",
                                    title: "50% OFF up to $10",
                                    subtitle: "Valid on orders above $25",
                                    isCodePink: true,
                                    isApplied: appliedCoupon == "MOD 50",
                                    onApply: {
                                        withAnimation {
                                            if appliedCoupon == "MOD 50" {
                                                appliedCoupon = nil
                                            } else {
                                                appliedCoupon = "MOD 50"
                                                couponAlertMsg = "50% discount applied! You saved $\(String(format: "%.2f", discount))."
                                                showCouponAlert = true
                                            }
                                        }
                                    }
                                )

                                CouponCard(
                                    code: "FEASTFREE",
                                    title: "FREE CHEESY BREAD",
                                    subtitle: "On orders above $30",
                                    isCodePink: false,
                                    isApplied: appliedCoupon == "FEASTFREE",
                                    onApply: {
                                        withAnimation {
                                            if appliedCoupon == "FEASTFREE" {
                                                appliedCoupon = nil
                                            } else {
                                                appliedCoupon = "FEASTFREE"
                                                couponAlertMsg = "Free Cheesy Bread added to your rewards!"
                                                showCouponAlert = true
                                            }
                                        }
                                    }
                                )
                            }
                            .padding(.horizontal, 16)
                        }
                    }

                    // 5. You Might Also Like Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("You Might Also Like")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.black)
                                Text("Add to your order with one tap")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Button(action: {}) {
                                HStack(spacing: 2) {
                                    Text("View menu")
                                        .font(.system(size: 13, weight: .semibold))
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 10, weight: .semibold))
                                }
                                .foregroundColor(.red)
                            }
                        }
                        .padding(.horizontal, 16)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                UpsellCard(
                                    title: "Pepperoni",
                                    subtitle: "Classic crispy...",
                                    price: "$16.99",
                                    badge: "POPULAR",
                                    badgeColor: Color(red: 0.96, green: 0.65, blue: 0.12),
                                    imageName: "pizza1",
                                    onAdd: {
                                        addItem(name: "Pepperoni Pizza", price: 16.99, image: "pizza1")
                                    }
                                )

                                UpsellCard(
                                    title: "Pepperoni Swirl",
                                    subtitle: "Cream cheese...",
                                    price: "$17.99",
                                    badge: "SPECIAL",
                                    badgeColor: Color.red,
                                    imageName: "pizza2",
                                    onAdd: {
                                        addItem(name: "Pepperoni Swirl", price: 17.99, image: "pizza2")
                                    }
                                )

                                UpsellCard(
                                    title: "Smoked Sausage",
                                    subtitle: "Onions & olives...",
                                    price: "$17.99",
                                    badge: nil,
                                    badgeColor: nil,
                                    imageName: "pizza3",
                                    onAdd: {
                                        addItem(name: "Smoked Sausage", price: 17.99, image: "pizza3")
                                    }
                                )
                            }
                            .padding(.horizontal, 16)
                        }
                    }

                    // 6. Bill Details Summary Box
                    VStack(spacing: 8) {
                        BillRow(title: "Items Subtotal", amount: subtotal)
                        if discount > 0 {
                            HStack {
                                Text("Coupon Discount (MOD 50)")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(red: 0.12, green: 0.65, blue: 0.38))
                                Spacer()
                                Text("-$\(String(format: "%.2f", discount))")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(Color(red: 0.12, green: 0.65, blue: 0.38))
                            }
                        }
                        if orderType == .delivery {
                            BillRow(title: "Delivery Fee", amount: deliveryFee)
                        } else {
                            HStack {
                                Text("Pickup Fee")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("FREE")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(Color(red: 0.12, green: 0.65, blue: 0.38))
                            }
                        }
                        
                        Divider().padding(.vertical, 4)
                        
                        HStack {
                            Text("Total to Pay")
                                .font(.system(size: 15, weight: .heavy))
                                .foregroundColor(.black)
                            Spacer()
                            Text("$\(String(format: "%.2f", grandTotal))")
                                .font(.system(size: 17, weight: .heavy))
                                .foregroundColor(.red)
                        }
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(16)
                    .padding(.horizontal, 16)

                    // Bottom spacing so content isn't cut off by floating bar
                    Color.clear.frame(height: 80)
                }
                .padding(.vertical, 10)
            }

            // MARK: - Bottom Floating Checkout Button
            VStack {
                Button(action: handleCheckout) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("$\(String(format: "%.2f", grandTotal))")
                                .font(.system(size: 16, weight: .heavy))
                            Text("TOTAL (INCL. TAXES)")
                                .font(.system(size: 10, weight: .bold))
                                .opacity(0.85)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 6) {
                            Text(orderType == .pickup ? "Proceed to Pickup" : "Proceed to Checkout")
                                .font(.system(size: 15, weight: .bold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .bold))
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .frame(height: 54)
                    .background(Color.red)
                    .cornerRadius(16)
                    .shadow(color: Color.red.opacity(0.35), radius: 10, x: 0, y: 5)
                }
                .disabled(cartItems.isEmpty)
                .opacity(cartItems.isEmpty ? 0.6 : 1.0)
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.white.opacity(0.0), Color.white.opacity(0.95), Color.white]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 85)
                .allowsHitTesting(false)
            )
        }
        .background(Color(red: 0.98, green: 0.98, blue: 0.99))
        .navigationBarHidden(true)
        .alert(isPresented: $showClearAlert) {
            Alert(
                title: Text("Clear Cart"),
                message: Text("Are you sure you want to remove all items from your cart?"),
                primaryButton: .destructive(Text("Clear")) {
                    withAnimation {
                        cartItems.removeAll()
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .alert(isPresented: $showCouponAlert) {
            Alert(title: Text("Coupon Applied"), message: Text(couponAlertMsg), dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $showVehicleEditSheet) {
            VehicleEditSheet(vehicle: $designatedVehicle, bay: $curbsideBay)
        }
        .sheet(isPresented: $showTimeOptionsSheet) {
            TimePickerSheet(selectedTime: $scheduledTime)
        }
        .onAppear {
            loadOrderTypeFromDefaults()
        }
        .onReceive(NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)) { _ in
            loadOrderTypeFromDefaults()
        }
    }

    // MARK: - Pickup Location Details Card (Snap Design)

    private var pickupLocationCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            // 1. Store Info Row
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 1.0, green: 0.90, blue: 0.90))
                        .frame(width: 44, height: 44)

                    Image(systemName: "storefront.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color(red: 0.78, green: 0.08, blue: 0.18))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Pickup Location")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.48))

                    Text("Downtown Hut #1204")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.black)

                    Text("452 Market St, San Francisco, CA (0.8 mi away)")
                        .font(.system(size: 13))
                        .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.48))
                        .lineLimit(2)

                    // Curbside Badge
                    HStack(spacing: 6) {
                        Image(systemName: "car.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color(red: 0.78, green: 0.08, blue: 0.18))

                        Text(curbsideBay)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color(red: 0.78, green: 0.08, blue: 0.18))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(red: 0.99, green: 0.92, blue: 0.93))
                    .cornerRadius(12)
                    .padding(.top, 4)
                }
            }

            Divider()
                .padding(.vertical, 2)

            // 2. Estimated Ready Row
            HStack(alignment: .center, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(red: 0.90, green: 0.96, blue: 0.93))
                        .frame(width: 36, height: 36)

                    Image(systemName: "timer")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color(red: 0.12, green: 0.55, blue: 0.35))
                }

                Group {
                    Text("Estimated Ready: ")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.black)
                    + Text("10–15 min (ASAP) • Kitchen on Normal Capacity.")
                        .font(.system(size: 13))
                        .foregroundColor(Color(red: 0.38, green: 0.38, blue: 0.42))
                }
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            }

            // 3. Designated Vehicle Box
            HStack(spacing: 12) {
                Image(systemName: "car.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color(red: 0.78, green: 0.08, blue: 0.18))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Designated Vehicle")
                        .font(.system(size: 11.5, weight: .bold))
                        .foregroundColor(Color(red: 0.78, green: 0.08, blue: 0.18))

                    Text(designatedVehicle)
                        .font(.system(size: 13.5, weight: .bold))
                        .foregroundColor(.black)
                }

                Spacer()

                Button(action: {
                    showVehicleEditSheet = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil")
                            .font(.system(size: 11, weight: .bold))
                        Text("Edit")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(Color(red: 0.78, green: 0.08, blue: 0.18))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Color(red: 0.97, green: 0.88, blue: 0.90))
                    .cornerRadius(10)
                }
            }
            .padding(12)
            .background(Color(red: 0.99, green: 0.96, blue: 0.97))
            .cornerRadius(14)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.gray.opacity(0.12), lineWidth: 1)
        )
    }

    // MARK: - Actions

    private func loadOrderTypeFromDefaults() {
        let saved = UserDefaults.standard.string(forKey: "selectedOrderType")
        withAnimation(.easeInOut(duration: 0.2)) {
            if saved == "pickup" {
                orderType = .pickup
            } else {
                orderType = .delivery
            }
        }
    }

    private func addItem(name: String, price: Double, image: String) {
        withAnimation {
            if let index = cartItems.firstIndex(where: { $0.name == name }) {
                cartItems[index].quantity += 1
            } else {
                cartItems.append(
                    CartItem(
                        name: name,
                        subtitle: "Standard Size",
                        price: price,
                        quantity: 1,
                        imageName: image,
                        customizations: []
                    )
                )
            }
        }
    }

    private func handleCheckout() {
        // Handle checkout action
    }
}

// MARK: - Cart Item Card Component

struct CartItemCard: View {
    @Binding var item: CartItem
    let onDelete: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                // Item Image
                if let _ = UIImage(named: item.imageName) {
                    Image(item.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 82, height: 82)
                        .cornerRadius(14)
                        .clipped()
                } else {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.gray.opacity(0.15))
                        .frame(width: 82, height: 82)
                }

                // Item Details
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .top) {
                        Text(item.name)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.black)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text("$\(String(format: "%.2f", item.price))")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.red)
                    }

                    Text(item.subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)

                    // Customization Pills
                    if !item.customizations.isEmpty {
                        HStack(spacing: 6) {
                            ForEach(item.customizations, id: \.text) { custom in
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(custom.isPositive ? Color(red: 0.12, green: 0.65, blue: 0.38) : Color.red.opacity(0.8))
                                        .frame(width: 5, height: 5)
                                    Text(custom.text)
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(custom.isPositive ? Color(red: 0.12, green: 0.55, blue: 0.35) : Color.gray)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(custom.isPositive ? Color(red: 0.90, green: 0.98, blue: 0.94) : Color(red: 0.95, green: 0.95, blue: 0.97))
                                .cornerRadius(8)
                            }
                        }
                        .padding(.top, 2)
                    }
                }
            }

            // Edit Item & Stepper Control Row
            HStack {
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil")
                            .font(.system(size: 11, weight: .semibold))
                        Text("Edit item")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(.red)
                }

                Spacer()

                // Stepper Pill (Trash/Minus, Count, Plus)
                HStack(spacing: 12) {
                    Button(action: {
                        if item.quantity > 1 {
                            item.quantity -= 1
                        } else {
                            onDelete()
                        }
                    }) {
                        Image(systemName: item.quantity == 1 ? "trash" : "minus")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.red)
                    }

                    Text("\(item.quantity)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.black)
                        .frame(minWidth: 16)

                    Button(action: {
                        item.quantity += 1
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            }
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
    }
}

// MARK: - Coupon Card Component

struct CouponCard: View {
    let code: String
    let title: String
    let subtitle: String
    let isCodePink: Bool
    let isApplied: Bool
    let onApply: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header: Code Badge + Apply Button
            HStack {
                HStack(spacing: 6) {
                    Text(code)
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundColor(isCodePink ? .red : Color(red: 0.12, green: 0.62, blue: 0.38))
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(isCodePink ? Color.red.opacity(0.08) : Color(red: 0.90, green: 0.98, blue: 0.94))
                .cornerRadius(6)

                Spacer()

                Button(action: onApply) {
                    Text(isApplied ? "APPLIED" : "APPLY")
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundColor(isApplied ? Color.green : Color.red)
                }
            }

            // Dashed Divider
            Line()
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
                .frame(height: 1)
                .foregroundColor(Color.gray.opacity(0.25))
                .padding(.vertical, 2)

            // Content
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.black)
                .lineLimit(1)

            Text(subtitle)
                .font(.system(size: 11))
                .foregroundColor(.gray)
                .lineLimit(1)
        }
        .padding(12)
        .frame(width: 220)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isApplied ? Color.green.opacity(0.5) : Color.gray.opacity(0.12), lineWidth: 1)
        )
    }
}

// MARK: - Upsell Card Component

struct UpsellCard: View {
    let title: String
    let subtitle: String
    let price: String
    let badge: String?
    let badgeColor: Color?
    let imageName: String
    let onAdd: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .topLeading) {
                if let _ = UIImage(named: imageName) {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 100)
                        .cornerRadius(12)
                        .clipped()
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.15))
                        .frame(width: 120, height: 100)
                }

                if let badge = badge, let color = badgeColor {
                    Text(badge)
                        .font(.system(size: 9, weight: .heavy))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(color)
                        .cornerRadius(5)
                        .padding(5)
                }
            }
            .frame(width: 120, height: 100)

            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.black)
                .lineLimit(1)

            Text(subtitle)
                .font(.system(size: 11))
                .foregroundColor(.gray)
                .lineLimit(1)

            HStack {
                Text(price)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.red)
                Spacer()
                Button(action: onAdd) {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 24, height: 24)
                        .background(Color.red)
                        .clipShape(Circle())
                }
            }
        }
        .padding(10)
        .frame(width: 140)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Helpers & Shapes

struct BillRow: View {
    let title: String
    let amount: Double

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(.gray)
            Spacer()
            Text("$\(String(format: "%.2f", amount))")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.black)
        }
    }
}

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}

struct EmptyCartView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "cart")
                .font(.system(size: 44))
                .foregroundColor(.gray.opacity(0.5))
            Text("Your Cart is Empty")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.black)
            Text("Explore our delicious menu and add your favorite pizzas!")
                .font(.system(size: 13))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Data Models

struct CartItem: Identifiable {
    let id = UUID()
    let name: String
    let subtitle: String
    let price: Double
    var quantity: Int
    let imageName: String
    var customizations: [CartCustomization]
}

struct CartCustomization {
    let text: String
    let isPositive: Bool
}

enum CartOrderType: String, CaseIterable, Identifiable {
    case pickup = "Pickup"
    case delivery = "Delivery"

    var id: String { rawValue }
}

// MARK: - Vehicle Edit Sheet

struct VehicleEditSheet: View {
    @Environment(\.presentationMode) private var presentationMode
    @Binding var vehicle: String
    @Binding var bay: String

    @State private var tempVehicle: String = ""
    @State private var tempBay: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Designated Vehicle Details")) {
                    TextField("e.g. White Honda Civic • CA 8XYZ123", text: $tempVehicle)
                }

                Section(header: Text("Curbside Bay / Instructions")) {
                    TextField("e.g. Curbside (Bay #1– 4)", text: $tempBay)
                }
            }
            .navigationTitle("Designated Vehicle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        vehicle = tempVehicle
                        bay = tempBay
                        presentationMode.wrappedValue.dismiss()
                    }
                    .font(.headline)
                    .foregroundColor(.red)
                }
            }
            .onAppear {
                tempVehicle = vehicle
                tempBay = bay
            }
        }
    }
}

// MARK: - Time Picker Sheet

struct TimePickerSheet: View {
    @Environment(\.presentationMode) private var presentationMode
    @Binding var selectedTime: String

    let timeSlots = [
        "Today, Oct 24 • 5:30 PM",
        "Today, Oct 24 • 6:00 PM",
        "Today, Oct 24 • 6:30 PM",
        "Today, Oct 24 • 7:00 PM",
        "Tomorrow, Oct 25 • 12:30 PM"
    ]

    var body: some View {
        NavigationView {
            List(timeSlots, id: \.self) { slot in
                Button(action: {
                    selectedTime = slot
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Text(slot)
                            .font(.system(size: 15, weight: selectedTime == slot ? .bold : .regular))
                            .foregroundColor(.black)
                        Spacer()
                        if selectedTime == slot {
                            Image(systemName: "checkmark")
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Scheduled Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        CartScreen()
    }
}

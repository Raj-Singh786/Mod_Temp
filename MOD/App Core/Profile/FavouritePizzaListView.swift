//
//  FavouritePizzaListView.swift
//  MOD
//
//  Created by Rajpal singh on 18/11/26.
//

import SwiftUI

// MARK: - Typealiases for Flexible Naming

typealias FavoritePizzaListView = FavouritePizzaListView
typealias FavoritesPizzaListView = FavouritePizzaListView

// MARK: - Models

struct SavedCustomPizzaItem: Identifiable, Hashable {
    let id: String
    var title: String
    var toppingsDescription: String
    var price: Double
    var locationName: String
    
    var formattedPriceAndLocation: String {
        String(format: "$%.2f at %@", price, locationName)
    }
}

struct FavoriteMenuItem: Identifiable, Hashable {
    let id: String
    var title: String
    var description: String
    var isVeg: Bool
    var calories: Int
    var price: Double
    var isFanFavorite: Bool
    var imageName: String
    var isFavorited: Bool
    
    var formattedPrice: String {
        String(format: "$%.2f", price)
    }
}

// MARK: - Custom Pizza Graphic Badge View

struct CustomPizzaGraphicBadgeView: View {
    var size: CGFloat = 88
    
    var body: some View {
        ZStack {
            // 1. Crust Layer
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0xDF / 255.0, green: 0xAD / 255.0, blue: 0x73 / 255.0),
                            Color(red: 0xC8 / 255.0, green: 0x93 / 255.0, blue: 0x59 / 255.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
                .shadow(color: Color.black.opacity(0.12), radius: 3, x: 0, y: 2)
            
            // 2. Cheese & Buffalo Sauce Base
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0xF7 / 255.0, green: 0xD3 / 255.0, blue: 0x9E / 255.0),
                            Color(red: 0xEA / 255.0, green: 0xBA / 255.0, blue: 0x7E / 255.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size * 0.82, height: size * 0.82)
            
            // 3. Toppings (Pepperoni, Jalapeños, Red Onion, Cheese Dollops)
            Group {
                // Pepperoni Discs
                pepperoniDot(x: -16, y: -14)
                pepperoniDot(x: 14, y: -18)
                pepperoniDot(x: -20, y: 12)
                pepperoniDot(x: 10, y: 16)
                pepperoniDot(x: -2, y: 0)
                pepperoniDot(x: 20, y: 0)
                pepperoniDot(x: -6, y: -20)
                
                // Jalapeño Rings (Right half + scattered)
                jalapenoRing(x: 8, y: -8)
                jalapenoRing(x: 18, y: 12)
                jalapenoRing(x: 22, y: -12)
                jalapenoRing(x: 2, y: 18)
                
                // Red Onion Rings
                redOnionRing(x: -10, y: 8)
                redOnionRing(x: 12, y: -2)
                redOnionRing(x: -12, y: -6)
                
                // Cheese Dollops
                cheeseDollop(x: -4, y: 12)
                cheeseDollop(x: -18, y: -4)
                cheeseDollop(x: 4, y: -14)
            }
        }
        .frame(width: size, height: size)
    }
    
    private func pepperoniDot(x: CGFloat, y: CGFloat) -> some View {
        Circle()
            .fill(Color(red: 0x9B / 255.0, green: 0x24 / 255.0, blue: 0x22 / 255.0))
            .frame(width: size * 0.12, height: size * 0.12)
            .offset(x: x * (size / 88.0), y: y * (size / 88.0))
    }
    
    private func jalapenoRing(x: CGFloat, y: CGFloat) -> some View {
        Circle()
            .stroke(Color(red: 0x3E / 255.0, green: 0x76 / 255.0, blue: 0x38 / 255.0), lineWidth: 2)
            .background(Circle().fill(Color(red: 0x5D / 255.0, green: 0x9B / 255.0, blue: 0x52 / 255.0)))
            .frame(width: size * 0.11, height: size * 0.11)
            .offset(x: x * (size / 88.0), y: y * (size / 88.0))
    }
    
    private func redOnionRing(x: CGFloat, y: CGFloat) -> some View {
        Circle()
            .stroke(Color(red: 0x8C / 255.0, green: 0x2B / 255.0, blue: 0x62 / 255.0), lineWidth: 1.5)
            .frame(width: size * 0.13, height: size * 0.13)
            .offset(x: x * (size / 88.0), y: y * (size / 88.0))
    }
    
    private func cheeseDollop(x: CGFloat, y: CGFloat) -> some View {
        Circle()
            .fill(Color.white.opacity(0.85))
            .frame(width: size * 0.08, height: size * 0.08)
            .offset(x: x * (size / 88.0), y: y * (size / 88.0))
    }
}

// MARK: - FavouritePizzaListView

struct FavouritePizzaListView: View {
    
    // MARK: - Configuration & Callbacks
    
    var showHeader: Bool = true
    var onBack: (() -> Void)? = nil
    var onCartTap: (() -> Void)? = nil
    var onStarTap: (() -> Void)? = nil
    var onBuildNewPizza: (() -> Void)? = nil
    var onCustomizeItem: ((FavoriteMenuItem) -> Void)? = nil
    
    // MARK: - State
    
    @State private var savedPizzas: [SavedCustomPizzaItem] = [
        SavedCustomPizzaItem(
            id: "sp-1",
            title: "FRIDAY NIGHT SPICY",
            toppingsDescription: "Sauce: Frank's Buffalo · Add Pepperoni (Extra) · Add Jalapeños (Right 1/2) · Add Red onion (Light)",
            price: 11.99,
            locationName: "Capitol Hill"
        )
    ]
    
    @State private var favoriteMenuItems: [FavoriteMenuItem] = [
        FavoriteMenuItem(
            id: "fm-1",
            title: "CARNIVORE",
            description: "Tomato sauce, mozzarella, parmesan, pepperoni, Italian sausage, ground be...",
            isVeg: false,
            calories: 1121,
            price: 13.99,
            isFanFavorite: false,
            imageName: "PizzaOn",
            isFavorited: true
        ),
        FavoriteMenuItem(
            id: "fm-2",
            title: "NO NAME CAKE",
            description: "Chocolate cake with a vanilla buttercream center and chocolate...",
            isVeg: true,
            calories: 290,
            price: 3.99,
            isFanFavorite: true,
            imageName: "Desert",
            isFavorited: true
        )
    ]
    
    // Alerts
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    
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
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
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
        }
    }
    
    // MARK: - 0. Custom Top Navigation Bar (Snapshot media_1794983248738_be077330.jpg)
    
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
            Text("Favorites")
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
        VStack(alignment: .leading, spacing: 20) {
            // Main Screen Header: FAVORITES & SAVED PIZZAS
            headerSection
            
            // Section 1: SAVED PIZZAS
            savedPizzasSection
            
            // Section 2: FAVORITE MENU ITEMS
            favoriteMenuItemsSection
        }
    }
    
    // MARK: - 1. Header Section
    
    private var headerSection: some View {
        Text("FAVORITES & SAVED PIZZAS")
            .font(.oswaldMedium(size: 32))
            .tracking(0.8)
            .foregroundColor(Color("app_black"))
            .padding(.top, 4)
    }
    
    // MARK: - 2. Section 1: SAVED PIZZAS
    
    private var savedPizzasSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header: SAVED PIZZAS & Build a new one
            HStack(alignment: .firstTextBaseline) {
                Text("SAVED PIZZAS")
                    .font(.oswaldMedium(size: 20))
                    .tracking(0.6)
                    .foregroundColor(Color("app_black"))
                
                Spacer()
                
                Button(action: {
                    if let onBuildNewPizza = onBuildNewPizza {
                        onBuildNewPizza()
                    } else if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                              let rootNav = windowScene.windows.first?.rootViewController as? UINavigationController,
                              let tabVC = rootNav.viewControllers.first as? UITabBarController {
                        tabVC.selectedIndex = 1
                    }
                }) {
                    Text("Build a new one")
                        .font(.barlowSemiBold(size: 13.5))
                        .foregroundColor(Color("Button_red"))
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Saved Pizzas Cards List
            if savedPizzas.isEmpty {
                VStack(spacing: 8) {
                    Text("No saved pizzas yet")
                        .font(.barlowBold(size: 15))
                        .foregroundColor(Color("app_black"))
                    
                    Text("Customize your dream pizza on the Menu tab and tap 'Save Pizza' to order it again quickly.")
                        .font(.barlowRegular(size: 13))
                        .foregroundColor(Color("text_gary"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(24)
                .frame(maxWidth: .infinity)
                .background(whiteCardBackground)
            } else {
                ForEach(savedPizzas) { pizza in
                    savedPizzaCard(pizza)
                }
            }
        }
    }
    
    private func savedPizzaCard(_ pizza: SavedCustomPizzaItem) -> some View {
        HStack(alignment: .top, spacing: 14) {
            // Left: Custom Pizza Graphic Badge
            CustomPizzaGraphicBadgeView(size: 88)
                .padding(.top, 2)
            
            // Right: Info & Actions
            VStack(alignment: .leading, spacing: 6) {
                // Title
                Text(pizza.title)
                    .font(.oswaldMedium(size: 17))
                    .tracking(0.5)
                    .foregroundColor(Color("app_black"))
                
                // Toppings description
                Text(pizza.toppingsDescription)
                    .font(.barlowRegular(size: 12.5))
                    .foregroundColor(Color("text_gary"))
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Price & Location
                HStack(spacing: 4) {
                    Text(String(format: "$%.2f", pizza.price))
                        .font(.barlowBold(size: 13.5))
                        .foregroundColor(Color("app_black"))
                    
                    Text("at \(pizza.locationName)")
                        .font(.barlowRegular(size: 13))
                        .foregroundColor(Color("text_gary"))
                }
                .padding(.top, 1)
                
                // Actions Row: USE & REMOVE
                HStack(spacing: 12) {
                    // USE Button
                    Button(action: {
                        CartManager.shared.addItem(
                            title: pizza.title,
                            price: pizza.price,
                            quantity: 1,
                            details: pizza.toppingsDescription,
                            calories: 980,
                            imageName: "PizzaOn"
                        )
                        alertTitle = "Added to Cart"
                        alertMessage = "'\(pizza.title)' has been added to your order."
                        showAlert = true
                    }) {
                        Text("USE")
                            .font(.oswaldMedium(size: 13))
                            .tracking(0.8)
                            .foregroundColor(.white)
                            .padding(.horizontal, 18)
                            .frame(height: 34)
                            .background(
                                Capsule()
                                    .fill(Color(red: 0x8C / 255.0, green: 0x1E / 255.0, blue: 0x2A / 255.0))
                                    .shadow(color: Color(red: 0x8C / 255.0, green: 0x1E / 255.0, blue: 0x2A / 255.0).opacity(0.35), radius: 4, x: 0, y: 2)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // REMOVE Button
                    Button(action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            savedPizzas.removeAll(where: { $0.id == pizza.id })
                        }
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: "trash")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(Color("Button_red"))
                            
                            Text("REMOVE")
                                .font(.oswaldMedium(size: 13))
                                .tracking(0.6)
                                .foregroundColor(Color("Button_red"))
                        }
                        .padding(.horizontal, 8)
                        .frame(height: 34)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.top, 4)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(whiteCardBackground)
    }
    
    // MARK: - 3. Section 2: FAVORITE MENU ITEMS
    
    private var favoriteMenuItemsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Section Header
            Text("FAVORITE MENU ITEMS")
                .font(.oswaldMedium(size: 20))
                .tracking(0.6)
                .foregroundColor(Color("app_black"))
            
            // Menu Cards List
            ForEach(favoriteMenuItems) { item in
                favoriteMenuItemCard(item)
            }
        }
    }
    
    private func favoriteMenuItemCard(_ item: FavoriteMenuItem) -> some View {
        HStack(spacing: 0) {
            // Left: Tan Background with Product Image & Optional Badge
            ZStack(alignment: .topLeading) {
                // Background
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(red: 0xF5 / 255.0, green: 0xEE / 255.0, blue: 0xE3 / 255.0))
                
                // Centered Image
                Image(item.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 88, height: 88)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Optional "Fan favorite" badge
                if item.isFanFavorite {
                    Text("Fan favorite")
                        .font(.barlowBold(size: 10.5))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Color("Button_red")))
                        .padding(8)
                }
            }
            .frame(width: 114)
            .clipped()
            
            // Right: Item Information & Customize Action
            VStack(alignment: .leading, spacing: 6) {
                // Top Title & Heart Row
                HStack(alignment: .top) {
                    Text(item.title)
                        .font(.oswaldMedium(size: 17))
                        .tracking(0.5)
                        .foregroundColor(Color("app_black"))
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // Heart Button
                    Button(action: {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                            if let idx = favoriteMenuItems.firstIndex(where: { $0.id == item.id }) {
                                favoriteMenuItems[idx].isFavorited.toggle()
                            }
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color(red: 0xFD / 255.0, green: 0xEE / 255.0, blue: 0xF0 / 255.0))
                                .frame(width: 28, height: 28)
                            
                            Image(systemName: item.isFavorited ? "heart.fill" : "heart")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color("Button_red"))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Description
                Text(item.description)
                    .font(.barlowRegular(size: 12.5))
                    .foregroundColor(Color("text_gary"))
                    .lineLimit(2)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Diet Badge & Calories
                HStack(spacing: 8) {
                    if item.isVeg {
                        // Veg Badge (Green)
                        HStack(spacing: 4) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 3)
                                    .stroke(Color(red: 0x3E / 255.0, green: 0x76 / 255.0, blue: 0x3B / 255.0), lineWidth: 1.2)
                                    .frame(width: 13, height: 13)
                                
                                Circle()
                                    .fill(Color(red: 0x3E / 255.0, green: 0x76 / 255.0, blue: 0x3B / 255.0))
                                    .frame(width: 5, height: 5)
                            }
                            
                            Text("Veg")
                                .font(.barlowBold(size: 11))
                                .foregroundColor(Color(red: 0x3E / 255.0, green: 0x76 / 255.0, blue: 0x3B / 255.0))
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color(red: 0x3E / 255.0, green: 0x76 / 255.0, blue: 0x3B / 255.0).opacity(0.35), lineWidth: 1)
                        )
                    } else {
                        // Non-veg Badge (Red)
                        HStack(spacing: 4) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 3)
                                    .stroke(Color("Button_red"), lineWidth: 1.2)
                                    .frame(width: 13, height: 13)
                                
                                Image(systemName: "triangle.fill")
                                    .font(.system(size: 5, weight: .bold))
                                    .foregroundColor(Color("Button_red"))
                            }
                            
                            Text("Non-veg")
                                .font(.barlowBold(size: 11))
                                .foregroundColor(Color("Button_red"))
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color("Button_red").opacity(0.35), lineWidth: 1)
                        )
                    }
                    
                    Text("\(item.calories) cal")
                        .font(.barlowRegular(size: 12))
                        .foregroundColor(Color("text_gary"))
                }
                .padding(.top, 1)
                
                // Price & CUSTOMIZE Button
                HStack(alignment: .center) {
                    Text(item.formattedPrice)
                        .font(.oswaldBold(size: 18))
                        .foregroundColor(Color("app_black"))
                    
                    Spacer()
                    
                    Button(action: {
                        if let onCustomizeItem = onCustomizeItem {
                            onCustomizeItem(item)
                        } else {
                            CartManager.shared.addItem(
                                title: item.title,
                                price: item.price,
                                quantity: 1,
                                details: item.description,
                                calories: item.calories,
                                imageName: item.imageName
                            )
                            alertTitle = "Added to Cart"
                            alertMessage = "'\(item.title)' has been added to your order."
                            showAlert = true
                        }
                    }) {
                        Text("CUSTOMIZE")
                            .font(.oswaldMedium(size: 13))
                            .tracking(0.8)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .frame(height: 34)
                            .background(
                                Capsule()
                                    .fill(Color(red: 0x8C / 255.0, green: 0x1E / 255.0, blue: 0x2A / 255.0))
                                    .shadow(color: Color("Button_red").opacity(0.3), radius: 4, x: 0, y: 2)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.top, 4)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, minHeight: 128)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.2)
                )
                .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
    
    // MARK: - Helper Styling
    
    private var whiteCardBackground: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.2)
            )
            .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }
}

// MARK: - SwiftUI Preview

struct FavouritePizzaListView_Previews: PreviewProvider {
    static var previews: some View {
        FavouritePizzaListView(showHeader: true)
    }
}

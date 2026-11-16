//
//  HomeView.swift
//  MOD
//
//  Created by Rajpal singh on 16/11/26.
//

import SwiftUI

// MARK: - Models

struct HomeCategoryItem: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
}

struct HomeMenuItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let price: String
    let imageName: String
    let tag: String?
    let isVeg: Bool
    let isVegan: Bool
    let calories: String
    let actionTitle: String
    var isFavorite: Bool = false
}

// MARK: - HomeView

struct HomeView: View {
    
    // MARK: - Properties
    
    var isGuest: Bool = true
    
    // MARK: - Callbacks
    
    var onProfileTap: (() -> Void)? = nil
    var onCartTap: (() -> Void)? = nil
    var onStartOrder: (() -> Void)? = nil
    var onBuildPizza: (() -> Void)? = nil
    var onSelectStore: (() -> Void)? = nil
    var onSelectTime: (() -> Void)? = nil
    var onCategorySelected: ((String) -> Void)? = nil
    var onFullMenuTap: (() -> Void)? = nil
    var onCustomizeItem: ((HomeMenuItem) -> Void)? = nil
    var onAddItem: ((HomeMenuItem) -> Void)? = nil
    var onSignIn: (() -> Void)? = nil
    var onJoinRewards: (() -> Void)? = nil
    var onClaimOffer: (() -> Void)? = nil
    
    // MARK: - State
    
    @State private var selectedOrderType: Int = 0 // 0: Pickup, 1: Delivery
    @State private var selectedStoreName: String = "Capitol Hill, Seattle"
    @State private var deliveryAddress: String = "Add a delivery address"
    @State private var selectedPickupOption: String = "In-store pickup"
    @State private var selectedWhenText: String = "ASAP unavailable"
    @State private var pickupWhenText: String = "ASAP · ~15 min"
    @State private var deliveryWhenText: String = "ASAP unavailable"
    @State private var isPickupScheduled: Bool = false
    @State private var isDeliveryScheduled: Bool = false
    @State private var showOrderSetup: Bool = false
    @State private var orderSetupInitialTab: Int = 0
    @State private var orderSetupAutoScrollToWhen: Bool = false
    @State private var favoritesState: [UUID: Bool] = [:]
    @State private var pizzaRotation: Double = 0
    
    // MARK: - Data
    
    private let categories: [HomeCategoryItem] = [
        HomeCategoryItem(name: "Pizzas", imageName: "per"),
        HomeCategoryItem(name: "Salads", imageName: "salad"),
        HomeCategoryItem(name: "Sides", imageName: "garlic_bread"),
        HomeCategoryItem(name: "Desserts", imageName: "Desert"),
        HomeCategoryItem(name: "Drinks", imageName: "free_drink")
    ]
    
    private let favoriteItems: [HomeMenuItem] = [
        HomeMenuItem(
            title: "OG PEPPERONI",
            description: "Tomato sauce, mozzarella, asiago and pepperoni.",
            price: "$10.99",
            imageName: "per",
            tag: "Popular",
            isVeg: false,
            isVegan: false,
            calories: "906 cal",
            actionTitle: "CUSTOMIZE"
        ),
        HomeMenuItem(
            title: "PERFECT PESTO",
            description: "Pesto, garlic rub, mozzarella, feta, artichokes, and fresh arugula.",
            price: "$13.99",
            imageName: "pesto",
            tag: "New",
            isVeg: true,
            isVegan: false,
            calories: "800 cal",
            actionTitle: "CUSTOMIZE"
        ),
        HomeMenuItem(
            title: "NO NAME CAKE",
            description: "Chocolate cake with vanilla buttercream center and chocolate glaze.",
            price: "$3.99",
            imageName: "Desert",
            tag: "Fan Favorite",
            isVeg: true,
            isVegan: false,
            calories: "760 cal",
            actionTitle: "+ ADD"
        ),
        HomeMenuItem(
            title: "HOUSE-MADE LEMONADE",
            description: "Fresh, lightly sweet lemonade.",
            price: "$2.99",
            imageName: "free_drink",
            tag: nil,
            isVeg: true,
            isVegan: true,
            calories: "150 cal",
            actionTitle: "+ ADD"
        )
    ]
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Background Color (app_background)
            Color("app_background")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Header Bar (compact, app_background color, centered icons)
                topHeaderBar
                
                // Scrollable Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Hero Banner Card
                        heroBannerCard
                        
                        // Order Mode & Store Selector Card
                        orderModeCard
                        
                        // "WHAT ARE YOU CRAVING?" Categories Section
                        categoriesSection
                        
                        // "FAVORITES IN YOUR AREA" Menu Section
                        favoritesSection
                        
                        // Sign In Rewards Teaser
                        signInTeaser
                        
                        // MOD REWARDS Banner Card
                        modRewardsCard
                        
                        // FEATURED OFFER Card
                        featuredOfferCard
                        
                        // Utility Quick Links
                        utilityLinksCard
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 2)
                    .padding(.bottom, 36)
                }
            }
        }
        // Hide the system navigation bar so it doesn't reserve blank space above the custom header
        .toolbar(.hidden, for: .navigationBar)   // iOS 16+
        .sheet(isPresented: $showOrderSetup) {
            OrderSetupView(
                initialOrderType: orderSetupInitialTab,
                autoScrollToWhen: orderSetupAutoScrollToWhen,
                currentStoreName: selectedStoreName,
                currentDeliveryAddress: deliveryAddress,
                currentPickupOption: selectedPickupOption,
                currentWhenText: orderSetupInitialTab == 0 ? (isPickupScheduled ? pickupWhenText : "ASAP · ~15 min") : (isDeliveryScheduled ? deliveryWhenText : "ASAP unavailable"),
                onDone: { newOrderType, newStoreName, newPickupOption, newAddress, newWhen in
                    selectedOrderType = newOrderType
                    selectedStoreName = newStoreName
                    selectedPickupOption = newPickupOption
                    deliveryAddress = newAddress
                    selectedWhenText = newWhen
                    
                    let isScheduled = !newWhen.lowercased().hasPrefix("asap")
                    if newOrderType == 0 {
                        pickupWhenText = newWhen
                        isPickupScheduled = isScheduled
                    } else {
                        deliveryWhenText = newWhen
                        isDeliveryScheduled = isScheduled
                    }
                    
                    showOrderSetup = false
                }
            )
        }
        .onAppear {
            withAnimation(.linear(duration: 35).repeatForever(autoreverses: false)) {
                pizzaRotation = 360
            }
        }
    }
    
    // MARK: - Top Header Bar
    
    private var topHeaderBar: some View {
        ZStack {
            // Left: MOD Shield Logo
            HStack {
                Image("app_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 38)
                    .accessibilityLabel("MOD Pizza Logo")
                Spacer()
            }
            
            // Center: Person and Cart icons in the exact middle of the screen
            HStack(spacing: 18) {
                // Profile Button
                Button(action: {
                    onProfileTap?()
                }) {
                    Image(systemName: "person")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(Color("app_black"))
                        .frame(width: 34, height: 34)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Shopping Cart Button
                Button(action: {
                    onCartTap?()
                }) {
                    Image(systemName: "cart")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(Color("Button_red"))
                        .frame(width: 34, height: 34)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 2)
        .padding(.bottom, 4)
        .background(Color("app_background"))
    }
    
    // MARK: - Hero Banner Card
    
    private var heroBannerCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top Tag
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 11))
                Text("FIRED IN MINUTES · TOPPINGS INCLUDED")
                    .font(.oswaldMedium(size: 11.5))
                    .tracking(1.2)
            }
            .foregroundColor(.white)
            .padding(.top, 20)
            .padding(.horizontal, 20)
            
            // Headline (YOUR PIZZA is app_white, YOUR WAY is pizza_found)
            VStack(alignment: .leading, spacing: -8) {   // try -4 to -12
                Text("YOUR PIZZA.")
                    .font(.oswaldMedium(size: 34))
                    .tracking(0.6)
                    .foregroundColor(Color("app_white"))
                
                Text("YOUR WAY.")
                    .font(.oswaldMedium(size: 34))
                    .tracking(0.6)
                    .foregroundColor(Color("pizza_found"))
            }
            .padding(.top, 10)
            .padding(.horizontal, 20)
            
            
            // Description
            Text("Pile on what you love, split it down the middle, or grab a go-to in two taps. Every pizza is made on demand.")
                .font(.barlowRegular(size: 13.5))
                .foregroundColor(.white.opacity(0.9))
                .lineSpacing(3)
                .padding(.top, 8)
                .padding(.horizontal, 20)
            
            // Action Buttons
            HStack(spacing: 10) {
                // Start Your Order Button
                Button(action: {
                    onStartOrder?()
                }) {
                    HStack(spacing: 6) {
                        Text("START YOUR ORDER")
                            .font(.oswaldMedium(size: 13.5))
                            .tracking(1.0)
                            .foregroundColor(Color("Button_red"))
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color("Button_red"))
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 42)
                    .background(
                        Capsule()
                            .fill(Color.white)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // Build Your Pizza Button
                Button(action: {
                    onBuildPizza?()
                }) {
                    Text("BUILD YOUR PIZZA")
                        .font(.oswaldMedium(size: 13.5))
                        .tracking(1.0)
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .padding(.horizontal, 16)
                        .frame(height: 42)
                        .background(
                            Capsule()
                                .stroke(Color.white.opacity(0.55), lineWidth: 1.2)
                                .background(Capsule().fill(Color.white.opacity(0.12)))
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.top, 16)
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
            
            // Pizza Cutout Graphic with Cream Arch Dome
            ZStack(alignment: .bottom) {
                // 1. Cream Dome Background Arch (spans across the bottom of the card)
                Circle()
                    .fill(Color("pizza_found"))
                    .frame(width: 380, height: 380)
                    .offset(y: 110)
                
                // 2. Centered PizzaOn Image (with continuous rotation)
                Image("PizzaOn")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 270, height: 270)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.16), radius: 8, x: 0, y: 4)
                    .rotationEffect(.degrees(pizzaRotation))
                    .offset(y: 42)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 205)
            .clipped()
            // 3. "MADE YOUR WAY" sticker: top-right, straddling the dome edge.
            //    Applied AFTER .clipped() so the part sticking out above the dome isn't cut off.
            .overlay(alignment: .topTrailing) {
                madeYourWayBadge
                    .padding(.trailing, 18)
                    .offset(y: -1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color("Button_red"))
        )
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
    }
    
    // MARK: - "MADE YOUR WAY" Sticker Badge
    
    private var madeYourWayBadge: some View {
        VStack(spacing: 1.5) {
            Text("MADE")
                .font(.oswaldBold(size: 11))
                .tracking(0.6)
            Text("YOUR")
                .font(.oswaldBold(size: 16))
                .tracking(0.6)
            Text("WAY")
                .font(.oswaldBold(size: 11))
                .tracking(0.6)
        }
        .foregroundColor(Color("Button_red"))
        .frame(width: 78, height: 78)
        .background(
            Circle()
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.18), radius: 6, x: 0, y: 3)
        )
        .rotationEffect(.degrees(-10))
    }
    
    // MARK: - Order Mode & Store Selector Card
    
    private var orderModeCard: some View {
        VStack(spacing: 0) {
            // Segmented Switcher (Pickup vs Delivery)
            HStack(spacing: 0) {
                // Pickup
                Button(action: {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.8)) {
                        selectedOrderType = 0
                    }
                }) {
                    HStack(spacing: 7) {
                        Image(systemName: "bag")
                            .font(.system(size: 14.5, weight: .semibold))
                        Text("Pickup")
                            .font(.barlowSemiBold(size: 15))
                    }
                    .foregroundColor(selectedOrderType == 0 ? Color("Button_red") : Color("app_black"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 38)
                    .background(
                        Group {
                            if selectedOrderType == 0 {
                                Capsule()
                                    .fill(Color.white)
                                    .overlay(
                                        Capsule()
                                            .stroke(Color("Button_red"), lineWidth: 1.8)
                                    )
                                    .shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: 1)
                            } else {
                                Color.clear
                            }
                        }
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // Delivery
                Button(action: {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.8)) {
                        selectedOrderType = 1
                    }
                }) {
                    HStack(spacing: 7) {
                        Image(systemName: "box.truck")
                            .font(.system(size: 14.5, weight: .semibold))
                        Text("Delivery")
                            .font(.barlowSemiBold(size: 15))
                    }
                    .foregroundColor(selectedOrderType == 1 ? Color("Button_red") : Color("app_black"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 38)
                    .background(
                        Group {
                            if selectedOrderType == 1 {
                                Capsule()
                                    .fill(Color.white)
                                    .overlay(
                                        Capsule()
                                            .stroke(Color("Button_red"), lineWidth: 1.8)
                                    )
                                    .shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: 1)
                            } else {
                                Color.clear
                            }
                        }
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(3)
            .background(
                Capsule()
                    .fill(Color(red: 0xF2 / 255.0, green: 0xEA / 255.0, blue: 0xDE / 255.0))
            )
            .padding(14)
            
            if selectedOrderType == 0 {
                // MARK: Pickup Rows
                // 1. In-Store Pickup Row
                Button(action: {
                    orderSetupInitialTab = 0
                    orderSetupAutoScrollToWhen = false
                    showOrderSetup = true
                    onSelectStore?()
                }) {
                    HStack(spacing: 14) {
                        Image(systemName: "storefront")
                            .font(.system(size: 18))
                            .foregroundColor(Color("Button_red"))
                            .frame(width: 26, height: 26)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(selectedPickupOption)
                                .font(.barlowRegular(size: 12))
                                .foregroundColor(Color("text_gary"))
                            Text(selectedStoreName)
                                .font(.barlowBold(size: 15))
                                .foregroundColor(Color("app_black"))
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color("text_gary").opacity(0.7))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .buttonStyle(PlainButtonStyle())
                
                Divider()
                    .background(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDF / 255.0))
                
                // 2. When / Time Row
                Button(action: {
                    orderSetupInitialTab = 0
                    orderSetupAutoScrollToWhen = true
                    showOrderSetup = true
                    onSelectTime?()
                }) {
                    HStack(spacing: 14) {
                        Image(systemName: "clock")
                            .font(.system(size: 18))
                            .foregroundColor(Color("Button_red"))
                            .frame(width: 26, height: 26)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("When")
                                .font(.barlowRegular(size: 12))
                                .foregroundColor(Color("text_gary"))
                            Text(isPickupScheduled ? pickupWhenText : "ASAP · ~15 min")
                                .font(.barlowBold(size: 15))
                                .foregroundColor(Color("app_black"))
                            if isPickupScheduled {
                                Text("Scheduled pickup")
                                    .font(.barlowMedium(size: 12))
                                    .foregroundColor(Color(red: 0x9E / 255.0, green: 0x66 / 255.0, blue: 0x22 / 255.0))
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color("text_gary").opacity(0.7))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                // MARK: Delivery Rows (Matching Snapshot 1)
                // 1. Delivering From Row
                Button(action: {
                    orderSetupInitialTab = 1
                    orderSetupAutoScrollToWhen = false
                    showOrderSetup = true
                    onSelectStore?()
                }) {
                    HStack(spacing: 14) {
                        Image(systemName: "storefront")
                            .font(.system(size: 18))
                            .foregroundColor(Color("Button_red"))
                            .frame(width: 26, height: 26)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Delivering from")
                                .font(.barlowRegular(size: 12))
                                .foregroundColor(Color("text_gary"))
                            Text(selectedStoreName)
                                .font(.barlowBold(size: 15))
                                .foregroundColor(Color("app_black"))
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color("text_gary").opacity(0.7))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .buttonStyle(PlainButtonStyle())
                
                Divider()
                    .background(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDF / 255.0))
                
                // 2. Deliver To Address Row
                Button(action: {
                    orderSetupInitialTab = 1
                    orderSetupAutoScrollToWhen = false
                    showOrderSetup = true
                }) {
                    HStack(spacing: 14) {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.system(size: 18))
                            .foregroundColor(Color("Button_red"))
                            .frame(width: 26, height: 26)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Deliver to · Leave at door")
                                .font(.barlowRegular(size: 12))
                                .foregroundColor(Color("text_gary"))
                            Text(deliveryAddress)
                                .font(.barlowBold(size: 15))
                                .foregroundColor(Color("app_black"))
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color("text_gary").opacity(0.7))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .buttonStyle(PlainButtonStyle())
                
                Divider()
                    .background(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDF / 255.0))
                
                // 3. When Row
                Button(action: {
                    orderSetupInitialTab = 1
                    orderSetupAutoScrollToWhen = true
                    showOrderSetup = true
                    onSelectTime?()
                }) {
                    HStack(spacing: 14) {
                        Image(systemName: "clock")
                            .font(.system(size: 18))
                            .foregroundColor(Color("Button_red"))
                            .frame(width: 26, height: 26)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("When")
                                .font(.barlowRegular(size: 12))
                                .foregroundColor(Color("text_gary"))
                            Text(isDeliveryScheduled ? deliveryWhenText : "ASAP unavailable")
                                .font(.barlowBold(size: 15))
                                .foregroundColor(Color("app_black"))
                            Text(isDeliveryScheduled ? "Scheduled delivery" : "Schedule for later")
                                .font(.barlowMedium(size: 12))
                                .foregroundColor(Color(red: 0x9E / 255.0, green: 0x66 / 255.0, blue: 0x22 / 255.0))
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color("text_gary").opacity(0.7))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 3)
        )
    }
    
    // MARK: - "WHAT ARE YOU CRAVING?" Categories Section
    
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack {
                Text("WHAT ARE YOU CRAVING?")
                    .font(.oswaldMedium(size: 20))
                    .tracking(0.6)
                    .foregroundColor(Color("app_black"))
                
                Spacer()
                
                Button(action: {
                    onFullMenuTap?()
                }) {
                    HStack(spacing: 3) {
                        Text("Full menu")
                            .font(.barlowMedium(size: 13.5))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(Color("Button_red"))
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // 3D Categories Cells Row
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(categories) { category in
                        Button(action: {
                            onCategorySelected?(category.name)
                        }) {
                            VStack(spacing: 8) {
                                // Circular view with pizza_found background behind image
                                ZStack {
                                    Circle()
                                        .fill(Color("pizza_found"))
                                        .frame(width: 58, height: 58)
                                    
                                    Image(category.imageName)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 48, height: 48)
                                        .clipShape(Circle())
                                }
                                
                                Text(category.name)
                                    .font(.barlowSemiBold(size: 13.5))
                                    .foregroundColor(Color("app_black"))
                            }
                            .frame(width: 80, height: 104)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(Color.white)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(Color(red: 0xEA / 255.0, green: 0xE2 / 255.0, blue: 0xD4 / 255.0), lineWidth: 1.2)
                            )
                            .shadow(color: Color.black.opacity(0.07), radius: 6, x: 0, y: 3.5)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 2)
            }
        }
        .padding(.top, 4)
    }
    
    // MARK: - "FAVORITES IN YOUR AREA" Section
    
    private var favoritesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("FAVORITES IN YOUR AREA")
                    .font(.oswaldMedium(size: 20))
                    .tracking(0.6)
                    .foregroundColor(Color("app_black"))
                
                Spacer()
                
                Button(action: {
                    onFullMenuTap?()
                }) {
                    HStack(spacing: 3) {
                        Text("Full menu")
                            .font(.barlowMedium(size: 13.5))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(Color("Button_red"))
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Text("Most-ordered in Capitol Hill, Seattle")
                .font(.barlowRegular(size: 12.5))
                .foregroundColor(Color("text_gary"))
                .padding(.top, -6)
            
            // Item Cards List
            VStack(spacing: 12) {
                ForEach(favoriteItems) { item in
                    menuItemCard(item: item)
                }
            }
        }
        .padding(.top, 8)
    }
    
    private func menuItemCard(item: HomeMenuItem) -> some View {
        let isFav = favoritesState[item.id] ?? item.isFavorite
        let dietaryColor: Color = item.isVeg ? Color("kale_green") : Color("Button_red")
        
        return HStack(spacing: 0) {
            // Left Panel (full-height pizza_found background with centered food image)
            ZStack(alignment: .topLeading) {
                Color("pizza_found")
                
                VStack {
                    Spacer(minLength: 8)
                    Image(item.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 96, height: 96)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 3)
                    Spacer(minLength: 8)
                }
                .frame(maxWidth: .infinity)
                
                // Item tag badge at top-left
                if let tag = item.tag {
                    Text(tag)
                        .font(.oswaldMedium(size: 10))
                        .tracking(0.5)
                        .foregroundColor(.white)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color("roma_red"))
                        )
                        .padding(.top, 10)
                        .padding(.leading, 10)
                }
            }
            .frame(width: 124)
            
            // Right Details Panel
            VStack(alignment: .leading, spacing: 6) {
                // Title and Heart Button
                HStack(alignment: .center) {
                    Text(item.title)
                        .font(.oswaldMedium(size: 19.5))
                        .tracking(0.4)
                        .foregroundColor(Color("app_black"))
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            favoritesState[item.id] = !isFav
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.2)
                                )
                                .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
                            
                            Image(systemName: isFav ? "suit.heart.fill" : "suit.heart")
                                .font(.system(size: 14, weight: isFav ? .bold : .medium))
                                .foregroundColor(isFav ? Color("Button_red") : Color("app_black").opacity(0.75))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Description
                Text(item.description)
                    .font(.barlowRegular(size: 13))
                    .foregroundColor(Color("text_gary"))
                    .lineLimit(2)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Dietary Pill & Calorie Row
                HStack(spacing: 8) {
                    HStack(spacing: 5) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 3)
                                .stroke(dietaryColor, lineWidth: 1.2)
                                .frame(width: 13, height: 13)
                            
                            if item.isVeg {
                                Circle()
                                    .fill(dietaryColor)
                                    .frame(width: 6, height: 6)
                            } else {
                                Image(systemName: "triangle.fill")
                                    .font(.system(size: 6))
                                    .foregroundColor(dietaryColor)
                            }
                        }
                        
                        Text(item.isVegan ? "Vegan" : (item.isVeg ? "Veg" : "Non-veg"))
                            .font(.barlowSemiBold(size: 12))
                            .foregroundColor(dietaryColor)
                    }
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .stroke(Color(red: 0xE5 / 255.0, green: 0xDF / 255.0, blue: 0xD3 / 255.0), lineWidth: 1)
                            .background(Capsule().fill(Color.white))
                    )
                    
                    Text(item.calories)
                        .font(.barlowRegular(size: 12.5))
                        .foregroundColor(Color("text_gary"))
                    
                    Spacer()
                }
                .padding(.top, 2)
                
                // Price & Action Button
                HStack(alignment: .center) {
                    Text(item.price)
                        .font(.oswaldBold(size: 21))
                        .foregroundColor(Color("app_black"))
                    
                    Spacer()
                    
                    Button(action: {
                        if item.actionTitle == "CUSTOMIZE" {
                            onCustomizeItem?(item)
                        } else {
                            onAddItem?(item)
                        }
                    }) {
                        Text(item.actionTitle)
                            .font(.oswaldMedium(size: 13.5))
                            .tracking(1.0)
                            .foregroundColor(.white)
                            .padding(.horizontal, 18)
                            .frame(height: 38)
                            .background(
                                Capsule()
                                    .fill(Color("Button_red"))
                            )
                            .shadow(color: Color("Button_red").opacity(0.3), radius: 5, x: 0, y: 2)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.top, 4)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 14)
            .background(Color.white)
        }
        .frame(maxWidth: .infinity)
        .fixedSize(horizontal: false, vertical: true)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDE / 255.0), lineWidth: 1.2)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 3)
    }
    
    // MARK: - Sign In Rewards Teaser
    
    private var signInTeaser: some View {
        HStack(spacing: 6) {
            Image(systemName: "star")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color("Button_red"))
            
            Button(action: {
                onSignIn?()
            }) {
                Text("Sign in")
                    .font(.barlowSemiBold(size: 13))
                    .underline()
                    .foregroundColor(Color("Button_red"))
            }
            .buttonStyle(PlainButtonStyle())
            
            Text("to always earn points and reorder in one tap.")
                .font(.barlowRegular(size: 13))
                .foregroundColor(Color("text_gary"))
            
            Spacer()
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 4)
    }
    
    // MARK: - MOD REWARDS Banner Card
    
    private var modRewardsCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Tag
            Text("MOD REWARDS")
                .font(.oswaldMedium(size: 11))
                .tracking(1.4)
                .foregroundColor(.white.opacity(0.7))
                .padding(.top, 20)
            
            // Headline
            Text("EARN ON EVERY PIZZA")
                .font(.oswaldMedium(size: 22))
                .tracking(0.6)
                .foregroundColor(.white)
                .padding(.top, 6)
            
            // Description
            Text("10 points per $1. Free pizza at 1500 points, member-only coupons and a digital wallet.")
                .font(.barlowRegular(size: 13))
                .foregroundColor(.white.opacity(0.85))
                .lineSpacing(2)
                .padding(.top, 6)
            
            // Buttons
            HStack(spacing: 10) {
                Button(action: {
                    onSignIn?()
                }) {
                    Text("SIGN IN")
                        .font(.oswaldMedium(size: 13))
                        .tracking(1.0)
                        .foregroundColor(Color("app_black"))
                        .padding(.horizontal, 16)
                        .frame(height: 36)
                        .background(
                            Capsule()
                                .fill(Color.white)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    onJoinRewards?()
                }) {
                    Text("JOIN MOD REWARDS")
                        .font(.oswaldMedium(size: 13))
                        .tracking(1.0)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .frame(height: 36)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.18))
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.top, 14)
            
            // Footnote
            Text("Passwordless: we text or email your code.")
                .font(.barlowRegular(size: 11.5))
                .foregroundColor(.white.opacity(0.55))
                .padding(.top, 10)
                .padding(.bottom, 18)
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0x22 / 255.0, green: 0x1A / 255.0, blue: 0x1D / 255.0),
                            Color(red: 0x3E / 255.0, green: 0x1B / 255.0, blue: 0x22 / 255.0),
                            Color(red: 0x26 / 255.0, green: 0x18 / 255.0, blue: 0x1B / 255.0)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 3)
    }
    
    // MARK: - FEATURED OFFER Card (roma_red with opacity, dotted border)
    
    private var featuredOfferCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 5) {
                Image(systemName: "tag.fill")
                    .font(.system(size: 10))
                Text("FEATURED OFFER")
                    .font(.oswaldMedium(size: 11))
                    .tracking(1.2)
            }
            .foregroundColor(Color("roma_red"))
            
            Text("Free dessert with any pizza")
                .font(.oswaldBold(size: 18))
                .tracking(0.4)
                .foregroundColor(Color("app_black"))
            
            Text("Buy any pizza and get one dessert on us. Up to $3.99.")
                .font(.barlowRegular(size: 12.5))
                .foregroundColor(Color("text_gary"))
            
            HStack {
                Button(action: {
                    onClaimOffer?()
                }) {
                    Text("SWEETDEAL")
                        .font(.oswaldMedium(size: 12))
                        .tracking(1.0)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .frame(height: 28)
                        .background(
                            Capsule()
                                .fill(Color("roma_red"))
                        )
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
            }
            .padding(.top, 4)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color("roma_red").opacity(0.06))
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(
                    Color("roma_red").opacity(0.4),
                    style: StrokeStyle(lineWidth: 1.4, dash: [4, 4])
                )
        )
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }
    
    // MARK: - Utility Links Card
    
    private var utilityLinksCard: some View {
        VStack(spacing: 0) {
            // Saved Pizzas Row
            utilityRow(
                icon: "suit.heart",
                title: "Saved pizzas & favorites",
                subtitle: "2 saved · 1 favorite"
            )
            
            Divider()
                .background(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDF / 255.0))
            
            // Group Order Row
            utilityRow(
                icon: "person.2",
                title: "Group order",
                subtitle: "One link, everyone orders pizza"
            )
            
            Divider()
                .background(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDF / 255.0))
            
            // All Offers Row
            utilityRow(
                icon: "tag",
                title: "All offers",
                subtitle: "1 available"
            )
        }
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
        )
    }
    
    private func utilityRow(icon: String, title: String, subtitle: String) -> some View {
        Button(action: {}) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 17))
                    .foregroundColor(Color("Button_red"))
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.barlowSemiBold(size: 14))
                        .foregroundColor(Color("app_black"))
                    Text(subtitle)
                        .font(.barlowRegular(size: 12))
                        .foregroundColor(Color("text_gary"))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color("text_gary").opacity(0.7))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(isGuest: true)
    }
}

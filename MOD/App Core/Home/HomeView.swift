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
    var userPoints: Int = 1240
    var targetPoints: Int = 1500
    var userTier: String = "Silver"
    var lifetimePointsToGold: Int = 2900
    
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
    
    @State private var currentIsGuest: Bool = true
    @State private var showMemberPassModal: Bool = false
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
    @State private var showMenuView: Bool = false
    @State private var showBuildYourPizzaHero: Bool = false
    @State private var selectedHomeItemForCustomization: HomeMenuItem? = nil
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
                        
                        if currentIsGuest {
                            // Sign In Rewards Teaser (Snap 1)
                            signInTeaser
                            
                            // MOD REWARDS Banner Card for Guest (Snap 1)
                            modRewardsCard
                        } else {
                            // MOD REWARDS Logged-In Card (Snap 2)
                            loggedInRewardsCard
                        }
                        
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
        .fullScreenCover(isPresented: $showMenuView) {
            MenuView(showDismissButton: true)
        }
        .fullScreenCover(isPresented: $showBuildYourPizzaHero) {
            MenuCustomizationView(
                pizzaTitle: "BUILD YOUR PIZZA",
                pizzaCategory: "PIZZAS",
                pizzaDescription: "Build your own with 40+ toppings and 8 finishing sauces — all for one price. Supports independent half-and-half recipes.",
                pizzaImageName: "PizzaOn",
                showRecipeStyle: true, // ONLY show recipe style when clicked on Build Your Pizza in HeroCardView!
                onBack: {
                    showBuildYourPizzaHero = false
                }
            )
        }
        .fullScreenCover(item: $selectedHomeItemForCustomization) { item in
            MenuCustomizationView(
                pizzaTitle: item.title,
                pizzaCategory: "PIZZAS",
                pizzaDescription: item.description,
                pizzaImageName: item.imageName,
                showRecipeStyle: false, // Don't show recipe style for particular pizza!
                onBack: {
                    selectedHomeItemForCustomization = nil
                }
            )
        }
        .fullScreenCover(isPresented: $showMemberPassModal) {
            DigitalMemberPassSheet(
                userName: "Raj",
                userPoints: 1240,
                tierName: userTier,
                onDismiss: {
                    showMemberPassModal = false
                }
            )
        }
        .onAppear {
            withAnimation(.linear(duration: 35).repeatForever(autoreverses: false)) {
                pizzaRotation = 360
            }
            if let saved = UserDefaults.standard.object(forKey: "isGuestUser") as? Bool {
                currentIsGuest = saved
            } else {
                currentIsGuest = isGuest
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .userLoggedOutNotification)) { _ in
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                currentIsGuest = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .userLoggedInNotification)) { _ in
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                currentIsGuest = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)) { _ in
            if let saved = UserDefaults.standard.object(forKey: "isGuestUser") as? Bool {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    currentIsGuest = saved
                }
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
            
            // Center: Star and Cart icons in the exact middle of the screen
            HStack(spacing: 18) {
                // Star Button (Tapping opens AccountSheet / redirects to Login if guest)
                Button(action: {
                    if let onProfileTap = onProfileTap {
                        onProfileTap()
                    } else {
                        AccountSheetManager.shared.handleStarTap()
                    }
                }) {
                    Image(systemName: "star")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(Color("app_black"))
                        .frame(width: 34, height: 34)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Shopping Cart Button with Live Badge
                TopCartButton(action: {
                    if let onCartTap = onCartTap {
                        onCartTap()
                    } else {
                        CartManager.shared.showCartSheet = true
                        NotificationCenter.default.post(name: .showCartNotification, object: nil)
                    }
                })
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 2)
        .padding(.bottom, 4)
        .background(Color("app_background"))
    }
    
    // MARK: - Hero Banner Card
    
    //
    //  HomeView_HeroBanner.swift
    //
    //  HOW TO USE
    //  In HomeView.swift, delete everything from
    //      // MARK: - Hero Banner Card
    //  down to the end of `madeYourWayBadge` (just above
    //      // MARK: - Order Mode & Store Selector Card ),
    //  and paste the two members below in its place.
    //  Nothing else in HomeView changes: it uses the same @State (pizzaRotation,
    //  showMenuView, showBuildYourPizzaHero) and the same callbacks as before.
    //

        // MARK: - Hero Banner Card
        
        private var heroBannerCard: some View {
            VStack(alignment: .leading, spacing: 0) {
                // Top tag (outlined flame, slightly softer white, like the prototype)
                HStack(spacing: 7) {
                    Image(systemName: "flame")
                        .font(.system(size: 11.5, weight: .regular))
                    Text("FIRED IN MINUTES · TOPPINGS INCLUDED")
                        .font(.oswaldMedium(size: 11.5))
                        .tracking(1.2)
                }
                .foregroundColor(.white.opacity(0.88))
                .padding(.top, 26)
                .padding(.horizontal, 20)
                
                // Headline: smaller and tightly stacked
                VStack(alignment: .leading, spacing: -12) {
                    Text("YOUR PIZZA.")
                        .font(.oswaldMedium(size: 28))
                        .tracking(0.4)
                        .foregroundColor(Color("app_white"))
                    
                    Text("YOUR WAY.")
                        .font(.oswaldMedium(size: 28))
                        .tracking(0.4)
                        .foregroundColor(Color("pizza_found"))
                }
                .padding(.top, 10)
                .padding(.horizontal, 20)
                
                // Description: larger text with more line spacing (wraps to 3 lines)
                Text("Pile on what you love, split it down the middle, or grab a go-to in two taps. Every pizza is made on demand.")
                    .font(.barlowRegular(size: 14.5))
                    .foregroundColor(.white.opacity(0.88))
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 8)
                    .padding(.horizontal, 20)
                
                // Action buttons (a little taller than before)
                HStack(spacing: 10) {
                    // Start Your Order
                    Button(action: {
                        MenuCoordinator.shared.selectCategoryAndOpenMenu(.all)
                        showMenuView = true
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
                        .frame(height: 44)
                        .background(
                            Capsule()
                                .fill(Color.white)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Build Your Pizza
                    Button(action: {
                        if let onBuildPizza = onBuildPizza {
                            onBuildPizza()
                        } else {
                            showBuildYourPizzaHero = true
                        }
                    }) {
                        Text("BUILD YOUR PIZZA")
                            .font(.oswaldMedium(size: 13.5))
                            .tracking(1.0)
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                            .padding(.horizontal, 16)
                            .frame(height: 44)
                            .background(
                                Capsule()
                                    .stroke(Color.white.opacity(0.35), lineWidth: 1.2)
                                    .background(Capsule().fill(Color.white.opacity(0.16)))
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.top, 16)
                .padding(.horizontal, 20)
                .padding(.bottom, 18)
                
                // Cream dome + pizza.
                // Color.clear fixes the size (card width x 230). The dome and pizza live in an
                // overlay, so the oversized 580pt circle can't widen the card; .clipped() trims it.
                Color.clear
                    .frame(maxWidth: .infinity)
                    .frame(height: 230)
                    .overlay(alignment: .top) {
                        ZStack(alignment: .top) {
                            // Wide, flat dome: 580pt circle => arc drops ~65pt at the card edges
                            Circle()
                                .fill(Color("pizza_found"))
                                .frame(width: 580, height: 580)
                            
                            // Swap "PizzaOn" for your new striped pizza asset (e.g. "PizzaHero")
                            Image("PizzaOn")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 270, height: 270)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.16), radius: 8, x: 0, y: 4)
                                .rotationEffect(.degrees(pizzaRotation))
                                .offset(y: 71)
                        }
                    }
                    .clipped()
                    // Sticker is applied AFTER .clipped() so the part above the dome isn't cut off
                    .overlay(alignment: .topTrailing) {
                        madeYourWayBadge
                            .padding(.trailing, 15)
                            .offset(y: -6)
                    }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            // Deeper maroon like the prototype (was Button_red)
            .background(Color("Button_red"))
            // Clip everything (dome corners included) to the card's rounded shape
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
        }
        
        // MARK: - "MADE YOUR WAY" Sticker Badge
        
        private var madeYourWayBadge: some View {
            VStack(spacing: 2) {
                Text("MADE")
                    .font(.oswaldBold(size: 12.5))
                    .tracking(0.7)
                Text("YOUR")
                    .font(.oswaldBold(size: 19))
                    .tracking(0.7)
                Text("WAY")
                    .font(.oswaldBold(size: 12.5))
                    .tracking(0.7)
            }
            .foregroundColor(Color("Button_red"))
            .frame(width: 92, height: 92)
            .background(
                Circle()
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.22), radius: 8, x: 0, y: 4)
            )
            .rotationEffect(.degrees(-10))
        }
    
    // MARK: - "MADE YOUR WAY" Sticker Badge
    
    
    
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
                    MenuCoordinator.shared.selectCategoryAndOpenMenu(.all)
                    showMenuView = true
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
                            let selectedCat: MenuCategory
                            switch category.name.lowercased() {
                            case "pizzas", "pizza":
                                selectedCat = .pizzas
                            case "salads", "salad":
                                selectedCat = .salads
                            case "sides", "side":
                                selectedCat = .sides
                            case "desserts", "dessert":
                                selectedCat = .desserts
                            case "drinks", "beverages":
                                selectedCat = .beverages
                            default:
                                selectedCat = .all
                            }
                            MenuCoordinator.shared.selectCategoryAndOpenMenu(selectedCat)
                            showMenuView = true
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
                    MenuCoordinator.shared.selectCategoryAndOpenMenu(.all)
                    showMenuView = true
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
                        .font(.oswaldLight(size: 19.5))
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
                            if let onCustomizeItem = onCustomizeItem {
                                onCustomizeItem(item)
                            } else {
                                selectedHomeItemForCustomization = item
                            }
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
    
    // MARK: - Sign In Rewards Teaser (Guest Mode - Snap 1)
    
    private var signInTeaser: some View {
        HStack(spacing: 6) {
            Image(systemName: "star")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color("Button_red"))
            
            Button(action: {
                handleSignInTap()
            }) {
                Text("Sign in")
                    .font(.barlowSemiBold(size: 13))
                    .underline()
                    .foregroundColor(Color("Button_red"))
            }
            .buttonStyle(PlainButtonStyle())
            
            Text("to see your go-to orders and reorder in one tap.")
                .font(.barlowRegular(size: 13))
                .foregroundColor(Color("text_gary"))
            
            Spacer()
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 4)
    }
    
    // MARK: - MOD REWARDS Banner Card (Guest Mode - Snap 1)
    
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
            Text("10 points per $1, free pizza at 1,500 points,\nmember-only coupons and a digital wallet.")
                .font(.barlowRegular(size: 13))
                .foregroundColor(.white.opacity(0.85))
                .lineSpacing(2)
                .padding(.top, 6)
            
            // Buttons
            HStack(spacing: 10) {
                Button(action: {
                    handleSignInTap()
                }) {
                    Text("SIGN IN")
                        .font(.oswaldMedium(size: 13))
                        .tracking(1.0)
                        .foregroundColor(Color("Button_red"))
                        .padding(.horizontal, 18)
                        .frame(height: 36)
                        .background(
                            Capsule()
                                .fill(Color.white)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    handleJoinRewardsTap()
                }) {
                    Text("JOIN MOD REWARDS")
                        .font(.oswaldMedium(size: 13))
                        .tracking(1.0)
                        .foregroundColor(.white)
                        .padding(.horizontal, 18)
                        .frame(height: 36)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.18))
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.32), lineWidth: 1.0)
                                )
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.top, 14)
            
            // Footnote
            Text("Passwordless — we text or email you a code.")
                .font(.barlowRegular(size: 11.5))
                .foregroundColor(.white.opacity(0.55))
                .padding(.top, 10)
                .padding(.bottom, 18)
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0x1E / 255.0, green: 0x1A / 255.0, blue: 0x1C / 255.0),
                            Color(red: 0x24 / 255.0, green: 0x19 / 255.0, blue: 0x1E / 255.0),
                            Color(red: 0x4D / 255.0, green: 0x18 / 255.0, blue: 0x24 / 255.0)
                        ]),
                        startPoint: .bottomLeading,
                        endPoint: .topTrailing
                    )
                )
        )
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 3)
    }
    
    // MARK: - Logged-In Member Rewards Card (Snap 2)
    
    private var loggedInRewardsCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header Row: Tag & Digital Pass Icon
            HStack(alignment: .center) {
                Text("MOD REWARDS · \(userTier.uppercased())")
                    .font(.oswaldMedium(size: 13))
                    .tracking(1.4)
                    .foregroundColor(.white.opacity(0.85))
                
                Spacer()
                
                // Digital Member Pass Button
                Button(action: {
                    showMemberPassModal = true
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.12))
                            .frame(width: 38, height: 38)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.24), lineWidth: 1.0)
                            )
                        
                        Image(systemName: "creditcard")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.top, 20)
            
            // Points Display
            Text("\(userPoints.formattedWithSeparator) pts")
                .font(.oswaldMedium(size: 44))
                .tracking(0.6)
                .foregroundColor(.white)
                .padding(.top, 6)
            
            // Subtitle
            Text("Enrolled member")
                .font(.barlowRegular(size: 14))
                .foregroundColor(.white.opacity(0.72))
                .padding(.top, 2)
            
            // Progress Bar
            GeometryReader { geo in
                let progress = min(max(CGFloat(userPoints) / CGFloat(targetPoints), 0.0), 1.0)
                ZStack(alignment: .leading) {
                    // Track
                    Capsule()
                        .fill(Color.white.opacity(0.16))
                        .frame(height: 8)
                    
                    // Fill (Golden gradient matching snapshot)
                    Capsule()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0xF2 / 255.0, green: 0xC1 / 255.0, blue: 0x5D / 255.0),
                                    Color(red: 0xFF / 255.0, green: 0xFA / 255.0, blue: 0xEB / 255.0)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(geo.size.width * progress, 8), height: 8)
                }
            }
            .frame(height: 8)
            .padding(.top, 16)
            
            // Points to next milestone
            let remainingPoints = max(targetPoints - userPoints, 0)
            Text("\(remainingPoints) pts to a free pizza")
                .font(.barlowBold(size: 15))
                .foregroundColor(.white)
                .padding(.top, 12)
            
            // Lifetime points info
            Text("\(lifetimePointsToGold.formattedWithSeparator) lifetime pts to Gold (1.5× earning)")
                .font(.barlowRegular(size: 13))
                .foregroundColor(.white.opacity(0.72))
                .padding(.top, 4)
            
            // Bottom Action Buttons: REDEEM & WALLET
            HStack(spacing: 12) {
                // REDEEM Button
                Button(action: {
                    switchToTab(2) // Switch to Rewards Tab
                }) {
                    Text("REDEEM")
                        .font(.oswaldMedium(size: 13.5))
                        .tracking(1.0)
                        .foregroundColor(Color("Button_red"))
                        .padding(.horizontal, 22)
                        .frame(height: 38)
                        .background(
                            Capsule()
                                .fill(Color.white)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                
                // WALLET Button
                Button(action: {
                    NotificationCenter.default.post(name: Notification.Name("showWalletDirectlyNotification"), object: nil)
                }) {
                    Text("WALLET")
                        .font(.oswaldMedium(size: 13.5))
                        .tracking(1.0)
                        .foregroundColor(.white)
                        .padding(.horizontal, 22)
                        .frame(height: 38)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.18))
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.30), lineWidth: 1.0)
                                )
                        )
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
            }
            .padding(.top, 18)
            .padding(.bottom, 22)
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0x1E / 255.0, green: 0x1A / 255.0, blue: 0x1C / 255.0),
                            Color(red: 0x24 / 255.0, green: 0x19 / 255.0, blue: 0x1E / 255.0),
                            Color(red: 0x4D / 255.0, green: 0x18 / 255.0, blue: 0x24 / 255.0)
                        ]),
                        startPoint: .bottomLeading,
                        endPoint: .topTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1.0)
                )
        )
        .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 4)
    }
    
    // MARK: - Navigation & Action Helpers
    
    private func handleSignInTap() {
        if let onSignIn = onSignIn {
            onSignIn()
        } else if let appDelegate = kSharedAppDelegate {
            appDelegate.moveToAuth(initialDestination: .login)
        } else {
            AccountSheetManager.shared.handleStarTap()
        }
    }
    
    private func handleJoinRewardsTap() {
        if let onJoinRewards = onJoinRewards {
            onJoinRewards()
        } else if let appDelegate = kSharedAppDelegate {
            appDelegate.moveToAuth(initialDestination: .login)
        } else {
            AccountSheetManager.shared.handleStarTap()
        }
    }
    
    private func switchToTab(_ index: Int) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootNav = windowScene.windows.first?.rootViewController as? UINavigationController,
           let tabVC = rootNav.viewControllers.first as? UITabBarController {
            tabVC.selectedIndex = index
        }
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
            .foregroundColor(Color("Button_red"))
            
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
                                .fill(Color("Button_red"))
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

// MARK: - Number Formatter Helper

private extension Int {
    var formattedWithSeparator: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

// MARK: - Preview

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HomeView(isGuest: true)
                .previewDisplayName("Guest Mode (Snap 1)")
            HomeView(isGuest: false)
                .previewDisplayName("Logged-In Mode (Snap 2)")
        }
    }
}






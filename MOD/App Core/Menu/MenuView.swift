//
//  MenuView.swift
//  MOD
//
//  Created by Rajpal singh on 16/11/26.
//

import SwiftUI
import Combine

// MARK: - Notification for Tab Switching

extension Notification.Name {
    static let selectMenuTabWithCategory = Notification.Name("selectMenuTabWithCategory")
}

// MARK: - Menu Category Enum

enum MenuCategory: String, CaseIterable, Identifiable, Hashable {
    case all = "All"
    case pizzas = "Pizzas"
    case salads = "Salads"
    case sides = "Sides"
    case desserts = "Desserts"
    case kidsMeal = "Kids Meal"
    case beverages = "Beverages"
    case extra = "Extra"
    
    var id: String { rawValue }
    var title: String { rawValue }
    
    var sectionTitle: String {
        switch self {
        case .all: return "ALL"
        case .pizzas: return "PIZZAS"
        case .salads: return "SALADS"
        case .sides: return "SIDES"
        case .desserts: return "DESSERTS"
        case .kidsMeal: return "KIDS MEAL"
        case .beverages: return "BEVERAGES"
        case .extra: return "EXTRAS"
        }
    }
    
    var accentColor: Color {
        switch self {
        case .pizzas, .all:
            return Color("Button_red")
        case .salads:
            return Color("kale_green")
        case .sides:
            return Color(red: 0x9E / 255.0, green: 0x66 / 255.0, blue: 0x22 / 255.0)
        case .desserts:
            return Color("Button_red")
        case .kidsMeal:
            return Color(red: 0xE0 / 255.0, green: 0x7A / 255.0, blue: 0x2F / 255.0)
        case .beverages:
            return Color(red: 0x36 / 255.0, green: 0x82 / 255.0, blue: 0xA3 / 255.0)
        case .extra:
            return Color("Button_red")
        }
    }
}

// MARK: - Dietary Filter Enum

enum DietaryFilter: String, CaseIterable, Identifiable, Hashable {
    case all = "All"
    case veg = "Veg"
    case nonVeg = "Non-veg"
    case vegan = "Vegan"
    
    var id: String { rawValue }
    var title: String { rawValue }
}

// MARK: - Menu Item Model

struct MenuItemModel: Identifiable, Equatable {
    let id: String
    let title: String
    let category: MenuCategory
    let description: String
    let price: String
    let imageName: String
    let tag: String?
    let isVeg: Bool
    let isVegan: Bool
    let calories: String
    let isSoldOut: Bool
    var isFavorite: Bool
}

// MARK: - Menu Coordinator Singleton

final class MenuCoordinator: ObservableObject {
    static let shared = MenuCoordinator()
    
    let objectWillChange = ObservableObjectPublisher()
    
    @Published var selectedCategory: MenuCategory = .all
    @Published var searchQuery: String = ""
    @Published var selectedDietaryFilter: DietaryFilter = .all
    
    func selectCategoryAndOpenMenu(_ category: MenuCategory) {
        selectedCategory = category
        NotificationCenter.default.post(name: .selectMenuTabWithCategory, object: category)
    }
}

// MARK: - MenuView

struct MenuView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var coordinator = MenuCoordinator.shared
    
    // MARK: - Configuration
    
    var initialCategory: MenuCategory? = nil
    var showDismissButton: Bool = false
    
    var onProfileTap: (() -> Void)? = nil
    var onCartTap: (() -> Void)? = nil
    var onCustomizeItem: ((MenuItemModel) -> Void)? = nil
    var onAddItem: ((MenuItemModel) -> Void)? = nil
    
    // MARK: - State
    
    @State private var selectedOrderType: Int = 0 // 0: Pickup, 1: Delivery
    @State private var storeName: String = "Capitol Hill, Seattle"
    @State private var pickupOption: String = "In-store pickup at"
    @State private var deliveryAddress: String = "Add a delivery address"
    @State private var whenText: String = "ASAP unavailable"
    @State private var whenSubtitle: String = "Schedule for later"
    @State private var showOrderSetup: Bool = false
    @State private var showCustomizationView: Bool = false
    @State private var selectedItemForCustomization: MenuItemModel? = nil
    @State private var orderSetupInitialTab: Int = 0
    @State private var orderSetupAutoScrollToWhen: Bool = false
    
    @State private var activeCategory: MenuCategory = .all
    @State private var activeDietFilter: DietaryFilter = .all
    @State private var searchText: String = ""
    @State private var favoritesState: [String: Bool] = [
        "maddy": true
    ]
    
    // MARK: - Full Menu Items Catalog
    
    private let allMenuItems: [MenuItemModel] = [
        // MARK: Pizzas
        MenuItemModel(
            id: "og_pepperoni",
            title: "OG PEPPERONI",
            category: .pizzas,
            description: "Tomato sauce, mozzarella, asiago and pepperoni.",
            price: "$10.99",
            imageName: "per",
            tag: "Popular",
            isVeg: false,
            isVegan: false,
            calories: "906 cal",
            isSoldOut: false,
            isFavorite: false
        ),
        MenuItemModel(
            id: "one_topping",
            title: "ONE TOPPING",
            category: .pizzas,
            description: "Everyday value: sauce, cheese and your one favorite topping.",
            price: "$8.99",
            imageName: "pizza1",
            tag: "Value",
            isVeg: false,
            isVegan: false,
            calories: "860 cal",
            isSoldOut: false,
            isFavorite: false
        ),
        MenuItemModel(
            id: "maddy",
            title: "MADDY'S FAVORITE",
            category: .pizzas,
            description: "Tomato sauce, mozzarella and asiago. Simple, cheesy, perfect.",
            price: "$9.99",
            imageName: "marg",
            tag: nil,
            isVeg: true,
            isVegan: false,
            calories: "682 cal",
            isSoldOut: false,
            isFavorite: true
        ),
        MenuItemModel(
            id: "mike_fav",
            title: "MIKE'S FAVORITE",
            category: .pizzas,
            description: "Tomato sauce, mozzarella, parmesan, ricotta, and spicy chicken sausage.",
            price: "$12.99",
            imageName: "pizza4",
            tag: "Sold out",
            isVeg: false,
            isVegan: false,
            calories: "940 cal",
            isSoldOut: true,
            isFavorite: false
        ),
        MenuItemModel(
            id: "perfect_pesto",
            title: "PERFECT PESTO",
            category: .pizzas,
            description: "Pesto, garlic rub, mozzarella, feta, artichokes, and fresh arugula.",
            price: "$13.99",
            imageName: "pesto",
            tag: "New",
            isVeg: true,
            isVegan: false,
            calories: "800 cal",
            isSoldOut: false,
            isFavorite: false
        ),
        MenuItemModel(
            id: "calexico",
            title: "CALEXICO",
            category: .pizzas,
            description: "Red sauce, mozzarella, gorgonzola, chicken, jalapenos, hot buffalo finish.",
            price: "$12.99",
            imageName: "pizza3 1",
            tag: nil,
            isVeg: false,
            isVegan: false,
            calories: "890 cal",
            isSoldOut: false,
            isFavorite: false
        ),
        MenuItemModel(
            id: "caspian",
            title: "CASPIAN",
            category: .pizzas,
            description: "BBQ sauce, mozzarella, gorgonzola, chicken, red onion, BBQ swirl.",
            price: "$12.99",
            imageName: "pizza2 1",
            tag: nil,
            isVeg: false,
            isVegan: false,
            calories: "920 cal",
            isSoldOut: false,
            isFavorite: false
        ),
        MenuItemModel(
            id: "lucy_sunshine",
            title: "LUCY SUNSHINE",
            category: .pizzas,
            description: "Garlic rub, mozzarella, parmesan, artichokes, red sauce dollops.",
            price: "$11.99",
            imageName: "pizza5",
            tag: "Popular",
            isVeg: true,
            isVegan: false,
            calories: "730 cal",
            isSoldOut: false,
            isFavorite: false
        ),
        MenuItemModel(
            id: "mad_dog",
            title: "MAD DOG",
            category: .pizzas,
            description: "Red sauce, mozzarella, pepperoni, mild sausage, ground beef.",
            price: "$13.49",
            imageName: "pizza6",
            tag: nil,
            isVeg: false,
            isVegan: false,
            calories: "980 cal",
            isSoldOut: false,
            isFavorite: false
        ),
        MenuItemModel(
            id: "dillon_james",
            title: "DILLON JAMES",
            category: .pizzas,
            description: "Red sauce, garlic rub, mozzarella, asiago, fresh basil, sliced tomatoes.",
            price: "$11.99",
            imageName: "pizza7",
            tag: nil,
            isVeg: true,
            isVegan: false,
            calories: "710 cal",
            isSoldOut: false,
            isFavorite: false
        ),
        MenuItemModel(
            id: "create_own_pizza",
            title: "CREATE YOUR OWN PIZZA",
            category: .pizzas,
            description: "Any sauce, any cheese, unlimited toppings all for one flat price.",
            price: "$11.99",
            imageName: "yourOwnPizza",
            tag: "Top Pick",
            isVeg: true,
            isVegan: false,
            calories: "Custom cal",
            isSoldOut: false,
            isFavorite: false
        ),
        
        // MARK: Salads
        MenuItemModel(
            id: "mod_salad",
            title: "THE MOD SALAD",
            category: .salads,
            description: "Build your own on romaine or mixed greens with 40+ toppings.",
            price: "$8.99",
            imageName: "salad",
            tag: nil,
            isVeg: true,
            isVegan: true,
            calories: "Custom cal",
            isSoldOut: false,
            isFavorite: false
        ),
        MenuItemModel(
            id: "caesar_salad",
            title: "CAESAR",
            category: .salads,
            description: "Romaine, Caesar dressing, asiago, parmesan and croutons.",
            price: "$8.99",
            imageName: "salad2",
            tag: nil,
            isVeg: true,
            isVegan: false,
            calories: "428 cal",
            isSoldOut: false,
            isFavorite: false
        ),
        MenuItemModel(
            id: "garden_salad",
            title: "GARDEN SALAD",
            category: .salads,
            description: "Romaine, mixed greens, diced tomatoes, cucumbers, sherry dijon vinaigrette.",
            price: "$8.99",
            imageName: "farm",
            tag: nil,
            isVeg: true,
            isVegan: true,
            calories: "340 cal",
            isSoldOut: false,
            isFavorite: false
        ),
        MenuItemModel(
            id: "med_salad",
            title: "MEDITERRANEAN SALAD",
            category: .salads,
            description: "Romaine, feta, kalamata olives, diced tomatoes, cucumber, red onion.",
            price: "$9.99",
            imageName: "veg",
            tag: "Popular",
            isVeg: true,
            isVegan: false,
            calories: "480 cal",
            isSoldOut: false,
            isFavorite: false
        ),
        
        // MARK: Sides
        MenuItemModel(
            id: "garlic_bread",
            title: "CHEESY GARLIC BREAD",
            category: .sides,
            description: "Warm pizza dough with garlic rub, mozzarella, parmesan, rosemary, red sauce dip.",
            price: "$5.99",
            imageName: "garlic_bread",
            tag: "Popular",
            isVeg: true,
            isVegan: false,
            calories: "620 cal",
            isSoldOut: false,
            isFavorite: false
        ),
        MenuItemModel(
            id: "mod_fries",
            title: "MOD FRIES",
            category: .sides,
            description: "Crispy seasoned potato wedges, oven baked golden with choice of dipping sauce.",
            price: "$4.49",
            imageName: "fries",
            tag: nil,
            isVeg: true,
            isVegan: true,
            calories: "410 cal",
            isSoldOut: false,
            isFavorite: false
        ),
        MenuItemModel(
            id: "garlic_sticks",
            title: "GARLIC CRUST STICKS",
            category: .sides,
            description: "Signature crust strips brushed with roasted garlic oil and grated parmesan.",
            price: "$4.99",
            imageName: "gc",
            tag: nil,
            isVeg: true,
            isVegan: false,
            calories: "510 cal",
            isSoldOut: false,
            isFavorite: false
        ),
        MenuItemModel(
            id: "brownie_sticks",
            title: "BROWNIE STICKS",
            category: .sides,
            description: "Rich fudge baked dessert sticks dusted with powdered sugar.",
            price: "$4.29",
            imageName: "brown",
            tag: nil,
            isVeg: true,
            isVegan: false,
            calories: "490 cal",
            isSoldOut: false,
            isFavorite: false
        ),
        
        // MARK: Desserts
        MenuItemModel(
            id: "no_name_cake",
            title: "NO NAME CAKE",
            category: .desserts,
            description: "Chocolate cake with vanilla buttercream center and rich chocolate glaze.",
            price: "$3.99",
            imageName: "Desert",
            tag: "Fan Favorite",
            isVeg: true,
            isVegan: false,
            calories: "760 cal",
            isSoldOut: false,
            isFavorite: false
        ),
        MenuItemModel(
            id: "cinnamon_strips",
            title: "CINNAMON STRIPS",
            category: .desserts,
            description: "Warm dough brushed with butter, cinnamon sugar, and sweet vanilla icing.",
            price: "$4.99",
            imageName: "cine",
            tag: nil,
            isVeg: true,
            isVegan: false,
            calories: "580 cal",
            isSoldOut: false,
            isFavorite: false
        ),
        
        // MARK: Kids Meal
        MenuItemModel(
            id: "kids_pizza_combo",
            title: "MINI PIZZA COMBO",
            category: .kidsMeal,
            description: "6-inch one-topping pizza with juice box and a mini treat.",
            price: "$6.99",
            imageName: "combo",
            tag: "Kids",
            isVeg: true,
            isVegan: false,
            calories: "520 cal",
            isSoldOut: false,
            isFavorite: false
        ),
        MenuItemModel(
            id: "kids_slice",
            title: "KIDS SLICE & DRINK",
            category: .kidsMeal,
            description: "Personal kid-size slice, apple slices, and choice of organic milk or juice.",
            price: "$5.99",
            imageName: "free_meal",
            tag: nil,
            isVeg: true,
            isVegan: false,
            calories: "440 cal",
            isSoldOut: false,
            isFavorite: false
        ),
        
        // MARK: Beverages
        MenuItemModel(
            id: "house_lemonade",
            title: "HOUSE-MADE LEMONADE",
            category: .beverages,
            description: "Fresh, lightly sweet house-pressed lemonade with pure cane sugar.",
            price: "$2.99",
            imageName: "free_drink",
            tag: "Fresh",
            isVeg: true,
            isVegan: true,
            calories: "210 cal",
            isSoldOut: false,
            isFavorite: false
        ),
        MenuItemModel(
            id: "coke_fountain",
            title: "COCA-COLA FOUNTAIN",
            category: .beverages,
            description: "Choice of fountain sodas: Coca-Cola, Diet Coke, Sprite, Dr Pepper.",
            price: "$2.79",
            imageName: "coke",
            tag: nil,
            isVeg: true,
            isVegan: true,
            calories: "140 cal",
            isSoldOut: false,
            isFavorite: false
        ),
        
        // MARK: Extra
        MenuItemModel(
            id: "hot_honey",
            title: "MIKE'S HOT HONEY DIP",
            category: .extra,
            description: "Honey infused with chili peppers. The perfect sweet-heat pizza drizzle.",
            price: "$1.25",
            imageName: "Mike's Hot Honey",
            tag: "Staff Pick",
            isVeg: true,
            isVegan: false,
            calories: "90 cal",
            isSoldOut: false,
            isFavorite: false
        ),
        MenuItemModel(
            id: "ranch_dip",
            title: "CREAMY RANCH CUP",
            category: .extra,
            description: "House-made herb buttermilk ranch dipping sauce.",
            price: "$0.99",
            imageName: "Ranch",
            tag: nil,
            isVeg: true,
            isVegan: false,
            calories: "140 cal",
            isSoldOut: false,
            isFavorite: false
        ),
        MenuItemModel(
            id: "balsamic_glaze",
            title: "BALSAMIC FIG GLAZE",
            category: .extra,
            description: "Tangy sweet Italian Modena balsamic glaze reduction.",
            price: "$1.25",
            imageName: "Balsamic Fig Glaze",
            tag: nil,
            isVeg: true,
            isVegan: true,
            calories: "80 cal",
            isSoldOut: false,
            isFavorite: false
        ),
        MenuItemModel(
            id: "garlic_dip",
            title: "ROASTED GARLIC DIP",
            category: .extra,
            description: "Slow-roasted whole garlic cloves in extra virgin olive oil.",
            price: "$1.00",
            imageName: "Garlic Roasted",
            tag: nil,
            isVeg: true,
            isVegan: true,
            calories: "110 cal",
            isSoldOut: false,
            isFavorite: false
        ),
        MenuItemModel(
            id: "bbq_cup",
            title: "BBQ DRIZZLE CUP",
            category: .extra,
            description: "Sweet smoky hickory BBQ dipping sauce.",
            price: "$0.99",
            imageName: "BBQ",
            tag: nil,
            isVeg: true,
            isVegan: true,
            calories: "70 cal",
            isSoldOut: false,
            isFavorite: false
        )
    ]
    
    // MARK: - Filtered Categories & Items
    
    private var visibleCategories: [MenuCategory] {
        if activeCategory == .all {
            return MenuCategory.allCases.filter { $0 != .all }
        } else {
            return [activeCategory]
        }
    }
    
    private func items(for category: MenuCategory) -> [MenuItemModel] {
        allMenuItems.filter { item in
            guard item.category == category else { return false }
            
            // Search Query Filter
            if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {
                let q = searchText.lowercased()
                let matchesTitle = item.title.lowercased().contains(q)
                let matchesDesc = item.description.lowercased().contains(q)
                let matchesTag = item.tag?.lowercased().contains(q) ?? false
                if !(matchesTitle || matchesDesc || matchesTag) {
                    return false
                }
            }
            
            // Dietary Filter
            switch activeDietFilter {
            case .all:
                return true
            case .veg:
                return item.isVeg || item.isVegan
            case .nonVeg:
                return !item.isVeg && !item.isVegan
            case .vegan:
                return item.isVegan
            }
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Color("app_background")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Custom Navigation Bar
                topNavigationBar
                
                // Scrollable Content
                ScrollViewReader { scrollProxy in
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 16) {
                            // 1. Order Setup Summary Card
                            orderModeCard
                            
                            // 2. MENU Title & Store Info
                            menuTitleSection
                            
                            // 3. Search Bar
                            searchBar
                            
                            // 4. Horizontal Category Pills
                            categoryPillsRow(scrollProxy: scrollProxy)
                            
                            // 5. Dietary Filter Capsule Bar
                            dietaryFilterBar
                            
                            // 6. Menu Sections (Categorized Items)
                            menuSectionsList
                            
                            Spacer()
                                .frame(height: CartManager.shared.totalItemCount > 0 ? 80 : 50)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 10)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            if let initial = initialCategory {
                activeCategory = initial
            } else if coordinator.selectedCategory != .all {
                activeCategory = coordinator.selectedCategory
            }
        }
        .onReceive(coordinator.$selectedCategory) { newCategory in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                activeCategory = newCategory
            }
        }
        .sheet(isPresented: $showOrderSetup) {
            OrderSetupView(
                initialOrderType: orderSetupInitialTab,
                autoScrollToWhen: orderSetupAutoScrollToWhen,
                currentStoreName: storeName,
                currentDeliveryAddress: deliveryAddress,
                currentPickupOption: pickupOption,
                currentWhenText: whenText,
                onDone: { newOrderType, newStoreName, newPickupOption, newAddress, newWhen in
                    selectedOrderType = newOrderType
                    storeName = newStoreName
                    pickupOption = newPickupOption
                    deliveryAddress = newAddress
                    whenText = newWhen
                    
                    if newWhen.lowercased().hasPrefix("asap") {
                        whenSubtitle = "Schedule for later"
                    } else {
                        whenSubtitle = newOrderType == 0 ? "Scheduled pickup" : "Scheduled delivery"
                    }
                    
                    showOrderSetup = false
                }
            )
        }
        .fullScreenCover(item: $selectedItemForCustomization) { item in
            MenuCustomizationView(
                pizzaTitle: item.title,
                pizzaCategory: "PIZZAS",
                pizzaDescription: item.description,
                pizzaImageName: item.imageName,
                showRecipeStyle: false, // Recipe style is strictly hidden for particular pizzas in Menu
                onBack: {
                    selectedItemForCustomization = nil
                }
            )
        }
    }
    
    // MARK: - Top Navigation Bar
    
    private var topNavigationBar: some View {
        ZStack {
            // Center: Screen Title
            Text("Menu")
                .font(.barlowBold(size: 18))
                .foregroundColor(Color("app_black"))
            
            // Left & Right Bar Buttons
            HStack {
                if showDismissButton {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color("app_black"))
                            .frame(width: 36, height: 36)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Spacer()
                
                HStack(spacing: 16) {
                    // Profile Icon
                    Button(action: {
                        onProfileTap?()
                    }) {
                        Image(systemName: "person")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundColor(Color("app_black"))
                            .frame(width: 34, height: 34)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Cart Icon with Live Item Count Badge
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
        }
        .padding(.horizontal, 20)
        .padding(.top, 4)
        .padding(.bottom, 8)
        .background(Color("app_background"))
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
                            .font(.barlowSemiBold(size: 14.5))
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
                                            .stroke(Color("Button_red"), lineWidth: 1.6)
                                    )
                                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
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
                            .font(.barlowSemiBold(size: 14.5))
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
                                            .stroke(Color("Button_red"), lineWidth: 1.6)
                                    )
                                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
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
            
            // Store & When Rows
            VStack(spacing: 0) {
                // Store Row
                Button(action: {
                    orderSetupInitialTab = selectedOrderType
                    orderSetupAutoScrollToWhen = false
                    showOrderSetup = true
                }) {
                    HStack(spacing: 14) {
                        Image(systemName: "storefront")
                            .font(.system(size: 17))
                            .foregroundColor(Color("Button_red"))
                            .frame(width: 24, height: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(selectedOrderType == 0 ? pickupOption : "Delivering from")
                                .font(.barlowRegular(size: 12))
                                .foregroundColor(Color("text_gary"))
                            Text(storeName)
                                .font(.barlowBold(size: 15))
                                .foregroundColor(Color("app_black"))
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color("text_gary").opacity(0.7))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .buttonStyle(PlainButtonStyle())
                
                Divider()
                    .background(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDF / 255.0))
                
                // When Row
                Button(action: {
                    orderSetupInitialTab = selectedOrderType
                    orderSetupAutoScrollToWhen = true
                    showOrderSetup = true
                }) {
                    HStack(spacing: 14) {
                        Image(systemName: "clock")
                            .font(.system(size: 17))
                            .foregroundColor(Color("Button_red"))
                            .frame(width: 24, height: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("When")
                                .font(.barlowRegular(size: 12))
                                .foregroundColor(Color("text_gary"))
                            Text(whenText)
                                .font(.barlowBold(size: 15))
                                .foregroundColor(Color("app_black"))
                            Text(whenSubtitle)
                                .font(.barlowMedium(size: 12))
                                .foregroundColor(Color(red: 0x9E / 255.0, green: 0x66 / 255.0, blue: 0x22 / 255.0))
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
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
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
        )
    }
    
    // MARK: - MENU Title Section
    
    private var menuTitleSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("MENU")
                .font(.oswaldBold(size: 32))
                .tracking(0.8)
                .foregroundColor(Color("app_black"))
            
            Text("\(storeName.components(separatedBy: ",").first ?? storeName) · prices for this store")
                .font(.barlowRegular(size: 13))
                .foregroundColor(Color("text_gary"))
        }
        .padding(.top, 4)
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundColor(Color("text_gary"))
            
            TextField("Search pizzas, toppings, drinks...", text: $searchText)
                .font(.barlowRegular(size: 14.5))
                .foregroundColor(Color("app_black"))
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color("text_gary"))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 44)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.gray.opacity(0.25), lineWidth: 1)
        )
    }
    
    // MARK: - Horizontal Category Pills
    
    private func categoryPillsRow(scrollProxy: ScrollViewProxy) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(MenuCategory.allCases, id: \.self) { category in
                    categoryPillButton(category: category)
                }
            }
            .padding(.vertical, 2)
        }
    }
    
    private func categoryPillButton(category: MenuCategory) -> some View {
        let isCatSelected = activeCategory == category
        
        return Button(action: {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                activeCategory = category
                coordinator.selectedCategory = category
            }
        }) {
            Text(category.title)
                .font(isCatSelected ? .barlowBold(size: 13.5) : .barlowSemiBold(size: 13.5))
                .foregroundColor(isCatSelected ? .white : Color("app_black"))
                .padding(.horizontal, 16)
                .frame(height: 36)
                .background(
                    Capsule()
                        .fill(isCatSelected ? Color("Button_red") : Color.white)
                )
                .overlay(
                    Capsule()
                        .stroke(isCatSelected ? Color("Button_red") : Color.gray.opacity(0.25), lineWidth: 1)
                )
                .shadow(color: isCatSelected ? Color("Button_red").opacity(0.2) : Color.black.opacity(0.02), radius: 3, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Dietary Filter Capsule Bar
    
    private var dietaryFilterBar: some View {
        HStack(spacing: 0) {
            ForEach(DietaryFilter.allCases, id: \.self) { filter in
                dietaryFilterButton(filter: filter)
            }
        }
        .padding(3)
        .background(
            Capsule()
                .fill(Color(red: 0xF3 / 255.0, green: 0xEC / 255.0, blue: 0xDE / 255.0))
        )
    }
    
    private func dietaryFilterButton(filter: DietaryFilter) -> some View {
        let isFilterSelected = activeDietFilter == filter
        
        return Button(action: {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                activeDietFilter = filter
            }
        }) {
            HStack(spacing: 6) {
                switch filter {
                case .all:
                    EmptyView()
                case .veg:
                    ZStack {
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(Color("kale_green"), lineWidth: 1.4)
                            .frame(width: 14, height: 14)
                        Circle()
                            .fill(Color("kale_green"))
                            .frame(width: 6, height: 6)
                    }
                case .nonVeg:
                    ZStack {
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(Color(red: 0x8A / 255.0, green: 0x2A / 255.0, blue: 0x28 / 255.0), lineWidth: 1.4)
                            .frame(width: 14, height: 14)
                        Image(systemName: "triangle.fill")
                            .font(.system(size: 6))
                            .foregroundColor(Color(red: 0x8A / 255.0, green: 0x2A / 255.0, blue: 0x28 / 255.0))
                    }
                case .vegan:
                    ZStack {
                        Circle()
                            .stroke(Color("kale_green"), lineWidth: 1.4)
                            .frame(width: 14, height: 14)
                        Circle()
                            .fill(Color("kale_green"))
                            .frame(width: 6, height: 6)
                    }
                }
                
                Text(filter.rawValue)
                    .font(.barlowSemiBold(size: 13))
                    .foregroundColor(isFilterSelected ? Color("app_black") : Color("app_black").opacity(0.75))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 36)
            .background(
                Group {
                    if isFilterSelected {
                        Capsule()
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.06), radius: 2, x: 0, y: 1)
                    } else {
                        Color.clear
                    }
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Menu Sections List
    
    private var menuSectionsList: some View {
        VStack(alignment: .leading, spacing: 24) {
            ForEach(visibleCategories, id: \.self) { category in
                let categoryItems = items(for: category)
                
                if !categoryItems.isEmpty {
                    VStack(alignment: .leading, spacing: 14) {
                        // Section Title & Counter Badge & Accent Underline
                        VStack(alignment: .leading, spacing: 5) {
                            HStack(spacing: 8) {
                                Text(category.sectionTitle)
                                    .font(.oswaldBold(size: 22))
                                    .tracking(0.8)
                                    .foregroundColor(Color("app_black"))
                                
                                Text("\(categoryItems.count)")
                                    .font(.barlowBold(size: 11.5))
                                    .foregroundColor(Color("text_gary"))
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 2)
                                    .background(
                                        Capsule()
                                            .fill(Color(red: 0xEE / 255.0, green: 0xEE / 255.0, blue: 0xEE / 255.0))
                                    )
                                
                                Spacer()
                            }
                            
                            // Colored Accent Bar (e.g. Red for Pizzas, Green for Salads)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(category.accentColor)
                                .frame(width: 44, height: 3)
                        }
                        
                        // Items in this Category
                        VStack(spacing: 12) {
                            ForEach(categoryItems) { item in
                                menuItemCard(item: item)
                            }
                        }
                    }
                    .id(category.id)
                }
            }
        }
    }
    
    // MARK: - Menu Item Card
    
    private func menuItemCard(item: MenuItemModel) -> some View {
        let isFav = favoritesState[item.id] ?? item.isFavorite
        
        return HStack(spacing: 0) {
            // Left Image Container (Circular cutout food image on pizza_found background matching snapshot)
            ZStack(alignment: .topLeading) {
                // Background Warm Cream Box
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
                
                // Item tag badge at top-left (e.g. Popular, Value, New, Sold out)
                if let tag = item.tag {
                    Text(tag)
                        .font(.oswaldMedium(size: 11))
                        .tracking(0.4)
                        .foregroundColor(.white)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(item.isSoldOut ? Color.gray.opacity(0.85) : Color("roma_red"))
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
                    // Item Name using Oswald Light Font (as per instruction, in dark red/burgundy)
                    Text(item.title)
                        .font(.oswaldLight(size: 19))
                        .tracking(0.4)
                        .foregroundColor(Color(red: 0x8A / 255.0, green: 0x1E / 255.0, blue: 0x2D / 255.0))
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // Favorite Heart Button
                    Button(action: {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
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
                
                // Description (NO TRUNCATION - full text visible across natural lines)
                Text(item.description)
                    .font(.barlowRegular(size: 13))
                    .foregroundColor(Color("text_gary"))
                    .lineLimit(nil)
                    .lineSpacing(2.5)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Dietary Pill & Calorie Row
                HStack(spacing: 8) {
                    dietaryBadge(isVeg: item.isVeg, isVegan: item.isVegan)
                    
                    Text(item.calories)
                        .font(.barlowRegular(size: 12.5))
                        .foregroundColor(Color("text_gary"))
                    
                    Spacer()
                }
                .padding(.top, 2)
                
                // Price & Action Button Row
                HStack(alignment: .center) {
                    Text(item.price)
                        .font(.oswaldBold(size: 21))
                        .foregroundColor(Color("app_black"))
                    
                    Spacer()
                    
                    if item.isSoldOut {
                        Text("SOLD OUT")
                            .font(.oswaldMedium(size: 13))
                            .tracking(0.8)
                            .foregroundColor(Color.gray.opacity(0.7))
                            .padding(.horizontal, 18)
                            .frame(height: 36)
                            .background(
                                Capsule()
                                    .fill(Color(red: 0xF2 / 255.0, green: 0xF2 / 255.0, blue: 0xF2 / 255.0))
                            )
                    } else {
                        Button(action: {
                            if item.category == .pizzas || item.category == .salads {
                                if let onCustomizeItem = onCustomizeItem {
                                    onCustomizeItem(item)
                                } else {
                                    selectedItemForCustomization = item
                                }
                            } else {
                                let priceVal = Double(item.price.replacingOccurrences(of: "$", with: "")) ?? 3.99
                                let calVal = Int(item.calories.components(separatedBy: " ").first ?? "")
                                CartManager.shared.addItem(
                                    title: item.title,
                                    price: priceVal,
                                    quantity: 1,
                                    details: item.description,
                                    calories: calVal,
                                    imageName: item.imageName
                                )
                                onAddItem?(item)
                            }
                        }) {
                            Text(item.category == .pizzas || item.category == .salads ? "CUSTOMIZE" : "+ ADD")
                                .font(.oswaldMedium(size: 13.5))
                                .tracking(1.0)
                                .foregroundColor(.white)
                                .padding(.horizontal, 18)
                                .frame(height: 36)
                                .background(
                                    Capsule()
                                        .fill(Color("Button_red"))
                                        .shadow(color: Color("Button_red").opacity(0.3), radius: 4, x: 0, y: 2)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
        .frame(minHeight: 148)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.2)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
    
    // MARK: - Dietary Badge Helper
    
    private func dietaryBadge(isVeg: Bool, isVegan: Bool) -> some View {
        let dietaryColor: Color = (isVeg || isVegan) ? Color("kale_green") : Color(red: 0x8A / 255.0, green: 0x2A / 255.0, blue: 0x28 / 255.0)
        let title: String = isVegan ? "Vegan" : (isVeg ? "Veg" : "Non-veg")
        
        return HStack(spacing: 5) {
            ZStack {
                if isVegan {
                    Circle()
                        .stroke(dietaryColor, lineWidth: 1.2)
                        .frame(width: 13, height: 13)
                    Circle()
                        .fill(dietaryColor)
                        .frame(width: 6, height: 6)
                } else if isVeg {
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(dietaryColor, lineWidth: 1.2)
                        .frame(width: 13, height: 13)
                    Circle()
                        .fill(dietaryColor)
                        .frame(width: 6, height: 6)
                } else {
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(dietaryColor, lineWidth: 1.2)
                        .frame(width: 13, height: 13)
                    Image(systemName: "triangle.fill")
                        .font(.system(size: 6))
                        .foregroundColor(dietaryColor)
                }
            }
            
            Text(title)
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
    }
}

// MARK: - Preview

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}

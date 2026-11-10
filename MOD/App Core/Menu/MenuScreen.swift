//
//  MenuScreen.swift
//  MOD
//
//  Created by Rajpal singh on 07/11/26.
//

import SwiftUI

struct MenuScreen: View {
    @Environment(\.dismiss) private var dismiss
    var showBackButton: Bool = false

    @State private var searchText: String = ""
    @State private var selectedDietary: DietaryFilter = .all
    @State private var selectedCategory: CategoryFilter = .all
    @State private var selectedTab: MenuTab = .classicPizzas
    @State private var showMenuCustomization: Bool = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                
                // 1. Header (Menu + Delivery Location + Notification Bell)
                HStack(alignment: .top, spacing: 12) {
                    if showBackButton {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black)
                                .frame(width: 40, height: 40)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
                        }
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Menu")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.black)
                        Text("Delivering to Silva Ave, Apt 4B")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // Notification Button
                    ZStack(alignment: .topTrailing) {
                        Button(action: {}) {
                            Image(systemName: "bell")
                                .font(.system(size: 18))
                                .foregroundColor(.black)
                                .frame(width: 44, height: 44)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
                        }
                        
                        // Badge
                        Text("3")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 18, height: 18)
                            .background(Color.red)
                            .clipShape(Circle())
                            .offset(x: -2, y: 2)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)

                // 2. Search Bar
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                    
                    TextField("Search pizzas, sides, beverages...", text: $searchText)
                        .font(.system(size: 14))
                }
                .padding(.horizontal, 14)
                .frame(height: 44)
                .background(Color(red: 0.96, green: 0.96, blue: 0.97))
                .cornerRadius(12)
                .padding(.horizontal, 16)

                // 3. Filter Chips - Row 1 (Dietary)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(DietaryFilter.allCases, id: \.self) { filter in
                            DietaryChip(filter: filter, isSelected: selectedDietary == filter) {
                                selectedDietary = filter
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }

                // 4. Filter Chips - Row 2 (Categories)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(CategoryFilter.allCases, id: \.self) { cat in
                            CategoryChip(category: cat, isSelected: selectedCategory == cat) {
                                selectedCategory = cat
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }

                // 5. Section Tabs (Promotions & Deals, Classic Pizzas, Traditional & Specialty)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 24) {
                        ForEach(MenuTab.allCases, id: \.self) { tab in
                            VStack(spacing: 8) {
                                Text(tab.rawValue)
                                    .font(.system(size: 14, weight: selectedTab == tab ? .bold : .semibold))
                                    .foregroundColor(selectedTab == tab ? .red : .gray)
                                
                                // Red Underline Indicator
                                Rectangle()
                                    .fill(selectedTab == tab ? Color.red : Color.clear)
                                    .frame(height: 2.5)
                                    .cornerRadius(1.5)
                            }
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedTab = tab
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.top, 2)

                // 6. Create Your Own Pizza Hero Banner
                CreateYourOwnBanner(onStartBuilding: {
                    showMenuCustomization = true
                })
                    .padding(.horizontal, 16)

                // 7. Classic Pizzas Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Classic Pizzas")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                        Spacer()
                        Text("\(MenuMockData.classicPizzas.count) items")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 16)

                    VStack(spacing: 12) {
                        ForEach(filteredClassicPizzas) { pizza in
                            MenuPizzaCard(pizza: pizza)
                        }
                    }
                    .padding(.horizontal, 16)
                }

                // 8. Traditional Pizzas Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Traditional Pizzas")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                        Spacer()
                        Text("\(MenuMockData.traditionalPizzas.count) items")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 16)

                    VStack(spacing: 12) {
                        ForEach(filteredTraditionalPizzas) { pizza in
                            MenuPizzaCard(pizza: pizza)
                        }
                    }
                    .padding(.horizontal, 16)
                }

                // 9. Bundle Deals Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        HStack(spacing: 8) {
                            Text("COMBO SAVER")
                                .font(.system(size: 10, weight: .heavy))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.red)
                                .cornerRadius(5)

                            Text("Bundle Deals")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                        }
                        
                        Spacer()
                        
                        Text("Save up to 30%")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 16)

                    VStack(spacing: 14) {
                        ForEach(MenuMockData.bundleDeals) { deal in
                            BundleDealCard(deal: deal)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                // Bottom Spacing
                Color.clear.frame(height: 20)
            }
            .padding(.vertical, 10)
        }
        .background(Color(red: 0.98, green: 0.98, blue: 0.99))
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showMenuCustomization) {
            MenuCustomization()
        }
    }

    // MARK: - Filter Logic

    private var filteredClassicPizzas: [MenuPizza] {
        MenuMockData.classicPizzas.filter { pizza in
            matchesSearch(pizza.name) && matchesDietary(isVeg: pizza.isVeg, isNonVeg: pizza.isNonVeg, isVegan: pizza.isVegan)
        }
    }

    private var filteredTraditionalPizzas: [MenuPizza] {
        MenuMockData.traditionalPizzas.filter { pizza in
            matchesSearch(pizza.name) && matchesDietary(isVeg: pizza.isVeg, isNonVeg: pizza.isNonVeg, isVegan: pizza.isVegan)
        }
    }

    private func matchesSearch(_ title: String) -> Bool {
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty { return true }
        return title.localizedCaseInsensitiveContains(searchText)
    }

    private func matchesDietary(isVeg: Bool, isNonVeg: Bool, isVegan: Bool) -> Bool {
        switch selectedDietary {
        case .all: return true
        case .veg: return isVeg
        case .nonVeg: return isNonVeg
        case .vegan: return isVegan
        }
    }
}

// MARK: - Enums

enum DietaryFilter: String, CaseIterable {
    case all = "All"
    case veg = "Veg"
    case nonVeg = "Non-Veg"
    case vegan = "Vegan"
}

enum CategoryFilter: String, CaseIterable {
    case all = "All"
    case classic = "Classic"
    case specialty = "Specialty"
    case sidesDrinks = "Sides & Drinks"
}

enum MenuTab: String, CaseIterable {
    case promos = "Promotions & Deals"
    case classicPizzas = "Classic Pizzas"
    case traditionalSpecialty = "Traditional & Specialty"
}

// MARK: - Chips & Filters

struct DietaryChip: View {
    let filter: DietaryFilter
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                switch filter {
                case .all:
                    EmptyView()
                case .veg:
                    VegSymbolView()
                case .nonVeg:
                    NonVegSymbolView()
                case .vegan:
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 11))
                        .foregroundColor(Color(red: 0.12, green: 0.65, blue: 0.38))
                }
                
                Text(filter.rawValue)
                    .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? .white : .black)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(isSelected ? Color.black : Color.white)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.black : Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

struct CategoryChip: View {
    let category: CategoryFilter
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                switch category {
                case .all:
                    EmptyView()
                case .classic:
                    Text("🍕")
                        .font(.system(size: 12))
                case .specialty:
                    Text("★")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                case .sidesDrinks:
                    Text("🥤")
                        .font(.system(size: 12))
                }
                
                Text(category.rawValue)
                    .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? .white : .black)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(isSelected ? Color.black : Color.white)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.black : Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

struct VegSymbolView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3)
                .stroke(Color(red: 0.12, green: 0.65, blue: 0.38), lineWidth: 1.5)
                .frame(width: 13, height: 13)
            Circle()
                .fill(Color(red: 0.12, green: 0.65, blue: 0.38))
                .frame(width: 6, height: 6)
        }
    }
}

struct NonVegSymbolView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3)
                .stroke(Color(red: 0.85, green: 0.2, blue: 0.2), lineWidth: 1.5)
                .frame(width: 13, height: 13)
            TriangleShape()
                .fill(Color(red: 0.85, green: 0.2, blue: 0.2))
                .frame(width: 6, height: 6)
        }
    }
}

struct TriangleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Create Your Own Pizza Banner

struct CreateYourOwnBanner: View {
    var onStartBuilding: (() -> Void)? = nil

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background Image
            if let _ = UIImage(named: "yourOwnPizza") {
                Image("yourOwnPizza")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 195)
                    .clipped()
            } else {
                Color.black
                    .frame(height: 195)
            }

            // Dark Gradient Overlay for Readability
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.88),
                    Color.black.opacity(0.65),
                    Color.black.opacity(0.3)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )

            // Content
            VStack(alignment: .leading, spacing: 8) {
                // Top Badges
                HStack {
                    HStack(spacing: 4) {
                        Text("⚡")
                            .font(.system(size: 11))
                        Text("CRAFT YOUR OWN")
                            .font(.system(size: 10, weight: .heavy))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(Color(red: 0.95, green: 0.62, blue: 0.12))
                    .cornerRadius(6)

                    Spacer()

                    HStack(spacing: 3) {
                        Text("From")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.85))
                        Text("$13.99")
                            .font(.system(size: 12, weight: .heavy))
                            .foregroundColor(Color(red: 1.0, green: 0.82, blue: 0.2))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.55))
                    .cornerRadius(6)
                }

                // Title & Subtitle
                Text("Create Your Own Pizza")
                    .font(.system(size: 19, weight: .heavy))
                    .foregroundColor(.white)

                Text("Pick your crust, signature sauce, cheeses & infinite toppings freshly baked just for you.")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.88))
                    .lineLimit(2)

                // Feature Pills
                HStack(spacing: 8) {
                    BannerTag(emoji: "🔥", text: "Fresh Dough")
                    BannerTag(emoji: "🧀", text: "3 Cheeses")
                    BannerTag(emoji: "🌶️", text: "20+ Toppings")
                }

                // Footer Row
                HStack {
                    HStack(spacing: 5) {
                        Circle()
                            .fill(Color(red: 0.12, green: 0.75, blue: 0.45))
                            .frame(width: 6, height: 6)
                        Text("Custom crust & drizzle")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.85))
                    }

                    Spacer()

                    Button(action: {
                        onStartBuilding?()
                    }) {
                        HStack(spacing: 4) {
                            Text("Start Building")
                                .font(.system(size: 12, weight: .bold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.red)
                        .cornerRadius(20)
                    }
                }
                .padding(.top, 2)
            }
            .padding(14)
        }
        .frame(height: 195)
        .cornerRadius(18)
        .clipped()
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        .onTapGesture {
            onStartBuilding?()
        }
    }
}

struct BannerTag: View {
    let emoji: String
    let text: String

    var body: some View {
        HStack(spacing: 4) {
            Text(emoji)
                .font(.system(size: 10))
            Text(text)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3.5)
        .background(Color.white.opacity(0.2))
        .cornerRadius(6)
    }
}

// MARK: - Pizza Card (Horizontal List Item)

struct MenuPizzaCard: View {
    let pizza: MenuPizza

    var body: some View {
        HStack(spacing: 12) {
            // Image with Badge
            ZStack(alignment: .topLeading) {
                if let _ = UIImage(named: pizza.imageName) {
                    Image(pizza.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 96, height: 96)
                        .cornerRadius(14)
                        .clipped()
                } else {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.gray.opacity(0.15))
                        .frame(width: 96, height: 96)
                }

                if let badge = pizza.badge {
                    Text(badge)
                        .font(.system(size: 9, weight: .heavy))
                        .foregroundColor(pizza.badgeTextColor ?? .white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(pizza.badgeBgColor ?? Color.red)
                        .cornerRadius(5)
                        .padding(5)
                }
            }
            .frame(width: 96, height: 96)

            // Text Info & Price
            VStack(alignment: .leading, spacing: 4) {
                Text(pizza.name)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.black)
                    .lineLimit(1)

                Text(pizza.description)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .lineLimit(2)

                Spacer(minLength: 4)

                HStack(alignment: .firstTextBaseline) {
                    HStack(spacing: 6) {
                        Text(pizza.price)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.red)

                        if let original = pizza.originalPrice {
                            Text(original)
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                                .strikethrough()
                        }
                    }

                    Spacer()

                    // Add Button (+)
                    Button(action: {}) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 34, height: 34)
                            .background(Color.red)
                            .clipShape(Circle())
                    }
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
    }
}

// MARK: - Bundle Deal Card

struct BundleDealCard: View {
    let deal: BundleDeal

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Top Tags Row
            HStack(spacing: 8) {
                // Tag 1 (e.g. TOP VALUE / FAMILY SIZE)
                HStack(spacing: 4) {
                    Text(deal.tag1Icon)
                        .font(.system(size: 10))
                    Text(deal.tag1Text)
                        .font(.system(size: 10, weight: .heavy))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 7)
                .padding(.vertical, 3.5)
                .background(deal.tag1Color)
                .cornerRadius(5)

                // Tag 2 (e.g. Serves 2 / Best Seller)
                HStack(spacing: 4) {
                    Text(deal.tag2Icon)
                        .font(.system(size: 10))
                    Text(deal.tag2Text)
                        .font(.system(size: 10, weight: .semibold))
                }
                .foregroundColor(Color(red: 0.35, green: 0.38, blue: 0.45))
                .padding(.horizontal, 7)
                .padding(.vertical, 3.5)
                .background(Color(red: 0.94, green: 0.95, blue: 0.97))
                .cornerRadius(5)

                Spacer()

                // Save Tag
                Text(deal.saveText)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(red: 0.12, green: 0.62, blue: 0.38))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color(red: 0.91, green: 0.98, blue: 0.94))
                    .cornerRadius(6)
            }

            // Title & Subtitle
            Text(deal.title)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.black)

            Text(deal.subtitle)
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .lineLimit(2)

            // Price & Actions Row
            HStack {
                HStack(spacing: 6) {
                    Text(deal.price)
                        .font(.system(size: 17, weight: .heavy))
                        .foregroundColor(.red)

                    Text(deal.originalPrice)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .strikethrough()
                }

                Spacer()

                // Customize Button
                Button(action: {}) {
                    Text("Customize")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Color.white)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }

                // Add Button (+)
                Button(action: {}) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 34, height: 34)
                        .background(Color.red)
                        .clipShape(Circle())
                }
            }
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
    }
}

// MARK: - Data Models

struct MenuPizza: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let price: String
    var originalPrice: String? = nil
    let imageName: String
    var badge: String? = nil
    var badgeBgColor: Color? = nil
    var badgeTextColor: Color? = nil
    var isVeg: Bool = false
    var isNonVeg: Bool = true
    var isVegan: Bool = false
}

struct BundleDeal: Identifiable {
    let id = UUID()
    let tag1Icon: String
    let tag1Text: String
    let tag1Color: Color
    let tag2Icon: String
    let tag2Text: String
    let saveText: String
    let title: String
    let subtitle: String
    let price: String
    let originalPrice: String
}

// MARK: - Mock Data

struct MenuMockData {
    static let classicPizzas: [MenuPizza] = [
        MenuPizza(
            name: "Pepperoni",
            description: "Generous slices of crispy pepperoni served over our signature melted...",
            price: "$16.99",
            originalPrice: "$19.99",
            imageName: "pizza1",
            badge: "★ BEST SELLER",
            badgeBgColor: Color.white.opacity(0.92),
            badgeTextColor: Color.red,
            isVeg: false,
            isNonVeg: true
        ),
        MenuPizza(
            name: "Pepperoni & Cream Cheese",
            description: "Signature pepperoni layered with rich cream cheese lattice swirl over melted...",
            price: "$17.99",
            originalPrice: nil,
            imageName: "pizza2",
            badge: "POPULAR",
            badgeBgColor: Color(red: 0.96, green: 0.65, blue: 0.12),
            badgeTextColor: .white,
            isVeg: false,
            isNonVeg: true
        ),
        MenuPizza(
            name: "Smoked Sausage & Cream Cheese",
            description: "Savory sliced artisan sausage paired with sweet sliced onions, olives, and...",
            price: "$17.99",
            originalPrice: nil,
            imageName: "pizza3",
            badge: nil,
            isVeg: false,
            isNonVeg: true
        )
    ]

    static let traditionalPizzas: [MenuPizza] = [
        MenuPizza(
            name: "Smoked Sausage & Onion",
            description: "Savory sliced artisan sausage paired with sweet sliced onions, olives, and...",
            price: "$16.99",
            originalPrice: nil,
            imageName: "pizza3",
            badge: "CLASSIC",
            badgeBgColor: Color(red: 0.18, green: 0.18, blue: 0.22),
            badgeTextColor: .white,
            isVeg: false,
            isNonVeg: true
        ),
        MenuPizza(
            name: "Chicken & Cream Cheese",
            description: "Signature pepperoni layered with rich cream cheese lattice swirl over melted...",
            price: "$17.99",
            originalPrice: nil,
            imageName: "pizza2",
            badge: nil,
            isVeg: false,
            isNonVeg: true
        )
    ]

    static let bundleDeals: [BundleDeal] = [
        BundleDeal(
            tag1Icon: "🔥",
            tag1Text: "TOP VALUE",
            tag1Color: Color.red,
            tag2Icon: "👥",
            tag2Text: "Serves 2",
            saveText: "Save 24%",
            title: "Meal for 2: Pizza & Sides Duo",
            subtitle: "1 Medium Pizza + Garlic Breadsticks + 2 Cans Coca-Cola (350ml)",
            price: "$24.99",
            originalPrice: "$32.90"
        ),
        BundleDeal(
            tag1Icon: "👨‍👩‍👧‍👦",
            tag1Text: "FAMILY SIZE",
            tag1Color: Color(red: 0.95, green: 0.62, blue: 0.12),
            tag2Icon: "★",
            tag2Text: "Best Seller",
            saveText: "Save $12.50",
            title: "Family Feast Mega Saver",
            subtitle: "2 Large Specialty Pizzas + Stuffed Cheesy Bread + 4 Dips + 2L Soda",
            price: "$39.99",
            originalPrice: "$52.50"
        )
    ]
}

#Preview {
    NavigationView {
        MenuScreen()
    }
}

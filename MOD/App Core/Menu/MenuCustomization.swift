//
//  MenuCustomization.swift
//  MOD
//
//  Created by Rajpal singh on 09/11/26.
//

import SwiftUI

// MARK: - Enums & Models

enum PortionOption: String, CaseIterable, Identifiable {
    case light = "Light"
    case regular = "Regular"
    case extra = "Extra"

    var id: String { rawValue }

    var calorieMultiplier: Double {
        switch self {
        case .light: return 0.6
        case .regular: return 1.0
        case .extra: return 1.5
        }
    }
}

enum PlacementOption: String, CaseIterable, Identifiable {
    case onTop = "On Top"
    case sideCup = "Side Cup"

    var id: String { rawValue }
}

struct CrustOption: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let subtitle: String
    let price: Double
    let calories: Int
    let isBaseIncluded: Bool
    let badge: String?
}

struct SauceItem: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let calories: Int
    let imageName: String
}

struct ToppingItem: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let calories: Int
    let imageName: String
    let category: String
}

struct FinishingSauceItem: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let calories: Int
    let imageName: String
}

struct SideSaladItem: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let ingredients: String
    let calories: Int
    let price: Double
}

// MARK: - Mock Data Source

struct CustomizationMockData {
    static let crusts: [CrustOption] = [
        CrustOption(
            name: "Artisan Thin (11\")",
            subtitle: "Signature crispy charred edge • Standard",
            price: 27.38,
            calories: 380,
            isBaseIncluded: true,
            badge: nil
        ),
        CrustOption(
            name: "Mega Dough Thick (11\")",
            subtitle: "Extra rise, fluffy center, crispy pan crust",
            price: 28.38,
            calories: 560,
            isBaseIncluded: false,
            badge: nil
        ),
        CrustOption(
            name: "Cauliflower Crust (10\")",
            subtitle: "Crisp vegetable base",
            price: 30.38,
            calories: 320,
            isBaseIncluded: false,
            badge: "Gluten-Friendly"
        ),
        CrustOption(
            name: "Gluten-Free Crust (11\")",
            subtitle: "Ancient grains blend",
            price: 29.38,
            calories: 340,
            isBaseIncluded: false,
            badge: nil
        )
    ]

    static let sauces: [SauceItem] = [
        SauceItem(name: "Tomato Sauce", calories: 2, imageName: "Tomato Sauce Dollops"),
        SauceItem(name: "BBQ Sauce", calories: 15, imageName: "BBQ"),
        SauceItem(name: "Creamy Alfredo", calories: 8, imageName: "cream2"),
        SauceItem(name: "Frank's RedHot Buffalo Sauce", calories: 3, imageName: "red"),
        SauceItem(name: "Garlic Rub", calories: 5, imageName: "garlic"),
        SauceItem(name: "Basil Pesto", calories: 12, imageName: "pesto")
    ]

    static let toppings: [ToppingItem] = [
        ToppingItem(name: "Shredded Mozzarella", calories: 120, imageName: "moz", category: "Cheese"),
        ToppingItem(name: "Fresh Mozzarella", calories: 100, imageName: "cream2", category: "Cheese"),
        ToppingItem(name: "Ricotta", calories: 80, imageName: "rico", category: "Cheese"),
        ToppingItem(name: "Pepperoni", calories: 80, imageName: "pizza1", category: "Meat"),
        ToppingItem(name: "Bacon", calories: 60, imageName: "Bacon", category: "Meat"),
        ToppingItem(name: "Grilled Chicken", calories: 50, imageName: "chicken", category: "Meat"),
        ToppingItem(name: "Sliced Tomatoes", calories: 20, imageName: "Tomato Sliced", category: "Veggie"),
        ToppingItem(name: "Mushroom", calories: 10, imageName: "Mushroom", category: "Veggie"),
        ToppingItem(name: "Fresh Basil", calories: 5, imageName: "Basil", category: "Veggie"),
        ToppingItem(name: "Black Olives", calories: 20, imageName: "Black Olives", category: "Veggie"),
        ToppingItem(name: "Roasted Corn", calories: 25, imageName: "Corn Roasted", category: "Veggie"),
        ToppingItem(name: "Jalapeños", calories: 5, imageName: "Jalapeños", category: "Veggie"),
        ToppingItem(name: "Arugula", calories: 5, imageName: "Arugula", category: "Veggie")
    ]

    static let finishingSauces: [FinishingSauceItem] = [
        FinishingSauceItem(name: "Balsamic Fig Glaze", calories: 30, imageName: "Balsamic Fig Glaze"),
        FinishingSauceItem(name: "BBQ Sauce", calories: 30, imageName: "BBQ"),
        FinishingSauceItem(name: "Frank's RedHot Buffalo Sauce", calories: 10, imageName: "red"),
        FinishingSauceItem(name: "Mike's Hot Honey", calories: 35, imageName: "Mike's Hot Honey"),
        FinishingSauceItem(name: "Ranch Dressing", calories: 45, imageName: "Ranch")
    ]

    static let cookingOptions: [String] = [
        "Light Bake",
        "Extra Crispy"
    ]

    static let sideSalads: [SideSaladItem] = [
        SideSaladItem(
            name: "Side Caesar",
            ingredients: "Romaine, Parmesan, Asiago, Croutons, Caesar Dressing",
            calories: 480,
            price: 4.99
        ),
        SideSaladItem(
            name: "Side Garden",
            ingredients: "Mixed Greens, Romaine, Diced Tomatoes, Cucumbers, Herb Vinaigrette",
            calories: 150,
            price: 4.99
        )
    ]
}

// MARK: - Main Screen

struct MenuCustomization: View {
    @Environment(\.dismiss) private var dismiss

    // MARK: - Customizable Pizza Parameters
    var pizzaName: String = "Create Your Own Pizza"
    var pizzaImageName: String = "yourOwnPizza"
    var basePrice: Double = 15.99
    var pizzaDescription: String = "Craft your masterpiece, no extra charges"

    // MARK: - Selections State
    @State private var selectedCrust: CrustOption = CustomizationMockData.crusts[0]
    @State private var selectedSauces: [UUID: PortionOption] = [:]
    @State private var selectedToppings: [UUID: PortionOption] = [:]
    @State private var selectedFinishingSauces: [UUID: PlacementOption] = [:]
    @State private var isSauceNoneSelected: Bool = false
    @State private var isToppingsNoneSelected: Bool = false
    @State private var isFinishingNoneSelected: Bool = false
    @State private var selectedCookingOption: String? = nil
    @State private var selectedSalad: UUID? = nil

    @State private var specialInstructions: String = ""
    @State private var recipientName: String = ""
    @State private var quantity: Int = 1
    @State private var showAddedToast: Bool = false

    // App Branding Colors
    private let modRed = Color(red: 0.78, green: 0.08, blue: 0.18)
    private let bannerPink = Color(red: 1.0, green: 0.94, blue: 0.95)
    private let screenBg = Color(red: 0.98, green: 0.98, blue: 0.99)
    private let borderGray = Color(red: 0.90, green: 0.90, blue: 0.92)

    init(
        pizzaName: String = "Create Your Own Pizza",
        pizzaImageName: String = "yourOwnPizza",
        basePrice: Double = 15.99,
        pizzaDescription: String = "Craft your masterpiece, no extra charges"
    ) {
        self.pizzaName = pizzaName
        self.pizzaImageName = pizzaImageName
        self.basePrice = basePrice
        self.pizzaDescription = pizzaDescription

        _selectedCrust = State(initialValue: CustomizationMockData.crusts[0])
        _selectedSauces = State(initialValue: [:])
        _selectedToppings = State(initialValue: [:])
        _selectedFinishingSauces = State(initialValue: [:])
        _isSauceNoneSelected = State(initialValue: false)
        _isToppingsNoneSelected = State(initialValue: false)
        _isFinishingNoneSelected = State(initialValue: false)
    }

    // MARK: - Calculated Properties

    private var totalToppingsCount: Int {
        selectedSauces.count + selectedToppings.count + selectedFinishingSauces.count
    }

    private var totalCalories: Int {
        var cals = selectedCrust.calories

        for sauce in CustomizationMockData.sauces {
            if let portion = selectedSauces[sauce.id] {
                cals += Int(Double(sauce.calories) * portion.calorieMultiplier)
            }
        }

        for topping in CustomizationMockData.toppings {
            if let portion = selectedToppings[topping.id] {
                cals += Int(Double(topping.calories) * portion.calorieMultiplier)
            }
        }

        for finishing in CustomizationMockData.finishingSauces {
            if selectedFinishingSauces[finishing.id] != nil {
                cals += finishing.calories
            }
        }

        if let saladId = selectedSalad,
           let salad = CustomizationMockData.sideSalads.first(where: { $0.id == saladId }) {
            cals += salad.calories
        }

        return cals
    }

    private var unitPrice: Double {
        let crustExtra = max(selectedCrust.price - CustomizationMockData.crusts[0].price, 0.0)
        var price = basePrice + crustExtra
        if let saladId = selectedSalad,
           let salad = CustomizationMockData.sideSalads.first(where: { $0.id == saladId }) {
            price += salad.price
        }
        return price
    }

    private var totalPrice: Double {
        unitPrice * Double(quantity)
    }

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // 1. Navigation Header
                navigationHeader

                // 2. Scrollable Customization Content
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        // Promo Strip
                        promoBanner

                        // Pizza Image & Status Preview
                        pizzaPreviewCard
                            .padding(.horizontal, 16)

                        // Section 1: Choose Crust & Dough
                        crustSection
                            .padding(.horizontal, 16)

                        // Section 2: Sauces (Required)
                        saucesSection
                            .padding(.horizontal, 16)

                        // Section 3: Cheeses & Toppings
                        toppingsSection
                            .padding(.horizontal, 16)

                        // Section 4: Finishing Sauces
                        finishingSaucesSection
                            .padding(.horizontal, 16)

                        // Section 5: Cooking Instructions
                        cookingInstructionsSection
                            .padding(.horizontal, 16)

                        // Section 6: Add a Side Salad
                        sideSaladSection
                            .padding(.horizontal, 16)

                        // Section 7: Special Instructions
                        specialInstructionsSection
                            .padding(.horizontal, 16)

                        // Section 8: Recipient Name
                        recipientNameSection
                            .padding(.horizontal, 16)

                        // Space for bottom sticky bar
                        Color.clear.frame(height: 120)
                    }
                    .padding(.vertical, 8)
                }
                .background(screenBg)
            }

            // 3. Sticky Bottom Bar
            stickyBottomBar
        }
        .edgesIgnoringSafeArea(.bottom)
        .overlay(
            toastOverlay
        )
    }

    // MARK: - 1. Navigation Header

    private var navigationHeader: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                    .frame(width: 38, height: 38)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 2)
            }

            Spacer()

            Text(pizzaName)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
                .lineLimit(1)

            Spacer()

            // Balance placeholder for center alignment
            Color.clear
                .frame(width: 38, height: 38)
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 10)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 2)
    }

    // MARK: - Promo Banner

    private var promoBanner: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(modRed.opacity(0.12))
                    .frame(width: 36, height: 36)

                Image(systemName: "tag.fill")
                    .font(.system(size: 16))
                    .foregroundColor(modRed)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(pizzaName == "Create Your Own Pizza" ? "1 Flat Price • Unlimited Free Toppings" : "Customize \(pizzaName)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.black)
                    .lineLimit(1)

                Text(pizzaDescription)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .lineLimit(2)

                Text("100% FREE ADD-ONS")
                    .font(.system(size: 9.5, weight: .heavy))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3.5)
                    .background(modRed)
                    .clipShape(Capsule())
                    .padding(.top, 2)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(bannerPink)
    }

    // MARK: - Pizza Preview Card

    private var pizzaPreviewCard: some View {
        VStack(spacing: 12) {
            // Pizza Image
            ZStack {
                if let _ = UIImage(named: pizzaImageName) {
                    Image(pizzaImageName)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .clipped()
                        .cornerRadius(16)
                } else if let _ = UIImage(named: "yourOwnPizza") {
                    Image("yourOwnPizza")
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .clipped()
                        .cornerRadius(16)
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.gray.opacity(0.15))
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                }
            }

            // Status Pill (Kept only size, removed info pill)
            HStack(spacing: 6) {
                Image(systemName: "circle.slash")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(modRed)

                Text("\(pizzaName) • \(selectedCrust.name)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.black)
                    .lineLimit(1)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.white)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
    }

    // MARK: - Section 1: Choose Crust & Dough

    private var crustSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("1. Choose Crust & Dough")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.black)

                    Text("Select your dough base (Single select)")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }

                Spacer()

                requiredBadge
            }

            // Crust Options List
            VStack(spacing: 10) {
                ForEach(CustomizationMockData.crusts) { crust in
                    crustCell(crust: crust, isSelected: selectedCrust == crust)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedCrust = crust
                            }
                        }
                }
            }
        }
    }

    private func crustCell(crust: CrustOption, isSelected: Bool) -> some View {
        HStack(alignment: .center, spacing: 12) {
            // Radio Button
            ZStack {
                if isSelected {
                    Circle()
                        .fill(modRed)
                        .frame(width: 22, height: 22)
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Circle()
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1.5)
                        .frame(width: 22, height: 22)
                }
            }

            // Title (Kept only size, removed info description)
            VStack(alignment: .leading, spacing: 3) {
                if let badge = crust.badge {
                    Text(badge)
                        .font(.system(size: 9.5, weight: .bold))
                        .foregroundColor(Color(red: 0.55, green: 0.38, blue: 0.05))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(red: 0.98, green: 0.93, blue: 0.78))
                        .cornerRadius(4)
                }

                Text(crust.name)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.black)
            }

            Spacer()

            // Price & Calories (Notice: Upgrade text has been removed as per user requirement!)
            VStack(alignment: .trailing, spacing: 2) {
                let crustPrice = basePrice + max(crust.price - CustomizationMockData.crusts[0].price, 0.0)
                Text("$\(String(format: "%.2f", crustPrice))")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)

                if crust.isBaseIncluded {
                    Text("Base Included")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color(red: 0.12, green: 0.65, blue: 0.38))
                }

                Text("\(crust.calories) kcal")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isSelected ? modRed : borderGray, lineWidth: isSelected ? 1.5 : 1)
        )
    }

    // MARK: - Section 2: Sauces (Required)

    private var saucesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Sauces")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.black)

                    Text("Select between 1 and 8 options")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }

                Spacer()

                requiredBadge
            }

            // Sauces List
            VStack(spacing: 12) {
                // "None" option
                noneOptionCell(
                    title: "None",
                    isSelected: isSauceNoneSelected,
                    onToggle: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            if isSauceNoneSelected {
                                isSauceNoneSelected = false
                            } else {
                                isSauceNoneSelected = true
                                selectedSauces.removeAll()
                            }
                        }
                    }
                )

                ForEach(CustomizationMockData.sauces) { sauce in
                    let isSelected = selectedSauces[sauce.id] != nil
                    let portion = selectedSauces[sauce.id] ?? .regular

                    sauceOrToppingCell(
                        name: sauce.name,
                        calories: sauce.calories,
                        imageName: sauce.imageName,
                        isSelected: isSelected,
                        selectedPortion: portion,
                        onToggle: {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                if isSelected {
                                    selectedSauces.removeValue(forKey: sauce.id)
                                } else {
                                    isSauceNoneSelected = false
                                    selectedSauces[sauce.id] = .regular
                                }
                            }
                        },
                        onPortionSelected: { newPortion in
                            withAnimation(.easeInOut(duration: 0.15)) {
                                selectedSauces[sauce.id] = newPortion
                            }
                        }
                    )
                }
            }
        }
    }

    // MARK: - Section 3: Cheeses & Toppings

    private var toppingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            VStack(alignment: .leading, spacing: 2) {
                Text("Cheeses & Toppings")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.black)

                Text("Choose as many as you like • 100% Free")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }

            // Toppings List
            VStack(spacing: 12) {
                // "None" option
                noneOptionCell(
                    title: "None",
                    isSelected: isToppingsNoneSelected,
                    onToggle: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            if isToppingsNoneSelected {
                                isToppingsNoneSelected = false
                            } else {
                                isToppingsNoneSelected = true
                                selectedToppings.removeAll()
                            }
                        }
                    }
                )

                ForEach(CustomizationMockData.toppings) { topping in
                    let isSelected = selectedToppings[topping.id] != nil
                    let portion = selectedToppings[topping.id] ?? .regular

                    sauceOrToppingCell(
                        name: topping.name,
                        calories: topping.calories,
                        imageName: topping.imageName,
                        isSelected: isSelected,
                        selectedPortion: portion,
                        onToggle: {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                if isSelected {
                                    selectedToppings.removeValue(forKey: topping.id)
                                } else {
                                    isToppingsNoneSelected = false
                                    selectedToppings[topping.id] = .regular
                                }
                            }
                        },
                        onPortionSelected: { newPortion in
                            withAnimation(.easeInOut(duration: 0.15)) {
                                selectedToppings[topping.id] = newPortion
                            }
                        }
                    )
                }
            }
        }
    }

    // MARK: - Section 4: Finishing Sauces

    private var finishingSaucesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            VStack(alignment: .leading, spacing: 2) {
                Text("Finishing Sauces")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.black)

                Text("Drizzled after bake • Choose placement")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }

            // Finishing Sauces List
            VStack(spacing: 12) {
                // "None" option
                noneOptionCell(
                    title: "None",
                    isSelected: isFinishingNoneSelected,
                    onToggle: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            if isFinishingNoneSelected {
                                isFinishingNoneSelected = false
                            } else {
                                isFinishingNoneSelected = true
                                selectedFinishingSauces.removeAll()
                            }
                        }
                    }
                )

                ForEach(CustomizationMockData.finishingSauces) { sauce in
                    let isSelected = selectedFinishingSauces[sauce.id] != nil
                    let placement = selectedFinishingSauces[sauce.id] ?? .onTop

                    finishingSauceCell(
                        sauce: sauce,
                        isSelected: isSelected,
                        selectedPlacement: placement,
                        onToggle: {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                if isSelected {
                                    selectedFinishingSauces.removeValue(forKey: sauce.id)
                                } else {
                                    isFinishingNoneSelected = false
                                    selectedFinishingSauces[sauce.id] = .onTop
                                }
                            }
                        },
                        onPlacementSelected: { newPlacement in
                            withAnimation(.easeInOut(duration: 0.15)) {
                                selectedFinishingSauces[sauce.id] = newPlacement
                            }
                        }
                    )
                }
            }
        }
    }

    // MARK: - Reusable None Option Cell

    private func noneOptionCell(title: String, isSelected: Bool, onToggle: @escaping () -> Void) -> some View {
        HStack(spacing: 14) {
            // Circular thumbnail
            ZStack {
                Circle()
                    .fill(Color(white: 0.94))
                    .frame(width: 52, height: 52)

                Image(systemName: "slash.circle")
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? modRed : Color.gray.opacity(0.5))
            }
            .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.black)

                Text("0 Cals")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }

            Spacer()

            // Radio / Checkmark
            ZStack {
                if isSelected {
                    Circle()
                        .fill(modRed)
                        .frame(width: 22, height: 22)
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Circle()
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1.5)
                        .frame(width: 22, height: 22)
                }
            }
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isSelected ? modRed : borderGray, lineWidth: isSelected ? 1.5 : 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onToggle()
        }
    }

    // MARK: - Reusable Sauce & Topping Cell (Opens Light / Regular / Extra on selection)

    private func sauceOrToppingCell(
        name: String,
        calories: Int,
        imageName: String,
        isSelected: Bool,
        selectedPortion: PortionOption,
        onToggle: @escaping () -> Void,
        onPortionSelected: @escaping (PortionOption) -> Void
    ) -> some View {
        VStack(spacing: 12) {
            // Main Row
            HStack(spacing: 14) {
                // Circular thumbnail
                circularThumbnail(imageName: imageName)

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.black)

                    Text("\(calories) Cals")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }

                Spacer()

                // If selected, display Xmark button to remove
                if isSelected {
                    Button(action: onToggle) {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.black.opacity(0.65))
                            .frame(width: 28, height: 28)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                onToggle()
            }

            // Expandable Sub-options: Light | Regular | Extra (Only visible on selection!)
            if isSelected {
                portionSegmentControl(selectedPortion: selectedPortion, onSelect: onPortionSelected)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isSelected ? modRed : borderGray, lineWidth: isSelected ? 1.5 : 1)
        )
    }

    // MARK: - Reusable Finishing Sauce Cell (Opens On Top / Side Cup on selection)

    private func finishingSauceCell(
        sauce: FinishingSauceItem,
        isSelected: Bool,
        selectedPlacement: PlacementOption,
        onToggle: @escaping () -> Void,
        onPlacementSelected: @escaping (PlacementOption) -> Void
    ) -> some View {
        VStack(spacing: 12) {
            // Main Row
            HStack(spacing: 14) {
                // Circular thumbnail
                circularThumbnail(imageName: sauce.imageName)

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(sauce.name)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.black)

                    Text("\(sauce.calories) Cals")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }

                Spacer()

                // Xmark button if selected
                if isSelected {
                    Button(action: onToggle) {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.black.opacity(0.65))
                            .frame(width: 28, height: 28)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                onToggle()
            }

            // Expandable Sub-options: On Top | Side Cup (Only visible on selection!)
            if isSelected {
                placementSegmentControl(selectedPlacement: selectedPlacement, onSelect: onPlacementSelected)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isSelected ? modRed : borderGray, lineWidth: isSelected ? 1.5 : 1)
        )
    }

    // MARK: - Segment Controls

    private func portionSegmentControl(
        selectedPortion: PortionOption,
        onSelect: @escaping (PortionOption) -> Void
    ) -> some View {
        HStack(spacing: 0) {
            ForEach(PortionOption.allCases) { portion in
                let isCurrent = portion == selectedPortion
                Button(action: {
                    onSelect(portion)
                }) {
                    Text(portion.rawValue)
                        .font(.system(size: 13, weight: isCurrent ? .bold : .medium))
                        .foregroundColor(isCurrent ? .white : .black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background(isCurrent ? modRed : Color.clear)
                }
            }
        }
        .background(Color.white)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(borderGray, lineWidth: 1)
        )
    }

    private func placementSegmentControl(
        selectedPlacement: PlacementOption,
        onSelect: @escaping (PlacementOption) -> Void
    ) -> some View {
        HStack(spacing: 0) {
            ForEach(PlacementOption.allCases) { placement in
                let isCurrent = placement == selectedPlacement
                Button(action: {
                    onSelect(placement)
                }) {
                    Text(placement.rawValue)
                        .font(.system(size: 13, weight: isCurrent ? .bold : .medium))
                        .foregroundColor(isCurrent ? .white : .black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background(isCurrent ? modRed : Color.clear)
                }
            }
        }
        .background(Color.white)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(borderGray, lineWidth: 1)
        )
    }

    // MARK: - Circular Thumbnail Helper

    private func circularThumbnail(imageName: String) -> some View {
        ZStack {
            Circle()
                .fill(Color(white: 0.94))
                .frame(width: 52, height: 52)

            if let uiImage = UIImage(named: imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(modRed.opacity(0.15))
                    .frame(width: 48, height: 48)
                Text("🍕")
                    .font(.system(size: 20))
            }
        }
        .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
    }

    // MARK: - Section 5: Cooking Instructions (Optional)

    private var cookingInstructionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Cooking Instructions (Optional)")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.black)

                Text("Select up to 1 option")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }

            VStack(spacing: 10) {
                ForEach(CustomizationMockData.cookingOptions, id: \.self) { option in
                    let isSelected = selectedCookingOption == option
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            if isSelected {
                                selectedCookingOption = nil
                            } else {
                                selectedCookingOption = option
                            }
                        }
                    }) {
                        HStack {
                            Text(option)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.black)

                            Spacer()

                            if isSelected {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(modRed)
                            }
                        }
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isSelected ? modRed : borderGray, lineWidth: isSelected ? 1.5 : 1)
                        )
                    }
                }
            }
        }
    }

    // MARK: - Section 6: Add a Side Salad

    private var sideSaladSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Add a Side Salad")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.black)

                Text("Select up to 1 option")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }

            VStack(spacing: 10) {
                ForEach(CustomizationMockData.sideSalads) { salad in
                    let isSelected = selectedSalad == salad.id
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            if isSelected {
                                selectedSalad = nil
                            } else {
                                selectedSalad = salad.id
                            }
                        }
                    }) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(salad.name + ": " + salad.ingredients)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.black)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)

                                Spacer()

                                if isSelected {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(modRed)
                                }
                            }

                            Text("\(salad.calories) Cals | $\(String(format: "%.2f", salad.price))")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isSelected ? modRed : borderGray, lineWidth: isSelected ? 1.5 : 1)
                        )
                    }
                }
            }
        }
    }

    // MARK: - Section 7: Special Instructions

    private var specialInstructionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Special Instructions")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.black)

            Text("Special instructions? We'll do our best. Note: if an item is not listed on the menu, it is temporarily unavailable.")
                .font(.system(size: 13))
                .foregroundColor(.gray)

            TextField("Enter request (40 character limit)", text: $specialInstructions)
                .font(.system(size: 14))
                .padding(14)
                .background(Color.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(borderGray, lineWidth: 1)
                )
                .onChange(of: specialInstructions) { newValue in
                    if newValue.count > 40 {
                        specialInstructions = String(newValue.prefix(40))
                    }
                }

            Divider()
                .padding(.top, 4)
        }
    }

    // MARK: - Section 8: Recipient Name

    private var recipientNameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Name:")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.black)

            TextField("Enter recipient (32 character limit)", text: $recipientName)
                .font(.system(size: 14))
                .padding(14)
                .background(Color.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(borderGray, lineWidth: 1)
                )
                .onChange(of: recipientName) { newValue in
                    if newValue.count > 32 {
                        recipientName = String(newValue.prefix(32))
                    }
                }
        }
    }

    // MARK: - Sticky Bottom Bar

    private var stickyBottomBar: some View {
        VStack(spacing: 12) {
            // Row 1: Calories & Quantity Stepper
            HStack(spacing: 12) {
                Text("\(totalCalories) Cals")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.black)

                Text("|")
                    .font(.system(size: 15))
                    .foregroundColor(Color.gray.opacity(0.4))

                Spacer()

                HStack(spacing: 12) {
                    Text("Qty.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.black)

                    // Minus Button
                    Button(action: {
                        if quantity > 1 {
                            quantity -= 1
                        }
                    }) {
                        Image(systemName: "minus")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Color(red: 0.25, green: 0.25, blue: 0.28))
                            .clipShape(Circle())
                    }

                    Text("\(quantity)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                        .frame(minWidth: 20)

                    // Plus Button
                    Button(action: {
                        quantity += 1
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Color(red: 0.25, green: 0.25, blue: 0.28))
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)

            // Row 2: Add To Cart Button
            Button(action: {
                withAnimation {
                    showAddedToast = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    dismiss()
                }
            }) {
                Text("ADD TO CART - $\(String(format: "%.2f", totalPrice))")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(modRed)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .background(
            Color.white
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: -4)
        )
    }

    // MARK: - Reusable Badges

    private var requiredBadge: some View {
        Text("Required")
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(modRed)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(bannerPink)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(modRed.opacity(0.3), lineWidth: 1)
            )
    }

    // MARK: - Toast Overlay

    private var toastOverlay: some View {
        Group {
            if showAddedToast {
                VStack {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                        Text("Added to Cart!")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.black.opacity(0.85))
                    .cornerRadius(25)
                    .shadow(radius: 10)
                    .transition(.opacity.combined(with: .scale))

                    Spacer()
                }
                .padding(.top, 60)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    MenuCustomization()
}

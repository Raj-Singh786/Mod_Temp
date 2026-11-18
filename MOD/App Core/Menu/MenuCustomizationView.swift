//
//  MenuCustomizationView.swift
//  MOD
//
//  Created by Rajpal singh on 17/11/26.
//

import SwiftUI

// MARK: - Recipe Style Enum

enum RecipeStyle: String, CaseIterable, Identifiable {
    case whole = "Whole pizza"
    case halfAndHalf = "Half & half"
    
    var id: String { rawValue }
}

// MARK: - Topping Portion & Amount Enums

enum ToppingPortion: String, CaseIterable, Identifiable, Hashable {
    case left = "Left ½"
    case whole = "Whole"
    case right = "Right ½"
    
    var id: String { rawValue }
    
    var shortTitle: String { rawValue }
    
    var calorieMultiplier: Double {
        switch self {
        case .left, .right: return 0.5
        case .whole: return 1.0
        }
    }
}

enum ToppingAmount: String, CaseIterable, Identifiable, Hashable {
    case light = "Light"
    case regular = "Regular"
    case extra = "Extra"
    
    var id: String { rawValue }
    
    var calorieMultiplier: Double {
        switch self {
        case .light: return 0.5
        case .regular: return 1.0
        case .extra: return 1.5
        }
    }
}

// MARK: - Sauce Option Model

struct SauceOption: Identifiable, Hashable {
    let id: String
    let name: String
    let baseCalories: Int
    let dotColor: Color
    var isNoSauce: Bool = false
}

// MARK: - Topping Category Enum

enum ToppingCategory: String, CaseIterable, Identifiable {
    case cheese = "CHEESES"
    case meat = "MEATS"
    case veggie = "VEGGIES & MORE"
    case finish = "FINISHES (AFTER BAKE)"
    
    var id: String { rawValue }
    
    var subtitle: String {
        switch self {
        case .cheese: return "Free unlimited"
        case .meat: return "Free unlimited"
        case .veggie: return "Free unlimited"
        case .finish: return "Added after bake"
        }
    }
}

// MARK: - Customizable Topping Model

struct CustomizableTopping: Identifiable, Hashable {
    let id: String
    let name: String
    let category: ToppingCategory
    let baseCalories: Int
    let dotColor: Color
    var isSelected: Bool = false
    var portion: ToppingPortion = .whole
    var amount: ToppingAmount = .regular
    
    var calculatedCalories: Int {
        guard isSelected else { return 0 }
        let raw = Double(baseCalories) * portion.calorieMultiplier * amount.calorieMultiplier
        return Int(round(raw))
    }
}

// MARK: - Pizza Size Enum

enum PizzaSize: String, CaseIterable, Identifiable {
    case mini = "Mini"
    case mod = "MOD"
    case mega = "Mega"
    
    var id: String { rawValue }
    
    var dimensionText: String {
        switch self {
        case .mini: return "6\""
        case .mod: return "11\""
        case .mega: return "11\" thick"
        }
    }
    
    var priceText: String {
        switch self {
        case .mini: return "$8.99"
        case .mod: return "$10.99"
        case .mega: return "$13.99"
        }
    }
    
    var basePrice: Double {
        switch self {
        case .mini: return 8.99
        case .mod: return 10.99
        case .mega: return 13.99
        }
    }
    
    var baseCalories: Int {
        switch self {
        case .mini: return 480
        case .mod: return 680
        case .mega: return 980
        }
    }
}

// MARK: - Pizza Crust Enum

enum PizzaCrust: String, CaseIterable, Identifiable {
    case thin = "Thin"
    case glutenFree = "Gluten-Free"
    case cauliflower = "Cauliflower"
    
    var id: String { rawValue }
    
    var extraPrice: Double {
        switch self {
        case .thin: return 0.0
        case .glutenFree: return 3.00
        case .cauliflower: return 3.00
        }
    }
    
    var extraCalories: Int {
        switch self {
        case .thin: return 0
        case .glutenFree: return 80
        case .cauliflower: return 60
        }
    }
    
    var label: String {
        switch self {
        case .thin: return "Thin · 0 cal"
        case .glutenFree: return "Gluten-Free (+$3.00 · +80 cal)"
        case .cauliflower: return "Cauliflower (+$3.00 · +60 cal)"
        }
    }
}

// MARK: - MenuCustomizationView

struct MenuCustomizationView: View {
    
    // MARK: - Customization Target Info
    
    var pizzaTitle: String = "BUILD YOUR PIZZA"
    var pizzaCategory: String = "PIZZAS"
    var pizzaDescription: String = "Build your own with 40+ toppings and 8 finishing sauces — all for one price. Supports independent half-and-half recipes."
    var pizzaImageName: String = "PizzaOn"
    var showRecipeStyle: Bool = false
    
    // MARK: - Callbacks
    
    var onBack: (() -> Void)? = nil
    var onAddToCart: ((Int, Double, Int) -> Void)? = nil
    var onStarTap: (() -> Void)? = nil
    var onCartTap: (() -> Void)? = nil
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Configuration State
    
    @State private var selectedSize: PizzaSize = .mod
    @State private var selectedCrust: PizzaCrust = .thin
    @State private var recipeStyle: RecipeStyle = .whole
    @State private var quantity: Int = 1
    @State private var showAddedToast: Bool = false
    @State private var isCustomBuildActive: Bool = false
    
    // MARK: - Sauce State (Single Selection with Grid)
    
    @State private var selectedSauceId: String
    @State private var saucePortion: ToppingPortion = .whole
    @State private var sauceAmount: ToppingAmount = .regular
    
    let sauceOptions: [SauceOption] = [
        SauceOption(id: "s_tomato", name: "Tomato", baseCalories: 30, dotColor: Color(red: 0xD8 / 255.0, green: 0x32 / 255.0, blue: 0x2A / 255.0)),
        SauceOption(id: "s_spicy_tomato", name: "Spicy tomato", baseCalories: 35, dotColor: Color(red: 0x9B / 255.0, green: 0x23 / 255.0, blue: 0x1A / 255.0)),
        SauceOption(id: "s_creamy_alfredo", name: "Creamy alfredo", baseCalories: 80, dotColor: Color(red: 0xF3 / 255.0, green: 0xEA / 255.0, blue: 0xD0 / 255.0)),
        SauceOption(id: "s_bbq", name: "BBQ", baseCalories: 40, dotColor: Color(red: 0x73 / 255.0, green: 0x2C / 255.0, blue: 0x1A / 255.0)),
        SauceOption(id: "s_buffalo", name: "Frank’s Buffalo", baseCalories: 25, dotColor: Color(red: 0xEB / 255.0, green: 0x5E / 255.0, blue: 0x1E / 255.0)),
        SauceOption(id: "s_pesto", name: "Pesto", baseCalories: 60, dotColor: Color(red: 0x5A / 255.0, green: 0x8C / 255.0, blue: 0x32 / 255.0)),
        SauceOption(id: "s_garlic_rub", name: "Garlic rub", baseCalories: 45, dotColor: Color(red: 0xF0 / 255.0, green: 0xDC / 255.0, blue: 0x96 / 255.0)),
        SauceOption(id: "s_olive_oil", name: "Olive oil", baseCalories: 50, dotColor: Color(red: 0xD6 / 255.0, green: 0xB9 / 255.0, blue: 0x46 / 255.0)),
        SauceOption(id: "s_no_sauce", name: "No sauce", baseCalories: 0, dotColor: Color.clear, isNoSauce: true)
    ]
    
    // MARK: - Toppings State (Cheeses, Meats, Veggies, Finishes)
    
    @State private var toppings: [CustomizableTopping]
    
    // MARK: - Initializer Supporting Custom Build or Particular Pizza Customization
    
    init(
        pizzaTitle: String = "BUILD YOUR PIZZA",
        pizzaCategory: String = "PIZZAS",
        pizzaDescription: String = "Build your own with 40+ toppings and 8 finishing sauces — all for one price. Supports independent half-and-half recipes.",
        pizzaImageName: String = "PizzaOn",
        showRecipeStyle: Bool = false,
        onBack: (() -> Void)? = nil,
        onAddToCart: ((Int, Double, Int) -> Void)? = nil,
        onStarTap: (() -> Void)? = nil,
        onCartTap: (() -> Void)? = nil
    ) {
        self.pizzaTitle = pizzaTitle
        self.pizzaCategory = pizzaCategory
        self.pizzaDescription = pizzaDescription
        self.pizzaImageName = pizzaImageName
        self.showRecipeStyle = showRecipeStyle
        self.onBack = onBack
        self.onAddToCart = onAddToCart
        self.onStarTap = onStarTap
        self.onCartTap = onCartTap
        
        _recipeStyle = State(initialValue: .whole)
        
        let (sauceId, initialToppings) = Self.recipeForPizza(title: pizzaTitle, description: pizzaDescription)
        _selectedSauceId = State(initialValue: sauceId)
        _toppings = State(initialValue: initialToppings)
    }
    
    // MARK: - Static Default Toppings & Recipe Matching
    
    static let defaultToppingsList: [CustomizableTopping] = [
        // CHEESES
        CustomizableTopping(id: "c1", name: "Mozzarella", category: .cheese, baseCalories: 180, dotColor: Color(red: 0xF7 / 255.0, green: 0xDF / 255.0, blue: 0xA5 / 255.0), isSelected: true, portion: .whole, amount: .regular),
        CustomizableTopping(id: "c2", name: "Asiago", category: .cheese, baseCalories: 90, dotColor: Color(red: 0xF3 / 255.0, green: 0xEA / 255.0, blue: 0xCA / 255.0)),
        CustomizableTopping(id: "c3", name: "Parmesan", category: .cheese, baseCalories: 70, dotColor: Color(red: 0xEE / 255.0, green: 0xE6 / 255.0, blue: 0xCF / 255.0)),
        CustomizableTopping(id: "c4", name: "Cheddar", category: .cheese, baseCalories: 110, dotColor: Color(red: 0xEA / 255.0, green: 0x9B / 255.0, blue: 0x3E / 255.0)),
        CustomizableTopping(id: "c5", name: "Feta", category: .cheese, baseCalories: 80, dotColor: Color(red: 0xF9 / 255.0, green: 0xF7 / 255.0, blue: 0xF0 / 255.0)),
        CustomizableTopping(id: "c6", name: "Gorgonzola", category: .cheese, baseCalories: 100, dotColor: Color(red: 0xDA / 255.0, green: 0xE5 / 255.0, blue: 0xD6 / 255.0)),
        CustomizableTopping(id: "c7", name: "Ricotta", category: .cheese, baseCalories: 90, dotColor: Color.white),
        CustomizableTopping(id: "c8", name: "Dairy-Free Cheese", category: .cheese, baseCalories: 120, dotColor: Color(red: 0xF8 / 255.0, green: 0xEE / 255.0, blue: 0xC8 / 255.0)),
        
        // MEATS
        CustomizableTopping(id: "m1", name: "Pepperoni", category: .meat, baseCalories: 120, dotColor: Color("Button_red")),
        CustomizableTopping(id: "m2", name: "Mild Italian Sausage", category: .meat, baseCalories: 140, dotColor: Color(red: 0x86 / 255.0, green: 0x3E / 255.0, blue: 0x22 / 255.0)),
        CustomizableTopping(id: "m3", name: "Spicy Chicken Sausage", category: .meat, baseCalories: 110, dotColor: Color(red: 0xB5 / 255.0, green: 0x58 / 255.0, blue: 0x34 / 255.0)),
        CustomizableTopping(id: "m4", name: "Bacon", category: .meat, baseCalories: 130, dotColor: Color(red: 0x98 / 255.0, green: 0x30 / 255.0, blue: 0x25 / 255.0)),
        CustomizableTopping(id: "m5", name: "Canadian Bacon", category: .meat, baseCalories: 80, dotColor: Color(red: 0xDA / 255.0, green: 0x72 / 255.0, blue: 0x76 / 255.0)),
        CustomizableTopping(id: "m6", name: "Grilled Chicken", category: .meat, baseCalories: 100, dotColor: Color(red: 0xD9 / 255.0, green: 0xB1 / 255.0, blue: 0x82 / 255.0)),
        CustomizableTopping(id: "m7", name: "Salami", category: .meat, baseCalories: 140, dotColor: Color(red: 0x93 / 255.0, green: 0x35 / 255.0, blue: 0x2B / 255.0)),
        CustomizableTopping(id: "m8", name: "Plant-Based Sausage", category: .meat, baseCalories: 120, dotColor: Color(red: 0x6E / 255.0, green: 0x4D / 255.0, blue: 0x3E / 255.0)),
        
        // VEGGIES & MORE
        CustomizableTopping(id: "v1", name: "Artichokes", category: .veggie, baseCalories: 20, dotColor: Color(red: 0x7E / 255.0, green: 0x98 / 255.0, blue: 0x68 / 255.0)),
        CustomizableTopping(id: "v2", name: "Red Onion", category: .veggie, baseCalories: 15, dotColor: Color(red: 0x8E / 255.0, green: 0x32 / 255.0, blue: 0x62 / 255.0)),
        CustomizableTopping(id: "v3", name: "Black Olives", category: .veggie, baseCalories: 35, dotColor: Color("app_black")),
        CustomizableTopping(id: "v4", name: "Roasted Red Peppers", category: .veggie, baseCalories: 25, dotColor: Color("Button_red")),
        CustomizableTopping(id: "v5", name: "Mushrooms", category: .veggie, baseCalories: 10, dotColor: Color(red: 0x9C / 255.0, green: 0x87 / 255.0, blue: 0x78 / 255.0)),
        CustomizableTopping(id: "v6", name: "Roasted Garlic Cloves", category: .veggie, baseCalories: 30, dotColor: Color(red: 0xD6 / 255.0, green: 0xC1 / 255.0, blue: 0x9B / 255.0)),
        CustomizableTopping(id: "v7", name: "Fresh Spinach", category: .veggie, baseCalories: 10, dotColor: Color(red: 0x3D / 255.0, green: 0x70 / 255.0, blue: 0x35 / 255.0)),
        CustomizableTopping(id: "v8", name: "Sliced Tomatoes", category: .veggie, baseCalories: 15, dotColor: Color(red: 0xD3 / 255.0, green: 0x38 / 255.0, blue: 0x2C / 255.0)),
        CustomizableTopping(id: "v9", name: "Jalapeños", category: .veggie, baseCalories: 10, dotColor: Color(red: 0x2A / 255.0, green: 0x6E / 255.0, blue: 0x30 / 255.0)),
        CustomizableTopping(id: "v10", name: "Pineapple", category: .veggie, baseCalories: 35, dotColor: Color(red: 0xF4 / 255.0, green: 0xC7 / 255.0, blue: 0x3C / 255.0)),
        CustomizableTopping(id: "v11", name: "Roasted Broccoli", category: .veggie, baseCalories: 25, dotColor: Color(red: 0x35 / 255.0, green: 0x64 / 255.0, blue: 0x3A / 255.0)),
        CustomizableTopping(id: "v12", name: "Fresh Basil", category: .veggie, baseCalories: 5, dotColor: Color(red: 0x46 / 255.0, green: 0x7A / 255.0, blue: 0x36 / 255.0)),
        CustomizableTopping(id: "v13", name: "Roasted Corn", category: .veggie, baseCalories: 30, dotColor: Color(red: 0xE6 / 255.0, green: 0xB9 / 255.0, blue: 0x41 / 255.0)),
        CustomizableTopping(id: "v14", name: "Arugula", category: .veggie, baseCalories: 10, dotColor: Color(red: 0x51 / 255.0, green: 0x77 / 255.0, blue: 0x3D / 255.0)),
        CustomizableTopping(id: "v15", name: "Green peppers", category: .veggie, baseCalories: 15, dotColor: Color(red: 0x42 / 255.0, green: 0x7E / 255.0, blue: 0x3F / 255.0)),
        CustomizableTopping(id: "v16", name: "Kalamata Olives", category: .veggie, baseCalories: 40, dotColor: Color(red: 0x47 / 255.0, green: 0x34 / 255.0, blue: 0x4B / 255.0)),
        
        // FINISHES (AFTER BAKE)
        CustomizableTopping(id: "f1", name: "Balsamic Fig Glaze", category: .finish, baseCalories: 40, dotColor: Color(red: 0x50 / 255.0, green: 0x28 / 255.0, blue: 0x22 / 255.0)),
        CustomizableTopping(id: "f2", name: "Mike’s Hot Honey", category: .finish, baseCalories: 50, dotColor: Color(red: 0xDD / 255.0, green: 0x8C / 255.0, blue: 0x26 / 255.0)),
        CustomizableTopping(id: "f3", name: "BBQ Drizzle", category: .finish, baseCalories: 35, dotColor: Color(red: 0x70 / 255.0, green: 0x33 / 255.0, blue: 0x1E / 255.0)),
        CustomizableTopping(id: "f4", name: "Buffalo Drizzle", category: .finish, baseCalories: 25, dotColor: Color("Button_red")),
        CustomizableTopping(id: "f5", name: "Pesto Drizzle", category: .finish, baseCalories: 50, dotColor: Color(red: 0x58 / 255.0, green: 0x7A / 255.0, blue: 0x30 / 255.0)),
        CustomizableTopping(id: "f6", name: "Ranch Drizzle", category: .finish, baseCalories: 60, dotColor: Color(red: 0xF3 / 255.0, green: 0xEE / 255.0, blue: 0xE4 / 255.0)),
        CustomizableTopping(id: "f7", name: "Sri-racha Drizzle", category: .finish, baseCalories: 15, dotColor: Color(red: 0xCA / 255.0, green: 0x3A / 255.0, blue: 0x27 / 255.0)),
        CustomizableTopping(id: "f8", name: "Red Pepper Flakes", category: .finish, baseCalories: 0, dotColor: Color(red: 0xB5 / 255.0, green: 0x31 / 255.0, blue: 0x25 / 255.0))
    ]
    
    static func recipeForPizza(title: String, description: String) -> (sauceId: String, toppings: [CustomizableTopping]) {
        let titleUpper = title.uppercased()
        let descLower = description.lowercased()
        
        // If it's standard Build Your Pizza, start with default (Mozzarella, Tomato Sauce)
        if titleUpper.contains("BUILD YOUR PIZZA") {
            return ("s_tomato", defaultToppingsList)
        }
        
        // 1. Determine Sauce
        var sauceId = "s_tomato"
        if titleUpper.contains("PESTO") || descLower.contains("pesto") {
            sauceId = "s_pesto"
        } else if titleUpper.contains("BBQ") || descLower.contains("bbq") {
            sauceId = "s_bbq"
        } else if titleUpper.contains("BUFFALO") || titleUpper.contains("CALEXICO") || descLower.contains("buffalo") {
            sauceId = "s_buffalo"
        } else if titleUpper.contains("ALFREDO") || titleUpper.contains("DOMINIC") || descLower.contains("alfredo") {
            sauceId = "s_creamy_alfredo"
        } else if titleUpper.contains("LUCY") || descLower.contains("garlic rub") {
            sauceId = "s_garlic_rub"
        } else if titleUpper.contains("DION") || descLower.contains("olive oil") {
            sauceId = "s_olive_oil"
        } else if titleUpper.contains("JASPER") || descLower.contains("spicy tomato") {
            sauceId = "s_spicy_tomato"
        }
        
        // 2. Determine Toppings
        var toppingsCopy = defaultToppingsList.map { topping -> CustomizableTopping in
            var t = topping
            t.isSelected = false
            return t
        }
        
        func selectTopping(id: String) {
            if let idx = toppingsCopy.firstIndex(where: { $0.id == id }) {
                toppingsCopy[idx].isSelected = true
            }
        }
        
        // Standard recipe cheeses & meats selection
        selectTopping(id: "c1") // Mozzarella by default
        
        if titleUpper.contains("PEPPERONI") || descLower.contains("pepperoni") {
            selectTopping(id: "m1") // Pepperoni
            selectTopping(id: "c2") // Asiago
        }
        if titleUpper.contains("MADDY") {
            selectTopping(id: "c2") // Asiago
        }
        if titleUpper.contains("MIKE") || descLower.contains("chicken sausage") {
            selectTopping(id: "c3") // Parmesan
            selectTopping(id: "c7") // Ricotta
            selectTopping(id: "m3") // Spicy Chicken Sausage
        }
        if titleUpper.contains("PESTO") {
            selectTopping(id: "c5") // Feta
            selectTopping(id: "v1") // Artichokes
            selectTopping(id: "v14") // Arugula
        }
        if titleUpper.contains("CALEXICO") {
            selectTopping(id: "c6") // Gorgonzola
            selectTopping(id: "m6") // Grilled Chicken
            selectTopping(id: "v9") // Jalapeños
        }
        if titleUpper.contains("CASPIAN") {
            selectTopping(id: "c6") // Gorgonzola
            selectTopping(id: "m6") // Grilled Chicken
            selectTopping(id: "v2") // Red Onion
        }
        if titleUpper.contains("LUCY") {
            selectTopping(id: "c3") // Parmesan
            selectTopping(id: "v8") // Sliced Tomatoes
        }
        if titleUpper.contains("JASPER") {
            selectTopping(id: "m2") // Mild Italian Sausage
            selectTopping(id: "v5") // Mushrooms
        }
        if titleUpper.contains("DION") {
            selectTopping(id: "c2") // Asiago
            selectTopping(id: "v12") // Fresh Basil
        }
        if titleUpper.contains("TRISTAN") {
            selectTopping(id: "c2") // Asiago
            selectTopping(id: "v4") // Roasted Red Peppers
            selectTopping(id: "v5") // Mushrooms
        }
        if titleUpper.contains("DOMINIC") {
            selectTopping(id: "c2") // Asiago
            selectTopping(id: "v8") // Sliced Tomatoes
            selectTopping(id: "v12") // Fresh Basil
            selectTopping(id: "m2") // Mild Italian Sausage
        }
        if titleUpper.contains("ONE TOPPING") {
            selectTopping(id: "m1") // Pepperoni
        }
        
        return (sauceId, toppingsCopy)
    }
    
    // MARK: - Computed Calorie & Price Calculations
    
    /// Whether current pizza has no meat selected
    var isVegetarian: Bool {
        !toppings.contains(where: { $0.category == .meat && $0.isSelected })
    }
    
    /// Calories contributed by the selected sauce, portion, and amount
    var calculatedSauceCalories: Int {
        guard let sauce = sauceOptions.first(where: { $0.id == selectedSauceId }), !sauce.isNoSauce else {
            return 0
        }
        let raw = Double(sauce.baseCalories) * saucePortion.calorieMultiplier * sauceAmount.calorieMultiplier
        return Int(round(raw))
    }
    
    /// Total calories of a single customized pizza
    var singlePizzaCalories: Int {
        let sizeBase = selectedSize.baseCalories
        let crustExtra = selectedCrust.extraCalories
        let sauceCal = calculatedSauceCalories
        let toppingsCal = toppings.reduce(0) { $0 + $1.calculatedCalories }
        return sizeBase + crustExtra + sauceCal + toppingsCal
    }
    
    /// Total price of a single customized pizza
    var singlePizzaPrice: Double {
        selectedSize.basePrice + selectedCrust.extraPrice
    }
    
    /// Total final price for current quantity
    var finalTotalPrice: Double {
        singlePizzaPrice * Double(quantity)
    }
    
    // MARK: - Active Ingredient Pill Tags
    
    /// Formatted pills describing all customized ingredients matching snapshot
    var activeIngredientPills: [String] {
        var pills: [String] = []
        
        // 1. Sauce
        if let sauce = sauceOptions.first(where: { $0.id == selectedSauceId }) {
            if sauce.isNoSauce {
                pills.append("No sauce")
            } else {
                let sauceName = sauce.name
                if saucePortion == .whole && sauceAmount == .regular {
                    pills.append("Sauce: \(sauceName)")
                } else if saucePortion != .whole && sauceAmount != .regular {
                    pills.append("Sauce: \(sauceName) (\(sauceAmount.rawValue), \(saucePortion.shortTitle))")
                } else if saucePortion != .whole {
                    pills.append("Sauce: \(sauceName) (\(saucePortion.shortTitle))")
                } else {
                    pills.append("Sauce: \(sauceName) (\(sauceAmount.rawValue))")
                }
            }
        }
        
        // 2. Toppings in Category Order (Cheese, Meat, Veggie, Finish)
        let selected = toppings.filter { $0.isSelected }
        for topping in selected {
            let label: String
            if topping.portion == .whole && topping.amount == .regular {
                label = "Add \(topping.name)"
            } else if topping.portion != .whole && topping.amount != .regular {
                label = "Add \(topping.name) (\(topping.amount.rawValue), \(topping.portion.shortTitle))"
            } else if topping.portion != .whole {
                label = "Add \(topping.name) (\(topping.portion.shortTitle))"
            } else {
                label = "Add \(topping.name) (\(topping.amount.rawValue))"
            }
            pills.append(label)
        }
        
        return pills
    }
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                Color("app_background")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top Custom Navigation Bar
                    customNavigationBar
                        .frame(width: geometry.size.width)
                    
                    // Scrollable Customization Content (Strictly Vertical Only)
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 22) {
                            // 1. Pizza Hero Visual Card
                            pizzaHeroCard
                            
                            // 2. Title & Badge Section
                            titleBadgeSection
                            
                            // 3. Size Selection Section
                            sizeSection
                            
                            // 4. Crust Selection Section
                            crustSection
                            
                            // 5. Recipe Style Section (Only shown when showRecipeStyle is true)
                            if showRecipeStyle {
                                recipeStyleSection
                            }
                            
                            // 6. Sauce Selection Section (2-Column Grid + Shared Controls)
                            sauceSection
                            
                            // 7. Toppings Sections (Cheeses, Meats, Veggies, Finishes)
                            ForEach(ToppingCategory.allCases) { category in
                                categorySection(category)
                            }
                            
                            // 8. Nutrition Facts Table Card
                            nutritionSummaryCard
                            
                            // Bottom Padding for Fixed Checkout Bar
                            Spacer()
                                .frame(height: 150)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 10)
                        .frame(width: geometry.size.width, alignment: .leading)
                    }
                    .frame(width: geometry.size.width)
                    .clipped()
                }
                
                // Fixed Bottom Checkout & Calorie Bar
                bottomCheckoutBar
                    .frame(width: geometry.size.width)
                
                // Toast Notification
                if showAddedToast {
                    VStack {
                        Spacer()
                        Text("Added custom \(pizzaTitle) to cart!")
                            .font(.barlowMedium(size: 14))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(Color("app_black").opacity(0.92))
                                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                            )
                            .padding(.bottom, 130)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    .animation(.easeInOut(duration: 0.25), value: showAddedToast)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
    
    // MARK: - Custom Top Navigation Bar
    
    private var customNavigationBar: some View {
        HStack(alignment: .center) {
            // Left: Red Back Button
            Button(action: {
                if let onBack = onBack {
                    onBack()
                } else {
                    dismiss()
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
            Text("Customize")
                .font(.oswaldMedium(size: 18))
                .foregroundColor(Color("app_black"))
            
            Spacer()
            
            // Right: Star & Red Cart Icons
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
                
                TopCartButton(action: {
                    if let onCartTap = onCartTap {
                        onCartTap()
                    } else {
                        CartManager.shared.showCartSheet = true
                        NotificationCenter.default.post(name: .showCartNotification, object: nil)
                    }
                })
            }
            .frame(width: 70, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
        .padding(.bottom, 10)
        .background(Color("app_background"))
    }
    
    // MARK: - 1. Pizza Hero Visual Card
    
    private var pizzaHeroCard: some View {
        VStack(spacing: 12) {
            ZStack {
                // Wide Rounded Tan Card Container
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color("pizza_found"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 235)
                
                if isCustomBuildActive {
                    // Real-Time Animated Pizza Canvas with SwiftUI Animations
                    InteractivePizzaCanvasView(
                        selectedSauceId: selectedSauceId,
                        saucePortion: saucePortion,
                        sauceAmount: sauceAmount,
                        toppings: toppings,
                        recipeStyle: showRecipeStyle ? recipeStyle : .whole,
                        pizzaSize: selectedSize
                    )
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.94).combined(with: .opacity),
                        removal: .scale(scale: 0.94).combined(with: .opacity)
                    ))
                } else {
                    // High-resolution Pizza Image (shows specific recipe image if available)
                    if let uiImg = UIImage(named: pizzaImageName) {
                        Image(uiImage: uiImg)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 205, height: 205)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.14), radius: 8, x: 0, y: 4)
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.94).combined(with: .opacity),
                                removal: .scale(scale: 0.94).combined(with: .opacity)
                            ))
                    } else {
                        Image("PizzaOn")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 205, height: 205)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.14), radius: 8, x: 0, y: 4)
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.94).combined(with: .opacity),
                                removal: .scale(scale: 0.94).combined(with: .opacity)
                            ))
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isCustomBuildActive.toggle()
                }
            }
            
            // Description below pizza visual
            if isCustomBuildActive {
                VStack(spacing: 12) {
                    Text("Illustrative preview — reflects your toppings, portions and placement.\nNot product photography.")
                        .font(.barlowRegular(size: 13))
                        .foregroundColor(Color("text_gary"))
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                        .padding(.horizontal, 16)
                    
                    if !activeIngredientPills.isEmpty {
                        IngredientsPillsFlowView(pills: activeIngredientPills)
                            .padding(.top, 2)
                    }
                }
                .transition(.opacity)
            } else {
                Text("Standard recipe photo. Customize it and we’ll switch to a live illustration of your build.")
                    .font(.barlowRegular(size: 13))
                    .foregroundColor(Color("text_gary"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .padding(.horizontal, 16)
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isCustomBuildActive)
    }
    
    // MARK: - 2. Title & Badge Section
    
    private var titleBadgeSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Category Red Title
            Text(pizzaCategory)
                .font(.oswaldMedium(size: 13))
                .tracking(1.0)
                .foregroundColor(Color("Button_red"))
            
            // Title
            Text(pizzaTitle)
                .font(.oswaldBold(size: 28))
                .tracking(0.6)
                .foregroundColor(Color("app_black"))
            
            // Subtitle
            Text(pizzaDescription)
                .font(.barlowRegular(size: 14))
                .foregroundColor(Color("text_gary"))
                .lineSpacing(2)
            
            // Veg Tag + Calorie info
            HStack(spacing: 8) {
                if isVegetarian {
                    // Veg Badge
                    HStack(spacing: 4.5) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 2.5)
                                .stroke(Color(red: 0x38 / 255.0, green: 0x7E / 255.0, blue: 0x3C / 255.0), lineWidth: 1.4)
                                .frame(width: 14, height: 14)
                            
                            Circle()
                                .fill(Color(red: 0x38 / 255.0, green: 0x7E / 255.0, blue: 0x3C / 255.0))
                                .frame(width: 6, height: 6)
                        }
                        
                        Text("Veg")
                            .font(.barlowBold(size: 12))
                            .foregroundColor(Color(red: 0x38 / 255.0, green: 0x7E / 255.0, blue: 0x3C / 255.0))
                    }
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3.5)
                    .background(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .stroke(Color(red: 0xD0 / 255.0, green: 0xD8 / 255.0, blue: 0xC8 / 255.0), lineWidth: 1.0)
                            .background(RoundedRectangle(cornerRadius: 6, style: .continuous).fill(Color.white))
                    )
                }
                
                Text(singlePizzaCalories == 680 ? "680 cal standard" : "\(singlePizzaCalories) cal standard")
                    .font(.barlowRegular(size: 13.5))
                    .foregroundColor(Color("text_gary"))
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - 3. Size Selection Section
    
    private var sizeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("SIZE")
                .font(.oswaldLight(size: 20))
                .tracking(0.8)
                .foregroundColor(Color("app_black"))
            
            HStack(spacing: 8) {
                ForEach(PizzaSize.allCases) { size in
                    sizeCard(size)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func sizeCard(_ size: PizzaSize) -> some View {
        let isSelected = selectedSize == size
        
        return Button(action: {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                selectedSize = size
                isCustomBuildActive = true
            }
        }) {
            VStack(spacing: 4) {
                Text(size.rawValue)
                    .font(.oswaldMedium(size: 16))
                    .foregroundColor(Color("app_black"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                
                Text(size.dimensionText)
                    .font(.barlowRegular(size: 12))
                    .foregroundColor(Color("text_gary"))
                    .lineLimit(1)
                
                Text(size.priceText)
                    .font(.barlowBold(size: 13))
                    .foregroundColor(Color("app_black"))
                    .padding(.top, 2)
                    .lineLimit(1)
                
                Text("\(size.baseCalories) cal")
                    .font(.barlowRegular(size: 11))
                    .foregroundColor(Color("Button_red"))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 4)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected ? Color(red: 0xFD / 255.0, green: 0xF2 / 255.0, blue: 0xF4 / 255.0) : Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isSelected ? Color("Button_red") : Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: isSelected ? 1.6 : 1.2)
            )
            .shadow(color: Color.black.opacity(0.02), radius: 3, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - 4. Crust Selection Section
    
    private var crustSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("CRUST")
                .font(.oswaldLight(size: 20))
                .tracking(0.8)
                .foregroundColor(Color("app_black"))
            
            HStack(spacing: 8) {
                ForEach(PizzaCrust.allCases) { crust in
                    crustCard(crust)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func crustCard(_ crust: PizzaCrust) -> some View {
        let isSelected = selectedCrust == crust
        
        return Button(action: {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                selectedCrust = crust
                isCustomBuildActive = true
            }
        }) {
            VStack(spacing: 3) {
                Text(crust.rawValue)
                    .font(.barlowSemiBold(size: 13.5))
                    .foregroundColor(Color("app_black"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                
                if crust.extraPrice > 0 {
                    Text("+$\(String(format: "%.2f", crust.extraPrice)) · +\(crust.extraCalories) cal")
                        .font(.barlowRegular(size: 10))
                        .foregroundColor(Color("Button_red"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                } else {
                    Text("Included · 0 cal")
                        .font(.barlowRegular(size: 10))
                        .foregroundColor(Color("text_gary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 4)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected ? Color(red: 0xFD / 255.0, green: 0xF2 / 255.0, blue: 0xF4 / 255.0) : Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isSelected ? Color("Button_red") : Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: isSelected ? 1.6 : 1.2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - 5. Recipe Style Section
    
    private var recipeStyleSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Divider()
                .background(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0))
                .padding(.bottom, 2)
            
            Text("RECIPE STYLE")
                .font(.oswaldLight(size: 20))
                .tracking(0.8)
                .foregroundColor(Color("app_black"))
            
            // Segmented Capsule: [ Whole pizza ] [ Half & half ]
            HStack(spacing: 4) {
                ForEach(RecipeStyle.allCases) { style in
                    let isSelected = recipeStyle == style
                    Button(action: {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                            recipeStyle = style
                            isCustomBuildActive = true
                        }
                    }) {
                        Text(style.rawValue)
                            .font(isSelected ? .barlowBold(size: 14) : .barlowMedium(size: 14))
                            .foregroundColor(Color("app_black"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 42)
                            .background(
                                Capsule()
                                    .fill(isSelected ? Color.white : Color.clear)
                                    .shadow(color: isSelected ? Color.black.opacity(0.08) : Color.clear, radius: 2, x: 0, y: 1)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(4)
            .background(
                Capsule()
                    .fill(Color(red: 0xF3 / 255.0, green: 0xEE / 255.0, blue: 0xE4 / 255.0))
            )
            
            Text("Use Left ½ / Right ½ on any topping, or switch to Half & half for two fully independent recipes.")
                .font(.barlowRegular(size: 13))
                .foregroundColor(Color("text_gary"))
                .lineSpacing(2)
            
            Divider()
                .background(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0))
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - 6. Sauce Selection Section (2-Column Box Grid)
    
    private var sauceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SAUCE")
                .font(.oswaldLight(size: 20))
                .tracking(0.8)
                .foregroundColor(Color("app_black"))
            
            let columns = [
                GridItem(.flexible(), spacing: 10),
                GridItem(.flexible(), spacing: 10)
            ]
            
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(sauceOptions) { sauce in
                    sauceBox(sauce)
                }
            }
            
            // Bottom Shared Portion & Amount Controls (Directly below sauce boxes)
            VStack(alignment: .leading, spacing: 8) {
                // Portion: Left ½ | Whole | Right ½
                HStack(spacing: 3) {
                    ForEach(ToppingPortion.allCases) { portion in
                        let isCurrent = saucePortion == portion
                        Button(action: {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                saucePortion = portion
                                isCustomBuildActive = true
                            }
                        }) {
                            Text(portion.shortTitle)
                                .font(isCurrent ? .barlowBold(size: 13) : .barlowSemiBold(size: 13))
                                .foregroundColor(isCurrent ? Color("Button_red") : Color("app_black"))
                                .padding(.horizontal, 14)
                                .frame(height: 32)
                                .background(
                                    Capsule()
                                        .fill(isCurrent ? Color.white : Color.clear)
                                        .shadow(color: isCurrent ? Color.black.opacity(0.08) : Color.clear, radius: 2, x: 0, y: 1)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(3)
                .background(
                    Capsule()
                        .fill(Color(red: 0xF3 / 255.0, green: 0xEE / 255.0, blue: 0xE4 / 255.0))
                )
                
                // Amount: Light | Regular | Extra
                HStack(spacing: 3) {
                    ForEach(ToppingAmount.allCases) { amount in
                        let isCurrent = sauceAmount == amount
                        Button(action: {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                sauceAmount = amount
                                isCustomBuildActive = true
                            }
                        }) {
                            Text(amount.rawValue)
                                .font(isCurrent ? .barlowBold(size: 13) : .barlowSemiBold(size: 13))
                                .foregroundColor(isCurrent ? Color("Button_red") : Color("app_black"))
                                .padding(.horizontal, 14)
                                .frame(height: 32)
                                .background(
                                    Capsule()
                                        .fill(isCurrent ? Color.white : Color.clear)
                                        .shadow(color: isCurrent ? Color.black.opacity(0.08) : Color.clear, radius: 2, x: 0, y: 1)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(3)
                .background(
                    Capsule()
                        .fill(Color(red: 0xF3 / 255.0, green: 0xEE / 255.0, blue: 0xE4 / 255.0))
                )
            }
            .padding(.top, 4)
            
            Divider()
                .background(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0))
                .padding(.top, 6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func sauceBox(_ sauce: SauceOption) -> some View {
        let isSelected = selectedSauceId == sauce.id
        
        return Button(action: {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                selectedSauceId = sauce.id
                isCustomBuildActive = true
            }
        }) {
            VStack(spacing: 8) {
                sauceDotView(for: sauce)
                
                Text(sauce.name)
                    .font(.barlowBold(size: 14))
                    .foregroundColor(Color("app_black"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 78)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? Color(red: 0xFD / 255.0, green: 0xF2 / 255.0, blue: 0xF4 / 255.0) : Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? Color("Button_red") : Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: isSelected ? 1.6 : 1.2)
            )
            .shadow(color: Color.black.opacity(0.02), radius: 3, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    @ViewBuilder
    private func sauceDotView(for sauce: SauceOption) -> some View {
        if sauce.isNoSauce {
            ZStack {
                Circle()
                    .stroke(Color(red: 0xD0 / 255.0, green: 0xCA / 255.0, blue: 0xC0 / 255.0), lineWidth: 1.5)
                    .frame(width: 26, height: 26)
                
                ForEach([-6, 0, 6], id: \.self) { offset in
                    Rectangle()
                        .fill(Color(red: 0xD0 / 255.0, green: 0xCA / 255.0, blue: 0xC0 / 255.0))
                        .frame(width: 1.5, height: 26)
                        .rotationEffect(.degrees(45))
                        .offset(x: CGFloat(offset))
                }
            }
            .frame(width: 26, height: 26)
            .clipShape(Circle())
        } else {
            ZStack {
                Circle()
                    .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.5)
                    .frame(width: 26, height: 26)
                
                Circle()
                    .fill(sauce.dotColor)
                    .frame(width: 20, height: 20)
            }
        }
    }
    
    // MARK: - 7. Toppings Category Section
    
    private func categorySection(_ category: ToppingCategory) -> some View {
        let categoryToppings = toppings.filter { $0.category == category }
        
        return VStack(alignment: .leading, spacing: 12) {
            // Category Header Row
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(category.rawValue)
                    .font(.oswaldLight(size: 20))
                    .tracking(0.8)
                    .foregroundColor(Color("app_black"))
                    .lineLimit(1)
                
                Text("· \(category.subtitle)")
                    .font(.barlowRegular(size: 13))
                    .foregroundColor(Color("text_gary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                
                Spacer()
            }
            
            // Topping List / Cells
            VStack(spacing: 8) {
                ForEach(categoryToppings) { topping in
                    toppingCell(topping)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Topping Cell (Expandable with Portion & Amount)
    
    private func toppingCell(_ topping: CustomizableTopping) -> some View {
        guard let index = toppings.firstIndex(where: { $0.id == topping.id }) else {
            return AnyView(EmptyView())
        }
        let isSelected = toppings[index].isSelected
        
        return AnyView(
            VStack(alignment: .leading, spacing: 10) {
                // Main Clickable Cell Row
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.78)) {
                        toppings[index].isSelected.toggle()
                        isCustomBuildActive = true
                    }
                }) {
                    HStack(spacing: 12) {
                        // Colored Dot Indicator
                        Circle()
                            .fill(topping.dotColor)
                            .frame(width: 14, height: 14)
                            .overlay(Circle().stroke(Color.black.opacity(0.12), lineWidth: 0.8))
                        
                        // Topping Name
                        Text(topping.name)
                            .font(.barlowSemiBold(size: 14.5))
                            .foregroundColor(Color("app_black"))
                            .lineLimit(1)
                        
                        Spacer()
                        
                        // Calorie Display (Shows exact calories added!)
                        if isSelected {
                            Text("+\(toppings[index].calculatedCalories) cal")
                                .font(.barlowBold(size: 13))
                                .foregroundColor(Color("Button_red"))
                                .lineLimit(1)
                        } else {
                            Text("+\(topping.baseCalories) cal")
                                .font(.barlowRegular(size: 12.5))
                                .foregroundColor(Color("text_gary"))
                                .lineLimit(1)
                        }
                        
                        // Selection Badge / Add Icon
                        ZStack {
                            if isSelected {
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(Color("Button_red"))
                                    .frame(width: 26, height: 26)
                                
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            } else {
                                Circle()
                                    .fill(Color(red: 0xF3 / 255.0, green: 0xEE / 255.0, blue: 0xE4 / 255.0))
                                    .frame(width: 26, height: 26)
                                
                                Image(systemName: "plus")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(Color("app_black"))
                            }
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                // Expanded Controls: Portion & Amount (Visible when selected)
                if isSelected {
                    VStack(alignment: .leading, spacing: 8) {
                        Divider()
                            .background(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0))
                            .padding(.vertical, 2)
                        
                        // 1. Portion Row: Left (½) | Whole | Right (½)
                        HStack(spacing: 8) {
                            Text("Portion:")
                                .font(.barlowMedium(size: 12))
                                .foregroundColor(Color("text_gary"))
                                .frame(width: 48, alignment: .leading)
                            
                            HStack(spacing: 3) {
                                ForEach(ToppingPortion.allCases) { portion in
                                    portionButton(portion: portion, index: index)
                                }
                            }
                            .padding(2)
                            .background(
                                Capsule()
                                    .fill(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0))
                            )
                        }
                        
                        // 2. Amount Row: Light | Regular | Extra
                        HStack(spacing: 8) {
                            Text("Amount:")
                                .font(.barlowMedium(size: 12))
                                .foregroundColor(Color("text_gary"))
                                .frame(width: 48, alignment: .leading)
                            
                            HStack(spacing: 3) {
                                ForEach(ToppingAmount.allCases) { amount in
                                    amountButton(amount: amount, index: index)
                                }
                            }
                            .padding(2)
                            .background(
                                Capsule()
                                    .fill(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0))
                            )
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? Color(red: 0xFD / 255.0, green: 0xF7 / 255.0, blue: 0xF5 / 255.0) : Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? Color("Button_red") : Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: isSelected ? 1.4 : 1.0)
            )
            .shadow(color: Color.black.opacity(0.02), radius: 3, x: 0, y: 1)
        )
    }
    
    private func portionButton(portion: ToppingPortion, index: Int) -> some View {
        let isCurrent = toppings[index].portion == portion
        
        return Button(action: {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                toppings[index].portion = portion
                isCustomBuildActive = true
            }
        }) {
            Text(portion.shortTitle)
                .font(.barlowSemiBold(size: 12))
                .foregroundColor(isCurrent ? Color("Button_red") : Color("app_black"))
                .padding(.horizontal, 10)
                .frame(height: 28)
                .background(
                    Capsule()
                        .fill(isCurrent ? Color.white : Color.clear)
                        .shadow(color: isCurrent ? Color.black.opacity(0.06) : Color.clear, radius: 2, x: 0, y: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func amountButton(amount: ToppingAmount, index: Int) -> some View {
        let isCurrent = toppings[index].amount == amount
        
        return Button(action: {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                toppings[index].amount = amount
                isCustomBuildActive = true
            }
        }) {
            Text(amount.rawValue)
                .font(.barlowSemiBold(size: 12))
                .foregroundColor(isCurrent ? Color("Button_red") : Color("app_black"))
                .padding(.horizontal, 10)
                .frame(height: 28)
                .background(
                    Capsule()
                        .fill(isCurrent ? Color.white : Color.clear)
                        .shadow(color: isCurrent ? Color.black.opacity(0.06) : Color.clear, radius: 2, x: 0, y: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - 8. Nutrition Facts Table Card
    
    private var nutritionSummaryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("NUTRITION FACTS (ESTIMATED)")
                .font(.oswaldLight(size: 20))
                .tracking(0.8)
                .foregroundColor(Color("app_black"))
            
            VStack(spacing: 8) {
                nutritionRow(label: "Calories", value: "\(singlePizzaCalories) cal", isBold: true)
                Divider()
                nutritionRow(label: "Total Fat", value: "\(Int(Double(singlePizzaCalories) * 0.034))g")
                Divider()
                nutritionRow(label: "Total Carbohydrates", value: "\(Int(Double(singlePizzaCalories) * 0.105))g")
                Divider()
                nutritionRow(label: "Sodium", value: "\(Int(Double(singlePizzaCalories) * 1.73))mg")
                Divider()
                nutritionRow(label: "Protein", value: "\(Int(Double(singlePizzaCalories) * 0.044))g")
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.2)
                    )
            )
            
            Text("2,000 calories a day is used for general nutrition advice, but calorie needs vary. Nutritional information is calculated based on standard portions.")
                .font(.barlowRegular(size: 11.5))
                .foregroundColor(Color("text_gary"))
                .lineSpacing(2)
                .padding(.top, 2)
        }
        .padding(.top, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func nutritionRow(label: String, value: String, isBold: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(isBold ? .barlowBold(size: 14) : .barlowRegular(size: 13.5))
                .foregroundColor(Color("app_black"))
            
            Spacer()
            
            Text(value)
                .font(isBold ? .oswaldBold(size: 15) : .barlowMedium(size: 13.5))
                .foregroundColor(isBold ? Color("Button_red") : Color("app_black"))
        }
    }
    
    // MARK: - Fixed Bottom Checkout Bar
    
    private var bottomCheckoutBar: some View {
        VStack(spacing: 8) {
            // Row 1: Quantity Selector + ADD TO CART Button
            HStack(spacing: 12) {
                // Quantity Selector: [-] 1 [+]
                HStack(spacing: 12) {
                    Button(action: {
                        if quantity > 1 {
                            quantity -= 1
                        }
                    }) {
                        Image(systemName: "minus")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(quantity > 1 ? Color("app_black") : Color("text_gary"))
                            .frame(width: 32, height: 46)
                    }
                    .disabled(quantity <= 1)
                    
                    Text("\(quantity)")
                        .font(.oswaldMedium(size: 16))
                        .foregroundColor(Color("app_black"))
                    
                    Button(action: {
                        quantity += 1
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color("app_black"))
                            .frame(width: 32, height: 46)
                    }
                }
                .padding(.horizontal, 4)
                .background(
                    Capsule()
                        .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.2)
                        .background(Capsule().fill(Color.white))
                )
                
                // ADD TO CART Button
                Button(action: {
                    let sauceName = sauceOptions.first(where: { $0.id == selectedSauceId })?.name ?? "Tomato"
                    let selectedToppingNames = toppings.filter { $0.isSelected }.map { $0.name }
                    let toppingsSummary = selectedToppingNames.isEmpty ? "" : " · " + selectedToppingNames.joined(separator: ", ")
                    let detailsText = "\(selectedSize.rawValue) · \(selectedCrust.rawValue) crust · \(sauceName) sauce" + toppingsSummary
                    
                    CartManager.shared.addItem(
                        title: pizzaTitle,
                        price: singlePizzaPrice,
                        quantity: quantity,
                        details: detailsText,
                        calories: singlePizzaCalories,
                        imageName: pizzaImageName
                    )
                    
                    onAddToCart?(quantity, finalTotalPrice, singlePizzaCalories)
                    showAddedToast = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        dismiss()
                    }
                }) {
                    Text("ADD TO CART — $\(String(format: "%.2f", finalTotalPrice))")
                        .font(.oswaldMedium(size: 15))
                        .tracking(0.8)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            Capsule()
                                .fill(Color("Button_red"))
                                .shadow(color: Color("Button_red").opacity(0.35), radius: 6, x: 0, y: 3)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Row 2: Final Total Calorie Count Display (Directly below Add to Cart Button as requested!)
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 13))
                    .foregroundColor(Color.orange)
                
                Text("Total Calories: \(singlePizzaCalories * quantity) cal")
                    .font(.barlowBold(size: 14))
                    .foregroundColor(Color("app_black"))
                
                if quantity > 1 {
                    Text("(\(singlePizzaCalories) cal each)")
                        .font(.barlowRegular(size: 12.5))
                        .foregroundColor(Color("text_gary"))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 2)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 18)
        .background(
            Color.white
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: -4)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

// MARK: - SwiftUI Preview

struct MenuCustomizationView_Previews: PreviewProvider {
    static var previews: some View {
        MenuCustomizationView()
    }
}

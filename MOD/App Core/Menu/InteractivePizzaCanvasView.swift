//
//  InteractivePizzaCanvasView.swift
//  MOD
//
//  Created by Rajpal singh on 17/11/26.
//

import SwiftUI

// MARK: - Squiggly Drizzle Shapes (For Mike's Hot Honey, BBQ, Balsamic, etc.)

struct VerticalSquigglyPath: Shape {
    var waveCount: Int = 3
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let step = rect.height / CGFloat(waveCount)
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        
        for i in 0..<waveCount {
            let startY = rect.minY + CGFloat(i) * step
            let midY = startY + step * 0.5
            let endY = startY + step
            
            let controlX1 = rect.midX + ((i % 2 == 0) ? rect.width * 0.5 : -rect.width * 0.5)
            let controlX2 = rect.midX + ((i % 2 == 0) ? -rect.width * 0.5 : rect.width * 0.5)
            
            path.addCurve(
                to: CGPoint(x: rect.midX, y: endY),
                control1: CGPoint(x: controlX1, y: midY),
                control2: CGPoint(x: controlX2, y: midY)
            )
        }
        return path
    }
}

struct HorizontalSquigglyPath: Shape {
    var waveCount: Int = 3
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let step = rect.width / CGFloat(waveCount)
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        
        for i in 0..<waveCount {
            let startX = rect.minX + CGFloat(i) * step
            let midX = startX + step * 0.5
            let endX = startX + step
            
            let controlY1 = rect.midY + ((i % 2 == 0) ? rect.height * 0.5 : -rect.height * 0.5)
            let controlY2 = rect.midY + ((i % 2 == 0) ? -rect.height * 0.5 : rect.height * 0.5)
            
            path.addCurve(
                to: CGPoint(x: endX, y: rect.midY),
                control1: CGPoint(x: midX, y: controlY1),
                control2: CGPoint(x: midX, y: controlY2)
            )
        }
        return path
    }
}

// MARK: - Predefined Coordinate Definition

struct ToppingCoordinate: Hashable {
    let x: CGFloat
    let y: CGFloat
    let angle: Double
    
    init(_ x: CGFloat, _ y: CGFloat, angle: Double = 0) {
        self.x = x
        self.y = y
        self.angle = angle
    }
}

// MARK: - Interactive Pizza Canvas View

struct InteractivePizzaCanvasView: View {
    let selectedSauceId: String
    let saucePortion: ToppingPortion
    let sauceAmount: ToppingAmount
    let toppings: [CustomizableTopping]
    let recipeStyle: RecipeStyle
    let pizzaSize: PizzaSize
    
    // MARK: - Predefined Coordinate Sets
    
    // 28 Cheese Blobs
    private let cheeseBlobCoords: [ToppingCoordinate] = [
        ToppingCoordinate(-42, -48, angle: 25),
        ToppingCoordinate(-24, -60, angle: -15),
        ToppingCoordinate(10, -55, angle: 40),
        ToppingCoordinate(38, -44, angle: -30),
        ToppingCoordinate(-56, -24, angle: 10),
        ToppingCoordinate(-28, -30, angle: 45),
        ToppingCoordinate(0, -34, angle: -20),
        ToppingCoordinate(28, -26, angle: 15),
        ToppingCoordinate(54, -18, angle: -45),
        ToppingCoordinate(-58, 8, angle: 30),
        ToppingCoordinate(-32, -4, angle: -10),
        ToppingCoordinate(-6, -2, angle: 20),
        ToppingCoordinate(22, 2, angle: -35),
        ToppingCoordinate(52, 12, angle: 25),
        ToppingCoordinate(-46, 32, angle: -25),
        ToppingCoordinate(-20, 24, angle: 15),
        ToppingCoordinate(8, 28, angle: -15),
        ToppingCoordinate(36, 34, angle: 35),
        ToppingCoordinate(-36, 56, angle: 45),
        ToppingCoordinate(-8, 52, angle: -10),
        ToppingCoordinate(20, 54, angle: 20),
        ToppingCoordinate(-12, -18, angle: -30),
        ToppingCoordinate(12, -16, angle: 25),
        ToppingCoordinate(-2, 14, angle: -5),
        ToppingCoordinate(44, -3, angle: 40),
        ToppingCoordinate(-44, -8, angle: -20),
        ToppingCoordinate(2, -42, angle: 15),
        ToppingCoordinate(4, 40, angle: -25)
    ]
    
    // Pepperoni Coordinates: Left, Right, Whole
    private let pepperoniLeftCoords: [ToppingCoordinate] = [
        ToppingCoordinate(-30, -50),
        ToppingCoordinate(-14, -50),
        ToppingCoordinate(-16, -34),
        ToppingCoordinate(-46, -18),
        ToppingCoordinate(-40, 22),
        ToppingCoordinate(-24, 46),
        ToppingCoordinate(-48, 8),
        ToppingCoordinate(-28, 4)
    ]
    
    private let pepperoniRightCoords: [ToppingCoordinate] = [
        ToppingCoordinate(30, -50),
        ToppingCoordinate(14, -50),
        ToppingCoordinate(16, -34),
        ToppingCoordinate(46, -18),
        ToppingCoordinate(40, 22),
        ToppingCoordinate(24, 46),
        ToppingCoordinate(48, 8),
        ToppingCoordinate(28, 4)
    ]
    
    // Green Pepper Strips Coordinates
    private let greenPepperCoords: [ToppingCoordinate] = [
        ToppingCoordinate(-23, -34, angle: 45),
        ToppingCoordinate(8, -12, angle: 60),
        ToppingCoordinate(4, 15, angle: 60),
        ToppingCoordinate(-18, 30, angle: -40),
        ToppingCoordinate(36, -35, angle: 15),
        ToppingCoordinate(-48, -10, angle: -35),
        ToppingCoordinate(44, 25, angle: -45),
        ToppingCoordinate(-12, 10, angle: 70)
    ]
    
    // Black Olives Coordinates
    private let blackOliveCoords: [ToppingCoordinate] = [
        ToppingCoordinate(-36, -30),
        ToppingCoordinate(30, -32),
        ToppingCoordinate(-18, 40),
        ToppingCoordinate(34, 30),
        ToppingCoordinate(15, -15),
        ToppingCoordinate(-42, 20),
        ToppingCoordinate(45, -5),
        ToppingCoordinate(-10, -50)
    ]
    
    // Red Onion Arc Coordinates
    private let redOnionCoords: [ToppingCoordinate] = [
        ToppingCoordinate(-30, -20, angle: -20),
        ToppingCoordinate(25, -40, angle: 45),
        ToppingCoordinate(-15, 30, angle: 75),
        ToppingCoordinate(35, 15, angle: -60),
        ToppingCoordinate(5, -10, angle: 15),
        ToppingCoordinate(-45, 35, angle: 30)
    ]
    
    // Mushroom Coordinates
    private let mushroomCoords: [ToppingCoordinate] = [
        ToppingCoordinate(-20, -42, angle: -10),
        ToppingCoordinate(38, -20, angle: 25),
        ToppingCoordinate(-40, 15, angle: 40),
        ToppingCoordinate(18, 38, angle: -30),
        ToppingCoordinate(-5, 5, angle: 15),
        ToppingCoordinate(30, 42, angle: 60)
    ]
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // 1. Crust & Rim Layer (210 x 210)
            crustLayer
            
            // 2. Sauce Layer (178 x 178)
            sauceLayer
            
            // 3. Cheese Melt Layer
            cheeseLayer
            
            // 4. Meat Toppings Layer
            meatLayer
            
            // 5. Veggie Toppings Layer
            veggieLayer
            
            // 6. Finishing Drizzles & Herbs Layer
            finishLayer
            
            // 7. Recipe Style Half & Half Divider
            if recipeStyle == .halfAndHalf {
                halfAndHalfDivider
            }
        }
        .frame(width: 210, height: 210)
    }
    
    // MARK: - 1. Crust Layer
    
    private var crustLayer: some View {
        ZStack {
            // Shadow under crust
            Circle()
                .fill(Color.black.opacity(0.15))
                .frame(width: 206, height: 206)
                .offset(y: 3)
                .blur(radius: 4)
            
            // Baked dough outer ring with radial baked gradient
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0xDE / 255.0, green: 0x9E / 255.0, blue: 0x58 / 255.0),
                            Color(red: 0xCA / 255.0, green: 0x85 / 255.0, blue: 0x44 / 255.0),
                            Color(red: 0xB8 / 255.0, green: 0x73 / 255.0, blue: 0x35 / 255.0)
                        ]),
                        center: .center,
                        startRadius: 84,
                        endRadius: 105
                    )
                )
                .frame(width: 210, height: 210)
            
            // Subtle crust rim outer edge
            Circle()
                .stroke(Color(red: 0xA6 / 255.0, green: 0x64 / 255.0, blue: 0x2A / 255.0), lineWidth: 1.5)
                .frame(width: 209, height: 209)
        }
    }
    
    // MARK: - 2. Sauce Layer
    
    private var sauceLayer: some View {
        ZStack {
            // Dough base inside crust rim
            Circle()
                .fill(Color(red: 0xF3 / 255.0, green: 0xE8 / 255.0, blue: 0xD0 / 255.0))
                .frame(width: 178, height: 178)
            
            if let sauceColor = currentSauceColor {
                Circle()
                    .fill(sauceColor)
                    .opacity(currentSauceOpacity)
                    .frame(width: 178, height: 178)
                    .mask(saucePortionMask)
            }
        }
        .frame(width: 178, height: 178)
        .clipShape(Circle())
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: selectedSauceId)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: saucePortion)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: sauceAmount)
    }
    
    private var currentSauceColor: Color? {
        switch selectedSauceId {
        case "s_tomato":
            return Color(red: 0xD8 / 255.0, green: 0x35 / 255.0, blue: 0x2A / 255.0)
        case "s_spicy_tomato":
            return Color(red: 0x9E / 255.0, green: 0x20 / 255.0, blue: 0x1A / 255.0)
        case "s_creamy_alfredo":
            return Color(red: 0xF5 / 255.0, green: 0xEC / 255.0, blue: 0xD0 / 255.0)
        case "s_bbq":
            return Color(red: 0x73 / 255.0, green: 0x2B / 255.0, blue: 0x1A / 255.0)
        case "s_buffalo":
            return Color(red: 0xEA / 255.0, green: 0x58 / 255.0, blue: 0x1E / 255.0)
        case "s_pesto":
            return Color(red: 0x58 / 255.0, green: 0x88 / 255.0, blue: 0x32 / 255.0)
        case "s_garlic_rub":
            return Color(red: 0xEE / 255.0, green: 0xD8 / 255.0, blue: 0x94 / 255.0)
        case "s_olive_oil":
            return Color(red: 0xD8 / 255.0, green: 0xC5 / 255.0, blue: 0x66 / 255.0)
        default:
            return nil
        }
    }
    
    private var currentSauceOpacity: Double {
        switch sauceAmount {
        case .light: return 0.65
        case .regular: return 0.88
        case .extra: return 1.0
        }
    }
    
    @ViewBuilder
    private var saucePortionMask: some View {
        switch saucePortion {
        case .whole:
            Rectangle()
        case .left:
            HStack(spacing: 0) {
                Rectangle()
                Color.clear
            }
        case .right:
            HStack(spacing: 0) {
                Color.clear
                Rectangle()
            }
        }
    }
    
    // MARK: - 3. Cheese Layer
    
    private var cheeseLayer: some View {
        let selectedCheeses = toppings.filter { $0.category == .cheese && $0.isSelected }
        
        return ZStack {
            if !selectedCheeses.isEmpty {
                ForEach(selectedCheeses) { cheese in
                    let coords = filterCoords(
                        cheeseBlobCoords,
                        portion: cheese.portion,
                        count: countForAmount(cheese.amount, base: 18, light: 10, extra: 28)
                    )
                    
                    let tint = cheeseColor(for: cheese.id)
                    
                    ForEach(coords, id: \.self) { pt in
                        Capsule()
                            .fill(tint)
                            .frame(width: 19, height: 13)
                            .rotationEffect(.degrees(pt.angle))
                            .offset(x: pt.x, y: pt.y)
                            .shadow(color: Color.black.opacity(0.04), radius: 1, x: 0, y: 1)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            }
        }
        .frame(width: 178, height: 178)
        .clipShape(Circle())
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: selectedCheeses.map { "\($0.id)_\($0.portion.rawValue)_\($0.amount.rawValue)" })
    }
    
    private func cheeseColor(for id: String) -> Color {
        switch id {
        case "c6": // Gorgonzola
            return Color(red: 0xD6 / 255.0, green: 0xE4 / 255.0, blue: 0xD8 / 255.0)
        case "c4": // Cheddar
            return Color(red: 0xF5 / 255.0, green: 0x9E / 255.0, blue: 0x32 / 255.0)
        case "c2": // Asiago
            return Color(red: 0xF3 / 255.0, green: 0xEA / 255.0, blue: 0xCA / 255.0)
        default: // Mozzarella & others
            return Color(red: 0xFD / 255.0, green: 0xF6 / 255.0, blue: 0xE3 / 255.0)
        }
    }
    
    // MARK: - 4. Meat Toppings Layer
    
    private var meatLayer: some View {
        let selectedMeats = toppings.filter { $0.category == .meat && $0.isSelected }
        
        return ZStack {
            ForEach(selectedMeats) { meat in
                let count = countForAmount(meat.amount, base: 6, light: 3, extra: 10)
                let coords = meatCoords(portion: meat.portion, count: count)
                
                ForEach(coords, id: \.self) { pt in
                    meatItemView(for: meat.id)
                        .offset(x: pt.x, y: pt.y)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .frame(width: 178, height: 178)
        .clipShape(Circle())
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: selectedMeats.map { "\($0.id)_\($0.portion.rawValue)_\($0.amount.rawValue)" })
    }
    
    @ViewBuilder
    private func meatItemView(for id: String) -> some View {
        if id == "m1" { // Pepperoni (Red round chips matching snapshot!)
            ZStack {
                Circle()
                    .fill(Color(red: 0xBA / 255.0, green: 0x2A / 255.0, blue: 0x26 / 255.0))
                    .frame(width: 17, height: 17)
                
                Circle()
                    .stroke(Color(red: 0x82 / 255.0, green: 0x1A / 255.0, blue: 0x14 / 255.0), lineWidth: 1.2)
                    .frame(width: 17, height: 17)
                
                Circle()
                    .fill(Color.white.opacity(0.24))
                    .frame(width: 3.5, height: 3.5)
                    .offset(x: -3, y: -3)
            }
            .shadow(color: Color.black.opacity(0.12), radius: 1, x: 0, y: 1)
        } else if id == "m2" || id == "m8" { // Sausage Chunks
            RoundedRectangle(cornerRadius: 3.5)
                .fill(Color(red: 0x7E / 255.0, green: 0x39 / 255.0, blue: 0x1C / 255.0))
                .frame(width: 11, height: 9)
                .shadow(color: Color.black.opacity(0.12), radius: 1, x: 0, y: 1)
        } else if id == "m4" { // Bacon Strips
            RoundedRectangle(cornerRadius: 1.5)
                .fill(Color(red: 0x8B / 255.0, green: 0x26 / 255.0, blue: 0x1E / 255.0))
                .frame(width: 14, height: 5)
        } else { // Chicken / Canadian Bacon / Salami
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(red: 0xD8 / 255.0, green: 0xB4 / 255.0, blue: 0x82 / 255.0))
                .frame(width: 12, height: 8)
        }
    }
    
    private func meatCoords(portion: ToppingPortion, count: Int) -> [ToppingCoordinate] {
        switch portion {
        case .left:
            return Array(pepperoniLeftCoords.prefix(count))
        case .right:
            return Array(pepperoniRightCoords.prefix(count))
        case .whole:
            let half = max(1, count / 2)
            let leftSlice = Array(pepperoniLeftCoords.prefix(half))
            let rightSlice = Array(pepperoniRightCoords.prefix(count - half))
            return leftSlice + rightSlice
        }
    }
    
    // MARK: - 5. Veggie Toppings Layer
    
    private var veggieLayer: some View {
        let selectedVeggies = toppings.filter { $0.category == .veggie && $0.isSelected }
        
        return ZStack {
            ForEach(selectedVeggies) { veggie in
                let count = countForAmount(veggie.amount, base: 6, light: 4, extra: 8)
                let coords = filterCoords(coordsForVeggie(veggie.id), portion: veggie.portion, count: count)
                
                ForEach(coords, id: \.self) { pt in
                    veggieItemView(for: veggie.id, angle: pt.angle)
                        .offset(x: pt.x, y: pt.y)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .frame(width: 178, height: 178)
        .clipShape(Circle())
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: selectedVeggies.map { "\($0.id)_\($0.portion.rawValue)_\($0.amount.rawValue)" })
    }
    
    @ViewBuilder
    private func veggieItemView(for id: String, angle: Double) -> some View {
        if id == "v15" { // Green Bell Peppers (Green capsule matching snapshot!)
            Capsule()
                .fill(Color(red: 0x2E / 255.0, green: 0x7D / 255.0, blue: 0x32 / 255.0))
                .frame(width: 15, height: 4.5)
                .rotationEffect(.degrees(angle))
                .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
        } else if id == "v3" || id == "v16" { // Olives
            Circle()
                .stroke(Color(red: 0x22 / 255.0, green: 0x22 / 255.0, blue: 0x22 / 255.0), lineWidth: 3.0)
                .frame(width: 12, height: 12)
        } else if id == "v2" { // Red Onion
            Path { path in
                path.addArc(center: CGPoint(x: 7, y: 7), radius: 7, startAngle: .degrees(0), endAngle: .degrees(150), clockwise: false)
            }
            .stroke(Color(red: 0x8E / 255.0, green: 0x2E / 255.0, blue: 0x62 / 255.0), lineWidth: 2.2)
            .frame(width: 14, height: 14)
            .rotationEffect(.degrees(angle))
        } else if id == "v5" { // Mushrooms
            Capsule()
                .fill(Color(red: 0x9E / 255.0, green: 0x8B / 255.0, blue: 0x7E / 255.0))
                .frame(width: 13, height: 6)
                .rotationEffect(.degrees(angle))
        } else if id == "v10" { // Pineapple
            RoundedRectangle(cornerRadius: 1.5)
                .fill(Color(red: 0xF4 / 255.0, green: 0xC7 / 255.0, blue: 0x3C / 255.0))
                .frame(width: 10, height: 9)
                .rotationEffect(.degrees(angle))
        } else { // Spinach, Basil, Tomatoes, Jalapenos
            Capsule()
                .fill(Color(red: 0x38 / 255.0, green: 0x6C / 255.0, blue: 0x30 / 255.0))
                .frame(width: 14, height: 5)
                .rotationEffect(.degrees(angle))
        }
    }
    
    private func coordsForVeggie(_ id: String) -> [ToppingCoordinate] {
        switch id {
        case "v15": return greenPepperCoords
        case "v3", "v16": return blackOliveCoords
        case "v2": return redOnionCoords
        case "v5": return mushroomCoords
        default: return greenPepperCoords
        }
    }
    
    // MARK: - 6. Finishing Layer (Drizzles)
    
    private var finishLayer: some View {
        let selectedFinishes = toppings.filter { $0.category == .finish && $0.isSelected }
        
        return ZStack {
            ForEach(selectedFinishes) { finish in
                let color = drizzleColor(for: finish.id)
                
                // Vertical Squiggly Wave
                if finish.portion != .left {
                    VerticalSquigglyPath(waveCount: 3)
                        .stroke(color, style: StrokeStyle(lineWidth: 2.4, lineCap: .round, lineJoin: .round))
                        .frame(width: 7, height: 30)
                        .offset(x: 36, y: 12)
                        .transition(.opacity.combined(with: .scale))
                }
                
                // Horizontal Squiggly Wave
                if finish.portion != .right {
                    HorizontalSquigglyPath(waveCount: 3)
                        .stroke(color, style: StrokeStyle(lineWidth: 2.4, lineCap: .round, lineJoin: .round))
                        .frame(width: 24, height: 8)
                        .offset(x: -22, y: 34)
                        .transition(.opacity.combined(with: .scale))
                }
            }
        }
        .frame(width: 178, height: 178)
        .clipShape(Circle())
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: selectedFinishes.map { "\($0.id)_\($0.portion.rawValue)" })
    }
    
    private func drizzleColor(for id: String) -> Color {
        switch id {
        case "f2": // Mike's Hot Honey (Golden-amber matching snapshot!)
            return Color(red: 0xDF / 255.0, green: 0x8C / 255.0, blue: 0x28 / 255.0)
        case "f1": // Balsamic Glaze
            return Color(red: 0x48 / 255.0, green: 0x22 / 255.0, blue: 0x1A / 255.0)
        case "f3": // BBQ Drizzle
            return Color(red: 0x6E / 255.0, green: 0x2B / 255.0, blue: 0x1A / 255.0)
        case "f4": // Buffalo
            return Color(red: 0xEA / 255.0, green: 0x58 / 255.0, blue: 0x1E / 255.0)
        case "f5": // Pesto
            return Color(red: 0x58 / 255.0, green: 0x88 / 255.0, blue: 0x32 / 255.0)
        case "f6": // Ranch
            return Color(red: 0xF8 / 255.0, green: 0xF4 / 255.0, blue: 0xEC / 255.0)
        default:
            return Color(red: 0xDF / 255.0, green: 0x8C / 255.0, blue: 0x28 / 255.0)
        }
    }
    
    // MARK: - 7. Half & Half Divider
    
    private var halfAndHalfDivider: some View {
        Path { path in
            path.move(to: CGPoint(x: 105, y: 16))
            path.addLine(to: CGPoint(x: 105, y: 194))
        }
        .stroke(Color.white.opacity(0.85), style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
    }
    
    // MARK: - Helpers
    
    private func countForAmount(_ amount: ToppingAmount, base: Int, light: Int, extra: Int) -> Int {
        switch amount {
        case .light: return light
        case .regular: return base
        case .extra: return extra
        }
    }
    
    private func filterCoords(_ coords: [ToppingCoordinate], portion: ToppingPortion, count: Int) -> [ToppingCoordinate] {
        let matching: [ToppingCoordinate]
        switch portion {
        case .left:
            matching = coords.filter { $0.x <= 0 }
        case .right:
            matching = coords.filter { $0.x >= 0 }
        case .whole:
            matching = coords
        }
        return Array(matching.prefix(count))
    }
}

// MARK: - Centered Flow Layout for Added Ingredients Pills

struct IngredientsPillsFlowView: View {
    let pills: [String]
    var availableWidth: CGFloat = UIScreen.main.bounds.width - 24
    
    var body: some View {
        let rows = computeRows()
        
        VStack(spacing: 8) {
            ForEach(0..<rows.count, id: \.self) { rowIndex in
                HStack(spacing: 8) {
                    ForEach(rows[rowIndex], id: \.self) { text in
                        Text(text)
                            .font(.barlowSemiBold(size: 13))
                            .foregroundColor(Color("app_black"))
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(
                                Capsule()
                                    .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.2)
                                    .background(Capsule().fill(Color.white))
                            )
                            .shadow(color: Color.black.opacity(0.02), radius: 2, x: 0, y: 1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private func computeRows() -> [[String]] {
        var rows: [[String]] = []
        var currentRow: [String] = []
        var currentLineWidth: CGFloat = 0
        let maxLineWidth = max(345, availableWidth)
        
        for pill in pills {
            let estimatedWidth = CGFloat(pill.count) * 5.6 + 24
            if currentLineWidth + estimatedWidth > maxLineWidth && !currentRow.isEmpty {
                rows.append(currentRow)
                currentRow = [pill]
                currentLineWidth = estimatedWidth + 8
            } else {
                currentRow.append(pill)
                currentLineWidth += estimatedWidth + 8
            }
        }
        if !currentRow.isEmpty {
            rows.append(currentRow)
        }
        return rows
    }
}

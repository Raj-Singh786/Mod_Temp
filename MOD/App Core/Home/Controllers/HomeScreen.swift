import SwiftUI

struct HomeScreen: View {
    @AppStorage("isGuestUser") var isGuestStored: Bool = true
    var isGuestOverride: Bool? = nil

    var isGuest: Bool {
        isGuestOverride ?? isGuestStored
    }

    @State private var selectedPromoIndex: Int = 0

    init(isGuest: Bool? = nil) {
        self.isGuestOverride = isGuest
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                // 1. Location Header (Adapts to Guest vs Logged-In)
                LocationHeaderView(isGuest: isGuest)

                // 2. Main Loyalty Card (Only for guest user)
                if isGuest {
                    WelcomeLoyaltyCardView()
                }

                // 3. Promotions & Deals Section (Wide card + page indicator)
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Promotions & Deals", buttonTitle: "All (6)", action: {})
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 14) {
                            ForEach(Array(MockData.promos.enumerated()), id: \.element.id) { index, promo in
                                PromoCardView(promo: promo)
                            }
                        }
                        .padding(.horizontal, 16)
                    }

                    // Page Indicator Dots
                    HStack(spacing: 6) {
                        ForEach(0..<MockData.promos.count, id: \.self) { index in
                            if index == selectedPromoIndex {
                                Capsule()
                                    .fill(Color.red)
                                    .frame(width: 22, height: 6)
                            } else {
                                Circle()
                                    .fill(Color(.systemGray4))
                                    .frame(width: 6, height: 6)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 4)
                }

                // 4. Feature Section (Guest: QuickFeaturesView | Logged-in: RecentOrderView)
                if isGuest {
                    QuickFeaturesView()
                } else {
                    RecentOrderView()
                }

                // 5. Recommended for You (Horizontal)
                SectionHeader(
                    title: "Recommended for You",
                    subtitle: "Bestsellers based on your taste",
                    buttonTitle: "View menu",
                    action: {}
                )
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(MockData.recommended) { pizza in
                            PizzaCardView(pizza: pizza)
                        }
                    }.padding(.horizontal, 16)
                }

                // 6. Value Combos (Horizontal)
                SectionHeader(
                    title: "Value Combos",
                    subtitle: "Pizza + Sides + Drinks combos",
                    buttonTitle: "View menu",
                    action: {}
                )
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(MockData.combos) { combo in
                            ComboCardView(combo: combo)
                        }
                    }.padding(.horizontal, 16)
                }
            }
            .padding(.vertical, 18)
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarHidden(true)
    }
}

// MARK: - Subviews

struct LocationHeaderView: View {
    var isGuest: Bool = false
    @State private var address: String = ""

    var body: some View {
        HStack(spacing: 10) {
            // Main Location Container
            HStack(spacing: 10) {
                // Pin Icon with Background
                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.1))
                        .frame(width: 38, height: 38)
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.red)
                }
                
                // Labels
                VStack(alignment: .leading, spacing: 2) {
                    Text(isGuest ? "Set delivery address" : "772 Silva Ave, Apt 4B")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.black)
                        .lineLimit(1)
                    Text(isGuest ? "Enter address for nearby" : "Delivery ~45 min • $2.99")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.down")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.white)
            .cornerRadius(28)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 3)
            
            // Pizza Tracker Icon (Only shown for logged-in users)
            if !isGuest {
                PizzaTrackerView(activeSlices: 2, totalSlices: 6, badgeCount: 2)
            }
            
            // Notification Button
            ZStack(alignment: .topTrailing) {
                Button(action: {}) {
                    Image(systemName: "bell")
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                        .frame(width: 44, height: 44)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 3)
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
        .padding(.top, 14)
    }
}

struct WelcomeLoyaltyCardView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("★ NEW MEMBER PERK")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.red.opacity(0.7))
                    .cornerRadius(8)
                Spacer()
                Text("Free to join")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.85))
            }
            Text("Unlock Up to $20 in Welcome Benefits")
                .font(.system(size: 19, weight: .heavy))
                .foregroundColor(.white)
            Text("Sign in or create an account to unlock vouchers, free delivery on your 1st order & member-only deals.")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.93))
            HStack(spacing: 10) {
                PillView(text: "$20 Off 1st Order")
                PillView(text: "Free Breadsticks")
                PillView(text: "Zero Delivery Fee")
            }
            HStack(spacing: 14) {
                Button(action: {}) {
                    Text("Claim Loyalty")
                        .font(.system(size: 15, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.white)
                        .foregroundColor(.red)
                        .cornerRadius(9)
                }
                Button(action: {}) {
                    Text("Browse as guest")
                        .font(.system(size: 15, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .foregroundColor(.white)
                        .background(Color.white.opacity(0.18))
                        .cornerRadius(9)
                }
            }
        }
        .padding(18)
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.red, Color.red.opacity(0.82)]),
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(22)
        .padding(.horizontal, 14)
    }
}

struct PromoCardView: View {
    let promo: Promo
    
    var body: some View {
        HStack(spacing: 0) {
            // Left Content
            VStack(alignment: .leading, spacing: 6) {
                // Badge
                Text(promo.badge)
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundColor(promo.badgeTextColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(promo.badgeBgColor)
                    .cornerRadius(6)

                // Multi-line Title
                VStack(alignment: .leading, spacing: 1) {
                    Text(promo.titleLine1)
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundColor(.white)
                    Text(promo.titleLine2)
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundColor(promo.titleLine2Color)
                }
                
                Text(promo.subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(1)
                
                Spacer(minLength: 6)
                
                // Button
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Text(promo.buttonText)
                            .font(.system(size: 13, weight: .bold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(promo.buttonTextColor)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(promo.buttonBgColor)
                    .cornerRadius(8)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .background(promo.cardBgColor)

            // Right Image
            ZStack {
                if let imageName = promo.imageName, !imageName.isEmpty, let _ = UIImage(named: imageName) {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 140, height: 156)
                        .clipped()
                } else {
                    ZStack {
                        Color.white.opacity(0.12)
                        VStack(spacing: 6) {
                            Image(systemName: "shippingbox.fill")
                                .font(.system(size: 34))
                                .foregroundColor(.white.opacity(0.75))
                            Text("FRESH & HOT")
                                .font(.system(size: 10, weight: .heavy))
                                .foregroundColor(.white.opacity(0.85))
                        }
                    }
                    .frame(width: 140, height: 156)
                }
            }
            .frame(width: 140, height: 156)
            .clipped()
        }
        .frame(width: 320, height: 156)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Quick Features (Hot & Fresh, Live Tracking, Hut Rewards)

struct QuickFeaturesView: View {
    var body: some View {
        HStack(spacing: 12) {
            QuickFeatureCard(
                iconName: "bolt.fill",
                title: "Hot & Fresh",
                subtitle: "30–min guarantee"
            )
            QuickFeatureCard(
                iconName: "mappin.and.ellipse",
                title: "Live Tracking",
                subtitle: "Oven to door"
            )
            QuickFeatureCard(
                iconName: "dollarsign.circle",
                title: "Hut Rewards",
                subtitle: "Earn free pizza"
            )
        }
        .padding(.horizontal, 16)
    }
}

struct QuickFeatureCard: View {
    let iconName: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.1))
                    .frame(width: 44, height: 44)
                Image(systemName: iconName)
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundColor(.red)
            }
            .padding(.top, 4)

            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.85)

            Text(subtitle)
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 6)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
    }
}

// MARK: - Pizza Tracker View (Logged-in Header)

struct PizzaTrackerView: View {
    var activeSlices: Int = 2
    var totalSlices: Int = 6
    var badgeCount: Int = 2

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ZStack {
                // Outer circle border
                Circle()
                    .stroke(Color.black.opacity(0.12), lineWidth: 1)
                    .background(Circle().fill(Color.white))

                // Custom Pizza Slices Canvas
                Canvas { context, size in
                    let center = CGPoint(x: size.width / 2, y: size.height / 2)
                    let radius = min(size.width, size.height) / 2 - 2
                    let sliceAngle = (2 * Double.pi) / Double(totalSlices)

                    for i in 0..<totalSlices {
                        let startAngle = Double(i) * sliceAngle - Double.pi / 2
                        let endAngle = startAngle + sliceAngle

                        var path = Path()
                        path.move(to: center)
                        path.addArc(center: center, radius: radius, startAngle: Angle(radians: startAngle), endAngle: Angle(radians: endAngle), clockwise: false)
                        path.closeSubpath()

                        if i < activeSlices {
                            // Active cheese & pepperoni slice
                            context.fill(path, with: .color(Color(red: 1.0, green: 0.78, blue: 0.28)))
                            context.stroke(path, with: .color(Color(red: 0.85, green: 0.55, blue: 0.1)), lineWidth: 1)

                            let midAngle = startAngle + sliceAngle / 2
                            let pepDist1 = radius * 0.52
                            let pep1 = CGPoint(x: center.x + CGFloat(cos(midAngle - 0.12)) * pepDist1,
                                               y: center.y + CGFloat(sin(midAngle - 0.12)) * pepDist1)
                            let pepDist2 = radius * 0.78
                            let pep2 = CGPoint(x: center.x + CGFloat(cos(midAngle + 0.14)) * pepDist2,
                                               y: center.y + CGFloat(sin(midAngle + 0.14)) * pepDist2)

                            let pepPath1 = Path(ellipseIn: CGRect(x: pep1.x - 2.5, y: pep1.y - 2.5, width: 5, height: 5))
                            context.fill(pepPath1, with: .color(Color(red: 0.85, green: 0.18, blue: 0.18)))
                            let pepPath2 = Path(ellipseIn: CGRect(x: pep2.x - 2, y: pep2.y - 2, width: 4, height: 4))
                            context.fill(pepPath2, with: .color(Color(red: 0.85, green: 0.18, blue: 0.18)))
                        } else {
                            // Inactive slice
                            context.fill(path, with: .color(Color(red: 0.93, green: 0.94, blue: 0.96)))
                            context.stroke(path, with: .color(Color.black.opacity(0.18)), lineWidth: 0.8)

                            let midAngle = startAngle + sliceAngle / 2
                            let dotDist = radius * 0.6
                            let dot = CGPoint(x: center.x + CGFloat(cos(midAngle)) * dotDist,
                                              y: center.y + CGFloat(sin(midAngle)) * dotDist)
                            let dotPath = Path(ellipseIn: CGRect(x: dot.x - 1, y: dot.y - 1, width: 2, height: 2))
                            context.fill(dotPath, with: .color(Color.black.opacity(0.25)))
                        }
                    }
                }
                .frame(width: 40, height: 40)
            }
            .frame(width: 44, height: 44)
            .background(Color.white)
            .clipShape(Circle())
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 3)

            // Red Badge
            if badgeCount > 0 {
                Text("\(badgeCount)")
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundColor(.white)
                    .frame(width: 18, height: 18)
                    .background(Color.red)
                    .clipShape(Circle())
                    .offset(x: 3, y: -3)
            }
        }
    }
}

// MARK: - Recent Order View (Logged-in Mode)

struct RecentOrderView: View {
    var statusText: String = "Delivered 3 days ago"
    var itemsText: String = "Pepperoni Pizza, Breadsticks,..."
    var priceText: String = "$24.90"
    var onReorder: () -> Void = {}
    var onViewAll: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Recent Order", buttonTitle: "View all", action: onViewAll)

            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 8) {
                    // Status Badge
                    Text(statusText)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(red: 0.12, green: 0.55, blue: 0.38))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color(red: 0.90, green: 0.98, blue: 0.94))
                        .cornerRadius(6)

                    // Items Description
                    Text(itemsText)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.black)
                        .lineLimit(1)

                    // Price
                    Text(priceText)
                        .font(.system(size: 17, weight: .heavy))
                        .foregroundColor(.black)
                }

                Spacer()

                // Reorder Button
                Button(action: onReorder) {
                    VStack(spacing: 5) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 18, weight: .bold))
                        Text("Reorder")
                            .font(.system(size: 13, weight: .bold))
                    }
                    .foregroundColor(.red)
                    .frame(width: 86, height: 72)
                    .background(Color.red.opacity(0.08))
                    .cornerRadius(14)
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(18)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 3)
            .padding(.horizontal, 16)
        }
    }
}

struct PizzaCardView: View {
    let pizza: Pizza
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Image with Badge
            ZStack(alignment: .topLeading) {
                if let _ = UIImage(named: pizza.imageName) {
                    Image(pizza.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 148, height: 125)
                        .cornerRadius(16)
                        .clipped()
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.gray.opacity(0.15))
                        .frame(width: 148, height: 125)
                }

                if let badge = pizza.badge, let color = pizza.badgeColor {
                    Text(badge)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(pizza.badgeTextColor ?? .white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(color)
                        .cornerRadius(6)
                        .padding(7)
                }
            }
            .frame(width: 148, height: 125)

            // Name
            Text(pizza.name)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.black)
                .lineLimit(1)

            // Description
            Text(pizza.description)
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .lineLimit(1)

            // Price & Plus Button Row
            HStack(alignment: .center) {
                Text(pizza.price)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)

                Spacer()

                Button(action: {}) {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(Color.red)
                        .clipShape(Circle())
                }
            }
        }
        .padding(11)
        .frame(width: 170)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
    }
}

struct ComboCardView: View {
    let combo: Combo
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                // Badge
                Text(combo.badge)
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundColor(.white)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.22))
                    .cornerRadius(6)

                // Multi-line Title
                VStack(alignment: .leading, spacing: 2) {
                    Text(combo.titleLine1)
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundColor(.white)
                    Text(combo.titleLine2)
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundColor(.white)
                }

                // Price Row
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(combo.price)
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundColor(.white)
                    Text(combo.originalPrice)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.65))
                        .strikethrough()
                }
                .padding(.top, 2)
            }

            Spacer()

            // Customize Button
            Button(action: {}) {
                Text("Customize")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(red: 0.88, green: 0.12, blue: 0.18))
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .cornerRadius(20)
            }
        }
        .padding(18)
        .frame(width: 330)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.88, green: 0.12, blue: 0.18),
                    Color(red: 0.72, green: 0.05, blue: 0.18)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(22)
        .shadow(color: Color(red: 0.88, green: 0.12, blue: 0.18).opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

struct PillView: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.white.opacity(0.16))
            .cornerRadius(9)
    }
}

struct SectionHeader: View {
    let title: String
    var subtitle: String? = nil
    var buttonTitle: String? = nil
    var action: (() -> Void)? = nil
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            if let buttonTitle = buttonTitle, let action = action {
                Button(action: action) {
                    Text(buttonTitle)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Mock Data Models

struct Promo: Identifiable {
    let id = UUID()
    let badge: String
    var badgeBgColor: Color = Color.red
    var badgeTextColor: Color = .white
    let titleLine1: String
    let titleLine2: String
    var titleLine2Color: Color = Color(red: 1.0, green: 0.78, blue: 0.1)
    let subtitle: String
    var buttonText: String = "Order Now"
    var cardBgColor: Color = Color(red: 0.11, green: 0.11, blue: 0.13)
    var buttonBgColor: Color = Color.red
    var buttonTextColor: Color = .white
    var imageName: String? = "onboard1"
}

struct Pizza: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let price: String
    let imageName: String
    var badge: String? = nil
    var badgeColor: Color? = nil
    var badgeTextColor: Color? = nil
}

struct Combo: Identifiable {
    let id = UUID()
    let badge: String
    let titleLine1: String
    let titleLine2: String
    let price: String
    let originalPrice: String
}

struct MockData {
    static let promos: [Promo] = [
        Promo(
            badge: "LIMITED OFFER",
            badgeBgColor: Color.red,
            badgeTextColor: .white,
            titleLine1: "MOD BOX",
            titleLine2: "UP TO 30% OFF",
            titleLine2Color: Color(red: 1.0, green: 0.78, blue: 0.1),
            subtitle: "Build your custom combo",
            buttonText: "Order Now",
            cardBgColor: Color(red: 0.11, green: 0.11, blue: 0.13),
            buttonBgColor: Color.red,
            buttonTextColor: .white,
            imageName: "onboard1"
        ),
        Promo(
            badge: "SUPER SAVER",
            badgeBgColor: Color(red: 1.0, green: 0.82, blue: 0.2),
            badgeTextColor: .black,
            titleLine1: "GREAT DEALS",
            titleLine2: "BUY 1 GET 1",
            titleLine2Color: .white,
            subtitle: "Online exclusive · Margherita + Sides",
            buttonText: "Order Now",
            cardBgColor: Color.red,
            buttonBgColor: .white,
            buttonTextColor: Color.red,
            imageName: "onboard2"
        ),
        Promo(
            badge: "WEEKEND SPECIAL",
            badgeBgColor: Color.red,
            badgeTextColor: .white,
            titleLine1: "COMBO CRUNCH",
            titleLine2: "FLAT 25% OFF",
            titleLine2Color: Color(red: 1.0, green: 0.78, blue: 0.1),
            subtitle: "Pizza + garlic sticks + drinks",
            buttonText: "Order Now",
            cardBgColor: Color(red: 0.11, green: 0.11, blue: 0.13),
            buttonBgColor: Color.red,
            buttonTextColor: .white,
            imageName: "onboard3"
        ),
        Promo(
            badge: "FAMILY PACK",
            badgeBgColor: Color(red: 1.0, green: 0.82, blue: 0.2),
            badgeTextColor: .black,
            titleLine1: "MEGA SAVER",
            titleLine2: "SAVE UP TO $15",
            titleLine2Color: .white,
            subtitle: "Feast with friends & family",
            buttonText: "Order Now",
            cardBgColor: Color.red,
            buttonBgColor: .white,
            buttonTextColor: Color.red,
            imageName: "onboard1"
        )
    ]
    static let recommended = [
        Pizza(
            name: "Pepperoni Lovers",
            description: "Signature red sauce,...",
            price: "$15.99",
            imageName: "pizza1",
            badge: "Popular",
            badgeColor: Color.black.opacity(0.75),
            badgeTextColor: .white
        ),
        Pizza(
            name: "Pepperoni &...",
            description: "Cream cheese swirl lattice",
            price: "$16.99",
            imageName: "pizza2",
            badge: "Special",
            badgeColor: Color(red: 0.98, green: 0.62, blue: 0.08),
            badgeTextColor: .white
        ),
        Pizza(
            name: "Classic Veggie",
            description: "Smoked artisan sausage...",
            price: "$14.50",
            imageName: "pizza3",
            badge: nil,
            badgeColor: nil,
            badgeTextColor: nil
        )
    ]
    static let combos = [
        Combo(
            badge: "FAMILY MEAL DEAL",
            titleLine1: "2 Mediums + Breadsticks +",
            titleLine2: "2L Soda",
            price: "$29.99",
            originalPrice: "$39.99"
        ),
        Combo(
            badge: "PARTY PACK",
            titleLine1: "3 Large Pizzas + Sides +",
            titleLine2: "3L Soda",
            price: "$39.99",
            originalPrice: "$49.99"
        )
    ]
}

#Preview("Logged-in User Mode") {
    NavigationView {
        HomeScreen(isGuest: false)
    }
}

#Preview("Guest User Mode") {
    NavigationView {
        HomeScreen(isGuest: true)
    }
}

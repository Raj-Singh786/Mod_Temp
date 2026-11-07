import SwiftUI

struct HomeScreen: View {
    @State private var selectedPromoIndex: Int = 0

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                // 1. Location Header
                LocationHeaderView()

                // 2. Main Loyalty Card (Welcome Perks)
                WelcomeLoyaltyCardView()

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

                // 4. Quick Feature Badges (Hot & Fresh, Live Tracking, Hut Rewards)
                QuickFeaturesView()

                // 5. Recommended for You (Horizontal)
                SectionHeader(title: "Recommended for You", subtitle: "Bestsellers based on your taste")
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(MockData.recommended) { pizza in
                            PizzaCardView(pizza: pizza)
                        }
                    }.padding(.horizontal, 16)
                }

                // 6. Value Combos (Horizontal)
                SectionHeader(title: "Value Combos", buttonTitle: "View menu", action: {})
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
    @State private var address: String = ""
    var body: some View {
        HStack(spacing: 12) {
            // Main Location Container
            HStack(spacing: 12) {
                // Pin Icon with Background
                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.1))
                        .frame(width: 40, height: 40)
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(.red)
                }
                
                // Labels
                VStack(alignment: .leading, spacing: 2) {
                    Text("Set delivery address")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                    Text("Enter address for nearb")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.down")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.white)
            .cornerRadius(30)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
            
            // Notification Button
            ZStack(alignment: .topTrailing) {
                Button(action: {}) {
                    Image(systemName: "bell")
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                        .frame(width: 44, height: 44)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
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
        .padding(.horizontal, 18)
        .padding(.top, 18)
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

struct PizzaCardView: View {
    let pizza: Pizza
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 13)
                    .fill(Color(.systemGray6))
                    .frame(height: 80)
                Image(systemName: "photo") // Placeholder
                    .resizable()
                    .scaledToFit()
                    .frame(height: 60)
            }
            Text(pizza.name)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.black)
                .lineLimit(2)
            Text(pizza.price)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.red)
            Button(action: {}) {
                Text("add")
                    .font(.system(size: 13, weight: .semibold))
                    .padding(.vertical, 5)
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(7)
            }
        }
        .padding(10)
        .background(Color.white)
        .cornerRadius(18)
        .frame(width: 130)
        .shadow(color: Color.black.opacity(0.11), radius: 6, x: 0, y: 4)
    }
}

struct ComboCardView: View {
    let combo: Combo
    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(combo.badge)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.red.opacity(0.9))
                .cornerRadius(7)
            Text(combo.title)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.black)
            Text(combo.subtitle)
                .font(.system(size: 13))
                .foregroundColor(Color(.systemGray))
            HStack {
                Text(combo.price)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.red)
                Spacer()
                Button(action: {}) {
                    Text("Customize")
                        .font(.system(size: 14, weight: .semibold))
                        .padding(.vertical, 8)
                        .frame(width: 90)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(18)
        .frame(width: 240)
        .shadow(color: Color.black.opacity(0.11), radius: 8, x: 0, y: 5)
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
    let price: String
}

struct Combo: Identifiable {
    let id = UUID()
    let badge: String
    let title: String
    let subtitle: String
    let price: String
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
        Pizza(name: "Pepperoni Lovers", price: "$12.99"),
        Pizza(name: "Farm House", price: "$11.49"),
        Pizza(name: "Classic Veggie", price: "$10.99")
    ]
    static let combos = [
        Combo(badge: "FAMILY MEAL DEAL", title: "2 Mediums · Breadsticks · 2L Soda", subtitle: "Pizza + sides + drinks combos", price: "$29.99 → $24.99"),
        Combo(badge: "PARTY PACK", title: "3 Large Pizzas · 3L Soda", subtitle: "Perfect for 6+ people", price: "$44.99 → $35.99")
    ]
}

#Preview {
    NavigationView {
        HomeScreen()
    }
}

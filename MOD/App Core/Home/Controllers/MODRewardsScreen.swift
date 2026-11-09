//
//  MODRewardsScreen.swift
//  MOD
//
//  Created by Rajpal singh on 09/11/26.
//

import SwiftUI

struct MODRewardsScreen: View {
    @Environment(\.presentationMode) private var presentationMode
    
    // State for interactive user feedback
    @State private var showingAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Navigation Bar
            // Custom Top Bar (Back button + Centered Title, Share button removed as requested)
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(width: 44, height: 44, alignment: .leading)
                        .contentShape(Rectangle())
                }
                
                Spacer()
                
                Text("MOD Rewards")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(red: 0.12, green: 0.12, blue: 0.16))
                
                Spacer()
                
                // Placeholder to keep the title centered without the share button
                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
            .background(Color.white)
            
            // MARK: - Scrollable Content
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    // 1. Points & Tier Milestone Summary Card
                    PointsSummaryCard()
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                    
                    // 2. Ready to Claim or Gift Section
                    ReadyToClaimSection(
                        onRedeem: { itemName in
                            alertTitle = "Reward Redeemed!"
                            alertMessage = "\(itemName) has been added to your cart."
                            showingAlert = true
                        },
                        onGift: { itemName in
                            alertTitle = "Gift Voucher Created"
                            alertMessage = "A shareable voucher link for \(itemName) is ready to send."
                            showingAlert = true
                        }
                    )
                    .padding(.horizontal, 16)
                    
                    // 3. Unlock More with Every Order Section
                    UnlockMoreSection()
                        .padding(.horizontal, 16)
                    
                    // 4. Weekly Points Boosters Section
                    WeeklyPointsBoostersSection(
                        onAction: { booster in
                            alertTitle = booster
                            alertMessage = "Points booster activated for your next order!"
                            showingAlert = true
                        }
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                }
            }
            .background(Color(red: 0.98, green: 0.98, blue: 0.99).ignoresSafeArea())
        }
        .background(Color.white.ignoresSafeArea(edges: .top))
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

// MARK: - 1. Points Summary Card

private struct PointsSummaryCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            
            // Top Badge
            HStack(spacing: 5) {
                Image(systemName: "tag.fill")
                    .font(.system(size: 10))
                Text("2 Rewards Unlocked")
                    .font(.system(size: 11, weight: .bold))
            }
            .foregroundColor(Color(red: 0.65, green: 0.44, blue: 0.08))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color(red: 1.0, green: 0.96, blue: 0.88))
            .cornerRadius(12)
            
            // Points Value & Slice Circular Tracker
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("185 MOD Points")
                        .font(.system(size: 26, weight: .heavy))
                        .foregroundColor(Color(red: 0.1, green: 0.12, blue: 0.18))
                    
                    Text("Only 15 pts away from next reward tier!")
                        .font(.system(size: 13))
                        .foregroundColor(Color(red: 0.45, green: 0.48, blue: 0.52))
                }
                
                Spacer()
                
                // Circular Slice Progress Badge (6/8 slices, badge 2)
                RewardsCircularSliceIndicator(current: 6, total: 8, badgeCount: 2)
            }
            
            // Milestone Row & Progress Bar
            VStack(spacing: 8) {
                HStack {
                    Text("Tier Milestone: Stuffed Cheesy Bread")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(red: 0.28, green: 0.28, blue: 0.32))
                    
                    Spacer()
                    
                    Text("185 / 200 pts")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(red: 0.88, green: 0.12, blue: 0.22))
                }
                
                // Red Progress Bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(red: 0.95, green: 0.88, blue: 0.90))
                            .frame(height: 6)
                        
                        Capsule()
                            .fill(Color(red: 0.88, green: 0.12, blue: 0.22))
                            .frame(width: geo.size.width * (185.0 / 200.0), height: 6)
                    }
                }
                .frame(height: 6)
            }
        }
        .padding(16)
        .background(
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white)
                
                // Subtle soft pink/red glow in the top-right corner matching snapshot
                RadialGradient(
                    gradient: Gradient(colors: [Color.red.opacity(0.08), Color.white.opacity(0.0)]),
                    center: .topTrailing,
                    startRadius: 10,
                    endRadius: 130
                )
                .cornerRadius(18)
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 3)
    }
}

// MARK: - Circular Slice Tracker View (6/8 with badge 2)

private struct RewardsCircularSliceIndicator: View {
    let current: Int
    let total: Int
    let badgeCount: Int
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            ZStack {
                // Background Track Ring
                Circle()
                    .stroke(Color(red: 0.96, green: 0.90, blue: 0.92), lineWidth: 5)
                    .frame(width: 62, height: 62)
                
                // Red Progress Ring
                Circle()
                    .trim(from: 0.0, to: CGFloat(current) / CGFloat(total))
                    .stroke(
                        Color(red: 0.88, green: 0.12, blue: 0.22),
                        style: StrokeStyle(lineWidth: 5, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 62, height: 62)
                
                // Inner Content: Pizza Slice Icon + 6/8 Label
                VStack(spacing: 2) {
                    MiniPizzaSliceIcon()
                        .frame(width: 18, height: 16)
                    
                    Text("\(current)/\(total)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(red: 0.18, green: 0.18, blue: 0.22))
                }
            }
            .frame(width: 66, height: 66)
            
            // Red Badge at Top-Right
            if badgeCount > 0 {
                Text("\(badgeCount)")
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundColor(.white)
                    .frame(width: 18, height: 18)
                    .background(Color(red: 0.88, green: 0.12, blue: 0.22))
                    .clipShape(Circle())
                    .offset(x: 2, y: -2)
            }
        }
    }
}

// MARK: - Mini Pizza Slice Icon

private struct MiniPizzaSliceIcon: View {
    var body: some View {
        ZStack {
            // Triangle Pizza Slice
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                
                Path { path in
                    path.move(to: CGPoint(x: w / 2, y: h))
                    path.addLine(to: CGPoint(x: 1, y: 3))
                    path.addQuadCurve(to: CGPoint(x: w - 1, y: 3), control: CGPoint(x: w / 2, y: 0))
                    path.closeSubpath()
                }
                .fill(Color(red: 0.98, green: 0.76, blue: 0.28))
                
                // Crust Arc
                Path { path in
                    path.move(to: CGPoint(x: 1, y: 3))
                    path.addQuadCurve(to: CGPoint(x: w - 1, y: 3), control: CGPoint(x: w / 2, y: 0))
                }
                .stroke(Color(red: 0.84, green: 0.52, blue: 0.18), lineWidth: 2)
                
                // Pepperoni dots
                Circle()
                    .fill(Color(red: 0.85, green: 0.18, blue: 0.18))
                    .frame(width: 3.5, height: 3.5)
                    .position(x: w * 0.45, y: h * 0.42)
                
                Circle()
                    .fill(Color(red: 0.85, green: 0.18, blue: 0.18))
                    .frame(width: 3, height: 3)
                    .position(x: w * 0.65, y: h * 0.55)
            }
        }
    }
}

// MARK: - 2. Ready to Claim Section

private struct ReadyToClaimSection: View {
    var onRedeem: (String) -> Void
    var onGift: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            
            // Section Header
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color(red: 0.88, green: 0.12, blue: 0.22))
                        .frame(width: 8, height: 8)
                    
                    Text("Ready to Claim or Gift")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(red: 0.12, green: 0.12, blue: 0.16))
                }
                
                Spacer()
                
                Text("2 Available")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(red: 0.88, green: 0.12, blue: 0.22))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(red: 0.99, green: 0.91, blue: 0.92))
                    .cornerRadius(10)
            }
            
            // Reward Card 1: Free Medium 2-Topping Pizza
            ClaimRewardCard(
                imageName: "pizza2",
                fallbackIcon: "flame.fill",
                imageBadge: "Medium",
                title: "Free Medium 2–Topping Pizza",
                valueText: "Valued at $16.99",
                expiryText: "Expires in 14 days",
                giftButtonTitle: "Gift to Friend",
                onRedeem: { onRedeem("Free Medium 2–Topping Pizza") },
                onGift: { onGift("Free Medium 2–Topping Pizza") }
            )
            
            // Reward Card 2: Free 2L Soda or Breadsticks
            ClaimRewardCard(
                imageName: "pizza1",
                fallbackIcon: "takeoutbag.and.cup.and.straw.fill",
                imageBadge: "Side or Sip",
                title: "Free 2L Soda or Breadsticks",
                valueText: "Valued at $6.99",
                expiryText: "Expires in 21 days",
                giftButtonTitle: "Gift / Share",
                onRedeem: { onRedeem("Free 2L Soda or Breadsticks") },
                onGift: { onGift("Free 2L Soda or Breadsticks") }
            )
            
            // Share the Love Banner
            ShareTheLoveBanner()
        }
    }
}

// MARK: - Claim Reward Card Item

private struct ClaimRewardCard: View {
    let imageName: String
    let fallbackIcon: String
    let imageBadge: String
    let title: String
    let valueText: String
    let expiryText: String
    let giftButtonTitle: String
    var onRedeem: () -> Void
    var onGift: () -> Void
    
    var body: some View {
        VStack(spacing: 14) {
            
            // Top Row: Thumbnail + Item Details
            HStack(alignment: .top, spacing: 14) {
                
                // Image with Tag Pill
                ZStack(alignment: .bottom) {
                    Group {
                        if let _ = UIImage(named: imageName) {
                            Image(imageName)
                                .resizable()
                                .scaledToFill()
                        } else {
                            ZStack {
                                Color(red: 0.96, green: 0.94, blue: 0.92)
                                Image(systemName: fallbackIcon)
                                    .font(.system(size: 30))
                                    .foregroundColor(Color.orange.opacity(0.8))
                            }
                        }
                    }
                    .frame(width: 76, height: 76)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Inset Badge on Image
                    Text(imageBadge)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.18))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2.5)
                        .background(Color.white.opacity(0.95))
                        .cornerRadius(6)
                        .shadow(color: Color.black.opacity(0.08), radius: 2, x: 0, y: 1)
                        .offset(y: 6)
                }
                .frame(width: 76, height: 82)
                
                // Content Column
                VStack(alignment: .leading, spacing: 5) {
                    
                    // Badge Row
                    HStack(spacing: 6) {
                        Text("FREE REWARD")
                            .font(.system(size: 9.5, weight: .heavy))
                            .foregroundColor(Color(red: 0.1, green: 0.58, blue: 0.32))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2.5)
                            .background(Color(red: 0.89, green: 0.97, blue: 0.92))
                            .cornerRadius(4)
                        
                        Text(valueText)
                            .font(.system(size: 11))
                            .foregroundColor(Color(red: 0.5, green: 0.52, blue: 0.56))
                    }
                    
                    // Title
                    Text(title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color(red: 0.12, green: 0.12, blue: 0.16))
                        .lineLimit(2)
                    
                    // Expiry Row
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 11))
                        Text(expiryText)
                            .font(.system(size: 11))
                    }
                    .foregroundColor(Color(red: 0.5, green: 0.52, blue: 0.56))
                }
                
                Spacer()
            }
            
            // Bottom Action Buttons Row
            HStack(spacing: 10) {
                // Redeem Button (Solid Red)
                Button(action: onRedeem) {
                    HStack(spacing: 6) {
                        Image(systemName: "ticket.fill")
                            .font(.system(size: 12))
                        Text("Redeem Now")
                            .font(.system(size: 13, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 38)
                    .background(Color(red: 0.88, green: 0.12, blue: 0.22))
                    .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Gift Button (Outlined Red)
                Button(action: onGift) {
                    HStack(spacing: 6) {
                        Image(systemName: "gift")
                            .font(.system(size: 12))
                        Text(giftButtonTitle)
                            .font(.system(size: 13, weight: .bold))
                    }
                    .foregroundColor(Color(red: 0.88, green: 0.12, blue: 0.22))
                    .frame(maxWidth: .infinity)
                    .frame(height: 38)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(red: 0.9, green: 0.85, blue: 0.86), lineWidth: 1)
                    )
                    .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Share the Love Banner

private struct ShareTheLoveBanner: View {
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Circle Peach Icon
            ZStack {
                Circle()
                    .fill(Color(red: 0.99, green: 0.91, blue: 0.84))
                    .frame(width: 38, height: 38)
                
                Image(systemName: "heart.fill")
                    .font(.system(size: 15))
                    .foregroundColor(Color(red: 0.76, green: 0.44, blue: 0.18))
            }
            
            // Text Column
            VStack(alignment: .leading, spacing: 2) {
                Text("Share the Love")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.12, blue: 0.18))
                
                Text("Send any reward instantly to friends or family via phone, email, or direct link!")
                    .font(.system(size: 11.5))
                    .foregroundColor(Color(red: 0.45, green: 0.48, blue: 0.55))
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(red: 0.95, green: 0.96, blue: 0.99))
        .cornerRadius(14)
    }
}

// MARK: - 3. Unlock More with Every Order Section

private struct UnlockMoreSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            
            // Section Title & Subtitle
            VStack(alignment: .leading, spacing: 3) {
                Text("Unlock More with Every Order")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.12, blue: 0.18))
                
                Text("Buy pizzas & drinks to unlock delicious perks")
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 0.45, green: 0.48, blue: 0.52))
            }
            
            // Card 1: Stuffed Cheesy Bread (Bordered with highlight stroke)
            VStack(spacing: 10) {
                HStack(alignment: .top, spacing: 12) {
                    ThumbnailImageView(imageName: "pizza1", fallbackIcon: "takeoutbag.and.cup.and.straw.fill")
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Stuffed Cheesy Bread")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color(red: 0.12, green: 0.12, blue: 0.16))
                            
                            Spacer()
                            
                            Text("15 PTS TO GO")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(Color(red: 0.8, green: 0.45, blue: 0.05))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color(red: 1.0, green: 0.94, blue: 0.85))
                                .cornerRadius(4)
                        }
                        
                        Text("Unlocks at 200 pts")
                            .font(.system(size: 11.5))
                            .foregroundColor(Color(red: 0.5, green: 0.52, blue: 0.56))
                    }
                }
                
                // Progress details
                VStack(spacing: 5) {
                    HStack {
                        Text("Current: 185 pts")
                            .font(.system(size: 11))
                            .foregroundColor(Color(red: 0.28, green: 0.28, blue: 0.32))
                        
                        Spacer()
                        
                        Text("92%")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color(red: 0.88, green: 0.12, blue: 0.22))
                    }
                    
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color(red: 0.95, green: 0.88, blue: 0.90))
                                .frame(height: 5)
                            
                            Capsule()
                                .fill(Color(red: 0.88, green: 0.12, blue: 0.22))
                                .frame(width: geo.size.width * 0.92, height: 5)
                        }
                    }
                    .frame(height: 5)
                }
            }
            .padding(14)
            .background(Color.white)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color(red: 0.96, green: 0.72, blue: 0.75), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
            
            // Card 2: Large Specialty Pizza
            VStack(spacing: 10) {
                HStack(alignment: .top, spacing: 12) {
                    ThumbnailImageView(imageName: "pizza3", fallbackIcon: "flame.fill")
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Large Specialty Pizza")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color(red: 0.12, green: 0.12, blue: 0.16))
                            
                            Spacer()
                            
                            Text("250 PTS")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(Color(red: 0.55, green: 0.55, blue: 0.58))
                        }
                        
                        Text("Pepperoni Lovers or Supreme Recipe")
                            .font(.system(size: 11.5))
                            .foregroundColor(Color(red: 0.5, green: 0.52, blue: 0.56))
                    }
                }
                
                // Light salmon banner
                HStack(spacing: 6) {
                    Text("▽")
                        .font(.system(size: 9, weight: .bold))
                    Text("Order 1 more Large Combo to unlock")
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundColor(Color(red: 0.85, green: 0.2, blue: 0.25))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(red: 1.0, green: 0.94, blue: 0.95))
                .cornerRadius(6)
            }
            .padding(14)
            .background(Color.white)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.black.opacity(0.05), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
            
            // Card 3: Cinnabon® Mini Rolls
            VStack(spacing: 10) {
                HStack(alignment: .top, spacing: 12) {
                    ThumbnailImageView(imageName: "onboard3", fallbackIcon: "star.fill")
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text("Cinnabon® Mini Rolls")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color(red: 0.12, green: 0.12, blue: 0.16))
                            
                            Text("COMBO PERK")
                                .font(.system(size: 8.5, weight: .bold))
                                .foregroundColor(Color(red: 0.5, green: 0.52, blue: 0.56))
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(Color(.systemGray6))
                                .cornerRadius(4)
                            
                            Spacer()
                        }
                        
                        Text("Free with every 2 Pizza + Drink Combos")
                            .font(.system(size: 11.5))
                            .foregroundColor(Color(red: 0.5, green: 0.52, blue: 0.56))
                    }
                }
                
                // Orange Progress Bar
                VStack(spacing: 5) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color(red: 0.94, green: 0.94, blue: 0.96))
                                .frame(height: 5)
                            
                            Capsule()
                                .fill(Color(red: 0.95, green: 0.65, blue: 0.15))
                                .frame(width: geo.size.width * 0.5, height: 5)
                        }
                    }
                    .frame(height: 5)
                    
                    HStack {
                        Text("1 / 2 Combos Ordered")
                            .font(.system(size: 11))
                            .foregroundColor(Color(red: 0.5, green: 0.52, blue: 0.56))
                        
                        Spacer()
                        
                        Text("1 Left")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color(red: 0.9, green: 0.55, blue: 0.1))
                    }
                }
            }
            .padding(14)
            .background(Color.white)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.black.opacity(0.05), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
            
            // Card 4: VIP Pizza Party Tier
            HStack(alignment: .center, spacing: 12) {
                // Left Icon Box
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(red: 0.93, green: 0.95, blue: 1.0))
                        .frame(width: 54, height: 54)
                    
                    Circle()
                        .fill(Color(red: 0.88, green: 0.12, blue: 0.22))
                        .frame(width: 26, height: 26)
                    
                    Image(systemName: "star.fill")
                        .font(.system(size: 13))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text("VIP Pizza Party Tier")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(red: 0.12, green: 0.12, blue: 0.16))
                        
                        Spacer()
                        
                        Text("VIP 5th ORDER")
                            .font(.system(size: 8.5, weight: .heavy))
                            .foregroundColor(Color(red: 0.98, green: 0.85, blue: 0.45))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color(red: 0.15, green: 0.1, blue: 0.05))
                            .cornerRadius(4)
                    }
                    
                    Text("Free Party Pizza Box + Two 2L Drinks on your 5th order milestone")
                        .font(.system(size: 11.5))
                        .foregroundColor(Color(red: 0.5, green: 0.52, blue: 0.56))
                        .lineLimit(2)
                }
            }
            .padding(14)
            .background(Color.white)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.black.opacity(0.05), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
        }
    }
}

// MARK: - Thumbnail Image Helper

private struct ThumbnailImageView: View {
    let imageName: String
    let fallbackIcon: String
    
    var body: some View {
        Group {
            if let _ = UIImage(named: imageName) {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    Color(red: 0.96, green: 0.94, blue: 0.92)
                    Image(systemName: fallbackIcon)
                        .font(.system(size: 22))
                        .foregroundColor(.orange)
                }
            }
        }
        .frame(width: 54, height: 54)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - 4. Weekly Points Boosters Section

private struct WeeklyPointsBoostersSection: View {
    var onAction: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            
            Text("Weekly Points Boosters")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(red: 0.1, green: 0.12, blue: 0.18))
            
            HStack(spacing: 12) {
                // Booster 1: Drinks & Sides
                BoosterCard(
                    icon: "bolt.fill",
                    iconColor: Color(red: 0.9, green: 0.2, blue: 0.2),
                    iconBgColor: Color(red: 1.0, green: 0.92, blue: 0.92),
                    badgeText: "2X POINTS",
                    badgeColor: Color(red: 0.88, green: 0.12, blue: 0.22),
                    title: "Drinks & Sides",
                    description: "Get double points on sodas, dips, and wings all week.",
                    actionTitle: "Order Sides →",
                    action: { onAction("Drinks & Sides Booster") }
                )
                
                // Booster 2: Invite Friends
                BoosterCard(
                    icon: "person.2.fill",
                    iconColor: Color(red: 0.85, green: 0.55, blue: 0.1),
                    iconBgColor: Color(red: 1.0, green: 0.96, blue: 0.88),
                    badgeText: "+50 PTS",
                    badgeColor: Color(red: 0.96, green: 0.65, blue: 0.12),
                    title: "Invite Friends",
                    description: "Give a free slice, earn 50 pts on their first order.",
                    actionTitle: "Invite Now →",
                    action: { onAction("Invite Friends Referral") }
                )
            }
        }
    }
}

// MARK: - Booster Card Item

private struct BoosterCard: View {
    let icon: String
    let iconColor: Color
    let iconBgColor: Color
    let badgeText: String
    let badgeColor: Color
    let title: String
    let description: String
    let actionTitle: String
    var action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            // Icon
            ZStack {
                Circle()
                    .fill(iconBgColor)
                    .frame(width: 30, height: 30)
                
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(iconColor)
            }
            
            // Badge
            Text(badgeText)
                .font(.system(size: 9, weight: .heavy))
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2.5)
                .background(badgeColor)
                .cornerRadius(4)
            
            // Title
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(red: 0.12, green: 0.12, blue: 0.16))
            
            // Description
            Text(description)
                .font(.system(size: 11))
                .foregroundColor(Color(red: 0.5, green: 0.52, blue: 0.56))
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer(minLength: 4)
            
            // Action Link Button
            Button(action: action) {
                Text(actionTitle)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(red: 0.88, green: 0.12, blue: 0.22))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 180)
        .background(Color.white)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Preview

#Preview {
    MODRewardsScreen()
}

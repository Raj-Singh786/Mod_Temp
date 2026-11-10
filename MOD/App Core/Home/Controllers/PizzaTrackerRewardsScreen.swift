//
//  PizzaTrackerRewardsScreen.swift
//  MOD
//
//  Created by Rajpal singh on 10/11/26.
//

import SwiftUI

struct PizzaTrackerRewardsScreen: View {
    @Environment(\.dismiss) private var dismiss

    // Rewards & Points State (matching snapshot)
    var userPoints: Int = 185
    var nextTierPoints: Int = 200
    var ptsToGo: Int = 15
    var activeSlices: Int = 6
    var totalSlices: Int = 8
    var badgeCount: Int = 2

    // Interactive States
    @State private var showSendRewardsScreen: Bool = false
    @State private var showMenuScreen: Bool = false
    @State private var showRedeemToast: Bool = false
    @State private var toastMessage: String = ""
    @State private var showShareSheet: Bool = false

    // App Branding Colors
    private let modRed = Color(red: 0.88, green: 0.12, blue: 0.22)
    private let screenBg = Color(red: 0.98, green: 0.98, blue: 0.99)
    private let textDark = Color(red: 0.10, green: 0.12, blue: 0.18)
    private let mintGreen = Color(red: 0.12, green: 0.65, blue: 0.38)
    private let mintGreenBg = Color(red: 0.90, green: 0.98, blue: 0.94)

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // 1. Fixed Header (Pinned on scroll)
                navigationHeader
                    .padding(.bottom, 6)
                    .background(
                        screenBg
                            .edgesIgnoringSafeArea(.top)
                    )
                    .zIndex(10)

                // Scrollable Content
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 18) {
                        // 2. Hero Points Card
                        heroPointsCard
                            .padding(.top, 4)

                        // 3. Section: Ready to Claim or Gift
                        readyToClaimSection

                        // 4. Banner: Share the Love
                        shareTheLoveBanner

                        // 5. Section: Unlock More with Every Order
                        unlockMoreSection

                        // 6. Section: Weekly Points Boosters
                        weeklyBoostersSection

                        // Bottom Spacing
                        Color.clear.frame(height: 36)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
            }

            // Toast Alert Overlay
            if showRedeemToast {
                VStack {
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)

                        Text(toastMessage)
                            .font(Font.appFont(.jakartaBold, size: 13))
                            .foregroundColor(.white)

                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color.black.opacity(0.88))
                    .cornerRadius(14)
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .background(screenBg.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showSendRewardsScreen) {
            SendRewardsScreen(userPoints: userPoints)
        }
        .fullScreenCover(isPresented: $showMenuScreen) {
            MenuScreen(showBackButton: true)
        }
    }

    // MARK: - 1. Fixed Navigation Header View

    private var navigationHeader: some View {
        HStack {
            // Back Button
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(Font.appFont(.jakartaBold, size: 15))
                    .foregroundColor(.black)
                    .frame(width: 38, height: 38)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
            }

            Spacer()

            Text("MOD Rewards")
                .font(Font.appFont(.jakartaBold, size: 18))
                .foregroundColor(textDark)

            Spacer()

            // Share Button
            Button(action: {
                shareRewardsInfo()
            }) {
                Image(systemName: "square.and.arrow.up")
                    .font(Font.appFont(.jakartaSemiBold, size: 15))
                    .foregroundColor(.black)
                    .frame(width: 38, height: 38)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
    }

    // MARK: - 2. Hero Points Card

    private var heroPointsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    // Tag
                    HStack(spacing: 5) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 11))
                        Text("2 Rewards Unlocked")
                            .font(Font.appFont(.jakartaBold, size: 11))
                    }
                    .foregroundColor(Color(red: 0.65, green: 0.42, blue: 0.10))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4.5)
                    .background(Color(red: 1.0, green: 0.95, blue: 0.88))
                    .cornerRadius(8)

                    // Title
                    Text("\(userPoints) MOD Points")
                        .font(Font.appFont(.jakartaExtraBold, size: 24))
                        .foregroundColor(textDark)
                        .padding(.top, 2)

                    // Subtitle
                    Text("Only \(ptsToGo) pts away from next reward tier!")
                        .font(Font.appFont(.jakartaMedium, size: 12))
                        .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.48))
                }

                Spacer()

                // Circular Pizza Tracker Indicator
                pizzaTrackerWidget
            }

            // Milestone & Progress Bar
            VStack(spacing: 8) {
                HStack {
                    Text("Tier Milestone: Stuffed Cheesy Bread")
                        .font(Font.appFont(.jakartaSemiBold, size: 12))
                        .foregroundColor(Color(red: 0.30, green: 0.30, blue: 0.35))

                    Spacer()

                    Text("\(userPoints) / \(nextTierPoints) pts")
                        .font(Font.appFont(.jakartaBold, size: 12))
                        .foregroundColor(modRed)
                }

                // Progress Bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(red: 0.93, green: 0.94, blue: 0.96))
                            .frame(height: 7)

                        Capsule()
                            .fill(modRed)
                            .frame(width: max(geo.size.width * CGFloat(Double(userPoints) / Double(nextTierPoints)), 14), height: 7)
                    }
                }
                .frame(height: 7)
            }
            .padding(.top, 2)
        }
        .padding(18)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.white,
                    Color.white,
                    Color(red: 1.0, green: 0.95, blue: 0.96)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 3)
    }

    // MARK: - Pizza Tracker Circular Widget

    private var pizzaTrackerWidget: some View {
        ZStack(alignment: .topTrailing) {
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color(red: 0.92, green: 0.92, blue: 0.94), lineWidth: 5)
                    .frame(width: 62, height: 62)

                // Active red arc for 6/8 slices (75%)
                Circle()
                    .trim(from: 0.0, to: CGFloat(activeSlices) / CGFloat(totalSlices))
                    .stroke(
                        modRed,
                        style: StrokeStyle(lineWidth: 5, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 62, height: 62)

                // Inside label: Pizza slice + 6/8
                VStack(spacing: 2) {
                    Image(systemName: "triangle.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(modRed)
                        .rotationEffect(.degrees(180))

                    Text("\(activeSlices)/\(totalSlices)")
                        .font(Font.appFont(.jakartaBold, size: 10))
                        .foregroundColor(textDark)
                }
            }
            .frame(width: 66, height: 66)

            // Red badge with "2"
            if badgeCount > 0 {
                Text("\(badgeCount)")
                    .font(Font.appFont(.jakartaBold, size: 10))
                    .foregroundColor(.white)
                    .frame(width: 18, height: 18)
                    .background(modRed)
                    .clipShape(Circle())
                    .offset(x: 3, y: -3)
            }
        }
    }

    // MARK: - 3. Section: Ready to Claim or Gift

    private var readyToClaimSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            HStack(spacing: 8) {
                Circle()
                    .fill(modRed)
                    .frame(width: 7, height: 7)

                Text("Ready to Claim or Gift")
                    .font(Font.appFont(.jakartaBold, size: 16))
                    .foregroundColor(textDark)

                Spacer()

                Text("2 Available")
                    .font(Font.appFont(.jakartaBold, size: 11))
                    .foregroundColor(modRed)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(Color(red: 1.0, green: 0.92, blue: 0.93))
                    .cornerRadius(8)
            }

            // Card 1: Free Medium 2-Topping Pizza
            claimableRewardCard(
                imageName: "pizza1",
                imageLabel: "Medium",
                title: "Free Medium 2–Topping Pizza",
                regularPrice: "Valued at $16.99",
                expiresText: "Expires in 14 days",
                onRedeem: {
                    triggerRedeemToast(name: "Free Medium 2–Topping Pizza")
                },
                onGift: {
                    showSendRewardsScreen = true
                },
                giftButtonTitle: "Gift to Friend"
            )

            // Card 2: Free 2L Soda or Breadsticks
            claimableRewardCard(
                imageName: "pizza2",
                imageLabel: "Side or Sip",
                title: "Free 2L Soda or Breadsticks",
                regularPrice: "Valued at $6.99",
                expiresText: "Expires in 21 days",
                onRedeem: {
                    triggerRedeemToast(name: "Free 2L Soda or Breadsticks")
                },
                onGift: {
                    showSendRewardsScreen = true
                },
                giftButtonTitle: "Gift / Share"
            )
        }
    }

    private func claimableRewardCard(
        imageName: String,
        imageLabel: String,
        title: String,
        regularPrice: String,
        expiresText: String,
        onRedeem: @escaping () -> Void,
        onGift: @escaping () -> Void,
        giftButtonTitle: String
    ) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Image with label
                ZStack(alignment: .bottom) {
                    if let _ = UIImage(named: imageName) {
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 82, height: 82)
                            .cornerRadius(12)
                            .clipped()
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.94, green: 0.95, blue: 0.97))
                            .frame(width: 82, height: 82)
                    }

                    Text(imageLabel)
                        .font(Font.appFont(.jakartaBold, size: 9))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2.5)
                        .background(Color.black.opacity(0.65))
                        .cornerRadius(4)
                        .padding(.bottom, 5)
                }
                .frame(width: 82, height: 82)

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text("FREE REWARD")
                            .font(Font.appFont(.jakartaBold, size: 9.5))
                            .foregroundColor(mintGreen)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(mintGreenBg)
                            .cornerRadius(5)

                        Text(regularPrice)
                            .font(Font.appFont(.jakartaMedium, size: 11))
                            .foregroundColor(.gray)
                    }

                    Text(title)
                        .font(Font.appFont(.jakartaBold, size: 14.5))
                        .foregroundColor(textDark)
                        .lineLimit(2)

                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                        Text(expiresText)
                            .font(Font.appFont(.jakartaMedium, size: 11))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 1)
                }

                Spacer()
            }

            // Action Buttons Row
            HStack(spacing: 10) {
                // Redeem Button
                Button(action: onRedeem) {
                    HStack(spacing: 6) {
                        Image(systemName: "ticket.fill")
                            .font(.system(size: 13, weight: .semibold))
                        Text("Redeem Now")
                            .font(Font.appFont(.jakartaBold, size: 13))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(modRed)
                    .cornerRadius(10)
                }

                // Gift Button
                Button(action: onGift) {
                    HStack(spacing: 6) {
                        Image(systemName: "gift.fill")
                            .font(.system(size: 13, weight: .semibold))
                        Text(giftButtonTitle)
                            .font(Font.appFont(.jakartaBold, size: 13))
                    }
                    .foregroundColor(modRed)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(Color.white)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(modRed.opacity(0.35), lineWidth: 1)
                    )
                }
            }
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    // MARK: - 4. Banner: Share the Love

    private var shareTheLoveBanner: some View {
        Button(action: {
            showSendRewardsScreen = true
        }) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color(red: 1.0, green: 0.92, blue: 0.86))
                        .frame(width: 42, height: 42)

                    Image(systemName: "heart.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color(red: 0.70, green: 0.40, blue: 0.15))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Share the Love")
                        .font(Font.appFont(.jakartaBold, size: 14))
                        .foregroundColor(textDark)

                    Text("Send any reward instantly to friends or family via phone, email, or direct link!")
                        .font(Font.appFont(.jakartaMedium, size: 11.5))
                        .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.50))
                        .lineLimit(2)
                }

                Spacer()
            }
            .padding(14)
            .background(Color(red: 0.95, green: 0.96, blue: 0.99))
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - 5. Section: Unlock More with Every Order

    private var unlockMoreSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            VStack(alignment: .leading, spacing: 3) {
                Text("Unlock More with Every Order")
                    .font(Font.appFont(.jakartaBold, size: 18))
                    .foregroundColor(textDark)

                Text("Buy pizzas & drinks to unlock delicious perks")
                    .font(Font.appFont(.jakartaMedium, size: 12))
                    .foregroundColor(.gray)
            }

            // Card 1: Stuffed Cheesy Bread (In Progress, Outlined)
            VStack(spacing: 10) {
                HStack(spacing: 12) {
                    if let _ = UIImage(named: "pizza1") {
                        Image("pizza1")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .cornerRadius(10)
                            .clipped()
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Stuffed Cheesy Bread")
                            .font(Font.appFont(.jakartaBold, size: 14))
                            .foregroundColor(textDark)
                        Text("Unlocks at 200 pts")
                            .font(Font.appFont(.jakartaMedium, size: 11.5))
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    Text("15 PTS TO GO")
                        .font(Font.appFont(.jakartaBold, size: 9.5))
                        .foregroundColor(Color(red: 0.65, green: 0.42, blue: 0.10))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(red: 1.0, green: 0.94, blue: 0.85))
                        .cornerRadius(6)
                }

                // Progress Info Row
                HStack {
                    Text("Current: \(userPoints) pts")
                        .font(Font.appFont(.jakartaMedium, size: 11.5))
                        .foregroundColor(Color(red: 0.35, green: 0.35, blue: 0.38))

                    Spacer()

                    Text("92%")
                        .font(Font.appFont(.jakartaBold, size: 11.5))
                        .foregroundColor(modRed)
                }

                // Red Progress Bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(red: 0.93, green: 0.94, blue: 0.96))
                            .frame(height: 6)

                        Capsule()
                            .fill(modRed)
                            .frame(width: geo.size.width * 0.925, height: 6)
                    }
                }
                .frame(height: 6)
            }
            .padding(14)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(modRed.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)

            // Card 2: Large Specialty Pizza
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 12) {
                    if let _ = UIImage(named: "pizza2") {
                        Image("pizza2")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .cornerRadius(10)
                            .clipped()
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Large Specialty Pizza")
                            .font(Font.appFont(.jakartaBold, size: 14))
                            .foregroundColor(textDark)
                        Text("Pepperoni Lovers or Supreme Recipe")
                            .font(Font.appFont(.jakartaMedium, size: 11.5))
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    Text("250 PTS")
                        .font(Font.appFont(.jakartaBold, size: 11.5))
                        .foregroundColor(Color(red: 0.55, green: 0.55, blue: 0.60))
                }

                // Order Combo Badge
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 11))
                        .foregroundColor(modRed)
                    Text("Order 1 more Large Combo to unlock")
                        .font(Font.appFont(.jakartaBold, size: 11))
                        .foregroundColor(modRed)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color(red: 1.0, green: 0.94, blue: 0.95))
                .cornerRadius(6)
            }
            .padding(14)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)

            // Card 3: Cinnabon® Mini Rolls
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 12) {
                    if let _ = UIImage(named: "pizza3") {
                        Image("pizza3")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .cornerRadius(10)
                            .clipped()
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Cinnabon® Mini Rolls")
                            .font(Font.appFont(.jakartaBold, size: 14))
                            .foregroundColor(textDark)
                        Text("Free with every 2 Pizza + Drink Combos")
                            .font(Font.appFont(.jakartaMedium, size: 11.5))
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    Text("COMBO PERK")
                        .font(Font.appFont(.jakartaBold, size: 9.5))
                        .foregroundColor(Color(red: 0.65, green: 0.45, blue: 0.25))
                }

                // Progress Bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(red: 0.93, green: 0.94, blue: 0.96))
                            .frame(height: 5)

                        Capsule()
                            .fill(Color(red: 0.95, green: 0.65, blue: 0.15))
                            .frame(width: geo.size.width * 0.5, height: 5)
                    }
                }
                .frame(height: 5)

                HStack {
                    Text("1 / 2 Combos Ordered")
                        .font(Font.appFont(.jakartaMedium, size: 11))
                        .foregroundColor(.gray)

                    Spacer()

                    Text("1 Left")
                        .font(Font.appFont(.jakartaBold, size: 11))
                        .foregroundColor(Color(red: 0.75, green: 0.45, blue: 0.10))
                }
            }
            .padding(14)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)

            // Card 4: VIP Pizza Party Tier
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(red: 0.94, green: 0.95, blue: 0.99))
                        .frame(width: 50, height: 50)

                    Circle()
                        .fill(modRed)
                        .frame(width: 26, height: 26)

                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text("VIP Pizza Party Tier")
                            .font(Font.appFont(.jakartaBold, size: 14))
                            .foregroundColor(textDark)

                        Spacer()

                        Text("VIP 5th ORDER")
                            .font(Font.appFont(.jakartaBold, size: 9))
                            .foregroundColor(Color(red: 0.95, green: 0.78, blue: 0.35))
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3.5)
                            .background(Color(red: 0.18, green: 0.12, blue: 0.05))
                            .cornerRadius(5)
                    }

                    Text("Free Party Pizza Box + Two 2L Drinks on your 5th order milestone")
                        .font(Font.appFont(.jakartaMedium, size: 11.5))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
            }
            .padding(14)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        }
    }

    // MARK: - 6. Section: Weekly Points Boosters

    private var weeklyBoostersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Points Boosters")
                .font(Font.appFont(.jakartaBold, size: 16))
                .foregroundColor(textDark)

            HStack(spacing: 12) {
                // Booster 1: Drinks & Sides
                VStack(alignment: .leading, spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 1.0, green: 0.92, blue: 0.93))
                            .frame(width: 34, height: 34)

                        Image(systemName: "bolt.fill")
                            .font(.system(size: 15))
                            .foregroundColor(modRed)
                    }

                    Text("2X POINTS")
                        .font(Font.appFont(.jakartaBold, size: 9))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(modRed)
                        .cornerRadius(4)

                    Text("Drinks & Sides")
                        .font(Font.appFont(.jakartaBold, size: 14))
                        .foregroundColor(textDark)

                    Text("Get double points on sodas, dips, and wings all week.")
                        .font(Font.appFont(.jakartaRegular, size: 11))
                        .foregroundColor(.gray)
                        .lineLimit(3)

                    Spacer(minLength: 4)

                    Button(action: {
                        showMenuScreen = true
                    }) {
                        HStack(spacing: 4) {
                            Text("Order Sides")
                                .font(Font.appFont(.jakartaBold, size: 12))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(modRed)
                    }
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)

                // Booster 2: Invite Friends
                VStack(alignment: .leading, spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 1.0, green: 0.95, blue: 0.88))
                            .frame(width: 34, height: 34)

                        Image(systemName: "person.2.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: 0.70, green: 0.45, blue: 0.12))
                    }

                    Text("+50 PTS")
                        .font(Font.appFont(.jakartaBold, size: 9))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color(red: 0.95, green: 0.65, blue: 0.15))
                        .cornerRadius(4)

                    Text("Invite Friends")
                        .font(Font.appFont(.jakartaBold, size: 14))
                        .foregroundColor(textDark)

                    Text("Give a free slice, earn 50 pts on their first order.")
                        .font(Font.appFont(.jakartaRegular, size: 11))
                        .foregroundColor(.gray)
                        .lineLimit(3)

                    Spacer(minLength: 4)

                    Button(action: {
                        shareRewardsInfo()
                    }) {
                        HStack(spacing: 4) {
                            Text("Invite Now")
                                .font(Font.appFont(.jakartaBold, size: 12))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(modRed)
                    }
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
            }
        }
    }

    // MARK: - Helper Methods

    private func triggerRedeemToast(name: String) {
        toastMessage = "\(name) claimed! Added to your order."
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            showRedeemToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeOut(duration: 0.3)) {
                showRedeemToast = false
            }
        }
    }

    private func shareRewardsInfo() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else { return }

        let shareText = "I have \(userPoints) MOD Points on MOD Pizza! Earn free pizza & exclusive rewards with my invite: https://modpizza.com/rewards"
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        rootVC.present(activityVC, animated: true)
    }
}

#Preview {
    PizzaTrackerRewardsScreen()
}

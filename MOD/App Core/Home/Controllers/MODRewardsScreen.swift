//
//  MODRewardsScreen.swift
//  MOD
//
//  Created by Rajpal singh on 09/11/26.
//

import SwiftUI

// MARK: - Models

struct RewardCatalogItem: Identifiable {
    let id: String
    let points: Int
    let title: String
    let subtitle: String
    let regularPrice: String
    let imageName: String
    let fallbackIcon: String
    let category: RewardFilterCategory
    let isUnlocked: Bool
    let pointsRemaining: Int?
}

enum RewardFilterCategory: String, CaseIterable, Identifiable {
    case all = "All Rewards"
    case sides = "Sides (100 pts)"
    case medium = "Medium Pizzas (300 pts)"
    case large = "Large Pizzas (500 pts)"

    var id: String { rawValue }

    var shortTitle: String {
        switch self {
        case .all: return "All Rewards"
        case .sides: return "Sides (100 pts)"
        case .medium: return "Medium Pizzas (300)"
        case .large: return "Large Pizzas (500)"
        }
    }
}

struct FriendRecipient: Identifiable {
    let id = UUID()
    let name: String
    let photo: String
    let hasBadge: Bool
    let isAddButton: Bool
}

struct PointsChallengeItem: Identifiable {
    let id = UUID()
    let title: String
    let pointsBadge: String
    let subtitle: String
    let iconName: String
    let iconColor: Color
    let iconBgColor: Color
    let isCompleted: Bool
}

// MARK: - MOD Rewards Screen

struct MODRewardsScreen: View {
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.dismiss) private var dismiss

    // User Reward Stats matching snapshot
    var userPoints: Int = 445
    var goalPoints: Int = 500
    var memberTier: String = "Gold Member"
    var slicesFilled: Int = 5
    var totalSlices: Int = 8

    // Interactive States
    @State private var selectedCategory: RewardFilterCategory = .all
    @State private var showWalletTopUp: Bool = false
    @State private var showSendPointsSheet: Bool = false
    @State private var showGiftPizzaSheet: Bool = false
    @State private var showHistorySheet: Bool = false
    @State private var selectedFriend: FriendRecipient? = nil
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false

    // App Theme Colors
    private let modRed = Color(red: 0.88, green: 0.12, blue: 0.22)
    private let darkHeroBg = Color(red: 0.08, green: 0.10, blue: 0.16)
    private let darkHeroBgEnd = Color(red: 0.13, green: 0.14, blue: 0.22)
    private let screenBg = Color(red: 0.98, green: 0.98, blue: 0.99)
    private let borderGray = Color(red: 0.91, green: 0.91, blue: 0.93)
    private let textDark = Color(red: 0.10, green: 0.12, blue: 0.18)
    private let goldPillBg = Color(red: 1.0, green: 0.95, blue: 0.82)
    private let goldPillText = Color(red: 0.55, green: 0.38, blue: 0.05)
    private let goldPts = Color(red: 0.98, green: 0.70, blue: 0.25)
    private let successGreen = Color(red: 0.12, green: 0.65, blue: 0.38)

    // Calculated points to milestone
    private var pointsToGoal: Int {
        max(goalPoints - userPoints, 0)
    }

    // Friends list matching snapshot
    private let friends: [FriendRecipient] = [
        FriendRecipient(name: "Mom", photo: "profile", hasBadge: true, isAddButton: false),
        FriendRecipient(name: "Alex M.", photo: "profile", hasBadge: false, isAddButton: false),
        FriendRecipient(name: "Jessica T.", photo: "profile", hasBadge: false, isAddButton: false),
        FriendRecipient(name: "Marcus R.", photo: "profile", hasBadge: false, isAddButton: false),
        FriendRecipient(name: "New", photo: "", hasBadge: false, isAddButton: true)
    ]

    // Challenges matching snapshot
    private let challenges: [PointsChallengeItem] = [
        PointsChallengeItem(
            title: "Order 2× this weekend",
            pointsBadge: "+50 pts",
            subtitle: "Expires Sunday at 11:59 PM • 1 of 2 completed",
            iconName: "bolt.fill",
            iconColor: Color(red: 0.88, green: 0.12, blue: 0.22),
            iconBgColor: Color(red: 1.0, green: 0.92, blue: 0.93),
            isCompleted: false
        ),
        PointsChallengeItem(
            title: "Try the New Stuffed Crust",
            pointsBadge: "+25 pts",
            subtitle: "Order any large stuffed crust pizza",
            iconName: "fork.knife",
            iconColor: Color(red: 0.70, green: 0.48, blue: 0.12),
            iconBgColor: Color(red: 1.0, green: 0.96, blue: 0.88),
            isCompleted: false
        )
    ]

    // Catalog Rewards matching snapshot
    private let catalogItems: [RewardCatalogItem] = [
        RewardCatalogItem(
            id: "R1",
            points: 100,
            title: "Stuffed Garlic Knots",
            subtitle: "4 pcs with marinara dipping sauce",
            regularPrice: "$6.49",
            imageName: "pizza1",
            fallbackIcon: "takeoutbag.and.cup.and.straw.fill",
            category: .sides,
            isUnlocked: true,
            pointsRemaining: nil
        ),
        RewardCatalogItem(
            id: "R2",
            points: 300,
            title: "Medium 2–Topping Pizza",
            subtitle: "Hand Tossed, Pan, or Thin 'N Crispy",
            regularPrice: "$14.99",
            imageName: "pizza2",
            fallbackIcon: "flame.fill",
            category: .medium,
            isUnlocked: true,
            pointsRemaining: nil
        ),
        RewardCatalogItem(
            id: "R3",
            points: 500,
            title: "Large Specialty Stuffed Crust",
            subtitle: "Any specialty recipe or custom up to 5 toppings",
            regularPrice: "$19.99",
            imageName: "pizza3",
            fallbackIcon: "lock.fill",
            category: .large,
            isUnlocked: false,
            pointsRemaining: 55
        )
    ]

    private var filteredCatalogItems: [RewardCatalogItem] {
        if selectedCategory == .all {
            return catalogItems
        }
        return catalogItems.filter { $0.category == selectedCategory }
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // 1. Navigation Header
            navigationHeader

            // 2. Scrollable Body
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 18) {
                    // Hero Card: Dark Points & Tier Card
                    heroPointsCard
                        .padding(.top, 10)

                    // Card 2: Share Points & Gift Rewards
                    sharePointsCard

                    // Section 3: Double Points & Challenges
                    challengesSection

                    // Section 4: Redeem Rewards
                    redeemRewardsSection

                    // Bottom safe spacing
                    Color.clear.frame(height: 36)
                }
                .padding(.horizontal, 16)
            }
            .background(screenBg)
        }
        .background(screenBg.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showWalletTopUp) {
            WalletTopUPScreen()
        }
        .sheet(isPresented: $showSendPointsSheet) {
            sendPointsSheetView
        }
        .sheet(isPresented: $showGiftPizzaSheet) {
            giftPizzaSheetView
        }
        .sheet(isPresented: $showHistorySheet) {
            pointsHistorySheetView
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    // MARK: - 1. Navigation Header

    private var navigationHeader: some View {
        HStack {
            // Back Button
            Button(action: {
                dismiss()
                presentationMode.wrappedValue.dismiss()
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
        .padding(.bottom, 8)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 2)
    }

    // MARK: - Hero Points Card (Dark Graphic Card matching snapshot)

    private var heroPointsCard: some View {
        VStack(spacing: 16) {
            // Top Row: Gold Member + Points & Pizza Slice Tracker
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    // Gold Member Tag
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 9.5))
                            .foregroundColor(goldPillText)
                        Text(memberTier)
                            .font(Font.appFont(.jakartaBold, size: 11))
                            .foregroundColor(goldPillText)
                    }
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(goldPillBg)
                    .cornerRadius(12)

                    // Points Value (445 PTS)
                    HStack(alignment: .firstTextBaseline, spacing: 5) {
                        Text("\(userPoints)")
                            .font(Font.appFont(.jakartaExtraBold, size: 36))
                            .foregroundColor(.white)

                        Text("PTS")
                            .font(Font.appFont(.jakartaBold, size: 16))
                            .foregroundColor(goldPts)
                    }

                    // Earning Rule
                    Text("Earn 2 pts per $1 spent on all orders")
                        .font(Font.appFont(.jakartaRegular, size: 11.5))
                        .foregroundColor(Color.white.opacity(0.72))
                }

                Spacer()

                // Circular Slices Indicator (5/8 Slices Filled)
                VStack(spacing: 4) {
                    ZStack {
                        // Track Circle
                        Circle()
                            .stroke(Color.white.opacity(0.14), lineWidth: 4.5)
                            .frame(width: 62, height: 62)

                        // Red Filled Arc (5/8 = 62.5%)
                        Circle()
                            .trim(from: 0.0, to: CGFloat(slicesFilled) / CGFloat(totalSlices))
                            .stroke(
                                modRed,
                                style: StrokeStyle(lineWidth: 4.5, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .frame(width: 62, height: 62)

                        // Inner Slice Icon + Number
                        VStack(spacing: 1.5) {
                            Text("🍕")
                                .font(.system(size: 13))

                            Text("\(slicesFilled)/\(totalSlices)")
                                .font(Font.appFont(.jakartaBold, size: 11))
                                .foregroundColor(.white)
                        }
                    }

                    Text("Slices Filled")
                        .font(Font.appFont(.jakartaRegular, size: 10))
                        .foregroundColor(Color.white.opacity(0.55))
                }
            }

            // Milestone Progress Row & Bar
            VStack(spacing: 7) {
                HStack {
                    HStack(spacing: 5) {
                        Circle()
                            .fill(modRed)
                            .frame(width: 6, height: 6)

                        Text("\(pointsToGoal) pts to Free Large Pizza!")
                            .font(Font.appFont(.jakartaBold, size: 12))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    Text("Goal: \(goalPoints)")
                        .font(Font.appFont(.jakartaMedium, size: 11.5))
                        .foregroundColor(Color.white.opacity(0.6))
                }

                // Gradient Progress Bar (Orange to Red)
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.14))
                            .frame(height: 7)

                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color(red: 1.0, green: 0.60, blue: 0.15), modRed],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * CGFloat(userPoints) / CGFloat(goalPoints), height: 7)
                    }
                }
                .frame(height: 7)
            }

            // Action Buttons Row: Earn More Points (Red) | History (Dark)
            HStack(spacing: 10) {
                // Earn More Points (Opens Top Up Screen)
                Button(action: {
                    showWalletTopUp = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 13, weight: .bold))

                        Text("Earn More Points")
                            .font(Font.appFont(.jakartaBold, size: 13.5))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(modRed)
                    .cornerRadius(12)
                    .shadow(color: modRed.opacity(0.4), radius: 6, x: 0, y: 3)
                }

                // History Button
                Button(action: {
                    showHistorySheet = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 13, weight: .bold))

                        Text("History")
                            .font(Font.appFont(.jakartaBold, size: 13.5))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 22)
                    .frame(height: 44)
                    .background(Color.white.opacity(0.12))
                    .cornerRadius(12)
                }
            }
        }
        .padding(18)
        .background(
            LinearGradient(
                colors: [darkHeroBg, darkHeroBgEnd],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .shadow(color: darkHeroBg.opacity(0.35), radius: 10, x: 0, y: 5)
    }

    // MARK: - Card 2: Share Points & Gift Rewards Card

    private var sharePointsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header: Hand Icon + Title
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(red: 1.0, green: 0.92, blue: 0.93))
                        .frame(width: 32, height: 32)

                    Text("🫶")
                        .font(.system(size: 15))
                }

                Text("Share Points & Gift Rewards")
                    .font(Font.appFont(.jakartaBold, size: 15))
                    .foregroundColor(textDark)
            }

            // Subtitle Description
            Text("Transfer points or gift a free slice/meal directly to family & friends.")
                .font(Font.appFont(.jakartaRegular, size: 12.5))
                .foregroundColor(.gray)
                .lineSpacing(2)

            // Horizontal Avatar List
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(friends) { friend in
                        Button(action: {
                            if friend.isAddButton {
                                alertTitle = "Add New Recipient"
                                alertMessage = "Enter contact phone number or email to add a new recipient."
                                showAlert = true
                            } else {
                                selectedFriend = friend
                                showSendPointsSheet = true
                            }
                        }) {
                            VStack(spacing: 6) {
                                ZStack(alignment: .bottomTrailing) {
                                    if friend.isAddButton {
                                        Circle()
                                            .stroke(style: StrokeStyle(lineWidth: 1.2, dash: [4, 3]))
                                            .foregroundColor(Color.gray.opacity(0.5))
                                            .frame(width: 50, height: 50)
                                            .overlay(
                                                Image(systemName: "plus")
                                                    .font(.system(size: 16, weight: .bold))
                                                    .foregroundColor(.gray)
                                            )
                                    } else {
                                        Circle()
                                            .fill(Color(red: 0.93, green: 0.93, blue: 0.95))
                                            .frame(width: 50, height: 50)
                                            .overlay(
                                                Image(systemName: "person.crop.circle.fill")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .foregroundColor(Color(red: 0.70, green: 0.72, blue: 0.78))
                                                    .padding(6)
                                            )
                                            .overlay(
                                                Circle()
                                                    .stroke(modRed.opacity(0.5), lineWidth: 1.5)
                                            )

                                        if friend.hasBadge {
                                            Circle()
                                                .fill(Color(red: 0.12, green: 0.65, blue: 0.38))
                                                .frame(width: 14, height: 14)
                                                .overlay(
                                                    Image(systemName: "heart.fill")
                                                        .font(.system(size: 7, weight: .bold))
                                                        .foregroundColor(.white)
                                                )
                                                .offset(x: 2, y: 2)
                                        }
                                    }
                                }

                                Text(friend.name)
                                    .font(Font.appFont(.jakartaSemiBold, size: 11.5))
                                    .foregroundColor(textDark)
                                    .lineLimit(1)
                            }
                            .frame(width: 58)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 2)
            }

            // Action Buttons: Send Points | Gift a Pizza
            HStack(spacing: 12) {
                // Send Points Button
                Button(action: {
                    showSendPointsSheet = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 12))
                            .foregroundColor(modRed)

                        Text("Send Points")
                            .font(Font.appFont(.jakartaBold, size: 13))
                            .foregroundColor(textDark)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 42)
                    .background(Color(red: 0.95, green: 0.96, blue: 0.99))
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(borderGray, lineWidth: 1))
                }

                // Gift a Pizza Button
                Button(action: {
                    showGiftPizzaSheet = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "gift.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color(red: 0.95, green: 0.60, blue: 0.10))

                        Text("Gift a Pizza")
                            .font(Font.appFont(.jakartaBold, size: 13))
                            .foregroundColor(textDark)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 42)
                    .background(Color(red: 0.95, green: 0.96, blue: 0.99))
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(borderGray, lineWidth: 1))
                }
            }

            // Shield Trust Strip
            HStack(spacing: 6) {
                Image(systemName: "checkmark.shield")
                    .font(.system(size: 11))
                    .foregroundColor(Color(red: 0.15, green: 0.55, blue: 0.45))

                Text("Instant transfer • Zero fees • Track gift status anytime")
                    .font(Font.appFont(.jakartaRegular, size: 11))
                    .foregroundColor(Color(red: 0.35, green: 0.45, blue: 0.42))
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 2)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(18)
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(borderGray, lineWidth: 1))
        .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 2)
    }

    // MARK: - Section 3: Double Points & Challenges

    private var challengesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header Row
            HStack {
                Text("Double Points & Challenges")
                    .font(Font.appFont(.jakartaBold, size: 16))
                    .foregroundColor(textDark)

                Spacer()

                Text("2 Active")
                    .font(Font.appFont(.jakartaBold, size: 12))
                    .foregroundColor(modRed)
            }

            // Challenge Cards List
            VStack(spacing: 10) {
                ForEach(challenges) { challenge in
                    challengeCard(challenge: challenge)
                }
            }
        }
    }

    private func challengeCard(challenge: PointsChallengeItem) -> some View {
        Button(action: {
            alertTitle = challenge.title
            alertMessage = "Activate this challenge to earn \(challenge.pointsBadge) on your next order!"
            showAlert = true
        }) {
            HStack(spacing: 12) {
                // Icon Box
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(challenge.iconBgColor)
                        .frame(width: 42, height: 42)

                    Image(systemName: challenge.iconName)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(challenge.iconColor)
                }

                // Texts
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(challenge.title)
                            .font(Font.appFont(.jakartaBold, size: 14))
                            .foregroundColor(textDark)

                        Text(challenge.pointsBadge)
                            .font(Font.appFont(.jakartaBold, size: 10.5))
                            .foregroundColor(Color(red: 0.65, green: 0.45, blue: 0.05))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(red: 1.0, green: 0.95, blue: 0.85))
                            .cornerRadius(5)
                    }

                    Text(challenge.subtitle)
                        .font(Font.appFont(.jakartaRegular, size: 11.5))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color.gray.opacity(0.6))
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(14)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(borderGray, lineWidth: 1))
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Section 4: Redeem Rewards

    private var redeemRewardsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header Row: Title + Catalog link
            HStack {
                Text("Redeem Rewards")
                    .font(Font.appFont(.jakartaBold, size: 16))
                    .foregroundColor(textDark)

                Spacer()

                Button(action: {
                    selectedCategory = .all
                }) {
                    Text("Catalog")
                        .font(Font.appFont(.jakartaSemiBold, size: 12))
                        .foregroundColor(.gray)
                }
            }

            // Horizontal Filter Chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(RewardFilterCategory.allCases) { cat in
                        let isSelected = selectedCategory == cat
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedCategory = cat
                            }
                        }) {
                            Text(cat.shortTitle)
                                .font(Font.appFont(.jakartaBold, size: 12))
                                .foregroundColor(isSelected ? .white : textDark)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 7)
                                .background(isSelected ? Color(red: 0.12, green: 0.14, blue: 0.20) : Color.white)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(borderGray, lineWidth: isSelected ? 0 : 1)
                                )
                        }
                    }
                }
            }

            // Reward Items List
            VStack(spacing: 12) {
                ForEach(filteredCatalogItems) { item in
                    rewardCatalogCard(item: item)
                }
            }
        }
    }

    // MARK: Reward Catalog Card

    private func rewardCatalogCard(item: RewardCatalogItem) -> some View {
        HStack(spacing: 14) {
            // Thumbnail with Points Badge
            ZStack(alignment: .topLeading) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.95, green: 0.94, blue: 0.92))
                        .frame(width: 82, height: 82)

                    if item.isUnlocked {
                        Image(systemName: item.fallbackIcon)
                            .font(.system(size: 26))
                            .foregroundColor(Color.orange.opacity(0.85))
                    } else {
                        // Locked Thumbnail with Lock Overlay
                        ZStack {
                            Image(systemName: "takeoutbag.and.cup.and.straw.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Color.gray.opacity(0.45))

                            Circle()
                                .fill(Color.black.opacity(0.45))
                                .frame(width: 28, height: 28)

                            Image(systemName: "lock.fill")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }

                // Points Badge on image
                Text("\(item.points) PTS")
                    .font(Font.appFont(.jakartaBold, size: 9))
                    .foregroundColor(Color(red: 0.55, green: 0.38, blue: 0.05))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color(red: 1.0, green: 0.95, blue: 0.82))
                    .cornerRadius(5)
                    .padding(5)
            }

            // Details Column
            VStack(alignment: .leading, spacing: 4) {
                // Status Line
                if item.isUnlocked {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 11))
                            .foregroundColor(successGreen)

                        Text("Unlocked & Ready")
                            .font(Font.appFont(.jakartaBold, size: 11.5))
                            .foregroundColor(successGreen)
                    }
                } else if let ptsLeft = item.pointsRemaining {
                    HStack(spacing: 4) {
                        Text("⏳")
                            .font(.system(size: 10))

                        Text("Only \(ptsLeft) pts away!")
                            .font(Font.appFont(.jakartaBold, size: 11.5))
                            .foregroundColor(modRed)
                    }
                }

                // Title
                Text(item.title)
                    .font(Font.appFont(.jakartaBold, size: 14.5))
                    .foregroundColor(textDark)
                    .lineLimit(1)

                // Subtitle
                Text(item.subtitle)
                    .font(Font.appFont(.jakartaRegular, size: 11.5))
                    .foregroundColor(.gray)
                    .lineLimit(1)

                // Price and Claim / Pts Left Action
                HStack(alignment: .center) {
                    HStack(spacing: 4) {
                        Text("Free")
                            .font(Font.appFont(.jakartaBold, size: 13))
                            .foregroundColor(textDark)

                        Text(item.regularPrice)
                            .font(Font.appFont(.jakartaRegular, size: 11.5))
                            .foregroundColor(.gray)
                            .strikethrough()
                    }

                    Spacer()

                    if item.isUnlocked {
                        // Claim Button (Red)
                        Button(action: {
                            alertTitle = "Reward Claimed!"
                            alertMessage = "\(item.title) has been added to your cart for FREE!"
                            showAlert = true
                        }) {
                            Text("Claim")
                                .font(Font.appFont(.jakartaBold, size: 12.5))
                                .foregroundColor(.white)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 7)
                                .background(modRed)
                                .cornerRadius(16)
                                .shadow(color: modRed.opacity(0.3), radius: 4, x: 0, y: 2)
                        }
                    } else if let ptsLeft = item.pointsRemaining {
                        // Locked points remaining button
                        Button(action: {
                            showWalletTopUp = true
                        }) {
                            Text("\(ptsLeft) pts left")
                                .font(Font.appFont(.jakartaBold, size: 11.5))
                                .foregroundColor(Color(red: 0.28, green: 0.42, blue: 0.72))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(Color(red: 0.92, green: 0.95, blue: 0.99))
                                .cornerRadius(16)
                        }
                    }
                }
                .padding(.top, 2)
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(borderGray, lineWidth: 1))
        .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 2)
    }

    // MARK: - Share Action

    private func shareRewardsInfo() {
        let textToShare = "Check out MOD Rewards! I have \(userPoints) points and unlocked delicious free rewards."
        let av = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(av, animated: true, completion: nil)
        }
    }

    // MARK: - Send Points Sheet View

    @State private var sendPointsAmount: String = "50"
    @State private var recipientName: String = "Mom"

    private var sendPointsSheetView: some View {
        VStack(spacing: 20) {
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 10)

            Text("Transfer MOD Points")
                .font(Font.appFont(.jakartaBold, size: 18))
                .foregroundColor(textDark)

            Text("Send points to family or friends instantly with zero fees.")
                .font(Font.appFont(.jakartaRegular, size: 13))
                .foregroundColor(.gray)

            VStack(alignment: .leading, spacing: 6) {
                Text("Recipient")
                    .font(Font.appFont(.jakartaBold, size: 12))
                    .foregroundColor(.gray)

                TextField("Recipient Name or Phone", text: $recipientName)
                    .font(Font.appFont(.jakartaMedium, size: 14))
                    .padding(12)
                    .background(Color(red: 0.96, green: 0.96, blue: 0.98))
                    .cornerRadius(10)
            }
            .padding(.horizontal, 20)

            VStack(alignment: .leading, spacing: 6) {
                Text("Points to Transfer (Max \(userPoints))")
                    .font(Font.appFont(.jakartaBold, size: 12))
                    .foregroundColor(.gray)

                HStack {
                    Text("PTS")
                        .font(Font.appFont(.jakartaBold, size: 16))
                        .foregroundColor(goldPts)

                    TextField("Points", text: $sendPointsAmount)
                        .font(Font.appFont(.jakartaExtraBold, size: 24))
                        .keyboardType(.numberPad)
                }
                .padding(12)
                .background(Color(red: 0.96, green: 0.96, blue: 0.98))
                .cornerRadius(10)
            }
            .padding(.horizontal, 20)

            Spacer()

            Button(action: {
                showSendPointsSheet = false
                alertTitle = "Points Transferred!"
                alertMessage = "Successfully transferred \(sendPointsAmount) PTS to \(recipientName)."
                showAlert = true
            }) {
                Text("Confirm Transfer")
                    .font(Font.appFont(.jakartaBold, size: 15))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(modRed)
                    .cornerRadius(14)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .presentationDetents([.height(380)])
    }

    // MARK: - Gift a Pizza Sheet View

    private var giftPizzaSheetView: some View {
        VStack(spacing: 18) {
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 10)

            Text("Gift a Pizza")
                .font(Font.appFont(.jakartaBold, size: 18))
                .foregroundColor(textDark)

            Text("Surprise someone special with a free pizza voucher from your points!")
                .font(Font.appFont(.jakartaRegular, size: 13))
                .foregroundColor(.gray)

            VStack(spacing: 10) {
                giftOptionRow(title: "Free Medium 2-Topping Pizza", pts: "300 PTS")
                giftOptionRow(title: "Free Stuffed Garlic Knots", pts: "100 PTS")
            }
            .padding(.horizontal, 20)

            Spacer()

            Button(action: {
                showGiftPizzaSheet = false
                alertTitle = "Pizza Gift Created!"
                alertMessage = "A shareable gift voucher link has been generated."
                showAlert = true
            }) {
                Text("Send Gift Link")
                    .font(Font.appFont(.jakartaBold, size: 15))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(modRed)
                    .cornerRadius(14)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .presentationDetents([.height(360)])
    }

    private func giftOptionRow(title: String, pts: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Font.appFont(.jakartaBold, size: 13.5))
                    .foregroundColor(textDark)
                Text(pts)
                    .font(Font.appFont(.jakartaSemiBold, size: 11.5))
                    .foregroundColor(goldPts)
            }
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(modRed)
        }
        .padding(14)
        .background(Color(red: 0.97, green: 0.97, blue: 0.99))
        .cornerRadius(12)
    }

    // MARK: - Points History Sheet View

    private var pointsHistorySheetView: some View {
        VStack(spacing: 16) {
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 10)

            Text("Points Activity")
                .font(Font.appFont(.jakartaBold, size: 18))
                .foregroundColor(textDark)

            List {
                historyRow(title: "Wallet Top Up Reload", date: "Today, 10:15 AM", pts: "+25 pts", isPositive: true)
                historyRow(title: "Order #PH-18602842", date: "Nov 08, 7:15 PM", pts: "+140 pts", isPositive: true)
                historyRow(title: "Redeemed Stuffed Knots", date: "Nov 02, 1:30 PM", pts: "-100 pts", isPositive: false)
                historyRow(title: "Challenge: Weekend Pizza", date: "Oct 28, 6:00 PM", pts: "+50 pts", isPositive: true)
            }
            .listStyle(PlainListStyle())
        }
        .presentationDetents([.medium])
    }

    private func historyRow(title: String, date: String, pts: String, isPositive: Bool) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(Font.appFont(.jakartaSemiBold, size: 13.5))
                    .foregroundColor(textDark)
                Text(date)
                    .font(Font.appFont(.jakartaRegular, size: 11.5))
                    .foregroundColor(.gray)
            }
            Spacer()
            Text(pts)
                .font(Font.appFont(.jakartaBold, size: 14))
                .foregroundColor(isPositive ? successGreen : modRed)
        }
    }
}

// MARK: - Preview

#Preview {
    MODRewardsScreen()
}

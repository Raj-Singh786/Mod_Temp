//
//  UserRewardView.swift
//  MOD
//
//  Created by Rajpal singh on 17/11/26.
//

import SwiftUI

// MARK: - Reward Item Model

struct RewardItem: Identifiable, Hashable {
    let id: String
    let points: Int
    let title: String
    let description: String
    let requirementNote: String
    let isGoldTierOnly: Bool
    let isProgressBased: Bool
    var progressPoints: Int = 0
    var targetPoints: Int = 1500
}

// MARK: - UserRewardView (MODRewardView)

typealias MODRewardView = UserRewardView

struct UserRewardView: View {
    
    // MARK: - Callbacks
    
    var onOpenMemberPass: (() -> Void)? = nil
    var onOpenWallet: (() -> Void)? = nil
    var onOpenActivity: (() -> Void)? = nil
    var onCartTap: (() -> Void)? = nil
    var onProfileTap: (() -> Void)? = nil
    
    // MARK: - Observed State
    
    @ObservedObject private var walletManager = WalletManager.shared
    
    // MARK: - State
    
    @State private var availablePoints: Int = 1240
    @State private var lifetimePoints: Int = 3100
    @State private var selectedRewardId: String? = nil
    @State private var selectedTierIndex: Int = 1 // 0: Member, 1: Silver, 2: Gold
    @State private var receiptCodeInput: String = ""
    @State private var showAddedReceiptAlert: Bool = false
    @State private var addedReceiptMessage: String = ""
    @State private var showWalletToast: Bool = false
    @State private var showWalletSheet: Bool = false
    @State private var showActivitySheet: Bool = false
    @State private var showActivityToast: Bool = false
    @State private var showProfileCompleteToast: Bool = false
    @State private var isProfileFinished: Bool = false
    
    // MARK: - Sample Rewards Data (Snapshot media_1794897972241_5e4e3034.png)
    
    private let rewards: [RewardItem] = [
        RewardItem(
            id: "r1",
            points: 500,
            title: "$5 OFF YOUR ORDER",
            description: "Take $5.00 off food when you spend $15 or more.",
            requirementNote: "Minimum food spend $15.00",
            isGoldTierOnly: false,
            isProgressBased: false
        ),
        RewardItem(
            id: "r2",
            points: 400,
            title: "FREE DELIVERY",
            description: "Delivery fee waived. Delivery orders only. Before taxes.",
            requirementNote: "Minimum food spend $15.00",
            isGoldTierOnly: false,
            isProgressBased: false
        ),
        RewardItem(
            id: "r3",
            points: 600,
            title: "FREE DESSERT",
            description: "One dessert in your cart is free (up to $4.49).",
            requirementNote: "Add a dessert to use this reward",
            isGoldTierOnly: false,
            isProgressBased: false
        ),
        RewardItem(
            id: "r4",
            points: 1500,
            title: "FREE PIZZA",
            description: "Free 11\" MOD pizza, any recipe (up to $10.99). Not valid on Crust Special.",
            requirementNote: "",
            isGoldTierOnly: false,
            isProgressBased: true,
            progressPoints: 1240,
            targetPoints: 1500
        ),
        RewardItem(
            id: "r5",
            points: 1200,
            title: "$15 OFF — GOLD",
            description: "Gold members: $15.00 off food on $40+ orders.",
            requirementNote: "Gold tier required",
            isGoldTierOnly: true,
            isProgressBased: false
        )
    ]
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            // 1. Header Section
            headerSection
            
            // 2. Dark Points Card
            pointsSummaryCard
            
            // 3. Redeem Points Section
            redeemPointsSection
            
            // 4. How You Earn Section
            howYouEarnSection
            
            // 5. Bonus Points Section
            bonusPointsSection
            
            // 6. Earn In Store Section
            earnInStoreSection
        }
        .alert(isPresented: $showAddedReceiptAlert) {
            Alert(
                title: Text("Receipt Added"),
                message: Text(addedReceiptMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .sheet(isPresented: $showWalletSheet) {
            AddWalletBalanceView(
                showHeader: true,
                onBack: {
                    showWalletSheet = false
                },
                onCartTap: onCartTap
            )
        }
        .sheet(isPresented: $showActivitySheet) {
            AllWalletActivityView(
                showHeader: true,
                onBack: {
                    showActivitySheet = false
                },
                onCartTap: onCartTap,
                onStarTap: onProfileTap
            )
        }
    }
    
    // MARK: - 1. Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("REWARDS")
                .font(.oswaldMedium(size: 32))
                .tracking(0.8)
                .foregroundColor(Color("app_black"))
            
            Text("Member since enrollment · ID 7730 4821 0093")
                .font(.barlowRegular(size: 14))
                .foregroundColor(Color("text_gary"))
        }
        .padding(.top, 4)
    }
    
    // MARK: - 2. Dark Points Summary Card
    
    private var pointsSummaryCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Tier & Multiplier Eyebrow
            Text("SILVER · 1.25x EARNING")
                .font(.oswaldMedium(size: 13))
                .tracking(1.0)
                .foregroundColor(Color.white.opacity(0.85))
            
            // Available Points Large Display
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("\(availablePoints.formattedWithSeparator)")
                    .font(.oswaldBold(size: 46))
                    .foregroundColor(.white)
                
                Text("available pts")
                    .font(.barlowMedium(size: 15))
                    .foregroundColor(Color.white.opacity(0.85))
            }
            
            // Lifetime Points
            Text("\(lifetimePoints.formattedWithSeparator) lifetime")
                .font(.barlowRegular(size: 13))
                .foregroundColor(Color.white.opacity(0.6))
                .padding(.top, -6)
            
            // Free Pizza Progress Section
            VStack(alignment: .leading, spacing: 6) {
                Text("260 to a free pizza")
                    .font(.barlowSemiBold(size: 14))
                    .foregroundColor(.white)
                
                // Progress Bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.18))
                            .frame(height: 7)
                        
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0xF3 / 255.0, green: 0xCF / 255.0, blue: 0x7A / 255.0),
                                        Color(red: 0xDE / 255.0, green: 0xB1 / 255.0, blue: 0x58 / 255.0)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(0, min(geo.size.width, geo.size.width * (CGFloat(availablePoints) / 1500.0))), height: 7)
                    }
                }
                .frame(height: 7)
                
                Text("2,500 lifetime pts to Gold")
                    .font(.barlowRegular(size: 12))
                    .foregroundColor(Color.white.opacity(0.6))
                    .padding(.top, 2)
            }
            .padding(.top, 4)
            
            // Action Buttons
            VStack(alignment: .leading, spacing: 10) {
                // Row 1: Member Pass & Wallet
                HStack(spacing: 10) {
                    // Member Pass Button
                    Button(action: {
                        onOpenMemberPass?()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "creditcard")
                                .font(.system(size: 13, weight: .bold))
                            
                            Text("MEMBER PASS")
                                .font(.oswaldMedium(size: 13))
                                .tracking(0.8)
                        }
                        .foregroundColor(Color("Button_red"))
                        .padding(.horizontal, 16)
                        .frame(height: 38)
                        .background(
                            Capsule()
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Wallet Button
                    Button(action: {
                        if let onOpenWallet = onOpenWallet {
                            onOpenWallet()
                        } else {
                            showWalletSheet = true
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "wallet.pass")
                                .font(.system(size: 13, weight: .regular))
                            
                            Text("WALLET \(walletManager.formattedGiftFunds)")
                                .font(.oswaldMedium(size: 13))
                                .tracking(0.8)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .frame(height: 38)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.16))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Row 2: Activity Button
                Button(action: {
                    if let onOpenActivity = onOpenActivity {
                        onOpenActivity()
                    } else {
                        showActivitySheet = true
                    }
                }) {
                    Text("ACTIVITY")
                        .font(.oswaldMedium(size: 13))
                        .tracking(0.8)
                        .foregroundColor(.white)
                        .padding(.horizontal, 18)
                        .frame(height: 34)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.16))
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.top, 6)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0x22 / 255.0, green: 0x1C / 255.0, blue: 0x20 / 255.0),
                            Color(red: 0x42 / 255.0, green: 0x1E / 255.0, blue: 0x24 / 255.0),
                            Color(red: 0x1E / 255.0, green: 0x19 / 255.0, blue: 0x1B / 255.0)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 4)
        )
    }
    
    // MARK: - 3. Redeem Points Section
    
    private var redeemPointsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text("REDEEM POINTS")
                    .font(.oswaldMedium(size: 22))
                    .tracking(0.6)
                    .foregroundColor(Color("app_black"))
                
                Text("One reward or coupon per order · points deducted only when checkout succeeds")
                    .font(.barlowRegular(size: 13.5))
                    .foregroundColor(Color("text_gary"))
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            // Reward Cards
            VStack(spacing: 12) {
                ForEach(rewards) { reward in
                    rewardCard(reward)
                }
            }
        }
        .padding(.top, 4)
    }
    
    private func rewardCard(_ reward: RewardItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 14) {
                // Circle Badge with Points
                ZStack {
                    Circle()
                        .fill(Color("pizza_found"))
                        .frame(width: 58, height: 58)
                    
                    VStack(spacing: -1) {
                        Text("\(reward.points)")
                            .font(.oswaldBold(size: 16))
                            .foregroundColor(Color("app_black"))
                        
                        Text("pts")
                            .font(.barlowRegular(size: 11))
                            .foregroundColor(Color("text_gary"))
                    }
                }
                
                // Content Information
                VStack(alignment: .leading, spacing: 5) {
                    // Title Row (with optional Gold badge)
                    HStack(alignment: .center, spacing: 8) {
                        Text(reward.title)
                            .font(.oswaldMedium(size: 16.5))
                            .foregroundColor(Color("app_black"))
                            .lineLimit(1)
                        
                        if reward.isGoldTierOnly {
                            Text("GOLD")
                                .font(.barlowBold(size: 10))
                                .foregroundColor(Color(red: 0x6E / 255.0, green: 0x51 / 255.0, blue: 0x22 / 255.0))
                                .padding(.horizontal, 7)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(Color(red: 0xF6 / 255.0, green: 0xEC / 255.0, blue: 0xD8 / 255.0))
                                )
                        }
                    }
                    
                    // Description
                    Text(reward.description)
                        .font(.barlowRegular(size: 13))
                        .foregroundColor(Color("text_gary"))
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Requirement Note (if present)
                    if !reward.requirementNote.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 11, weight: .medium))
                            
                            Text(reward.requirementNote)
                                .font(.barlowRegular(size: 12))
                        }
                        .foregroundColor(Color(red: 0x93 / 255.0, green: 0x5E / 255.0, blue: 0x28 / 255.0))
                        .padding(.top, 1)
                    }
                    
                    // Progress Bar for Free Pizza
                    if reward.isProgressBased {
                        VStack(alignment: .leading, spacing: 4) {
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0))
                                        .frame(height: 6)
                                    
                                    Capsule()
                                        .fill(Color("Button_red"))
                                        .frame(width: geo.size.width * (CGFloat(reward.progressPoints) / CGFloat(reward.targetPoints)), height: 6)
                                }
                            }
                            .frame(height: 6)
                            
                            Text("\(reward.targetPoints - reward.progressPoints) more points needed")
                                .font(.barlowMedium(size: 11.5))
                                .foregroundColor(Color("text_gary"))
                        }
                        .padding(.top, 4)
                    }
                }
            }
            
            // SELECT / SELECTED Button (for non-progress items)
            if !reward.isProgressBased {
                HStack {
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                            if selectedRewardId == reward.id {
                                selectedRewardId = nil
                            } else {
                                selectedRewardId = reward.id
                            }
                        }
                    }) {
                        HStack(spacing: 5) {
                            if selectedRewardId == reward.id {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 11, weight: .bold))
                                Text("SELECTED")
                            } else {
                                Text("SELECT")
                            }
                        }
                        .font(.oswaldMedium(size: 13))
                        .tracking(0.8)
                        .foregroundColor(.white)
                        .padding(.horizontal, 22)
                        .frame(height: 34)
                        .background(
                            Capsule()
                                .fill(selectedRewardId == reward.id ? Color("Button_red") : Color(red: 0xB5 / 255.0, green: 0x6E / 255.0, blue: 0x76 / 255.0))
                                .shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                }
                .padding(.top, 2)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.2)
                )
                .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
        )
    }
    
    // MARK: - 4. How You Earn Section
    
    private var howYouEarnSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("HOW YOU EARN")
                .font(.oswaldMedium(size: 20))
                .tracking(0.6)
                .foregroundColor(Color("app_black"))
            
            VStack(alignment: .leading, spacing: 14) {
                // Info Rows
                earnInfoRow(label: "Rate:", value: "10 pts per $1 on food after discounts")
                earnInfoRow(label: "Your multiplier:", value: "1.25x (Silver)")
                earnInfoRow(label: "Daily cap:", value: "2,000 pts")
                earnInfoRow(label: "When:", value: "Awarded once your order is completed")
                
                // Tier Switcher Boxes
                HStack(spacing: 8) {
                    tierBox(index: 0, title: "Member", subtitle: "0 - 999 pts · 1x")
                    tierBox(index: 1, title: "Silver", subtitle: "1,000 to 2,499 pts · 1.25x")
                    tierBox(index: 2, title: "Gold", subtitle: "2,500+ lifetime pts · 1.5x")
                }
                .padding(.top, 4)
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.2)
                    )
                    .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
            )
        }
        .padding(.top, 4)
    }
    
    private func earnInfoRow(label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(label)
                .font(.barlowRegular(size: 13.5))
                .foregroundColor(Color("text_gary"))
                .frame(width: 105, alignment: .leading)
            
            Text(value)
                .font(.barlowSemiBold(size: 14))
                .foregroundColor(Color("app_black"))
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
    
    private func tierBox(index: Int, title: String, subtitle: String) -> some View {
        let isSelected = selectedTierIndex == index
        
        return Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                selectedTierIndex = index
            }
        }) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.barlowBold(size: 13))
                    .foregroundColor(Color("app_black"))
                
                Text(subtitle)
                    .font(.barlowRegular(size: 10.5))
                    .foregroundColor(Color("text_gary"))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, minHeight: 62)
            .padding(.horizontal, 4)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? Color("pizza_found") : Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isSelected ? Color("Button_red") : Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: isSelected ? 1.6 : 1.2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - 5. Bonus Points Section
    
    private var bonusPointsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("BONUS POINTS")
                .font(.oswaldMedium(size: 20))
                .tracking(0.6)
                .foregroundColor(Color("app_black"))
            
            VStack(spacing: 14) {
                // 1. Complete your profile
                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Complete your profile")
                            .font(.barlowBold(size: 15))
                            .foregroundColor(Color("app_black"))
                        
                        Text("+100 pts once: need name, email, phone and birthday")
                            .font(.barlowRegular(size: 13))
                            .foregroundColor(Color("text_gary"))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        isProfileFinished.toggle()
                        if isProfileFinished {
                            availablePoints += 100
                            lifetimePoints += 100
                        } else {
                            availablePoints -= 100
                            lifetimePoints -= 100
                        }
                    }) {
                        Text(isProfileFinished ? "COMPLETED" : "FINISH PROFILE")
                            .font(.oswaldMedium(size: 12))
                            .tracking(0.6)
                            .foregroundColor(isProfileFinished ? Color.white : Color("app_black"))
                            .padding(.horizontal, 14)
                            .frame(height: 36)
                            .background(
                                Capsule()
                                    .fill(isProfileFinished ? Color("Button_red") : Color.white)
                            )
                            .overlay(
                                Capsule()
                                    .stroke(Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0), lineWidth: 1.2)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Divider()
                    .background(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0))
                
                // 2. Pizza Explorer
                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Pizza Explorer")
                            .font(.barlowBold(size: 15))
                            .foregroundColor(Color("app_black"))
                        
                        Text("Try 3 different signature pizzas · +250 pts")
                            .font(.barlowRegular(size: 13))
                            .foregroundColor(Color("text_gary"))
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 6) {
                        // Progress bars: 2 filled, 1 gray
                        HStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color("Button_red"))
                                .frame(width: 14, height: 5)
                            
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color("Button_red"))
                                .frame(width: 14, height: 5)
                            
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color(red: 0xE2 / 255.0, green: 0xDC / 255.0, blue: 0xD0 / 255.0))
                                .frame(width: 14, height: 5)
                        }
                        
                        Text("2/3")
                            .font(.barlowSemiBold(size: 13))
                            .foregroundColor(Color("app_black"))
                    }
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.2)
                    )
                    .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
            )
        }
        .padding(.top, 4)
    }
    
    // MARK: - 6. Earn In Store Section
    
    private var earnInStoreSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 14) {
                // Header
                HStack(spacing: 8) {
                    Image(systemName: "storefront")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color("Button_red"))
                    
                    Text("EARN IN STORE")
                        .font(.oswaldMedium(size: 16))
                        .tracking(0.6)
                        .foregroundColor(Color("Button_red"))
                }
                
                // Description
                Text("Ordered at the counter? Show your member code before paying, or add your receipt afterwards within 30 days.")
                    .font(.barlowRegular(size: 13))
                    .foregroundColor(Color("text_gary"))
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Two Action Cards: Show member code & Scan receipt
                HStack(spacing: 12) {
                    // Show member code
                    Button(action: {
                        onOpenMemberPass?()
                    }) {
                        VStack(alignment: .leading, spacing: 6) {
                            Image(systemName: "creditcard")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(Color("Button_red"))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Show member\ncode")
                                    .font(.barlowBold(size: 13))
                                    .foregroundColor(Color("app_black"))
                                    .lineLimit(2)
                                
                                Text("Scan at the\nregister")
                                    .font(.barlowRegular(size: 11.5))
                                    .foregroundColor(Color("text_gary"))
                                    .lineLimit(2)
                            }
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.2)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Scan receipt
                    Button(action: {
                        addedReceiptMessage = "Camera scanner ready to capture receipt barcode."
                        showAddedReceiptAlert = true
                    }) {
                        VStack(alignment: .leading, spacing: 6) {
                            Image(systemName: "qrcode.viewfinder")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(Color("Button_red"))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Scan receipt\n")
                                    .font(.barlowBold(size: 13))
                                    .foregroundColor(Color("app_black"))
                                    .lineLimit(2)
                                
                                Text("Use your camera\n")
                                    .font(.barlowRegular(size: 11.5))
                                    .foregroundColor(Color("text_gary"))
                                    .lineLimit(2)
                            }
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.2)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Receipt Code Input Field + ADD Button
                HStack(spacing: 8) {
                    TextField("Enter receipt or loyalty code", text: $receiptCodeInput)
                        .font(.barlowRegular(size: 14))
                        .foregroundColor(Color("app_black"))
                        .autocapitalization(.allCharacters)
                        .disableAutocorrection(true)
                        .padding(.horizontal, 14)
                        .frame(height: 46)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0), lineWidth: 1.2)
                                .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.white))
                        )
                    
                    Button(action: {
                        let trimmed = receiptCodeInput.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        availablePoints += 85
                        lifetimePoints += 85
                        addedReceiptMessage = "Code '\(trimmed)' redeemed! +85 points added to your account."
                        receiptCodeInput = ""
                        showAddedReceiptAlert = true
                    }) {
                        Text("ADD")
                            .font(.oswaldMedium(size: 14))
                            .tracking(0.8)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .frame(height: 46)
                            .background(
                                Capsule()
                                    .fill(Color("app_black"))
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.top, 4)
                
                // Sample Pills
                HStack(spacing: 6) {
                    Text("Try a sample:")
                        .font(.barlowRegular(size: 11.5))
                        .foregroundColor(Color("text_gary"))
                    
                    Button(action: {
                        receiptCodeInput = "RCPT-1588-55213"
                    }) {
                        Text("RCPT-1588-55213")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(Color("app_black"))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color(red: 0xF0 / 255.0, green: 0xEA / 255.0, blue: 0xDE / 255.0))
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Text("or")
                        .font(.barlowRegular(size: 11.5))
                        .foregroundColor(Color("text_gary"))
                    
                    Button(action: {
                        receiptCodeInput = "DEMO40"
                    }) {
                        Text("DEMO40")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(Color("app_black"))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color(red: 0xF0 / 255.0, green: 0xEA / 255.0, blue: 0xDE / 255.0))
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.2)
                    )
                    .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
            )
        }
        .padding(.top, 4)
    }
}

// MARK: - Number Formatter Helper

private extension Int {
    var formattedWithSeparator: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

// MARK: - SwiftUI Preview

struct UserRewardView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            UserRewardView()
                .padding(.horizontal, 16)
        }
        .background(Color("app_background"))
    }
}

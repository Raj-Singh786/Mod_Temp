//
//  ProfileScreen.swift
//  MOD
//
//  Created by Rajpal singh on 09/11/26.
//

import SwiftUI

struct ProfileScreen: View {
    // MARK: - State
    @State private var isDarkMode: Bool = false
    @State private var showRewardsScreen: Bool = false
    @State private var showOrdersHistoryScreen: Bool = false
    @State private var showingAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var showLogoutDialog: Bool = false
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                
                // 1. Navigation Header
                ProfileHeaderView(
                    onPizzaTapped: {
                        showRewardsScreen = true
                    },
                    onMoreTapped: {
                        triggerAlert(title: "Profile Options", message: "Account settings and quick actions.")
                    }
                )
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                // 2. User Info Card (Avatar, Name, VIP status, Edit button)
                UserInfoCardView(
                    onEditProfile: {
                        triggerAlert(title: "Edit Profile", message: "Edit profile details feature coming soon.")
                    }
                )
                .padding(.horizontal, 16)
                
                // 3. Dark MOD-PAY / MOD Wallet Card
                ModWalletCardView(
                    onTopUp: {
                        triggerAlert(title: "Top Up Wallet", message: "Choose amount to reload your MOD-PAY balance.")
                    },
                    onScan: {
                        triggerAlert(title: "Scan Receipt", message: "Scan in-store receipt QR to earn points instantly.")
                    },
                    onRewards: {
                        showRewardsScreen = true
                    },
                    onHistory: {
                        triggerAlert(title: "Transaction History", message: "Viewing all wallet transactions and reloads.")
                    },
                    onCashbackTapped: {
                        triggerAlert(title: "Hut Wallet Cashback", message: "Earn 5% cashback on all orders paid via Hut Wallet.")
                    }
                )
                .padding(.horizontal, 16)
                
                // 4. Section: Orders & Dining
                VStack(alignment: .leading, spacing: 8) {
                    Text("ORDERS & DINING")
                        .font(.system(size: 11.5, weight: .bold))
                        .foregroundColor(Color(red: 0.45, green: 0.48, blue: 0.55))
                        .padding(.horizontal, 4)
                    
                    VStack(spacing: 0) {
                        ProfileMenuRow(
                            icon: "bag.fill",
                            iconColor: Color(red: 0.88, green: 0.12, blue: 0.22),
                            iconBgColor: Color(red: 0.99, green: 0.92, blue: 0.93),
                            title: "My Orders",
                            action: { showOrdersHistoryScreen = true }
                        )
                        Divider().padding(.leading, 56)
                        
                        ProfileMenuRow(
                            icon: "clock.arrow.circlepath",
                            iconColor: Color(red: 0.88, green: 0.12, blue: 0.22),
                            iconBgColor: Color(red: 0.99, green: 0.92, blue: 0.93),
                            title: "Orders History",
                            action: { showOrdersHistoryScreen = true }
                        )
                        Divider().padding(.leading, 56)
                        
                        ProfileMenuRow(
                            icon: "heart.fill",
                            iconColor: Color(red: 0.88, green: 0.12, blue: 0.22),
                            iconBgColor: Color(red: 0.99, green: 0.92, blue: 0.93),
                            title: "Favorite Pizzas & Stores",
                            trailingValue: "4 saved",
                            action: { triggerAlert(title: "Favorites", message: "Viewing 4 saved favorite items & stores.") }
                        )
                        Divider().padding(.leading, 56)
                        
                        ProfileMenuRow(
                            icon: "tag.fill",
                            iconColor: Color(red: 0.88, green: 0.12, blue: 0.22),
                            iconBgColor: Color(red: 0.99, green: 0.92, blue: 0.93),
                            title: "Special Offers & Promo Codes",
                            badgeText: "3 new",
                            badgeColor: Color(red: 0.88, green: 0.12, blue: 0.22),
                            badgeBgColor: Color(red: 0.99, green: 0.92, blue: 0.93),
                            action: { triggerAlert(title: "Special Offers", message: "3 new coupon codes available for use!") }
                        )
                        Divider().padding(.leading, 56)
                        
                        ProfileMenuRow(
                            icon: "creditcard.fill",
                            iconColor: Color(red: 0.88, green: 0.12, blue: 0.22),
                            iconBgColor: Color(red: 0.99, green: 0.92, blue: 0.93),
                            title: "Payment Methods",
                            trailingValue: "Apple Pay  •• 4219",
                            action: { triggerAlert(title: "Payment Methods", message: "Manage Apple Pay, credit cards and saved methods.") }
                        )
                    }
                    .background(Color.white)
                    .cornerRadius(18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.black.opacity(0.04), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
                }
                .padding(.horizontal, 16)
                
                // 5. Section: Account & Preferences
                VStack(alignment: .leading, spacing: 8) {
                    Text("ACCOUNT & PREFERENCES")
                        .font(.system(size: 11.5, weight: .bold))
                        .foregroundColor(Color(red: 0.45, green: 0.48, blue: 0.55))
                        .padding(.horizontal, 4)
                    
                    VStack(spacing: 0) {
                        ProfileMenuRow(
                            icon: "mappin.and.ellipse",
                            iconColor: Color(red: 0.28, green: 0.45, blue: 0.65),
                            iconBgColor: Color(red: 0.94, green: 0.96, blue: 0.99),
                            title: "Saved Addresses",
                            trailingValue: "Av. João da Silva, 772",
                            action: { triggerAlert(title: "Saved Addresses", message: "Manage home, work, and delivery addresses.") }
                        )
                        Divider().padding(.leading, 56)
                        
                        ProfileMenuRow(
                            icon: "shield.lefthalf.filled",
                            iconColor: Color(red: 0.28, green: 0.45, blue: 0.65),
                            iconBgColor: Color(red: 0.94, green: 0.96, blue: 0.99),
                            title: "Security & Biometrics",
                            trailingValue: "Enabled",
                            trailingValueColor: Color(red: 0.1, green: 0.65, blue: 0.38),
                            action: { triggerAlert(title: "Security & Biometrics", message: "Face ID and two-factor authentication are enabled.") }
                        )
                        Divider().padding(.leading, 56)
                        
                        ProfileMenuRow(
                            icon: "globe",
                            iconColor: Color(red: 0.28, green: 0.45, blue: 0.65),
                            iconBgColor: Color(red: 0.94, green: 0.96, blue: 0.99),
                            title: "Language",
                            trailingValue: "English (US)",
                            action: { triggerAlert(title: "Language", message: "Select application display language.") }
                        )
                        Divider().padding(.leading, 56)
                        
                        // Dark Mode Toggle Row
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(red: 0.94, green: 0.96, blue: 0.99))
                                    .frame(width: 36, height: 36)
                                Image(systemName: "moon.fill")
                                    .font(.system(size: 15))
                                    .foregroundColor(Color(red: 0.28, green: 0.45, blue: 0.65))
                            }
                            
                            Text("Dark Mode")
                                .font(.system(size: 14.5, weight: .semibold))
                                .foregroundColor(Color(red: 0.12, green: 0.12, blue: 0.16))
                            
                            Spacer()
                            
                            Toggle("", isOn: $isDarkMode)
                                .labelsHidden()
                                .toggleStyle(SwitchToggleStyle(tint: Color(red: 0.88, green: 0.12, blue: 0.22)))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                    }
                    .background(Color.white)
                    .cornerRadius(18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.black.opacity(0.04), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
                }
                .padding(.horizontal, 16)
                
                // 6. Section: Support & Rewards
                VStack(alignment: .leading, spacing: 8) {
                    Text("SUPPORT & REWARDS")
                        .font(.system(size: 11.5, weight: .bold))
                        .foregroundColor(Color(red: 0.45, green: 0.48, blue: 0.55))
                        .padding(.horizontal, 4)
                    
                    VStack(spacing: 0) {
                        ProfileMenuRow(
                            icon: "medal.fill",
                            iconColor: Color(red: 0.85, green: 0.55, blue: 0.1),
                            iconBgColor: Color(red: 1.0, green: 0.96, blue: 0.88),
                            title: "MOD Rewards Club & Tier",
                            trailingValue: "Gold",
                            trailingValueColor: Color(red: 0.85, green: 0.55, blue: 0.1),
                            action: { showRewardsScreen = true }
                        )
                        Divider().padding(.leading, 56)
                        
                        ProfileMenuRow(
                            icon: "questionmark.bubble.fill",
                            iconColor: Color(red: 0.28, green: 0.45, blue: 0.65),
                            iconBgColor: Color(red: 0.94, green: 0.96, blue: 0.99),
                            title: "Help Center & Live Chat",
                            trailingValue: "24/7 Support",
                            action: { triggerAlert(title: "Help Center", message: "Connecting you with live customer support...") }
                        )
                        Divider().padding(.leading, 56)
                        
                        ProfileMenuRow(
                            icon: "person.2.fill",
                            iconColor: Color(red: 0.35, green: 0.4, blue: 0.6),
                            iconBgColor: Color(red: 0.94, green: 0.95, blue: 0.99),
                            title: "Invite Friends",
                            badgeText: "Get $10",
                            badgeColor: Color(red: 0.88, green: 0.12, blue: 0.22),
                            badgeBgColor: Color(red: 0.99, green: 0.92, blue: 0.93),
                            action: { triggerAlert(title: "Referral Program", message: "Invite your friends and earn $10 credit on their first purchase!") }
                        )
                    }
                    .background(Color.white)
                    .cornerRadius(18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.black.opacity(0.04), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
                }
                .padding(.horizontal, 16)
                
                // 7. Logout Button
                Button(action: {
                    showLogoutDialog = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 15, weight: .bold))
                        Text("Logout")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundColor(Color(red: 0.88, green: 0.12, blue: 0.22))
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.white)
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color(red: 0.94, green: 0.88, blue: 0.90), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 1)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 16)
                
                // 8. Footer App Version
                Text("Pizza Hut App v5.12.0 (Build 9842)")
                    .font(.system(size: 11))
                    .foregroundColor(Color(red: 0.65, green: 0.68, blue: 0.72))
                    .padding(.top, 4)
                    .padding(.bottom, 28)
            }
        }
        .background(Color(red: 0.98, green: 0.98, blue: 0.99).ignoresSafeArea())
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showRewardsScreen) {
            MODRewardsScreen()
        }
        .fullScreenCover(isPresented: $showOrdersHistoryScreen) {
            OrderHistoryScreen()
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .actionSheet(isPresented: $showLogoutDialog) {
            ActionSheet(
                title: Text("Log Out"),
                message: Text("Are you sure you want to log out of your account?"),
                buttons: [
                    .destructive(Text("Log Out")) {
                        UserDefaults.standard.set(true, forKey: "isGuestUser")
                        triggerAlert(title: "Logged Out", message: "You have been successfully logged out.")
                    },
                    .cancel()
                ]
            )
        }
    }
    
    private func triggerAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showingAlert = true
    }
}

// MARK: - 1. Top Navigation Header View

private struct ProfileHeaderView: View {
    var onPizzaTapped: () -> Void
    var onMoreTapped: () -> Void
    
    var body: some View {
        HStack(alignment: .center) {
            // Left: Pizza icon badge + Title
            HStack(spacing: 12) {
                Button(action: onPizzaTapped) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.99, green: 0.92, blue: 0.93))
                            .frame(width: 36, height: 36)
                        
                        MiniHeaderPizzaIcon()
                            .frame(width: 18, height: 16)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Text("Profile")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(red: 0.12, green: 0.12, blue: 0.16))
            }
            
            Spacer()
            
            // Right: Ellipsis more button
            Button(action: onMoreTapped) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 36, height: 36)
                        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                    
                    Image(systemName: "ellipsis")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(red: 0.25, green: 0.25, blue: 0.28))
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

// MARK: - Mini Header Pizza Slice Icon

private struct MiniHeaderPizzaIcon: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            
            Path { path in
                path.move(to: CGPoint(x: w / 2, y: h))
                path.addLine(to: CGPoint(x: 1, y: 3))
                path.addQuadCurve(to: CGPoint(x: w - 1, y: 3), control: CGPoint(x: w / 2, y: 0))
                path.closeSubpath()
            }
            .fill(Color(red: 0.88, green: 0.12, blue: 0.22))
            
            Circle()
                .fill(Color.white.opacity(0.85))
                .frame(width: 3, height: 3)
                .position(x: w * 0.45, y: h * 0.4)
            
            Circle()
                .fill(Color.white.opacity(0.85))
                .frame(width: 2.5, height: 2.5)
                .position(x: w * 0.65, y: h * 0.55)
        }
    }
}

// MARK: - 2. User Info Card View

private struct UserInfoCardView: View {
    var onEditProfile: () -> Void
    
    var body: some View {
        HStack(spacing: 14) {
            
            // User Avatar with Verified Green Badge
            ZStack(alignment: .bottomTrailing) {
                // Round Avatar
                ZStack {
                    Circle()
                        .fill(Color(red: 0.95, green: 0.95, blue: 0.97))
                        .frame(width: 62, height: 62)
                    
                    // Avatar illustration
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 58, height: 58)
                        .foregroundColor(Color(red: 0.75, green: 0.78, blue: 0.85))
                }
                
                // Green Verified Check Badge
                ZStack {
                    Circle()
                        .fill(Color(red: 0.1, green: 0.65, blue: 0.38))
                        .frame(width: 20, height: 20)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundColor(.white)
                }
                .offset(x: 2, y: 2)
            }
            
            // Name, Phone, Email & Gold VIP Badge
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text("Andrew Ainsley")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(Color(red: 0.1, green: 0.12, blue: 0.16))
                    
                    Spacer()
                    
                    // Gold VIP Badge
                    HStack(spacing: 3) {
                        Text("★")
                            .font(.system(size: 10))
                        Text("Gold VIP")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(Color(red: 0.75, green: 0.5, blue: 0.08))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Color(red: 1.0, green: 0.96, blue: 0.88))
                    .cornerRadius(8)
                }
                
                Text("+1 111 467 378 399")
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 0.45, green: 0.48, blue: 0.52))
                
                HStack {
                    Text("andrew.ainsley@icloud.com")
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 0.45, green: 0.48, blue: 0.52))
                    
                    Spacer()
                    
                    // Edit pencil button
                    Button(action: onEditProfile) {
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.99, green: 0.93, blue: 0.94))
                                .frame(width: 28, height: 28)
                            
                            Image(systemName: "pencil")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color(red: 0.88, green: 0.12, blue: 0.22))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.black.opacity(0.04), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }
}

// MARK: - 3. MOD-PAY / MOD Wallet Card

private struct ModWalletCardView: View {
    var onTopUp: () -> Void
    var onScan: () -> Void
    var onRewards: () -> Void
    var onHistory: () -> Void
    var onCashbackTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 14) {
            
            // Header Row: MOD-PAY logo + Active Member badge
            HStack(alignment: .center) {
                HStack(spacing: 10) {
                    // Logo Icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(red: 0.88, green: 0.12, blue: 0.22))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "creditcard.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text("MOD-PAY")
                            .font(.system(size: 10, weight: .heavy))
                            .foregroundColor(Color.white.opacity(0.6))
                        Text("MOD Wallet")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
                
                // Active Member Badge
                HStack(spacing: 4) {
                    Image(systemName: "medal.fill")
                        .font(.system(size: 10))
                    Text("Active Member")
                        .font(.system(size: 10.5, weight: .bold))
                }
                .foregroundColor(Color(red: 0.98, green: 0.78, blue: 0.28))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.white.opacity(0.12))
                .cornerRadius(14)
            }
            
            // Middle Two Stat Cards (Available Balance & MOD Points)
            HStack(spacing: 10) {
                // Available Balance Card
                VStack(alignment: .leading, spacing: 4) {
                    Text("Available Balance")
                        .font(.system(size: 11))
                        .foregroundColor(Color.white.opacity(0.65))
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("$48.50")
                            .font(.system(size: 20, weight: .heavy))
                            .foregroundColor(.white)
                        Text("USD")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(Color.white.opacity(0.6))
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 9))
                        Text("Auto-reload active")
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundColor(Color(red: 0.2, green: 0.82, blue: 0.55))
                    .padding(.top, 2)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.08))
                .cornerRadius(12)
                
                // MOD Points Card
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("MOD Points")
                            .font(.system(size: 11))
                            .foregroundColor(Color.white.opacity(0.65))
                        Spacer()
                        Circle()
                            .fill(Color(red: 0.98, green: 0.76, blue: 0.2))
                            .frame(width: 6, height: 6)
                    }
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("420")
                            .font(.system(size: 20, weight: .heavy))
                            .foregroundColor(Color(red: 0.98, green: 0.76, blue: 0.2))
                        Text("pts")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color(red: 0.98, green: 0.76, blue: 0.2))
                    }
                    
                    Text("Redeem free medium...")
                        .font(.system(size: 10))
                        .foregroundColor(Color.white.opacity(0.6))
                        .lineLimit(1)
                        .padding(.top, 2)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.08))
                .cornerRadius(12)
            }
            
            // Cashback Promo Banner
            Button(action: onCashbackTapped) {
                HStack(spacing: 6) {
                    Text("%")
                        .font(.system(size: 11, weight: .black))
                    Text("Save 5% cashback on every Hut Wallet order →")
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.9))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 7)
                .background(Color(red: 0.45, green: 0.08, blue: 0.18).opacity(0.75))
                .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Quick Action Buttons (Top Up, Scan Rew., Rewards, History)
            HStack(spacing: 12) {
                WalletActionButton(
                    icon: "plus",
                    label: "Top Up",
                    isPrimary: true,
                    action: onTopUp
                )
                
                WalletActionButton(
                    icon: "qrcode.viewfinder",
                    label: "Scan Rew.",
                    isPrimary: false,
                    action: onScan
                )
                
                WalletActionButton(
                    icon: "ticket.fill",
                    label: "Rewards",
                    isPrimary: false,
                    action: onRewards
                )
                
                WalletActionButton(
                    icon: "clock.arrow.circlepath",
                    label: "History",
                    isPrimary: false,
                    action: onHistory
                )
            }
            .padding(.top, 2)
        }
        .padding(16)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.12, green: 0.13, blue: 0.18),
                    Color(red: 0.08, green: 0.09, blue: 0.13)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Wallet Action Button Item

private struct WalletActionButton: View {
    let icon: String
    let label: String
    let isPrimary: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isPrimary ? Color(red: 0.88, green: 0.12, blue: 0.22) : Color.white.opacity(0.12))
                        .frame(width: 48, height: 44)
                    
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Text(label)
                    .font(.system(size: 10.5, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.85))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Profile Menu Row Component

private struct ProfileMenuRow: View {
    let icon: String
    let iconColor: Color
    let iconBgColor: Color
    let title: String
    var trailingValue: String? = nil
    var trailingValueColor: Color = Color(red: 0.45, green: 0.48, blue: 0.55)
    var badgeText: String? = nil
    var badgeColor: Color = Color.white
    var badgeBgColor: Color = Color.clear
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                // Leading Icon Container
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(iconBgColor)
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .font(.system(size: 15))
                        .foregroundColor(iconColor)
                }
                
                // Title
                Text(title)
                    .font(.system(size: 14.5, weight: .semibold))
                    .foregroundColor(Color(red: 0.12, green: 0.12, blue: 0.16))
                
                Spacer()
                
                // Optional Trailing Badge Pill
                if let badge = badgeText {
                    Text(badge)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(badgeColor)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(badgeBgColor)
                        .cornerRadius(6)
                }
                
                // Optional Trailing Text Value
                if let val = trailingValue {
                    Text(val)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(trailingValueColor)
                        .lineLimit(1)
                }
                
                // Chevron Indicator
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(red: 0.72, green: 0.75, blue: 0.8))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

#Preview {
    ProfileScreen()
}

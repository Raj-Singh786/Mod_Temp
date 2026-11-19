//
//  SettingUserInfo.swift
//  MOD
//
//  Created by Rajpal singh on 18/11/26.
//

import SwiftUI
import Combine

// MARK: - Typealias for Flexible Naming

typealias SettingUserInfoView = SettingUserInfo

// MARK: - Global Account Sheet Manager

final class AccountSheetManager: ObservableObject {
    static let shared = AccountSheetManager()
    
    @Published var showAccountSheet: Bool = false
    @Published var showLoginSheet: Bool = false
    
    private init() {}
    
    func handleStarTap() {
        let isGuest = (UserDefaults.standard.object(forKey: "isGuestUser") as? Bool) ?? false
        if isGuest {
            if let appDelegate = kSharedAppDelegate {
                appDelegate.moveToAuth(initialDestination: .login)
            } else {
                NotificationCenter.default.post(name: .presentGlobalLoginNotification, object: nil)
            }
        } else {
            NotificationCenter.default.post(name: .presentGlobalAccountNotification, object: nil)
        }
    }
}

// MARK: - Global Notification Names

extension Notification.Name {
    static let presentGlobalAccountNotification = Notification.Name("presentGlobalAccountNotification")
    static let presentGlobalLoginNotification = Notification.Name("presentGlobalLoginNotification")
    static let handleStarTapNotification = Notification.Name("handleStarTapNotification")
    static let userLoggedOutNotification = Notification.Name("userLoggedOutNotification")
    static let userLoggedInNotification = Notification.Name("userLoggedInNotification")
}

// MARK: - Reusable Top Star Button Component

struct TopStarButton: View {
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button(action: {
            if let action = action {
                action()
            } else {
                AccountSheetManager.shared.handleStarTap()
            }
        }) {
            Image(systemName: "star")
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(Color("app_black"))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - SettingUserInfo View

struct SettingUserInfo: View {
    
    // MARK: - Callbacks
    
    var onDismiss: (() -> Void)? = nil
    var onNavigateToRewards: (() -> Void)? = nil
    var onNavigateToWallet: (() -> Void)? = nil
    var onNavigateToMemberPass: (() -> Void)? = nil
    var onNavigateToOrders: (() -> Void)? = nil
    var onNavigateToAccountSettings: (() -> Void)? = nil
    var onSignOut: (() -> Void)? = nil
    
    // MARK: - State & Observed Data
    
    @ObservedObject private var walletManager = WalletManager.shared
    
    var userName: String = "Raj"
    var userPoints: Int = 1240
    var userTier: String = "Silver"
    var initialLetter: String = "R"
    
    @State private var showMemberPassModal: Bool = false
    @State private var showAddWalletBalanceSheet: Bool = false
    
    @Environment(\.presentationMode) private var presentationMode
    
    // MARK: - Body
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background Dim Scrim
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissView()
                }
            
            // Bottom Sheet Content
            VStack(spacing: 0) {
                // Drag Handle
                Capsule()
                    .fill(Color(red: 0xD0 / 255.0, green: 0xC8 / 255.0, blue: 0xBC / 255.0))
                    .frame(width: 40, height: 4.5)
                    .padding(.top, 10)
                    .padding(.bottom, 14)
                
                // Header Row: ACCOUNT + Circular 'X' Close
                HStack(alignment: .center) {
                    Text("ACCOUNT")
                        .font(.oswaldBold(size: 24))
                        .tracking(0.6)
                        .foregroundColor(Color("app_black"))
                    
                    Spacer()
                    
                    Button(action: {
                        dismissView()
                    }) {
                        ZStack {
                            Circle()
                                .stroke(Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0), lineWidth: 1.2)
                                .background(Circle().fill(Color.white))
                                .frame(width: 38, height: 38)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(Color("app_black"))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 18)
                
                // User Profile Header: Burgundy Avatar + Name + Points/Tier
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0x8C / 255.0, green: 0x1E / 255.0, blue: 0x2A / 255.0))
                            .frame(width: 56, height: 56)
                        
                        Text(initialLetter.uppercased())
                            .font(.oswaldBold(size: 26))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(userName)
                            .font(.barlowBold(size: 17.5))
                            .foregroundColor(Color("app_black"))
                        
                        Text("\(userPoints.formattedWithSeparator) pts · \(userTier)")
                            .font(.barlowRegular(size: 13.5))
                            .foregroundColor(Color("text_gary"))
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                
                // Menu Navigation Card (5 Items matching snapshot)
                menuCard
                    .padding(.horizontal, 20)
                    .padding(.bottom, 22)
                
                // SIGN OUT Button (Capsule)
                Button(action: {
                    handleSignOut()
                }) {
                    Text("SIGN OUT")
                        .font(.oswaldMedium(size: 14))
                        .tracking(1.0)
                        .foregroundColor(Color("app_black"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            Capsule()
                                .stroke(Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0), lineWidth: 1.2)
                                .background(Capsule().fill(Color.white))
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 20)
                .padding(.bottom, 28)
            }
            .background(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.18), radius: 18, x: 0, y: -4)
            )
            .edgesIgnoringSafeArea(.bottom)
        }
        .fullScreenCover(isPresented: $showMemberPassModal) {
            DigitalMemberPassSheet(
                userName: userName,
                userPoints: userPoints,
                tierName: userTier,
                onDismiss: {
                    showMemberPassModal = false
                },
                onBrowseRewards: {
                    showMemberPassModal = false
                    dismissView()
                    switchToTab(2)
                }
            )
        }
        .fullScreenCover(isPresented: $showAddWalletBalanceSheet) {
            AddWalletBalanceView(
                showHeader: true,
                onBack: {
                    showAddWalletBalanceSheet = false
                }
            )
        }
    }
    
    // MARK: - Menu Card
    
    private var menuCard: some View {
        VStack(spacing: 0) {
            // Row 1: Rewards (with highlighted rounded card style matching snapshot)
            Button(action: {
                if let onNavigateToRewards = onNavigateToRewards {
                    onNavigateToRewards()
                } else {
                    dismissView()
                    switchToTab(2)
                }
            }) {
                HStack(spacing: 14) {
                    Image(systemName: "star")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(Color("Button_red"))
                        .frame(width: 24)
                    
                    Text("Rewards")
                        .font(.barlowBold(size: 15))
                        .foregroundColor(Color("app_black"))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(red: 0xC0 / 255.0, green: 0xB8 / 255.0, blue: 0xAC / 255.0))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color(red: 0x8C / 255.0, green: 0x1E / 255.0, blue: 0x2A / 255.0), lineWidth: 1.2)
                        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.white))
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            dividerLine
            
            // Row 2: Wallet · $25.00
            let walletAmountText = walletManager.formattedGiftFunds
            menuItemRow(
                iconName: "creditcard",
                title: "Wallet · \(walletAmountText)",
                action: {
                    if let onNavigateToWallet = onNavigateToWallet {
                        onNavigateToWallet()
                    } else {
                        showAddWalletBalanceSheet = true
                    }
                }
            )
            
            dividerLine
            
            // Row 3: Member pass
            menuItemRow(
                iconName: "creditcard",
                title: "Member pass",
                action: {
                    if let onNavigateToMemberPass = onNavigateToMemberPass {
                        onNavigateToMemberPass()
                    } else {
                        showMemberPassModal = true
                    }
                }
            )
            
            dividerLine
            
            // Row 4: Orders
            menuItemRow(
                iconName: "doc.text",
                title: "Orders",
                action: {
                    if let onNavigateToOrders = onNavigateToOrders {
                        onNavigateToOrders()
                    } else {
                        dismissView()
                        switchToTab(3)
                    }
                }
            )
            
            dividerLine
            
            // Row 5: Account settings
            menuItemRow(
                iconName: "person",
                title: "Account settings",
                action: {
                    if let onNavigateToAccountSettings = onNavigateToAccountSettings {
                        onNavigateToAccountSettings()
                    } else {
                        dismissView()
                        switchToTab(4)
                    }
                }
            )
        }
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.2)
                )
        )
    }
    
    private func menuItemRow(iconName: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: iconName)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(Color("Button_red"))
                    .frame(width: 24)
                
                Text(title)
                    .font(.barlowBold(size: 15))
                    .foregroundColor(Color("app_black"))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(red: 0xC0 / 255.0, green: 0xB8 / 255.0, blue: 0xAC / 255.0))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var dividerLine: some View {
        Rectangle()
            .fill(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0))
            .frame(height: 1)
    }
    
    // MARK: - Helpers
    
    private func handleSignOut() {
        UserDefaults.standard.set(true, forKey: "isGuestUser")
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(name: .userLoggedOutNotification, object: nil)
        if let onSignOut = onSignOut {
            onSignOut()
        } else {
            dismissView()
            switchToTab(0)
        }
    }
    
    private func dismissView() {
        if let onDismiss = onDismiss {
            onDismiss()
        } else {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func switchToTab(_ index: Int) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootNav = windowScene.windows.first?.rootViewController as? UINavigationController,
           let tabVC = rootNav.viewControllers.first as? UITabBarController {
            tabVC.selectedIndex = index
        }
    }
}

// MARK: - Digital Member Pass Sheet (Post-Enrollment Member Pass)

typealias MemberPassView = DigitalMemberPassSheet

struct DigitalMemberPassSheet: View {
    var userName: String = "Raj"
    var userPoints: Int = 1240
    var tierName: String = "Silver"
    var onDismiss: (() -> Void)? = nil
    var onBack: (() -> Void)? = nil
    var onBrowseRewards: (() -> Void)? = nil
    var onScanReceipt: (() -> Void)? = nil
    var onEnterCode: (() -> Void)? = nil
    var onCartTap: (() -> Void)? = nil
    var onStarTap: (() -> Void)? = nil
    
    @ObservedObject private var cartManager = CartManager.shared
    
    var body: some View {
        ZStack {
            // Background color matching Rewards theme
            Color("app_background").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Top Navigation Bar matching post-enrollment screen
                customNavigationBar
                
                // Scrollable Content
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        // Header Titles
                        VStack(alignment: .leading, spacing: 6) {
                            Text("MEMBER PASS")
                                .font(.oswaldMedium(size: 32))
                                .tracking(0.6)
                                .foregroundColor(Color("app_black"))
                            
                            Text("Show this at the counter to earn on in-store orders.")
                                .font(.barlowRegular(size: 14))
                                .foregroundColor(Color("text_gary"))
                        }
                        .padding(.top, 4)
                        
                        // Digital Member Pass Card (Dark Gradient Card)
                        memberPassCard
                        
                        // Action Buttons Below Card
                        actionButtonsRow
                        
                        // BROWSE REWARDS Button
                        browseRewardsButton
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 36)
                }
            }
        }
    }
    
    // MARK: - Custom Navigation Bar
    
    private var customNavigationBar: some View {
        HStack(alignment: .center) {
            // Left: Back Button
            Button(action: {
                if let onBack = onBack {
                    onBack()
                } else if let onDismiss = onDismiss {
                    onDismiss()
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
            Text("Member pass")
                .font(.oswaldMedium(size: 17))
                .foregroundColor(Color("app_black"))
            
            Spacer()
            
            // Right: Star & Cart Icons
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
                
                Button(action: {
                    if let onCartTap = onCartTap {
                        onCartTap()
                    } else {
                        NotificationCenter.default.post(name: Notification.Name("showCartDirectlyNotification"), object: nil)
                    }
                }) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "bag")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(Color("app_black"))
                        
                        let count = cartManager.totalItemCount
                        if count > 0 {
                            Text("\(count)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 15, height: 15)
                                .background(Circle().fill(Color("Button_red")))
                                .offset(x: 7, y: -6)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color("app_background"))
    }
    
    // MARK: - Member Pass Card (Dark Gradient Card Matching Post-Enrollment)
    
    private var memberPassCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Top Row: MOD Logo + "Rewards" + "Silver" Tier Badge
            HStack(alignment: .center) {
                HStack(spacing: 8) {
                    Image("app_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 38)
                    
                    Text("Rewards")
                        .font(.oswaldMedium(size: 22))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Silver Tier Badge
                let badgeTier = tierName.replacingOccurrences(of: " member", with: "")
                Text(badgeTier.isEmpty ? "Silver" : badgeTier)
                    .font(.barlowBold(size: 12.5))
                    .foregroundColor(Color(red: 0x58 / 255.0, green: 0x40 / 255.0, blue: 0x1E / 255.0))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(Color(red: 0xF5 / 255.0, green: 0xEA / 255.0, blue: 0xD6 / 255.0))
                    )
            }
            
            // Member Name & Points
            VStack(alignment: .leading, spacing: 3) {
                Text(userName.isEmpty ? "Raj" : userName)
                    .font(.oswaldMedium(size: 34))
                    .tracking(0.5)
                    .foregroundColor(.white)
                
                HStack(spacing: 4) {
                    Text("\(userPoints.formattedWithSeparator)")
                        .font(.barlowBold(size: 15))
                        .foregroundColor(.white)
                    Text("pts available")
                        .font(.barlowRegular(size: 15))
                        .foregroundColor(Color.white.opacity(0.75))
                }
            }
            .padding(.top, 4)
            
            // Barcode White Container
            VStack(spacing: 8) {
                // Barcode Stripes Graphic
                BarcodeGraphicView()
                    .padding(.top, 14)
                    .padding(.horizontal, 10)
                
                // Barcode Number
                Text("7730  4821  0093")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(Color("app_black"))
                    .tracking(2.5)
                    .padding(.bottom, 12)
            }
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white)
            )
            
            // Disclaimer below barcode
            Text("Enrolled member · Sample barcode for demonstration — not scannable.")
                .font(.barlowRegular(size: 11.5))
                .foregroundColor(Color.white.opacity(0.6))
                .lineSpacing(2)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: Color(red: 0x18 / 255.0, green: 0x14 / 255.0, blue: 0x16 / 255.0), location: 0.0),
                            .init(color: Color(red: 0x22 / 255.0, green: 0x16 / 255.0, blue: 0x19 / 255.0), location: 0.5),
                            .init(color: Color(red: 0x48 / 255.0, green: 0x17 / 255.0, blue: 0x20 / 255.0), location: 1.0)
                        ],
                        startPoint: .bottomLeading,
                        endPoint: .topTrailing
                    )
                )
        )
        .shadow(color: Color.black.opacity(0.18), radius: 12, x: 0, y: 6)
    }
    
    // MARK: - Action Buttons Below Card
    
    private var actionButtonsRow: some View {
        HStack(spacing: 12) {
            // SCAN A RECEIPT INSTEAD
            Button(action: {
                if let onScanReceipt = onScanReceipt {
                    onScanReceipt()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "scope")
                        .font(.system(size: 14, weight: .bold))
                    Text("SCAN A RECEIPT INSTEAD")
                        .font(.oswaldMedium(size: 13.5))
                        .tracking(0.8)
                }
                .foregroundColor(Color("app_black"))
                .padding(.horizontal, 16)
                .frame(height: 44)
                .background(
                    Capsule()
                        .stroke(Color.gray.opacity(0.35), lineWidth: 1)
                        .background(Capsule().fill(Color.white.opacity(0.6)))
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // ENTER A CODE
            Button(action: {
                if let onEnterCode = onEnterCode {
                    onEnterCode()
                }
            }) {
                Text("ENTER A CODE")
                    .font(.oswaldMedium(size: 13.5))
                    .tracking(0.8)
                    .foregroundColor(Color("app_black"))
                    .padding(.horizontal, 10)
                    .frame(height: 44)
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
        }
        .padding(.top, 4)
    }
    
    // MARK: - BROWSE REWARDS Button
    
    private var browseRewardsButton: some View {
        Button(action: {
            if let onBrowseRewards = onBrowseRewards {
                onBrowseRewards()
            } else {
                if let onBack = onBack {
                    onBack()
                } else if let onDismiss = onDismiss {
                    onDismiss()
                }
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootNav = windowScene.windows.first?.rootViewController as? UINavigationController,
                   let tabVC = rootNav.viewControllers.first as? UITabBarController {
                    tabVC.selectedIndex = 2
                }
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: "gift")
                    .font(.system(size: 15, weight: .semibold))
                
                Text("BROWSE REWARDS")
                    .font(.oswaldMedium(size: 15))
                    .tracking(1.0)
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 13, weight: .bold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 22)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                Capsule()
                    .fill(Color("Button_red"))
                    .shadow(color: Color("Button_red").opacity(0.35), radius: 6, x: 0, y: 3)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.top, 8)
    }
}

// MARK: - Private Int Formatter

private extension Int {
    var formattedWithSeparator: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

// MARK: - Preview

struct SettingUserInfo_Previews: PreviewProvider {
    static var previews: some View {
        SettingUserInfo()
    }
}

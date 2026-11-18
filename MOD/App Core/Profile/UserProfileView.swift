//
//  UserProfileView.swift
//  MOD
//
//  Created by Rajpal singh on 18/11/26.
//

import SwiftUI

// MARK: - Typealias for Flexible Naming

typealias UserprofileView = UserProfileView

// MARK: - UserProfileView

struct UserProfileView: View {
    
    // MARK: - Callbacks
    
    var onCartTap: (() -> Void)? = nil
    var onStarTap: (() -> Void)? = nil
    var onNavigateToRewards: (() -> Void)? = nil
    var onNavigateToOrders: (() -> Void)? = nil
    var onNavigateToHome: (() -> Void)? = nil
    
    // MARK: - Observed State
    
    @ObservedObject private var walletManager = WalletManager.shared
    
    // MARK: - User State
    
    @State private var fullName: String = "raj"
    @State private var email: String = "rajallshputta087@gmail.com"
    @State private var phone: String = "(206) 555-0142"
    @State private var birthday: String = ""
    @State private var tierName: String = "Silver member"
    @State private var initialLetter: String = "R"
    
    // Stats
    @State private var points: Int = 1240
    @State private var ordersCount: Int = 3
    @State private var savedFavoritesCount: Int = 1
    @State private var profileCompletionPercent: Int = 60
    
    // Allergies & Dietary
    @State private var allergiesText: String = "None added"
    @State private var dietaryText: String = "None added"
    
    // Notification Toggles
    @State private var orderUpdatesEnabled: Bool = true
    @State private var offersAndNewsEnabled: Bool = true
    @State private var dealAlertsEnabled: Bool = false
    
    // Sheets & Alerts
    @State private var showEditPersonalInfoSheet: Bool = false
    @State private var showEditAllergiesSheet: Bool = false
    @State private var showWalletSheet: Bool = false
    @State private var showActivitySheet: Bool = false
    @State private var showMemberPassSheet: Bool = false
    @State private var showSignOutAlert: Bool = false
    @State private var showResetDemoDataAlert: Bool = false
    @State private var infoAlertTitle: String = ""
    @State private var infoAlertMessage: String = ""
    @State private var showInfoAlert: Bool = false
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Color("app_background")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Custom Navigation Bar
                customNavigationBar
                
                // Scrollable Content
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        // 1. User Hero Card (Dark Gradient)
                        userHeroCard
                        
                        // 2. Personal Information Card
                        personalInformationCard
                        
                        // 3. Allergies & Dietary Restrictions Card
                        allergiesAndDietaryCard
                        
                        // 4. Notifications & Privacy Card
                        notificationsAndPrivacyCard
                        
                        // 5. MOD Rewards Quick Card
                        rewardsQuickCard
                        
                        // 6. Account Menu Navigation List Card
                        accountMenuCard
                        
                        // 7. Demo Data Reset Card
                        demoDataCard
                        
                        Spacer()
                            .frame(height: 36)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                }
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        // Sheets
        .sheet(isPresented: $showEditPersonalInfoSheet) {
            editPersonalInfoSheetView
        }
        .sheet(isPresented: $showEditAllergiesSheet) {
            editAllergiesSheetView
        }
        .sheet(isPresented: $showWalletSheet) {
            AddWalletBalanceView(
                showHeader: true,
                onBack: {
                    showWalletSheet = false
                },
                onCartTap: onCartTap,
                onStarTap: onStarTap
            )
        }
        .sheet(isPresented: $showActivitySheet) {
            AllWalletActivityView(
                showHeader: true,
                onBack: {
                    showActivitySheet = false
                },
                onCartTap: onCartTap,
                onStarTap: onStarTap
            )
        }
        .sheet(isPresented: $showMemberPassSheet) {
            memberPassSheetView
        }
        // Alerts
        .alert(isPresented: $showSignOutAlert) {
            Alert(
                title: Text("Sign Out"),
                message: Text("Are you sure you want to sign out of your MOD account?"),
                primaryButton: .destructive(Text("Sign Out")) {
                    UserDefaults.standard.set(true, forKey: "isGuestUser")
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let rootNav = windowScene.windows.first?.rootViewController as? UINavigationController,
                       let tabVC = rootNav.viewControllers.first as? UITabBarController {
                        tabVC.selectedIndex = 0
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .alert(isPresented: $showResetDemoDataAlert) {
            Alert(
                title: Text("Reset Demo Data"),
                message: Text("This will reset your wallet balance, rewards points, and local preferences to defaults."),
                primaryButton: .destructive(Text("Reset")) {
                    walletManager.giftWalletFunds = 25.00
                    walletManager.serviceCredit = 5.00
                    points = 1240
                    ordersCount = 3
                    savedFavoritesCount = 1
                    profileCompletionPercent = 60
                    orderUpdatesEnabled = true
                    offersAndNewsEnabled = true
                    dealAlertsEnabled = false
                    infoAlertTitle = "Demo Data Reset"
                    infoAlertMessage = "All demo data has been restored to default values."
                    showInfoAlert = true
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    // MARK: - 0. Custom Top Navigation Bar (Snapshot media_1794981635107_ec92abfa.png)
    
    private var customNavigationBar: some View {
        HStack(alignment: .center) {
            // Left Placeholder to balance the centered title
            Color.clear
                .frame(width: 70, height: 32)
            
            Spacer()
            
            // Center: Title
            Text("Account")
                .font(.oswaldMedium(size: 18))
                .foregroundColor(Color("app_black"))
            
            Spacer()
            
            // Right: Star & Cart Icons
            HStack(spacing: 16) {
                Button(action: {
                    onStarTap?()
                }) {
                    Image(systemName: "star")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(Color("app_black"))
                }
                .buttonStyle(PlainButtonStyle())
                
                TopCartButton(action: onCartTap)
            }
            .frame(width: 70, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
        .padding(.bottom, 10)
        .background(Color("app_background"))
    }
    
    // MARK: - 1. User Hero Card (Dark Gradient)
    
    private var userHeroCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            // Top Row: Avatar + Info + Sign Out
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .center, spacing: 14) {
                    // Avatar Circle
                    ZStack {
                        Circle()
                            .fill(Color(red: 0xF3 / 255.0, green: 0xEB / 255.0, blue: 0xDD / 255.0))
                            .frame(width: 56, height: 56)
                        
                        Text(initialLetter.uppercased())
                            .font(.oswaldBold(size: 26))
                            .foregroundColor(Color(red: 0x76 / 255.0, green: 0x1E / 255.0, blue: 0x2A / 255.0))
                    }
                    
                    // Name & Tier Info
                    VStack(alignment: .leading, spacing: 4) {
                        Text(fullName.uppercased())
                            .font(.oswaldBold(size: 24))
                            .foregroundColor(.white)
                        
                        // Tier Pill Badge
                        Text(tierName)
                            .font(.barlowBold(size: 11))
                            .foregroundColor(Color(red: 0x6E / 255.0, green: 0x51 / 255.0, blue: 0x22 / 255.0))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(Color(red: 0xF7 / 255.0, green: 0xEE / 255.0, blue: 0xD8 / 255.0))
                            )
                    }
                    
                    Spacer()
                }
                
                // Enrollment info subtext
                Text("MOD Rewards member · Signed in with SMS")
                    .font(.barlowRegular(size: 13))
                    .foregroundColor(Color.white.opacity(0.7))
                
                // SIGN OUT Button
                Button(action: {
                    showSignOutAlert = true
                }) {
                    Text("SIGN OUT")
                        .font(.oswaldMedium(size: 12))
                        .tracking(0.8)
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .frame(height: 30)
                        .background(
                            Capsule()
                                .stroke(Color.white.opacity(0.35), lineWidth: 1)
                                .background(Capsule().fill(Color.white.opacity(0.08)))
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // 4 Stat Boxes (Grid: Row 1 = 3 boxes, Row 2 = 1 box)
            VStack(spacing: 8) {
                // Row 1: Points, Wallet, Orders
                HStack(spacing: 8) {
                    statBox(value: points.formattedWithSeparator, label: "Points")
                    statBox(value: "$45.00", label: "Wallet")
                    statBox(value: "\(ordersCount)", label: "Orders")
                }
                
                // Row 2: Saved favorite
                HStack(spacing: 8) {
                    statBox(value: "\(savedFavoritesCount)", label: "Saved favorite")
                    Spacer()
                }
            }
            
            // Profile Completion Section
            VStack(alignment: .leading, spacing: 6) {
                Text("Profile \(profileCompletionPercent)% complete")
                    .font(.barlowSemiBold(size: 13.5))
                    .foregroundColor(.white)
                
                Text("Add birthday for 40 pts + treat")
                    .font(.barlowRegular(size: 12))
                    .foregroundColor(Color.white.opacity(0.7))
                
                // Progress Bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 6)
                        
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
                            .frame(width: max(0, min(geo.size.width, geo.size.width * CGFloat(profileCompletionPercent) / 100.0)), height: 6)
                    }
                }
                .frame(height: 6)
                
                Text("Finish name, email, phone and birthday to earn +100 pts")
                    .font(.barlowRegular(size: 12))
                    .foregroundColor(Color.white.opacity(0.7))
                    .padding(.top, 4)
            }
            .padding(.top, 4)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0x22 / 255.0, green: 0x18 / 255.0, blue: 0x1C / 255.0),
                            Color(red: 0x44 / 255.0, green: 0x1A / 255.0, blue: 0x22 / 255.0),
                            Color(red: 0x1E / 255.0, green: 0x17 / 255.0, blue: 0x1A / 255.0)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 4)
        )
    }
    
    private func statBox(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.oswaldBold(size: 20))
                .foregroundColor(.white)
            
            Text(label)
                .font(.barlowRegular(size: 12))
                .foregroundColor(Color.white.opacity(0.65))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(0.12))
        )
    }
    
    // MARK: - 2. Personal Information Card
    
    private var personalInformationCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header Row
            HStack(alignment: .top, spacing: 12) {
                // Pink icon badge
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(red: 0xFD / 255.0, green: 0xEE / 255.0, blue: 0xF0 / 255.0))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: "person.text.rectangle")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color("Button_red"))
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text("PERSONAL INFORMATION")
                        .font(.oswaldMedium(size: 16))
                        .tracking(0.6)
                        .foregroundColor(Color("app_black"))
                    
                    Text("Used for your receipts and rewards")
                        .font(.barlowRegular(size: 12.5))
                        .foregroundColor(Color("text_gary"))
                }
                
                Spacer()
                
                editButton {
                    showEditPersonalInfoSheet = true
                }
            }
            
            // Info Rows
            VStack(spacing: 12) {
                infoRow(label: "Full name", value: fullName)
                dividerLine
                infoRow(label: "Email", value: email)
                dividerLine
                infoRow(label: "Phone", value: phone)
                dividerLine
                infoRow(
                    label: "Birthday",
                    value: birthday.isEmpty ? "Add for a birthday treat" : birthday,
                    isPlaceholder: birthday.isEmpty
                )
            }
            .padding(.top, 4)
        }
        .padding(18)
        .background(whiteCardBackground)
    }
    
    private func infoRow(label: String, value: String, isPlaceholder: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label)
                .font(.barlowRegular(size: 12.5))
                .foregroundColor(Color("text_gary"))
            
            Text(value)
                .font(isPlaceholder ? .barlowRegular(size: 13.5) : .barlowBold(size: 14.5))
                .foregroundColor(isPlaceholder ? Color("text_gary") : Color("app_black"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - 3. Allergies & Dietary Restrictions Card
    
    private var allergiesAndDietaryCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header Row
            HStack(alignment: .top, spacing: 12) {
                // Green icon badge
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(red: 0xEE / 255.0, green: 0xF5 / 255.0, blue: 0xEA / 255.0))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: "leaf")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color(red: 0x3E / 255.0, green: 0x76 / 255.0, blue: 0x3B / 255.0))
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text("ALLERGIES & DIETARY RESTRICTIONS")
                        .font(.oswaldMedium(size: 16))
                        .tracking(0.6)
                        .foregroundColor(Color("app_black"))
                    
                    Text("Helps us flag items and prepare your order with care")
                        .font(.barlowRegular(size: 12.5))
                        .foregroundColor(Color("text_gary"))
                }
                
                Spacer()
                
                editButton {
                    showEditAllergiesSheet = true
                }
            }
            
            // Allergies section
            VStack(alignment: .leading, spacing: 3) {
                Text("ALLERGIES")
                    .font(.oswaldMedium(size: 13))
                    .tracking(0.6)
                    .foregroundColor(Color("app_black"))
                
                Text(allergiesText)
                    .font(.barlowRegular(size: 13.5))
                    .foregroundColor(Color("text_gary"))
            }
            
            // Dietary restrictions section
            VStack(alignment: .leading, spacing: 3) {
                Text("DIETARY RESTRICTIONS")
                    .font(.oswaldMedium(size: 13))
                    .tracking(0.6)
                    .foregroundColor(Color("app_black"))
                
                Text(dietaryText)
                    .font(.barlowRegular(size: 13.5))
                    .foregroundColor(Color("text_gary"))
            }
            
            // Footnote
            Text("Shared kitchens: Cross-contact with allergens is possible. For severe allergies, please speak with our team.")
                .font(.barlowRegular(size: 12))
                .foregroundColor(Color("text_gary"))
                .lineSpacing(2)
        }
        .padding(18)
        .background(whiteCardBackground)
    }
    
    // MARK: - 4. Notifications & Privacy Card
    
    private var notificationsAndPrivacyCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header Row
            HStack(alignment: .top, spacing: 12) {
                // Cyan icon badge
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(red: 0xE6 / 255.0, green: 0xF2 / 255.0, blue: 0xF5 / 255.0))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: "envelope")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color(red: 0x2E / 255.0, green: 0x76 / 255.0, blue: 0x86 / 255.0))
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text("NOTIFICATIONS & PRIVACY")
                        .font(.oswaldMedium(size: 16))
                        .tracking(0.6)
                        .foregroundColor(Color("app_black"))
                    
                    Text("Choose what we send you (simulated — nothing is sent)")
                        .font(.barlowRegular(size: 12.5))
                        .foregroundColor(Color("text_gary"))
                }
            }
            
            // 3 Toggles
            VStack(spacing: 14) {
                toggleRow(
                    isOn: $orderUpdatesEnabled,
                    title: "Order updates",
                    subtitle: "Status changes for your orders"
                )
                
                toggleRow(
                    isOn: $offersAndNewsEnabled,
                    title: "Offers & news by email",
                    subtitle: "Deals, new pizzas and member perks"
                )
                
                toggleRow(
                    isOn: $dealAlertsEnabled,
                    title: "Deal alerts on this device",
                    subtitle: "Push notifications about flash deals"
                )
            }
            .padding(.top, 4)
        }
        .padding(18)
        .background(whiteCardBackground)
    }
    
    private func toggleRow(isOn: Binding<Bool>, title: String, subtitle: String) -> some View {
        HStack(alignment: .center, spacing: 12) {
            // Custom styled switch (on = Button_red, off = gray)
            Button(action: {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                    isOn.wrappedValue.toggle()
                }
            }) {
                ZStack(alignment: isOn.wrappedValue ? .trailing : .leading) {
                    Capsule()
                        .fill(isOn.wrappedValue ? Color("Button_red") : Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0))
                        .frame(width: 44, height: 26)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 22, height: 22)
                        .padding(.horizontal, 2)
                        .shadow(color: Color.black.opacity(0.15), radius: 2, x: 0, y: 1)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.barlowBold(size: 14.5))
                    .foregroundColor(Color("app_black"))
                
                Text(subtitle)
                    .font(.barlowRegular(size: 12.5))
                    .foregroundColor(Color("text_gary"))
            }
            
            Spacer()
        }
    }
    
    // MARK: - 5. MOD Rewards Quick Card
    
    private var rewardsQuickCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("MOD REWARDS")
                .font(.oswaldBold(size: 12.5))
                .tracking(1.0)
                .foregroundColor(Color("Button_red"))
            
            Text("\(points.formattedWithSeparator) pts")
                .font(.oswaldBold(size: 32))
                .foregroundColor(Color("app_black"))
            
            // Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0))
                        .frame(height: 5)
                    
                    Capsule()
                        .fill(Color("Button_red"))
                        .frame(width: geo.size.width * (CGFloat(points) / 1500.0), height: 5)
                }
            }
            .frame(height: 5)
            
            Text("260 pts to a free pizza")
                .font(.barlowRegular(size: 13))
                .foregroundColor(Color("text_gary"))
            
            // Actions: REDEEM & PASS
            HStack(spacing: 10) {
                Button(action: {
                    if let onNavigateToRewards = onNavigateToRewards {
                        onNavigateToRewards()
                    } else if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                              let rootNav = windowScene.windows.first?.rootViewController as? UINavigationController,
                              let tabVC = rootNav.viewControllers.first as? UITabBarController {
                        tabVC.selectedIndex = 2
                    }
                }) {
                    Text("REDEEM")
                        .font(.oswaldMedium(size: 13))
                        .tracking(0.8)
                        .foregroundColor(.white)
                        .padding(.horizontal, 18)
                        .frame(height: 34)
                        .background(
                            Capsule()
                                .fill(Color("Button_red"))
                                .shadow(color: Color("Button_red").opacity(0.3), radius: 4, x: 0, y: 2)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    showMemberPassSheet = true
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: "creditcard")
                            .font(.system(size: 11, weight: .bold))
                        
                        Text("PASS")
                            .font(.oswaldMedium(size: 13))
                            .tracking(0.8)
                    }
                    .foregroundColor(Color("app_black"))
                    .padding(.horizontal, 16)
                    .frame(height: 34)
                    .background(
                        Capsule()
                            .stroke(Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0), lineWidth: 1.2)
                            .background(Capsule().fill(Color.white))
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.top, 4)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(whiteCardBackground)
    }
    
    // MARK: - 6. Account Menu Navigation List Card
    
    private var accountMenuCard: some View {
        VStack(spacing: 0) {
            menuRow(
                iconName: "mappin.and.ellipse",
                title: "Saved addresses",
                subtitle: "0 saved",
                action: {
                    infoAlertTitle = "Saved Addresses"
                    infoAlertMessage = "You haven't saved any delivery addresses yet."
                    showInfoAlert = true
                }
            )
            
            dividerLine
            
            menuRow(
                iconName: "heart",
                title: "Favorites & saved pizzas",
                subtitle: "\(savedFavoritesCount) favorite pizza",
                action: {
                    infoAlertTitle = "Favorites"
                    infoAlertMessage = "You have 1 favorite pizza: 11\" MOD Custom Crust."
                    showInfoAlert = true
                }
            )
            
            dividerLine
            
            menuRow(
                iconName: "doc.text",
                title: "Orders & receipts",
                subtitle: "\(ordersCount) orders",
                action: {
                    if let onNavigateToOrders = onNavigateToOrders {
                        onNavigateToOrders()
                    } else if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                              let rootNav = windowScene.windows.first?.rootViewController as? UINavigationController,
                              let tabVC = rootNav.viewControllers.first as? UITabBarController {
                        tabVC.selectedIndex = 3
                    }
                }
            )
            
            dividerLine
            
            menuRow(
                iconName: "tag",
                title: "Saved offers",
                subtitle: "1 saved",
                action: {
                    infoAlertTitle = "Saved Offers"
                    infoAlertMessage = "Active offer: $5 OFF on your next order."
                    showInfoAlert = true
                }
            )
            
            dividerLine
            
            menuRow(
                iconName: "person.2",
                title: "Group orders",
                subtitle: "Host and join group orders",
                action: {
                    infoAlertTitle = "Group Orders"
                    infoAlertMessage = "Group ordering is enabled. Invite team members with a shared link."
                    showInfoAlert = true
                }
            )
            
            dividerLine
            
            menuRow(
                iconName: "creditcard",
                title: "Wallet",
                subtitle: "$45.00",
                action: {
                    showWalletSheet = true
                }
            )
            
            dividerLine
            
            menuRow(
                iconName: "clock",
                title: "Activity",
                subtitle: "Points & wallet history",
                action: {
                    showActivitySheet = true
                }
            )
        }
        .background(whiteCardBackground)
    }
    
    private func menuRow(iconName: String, title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: iconName)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color("Button_red"))
                    .frame(width: 22)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.barlowBold(size: 14.5))
                        .foregroundColor(Color("app_black"))
                    
                    Text(subtitle)
                        .font(.barlowRegular(size: 12.5))
                        .foregroundColor(Color("text_gary"))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(red: 0xC0 / 255.0, green: 0xB8 / 255.0, blue: 0xAC / 255.0))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - 7. Demo Data Reset Card
    
    private var demoDataCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("DEMO DATA")
                .font(.oswaldMedium(size: 16))
                .tracking(0.6)
                .foregroundColor(Color("app_black"))
            
            Text("Stored in this browser.")
                .font(.barlowRegular(size: 13))
                .foregroundColor(Color("text_gary"))
            
            Button(action: {
                showResetDemoDataAlert = true
            }) {
                Text("RESET ALL DEMO DATA")
                    .font(.oswaldMedium(size: 13))
                    .tracking(0.8)
                    .foregroundColor(Color("Button_red"))
                    .padding(.horizontal, 18)
                    .frame(height: 38)
                    .background(
                        Capsule()
                            .stroke(Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0), lineWidth: 1.2)
                            .background(Capsule().fill(Color.white))
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 2)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(red: 0xF5 / 255.0, green: 0xEE / 255.0, blue: 0xE3 / 255.0))
        )
    }
    
    // MARK: - Helper Views & Styling
    
    private var whiteCardBackground: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.2)
            )
            .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }
    
    private var dividerLine: some View {
        Rectangle()
            .fill(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0))
            .frame(height: 1)
    }
    
    private func editButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: "pencil")
                    .font(.system(size: 11, weight: .bold))
                
                Text("EDIT")
                    .font(.oswaldMedium(size: 12))
                    .tracking(0.8)
            }
            .foregroundColor(Color("app_black"))
            .padding(.horizontal, 12)
            .frame(height: 30)
            .background(
                Capsule()
                    .stroke(Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0), lineWidth: 1.2)
                    .background(Capsule().fill(Color.white))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Sheets
    
    private var editPersonalInfoSheetView: some View {
        NavigationView {
            ZStack {
                Color("app_background").ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        editTextField(title: "Full name", text: $fullName)
                        editTextField(title: "Email", text: $email)
                        editTextField(title: "Phone", text: $phone)
                        editTextField(title: "Birthday", text: $birthday, placeholder: "e.g. Nov 14")
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Edit Information")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if !fullName.isEmpty {
                            initialLetter = String(fullName.prefix(1))
                        }
                        showEditPersonalInfoSheet = false
                    }
                    .font(.barlowBold(size: 16))
                    .foregroundColor(Color("Button_red"))
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showEditPersonalInfoSheet = false
                    }
                    .font(.barlowRegular(size: 16))
                    .foregroundColor(Color("text_gary"))
                }
            }
        }
    }
    
    private var editAllergiesSheetView: some View {
        NavigationView {
            ZStack {
                Color("app_background").ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        editTextField(title: "Allergies", text: $allergiesText, placeholder: "e.g. Peanuts, Shellfish")
                        editTextField(title: "Dietary Restrictions", text: $dietaryText, placeholder: "e.g. Vegetarian, Gluten-free")
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Edit Allergies & Diet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        showEditAllergiesSheet = false
                    }
                    .font(.barlowBold(size: 16))
                    .foregroundColor(Color("Button_red"))
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showEditAllergiesSheet = false
                    }
                    .font(.barlowRegular(size: 16))
                    .foregroundColor(Color("text_gary"))
                }
            }
        }
    }
    
    private var memberPassSheetView: some View {
        NavigationView {
            ZStack {
                Color("app_background").ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
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
                        
                        // Pass Card
                        VStack(spacing: 16) {
                            HStack {
                                Image("app_logo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 36)
                                
                                Text("Rewards")
                                    .font(.oswaldMedium(size: 20))
                                
                                Spacer()
                                
                                Text(tierName)
                                    .font(.barlowBold(size: 11))
                                    .foregroundColor(Color(red: 0x6E / 255.0, green: 0x51 / 255.0, blue: 0x22 / 255.0))
                                    .padding(.horizontal, 9)
                                    .padding(.vertical, 3)
                                    .background(Capsule().fill(Color(red: 0xF7 / 255.0, green: 0xEE / 255.0, blue: 0xD8 / 255.0)))
                            }
                            
                            BarcodeGraphicView()
                                .frame(height: 58)
                            
                            Text("7730 4821 0093")
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                                .tracking(2.0)
                        }
                        .padding(20)
                        .background(whiteCardBackground)
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Digital Pass")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showMemberPassSheet = false
                    }
                    .font(.barlowBold(size: 16))
                    .foregroundColor(Color("Button_red"))
                }
            }
        }
    }
    
    private func editTextField(title: String, text: Binding<String>, placeholder: String = "") -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.barlowBold(size: 13.5))
                .foregroundColor(Color("app_black"))
            
            TextField(placeholder, text: text)
                .font(.barlowRegular(size: 15))
                .foregroundColor(Color("app_black"))
                .padding(.horizontal, 14)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0), lineWidth: 1.2)
                        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.white))
                )
        }
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

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView()
    }
}

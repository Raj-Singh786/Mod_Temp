//
//  UserProfileView.swift
//  MOD
//
//  Created by Rajpal singh on 18/11/26.
//

import SwiftUI

// MARK: - Typealias for Flexible Naming

typealias UserprofileView = UserProfileView

// MARK: - Dietary Option Model

struct DietaryOptionItem: Identifiable {
    let id: String
    let title: String
    let subtitle: String
}

// MARK: - UserProfileView

struct UserProfileView: View {
    
    // MARK: - Initial Guest Configuration
    
    var initialIsGuest: Bool? = nil
    
    // MARK: - Callbacks
    
    var onCartTap: (() -> Void)? = nil
    var onStarTap: (() -> Void)? = nil
    var onNavigateToRewards: (() -> Void)? = nil
    var onNavigateToOrders: (() -> Void)? = nil
    var onNavigateToHome: (() -> Void)? = nil
    
    // MARK: - Observed State
    
    @ObservedObject private var walletManager = WalletManager.shared
    @ObservedObject private var addressManager = AddressManager.shared
    @ObservedObject private var dealsManager = DealsManager.shared
    @ObservedObject private var groupOrderManager = GroupOrderManager.shared
    
    // MARK: - Guest / Member Mode State
    
    @State private var isGuest: Bool = false
    @State private var guestFullName: String = ""
    @State private var guestEmail: String = ""
    @State private var guestPhone: String = ""
    @State private var guestOffersEmailEnabled: Bool = false
    
    // MARK: - User State
    
    @State private var fullName: String = "raj"
    @State private var email: String = "risabhputta213@gmail.com"
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
    
    // Inline Edit States
    @State private var isEditingPersonalInfo: Bool = false
    @State private var isEditingAllergies: Bool = false
    
    // Draft Personal Info Fields (Snapshot 1)
    @State private var editFullName: String = "raj"
    @State private var editMobileNumber: String = "(206) 555-0142"
    @State private var editEmail: String = "risabhputta213@gmail.com"
    @State private var editBirthday: String = ""
    
    // Allergies & Dietary Selection States (Snapshot 2)
    @State private var selectedAllergens: Set<String> = ["Milk"]
    @State private var otherAllergiesNotes: String = ""
    @State private var selectedDietaryRestrictions: Set<String> = []
    
    // Saved snapshots for cancel
    @State private var savedAllergens: Set<String> = ["Milk"]
    @State private var savedOtherNotes: String = ""
    @State private var savedDietary: Set<String> = []
    
    // Static Allergen Rows matching Snapshot 2
    private let allergenRows: [[String]] = [
        ["Milk", "Eggs", "Wheat", "Soy"],
        ["Peanuts", "Tree nuts", "Sesame"],
        ["Fish", "Shellfish"]
    ]
    
    // Static Dietary Options matching Snapshot 2
    private let dietaryOptions: [DietaryOptionItem] = [
        DietaryOptionItem(id: "veg", title: "Vegetarian", subtitle: "No meat or fish"),
        DietaryOptionItem(id: "vegan", title: "Vegan", subtitle: "No animal products"),
        DietaryOptionItem(id: "dairy", title: "Dairy-free", subtitle: "No cheese or dairy sauces"),
        DietaryOptionItem(id: "pork", title: "No pork", subtitle: "No pepperoni, sausage, ham, bacon or salami"),
        DietaryOptionItem(id: "gluten", title: "Gluten-conscious", subtitle: "Prefer cauliflower crust")
    ]
    
    // Notification Toggles
    @State private var orderUpdatesEnabled: Bool = true
    @State private var offersAndNewsEnabled: Bool = true
    @State private var dealAlertsEnabled: Bool = false
    
    // Sheets & Alerts
    @State private var showSavedAddressesSheet: Bool = false
    @State private var showFavoritesSheet: Bool = false
    @State private var showSavedDealsSheet: Bool = false
    @State private var showGroupOrdersSheet: Bool = false
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
                        
                        // 2. Personal Information Card (With Inline Edit Mode)
                        personalInformationCard
                        
                        // 3. Allergies & Dietary Restrictions Card (With Inline Edit Mode)
                        allergiesAndDietaryCard
                        
                        // 4. Notifications & Privacy Card
                        notificationsAndPrivacyCard
                        
                        if !isGuest {
                            // 5. MOD Rewards Quick Card
                            rewardsQuickCard
                        } else {
                            // 5. Earn on Every Order Card (Guest)
                            earnOnEveryOrderCard
                        }
                        
                        // 6. Account Menu Navigation List Card (Wallet & Activity hidden in Guest Mode)
                        accountMenuCard
                        
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
        .onAppear {
            if let initial = initialIsGuest {
                isGuest = initial
            } else if let saved = UserDefaults.standard.object(forKey: "isGuestUser") as? Bool {
                isGuest = saved
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .userLoggedOutNotification)) { _ in
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                isGuest = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)) { _ in
            if let saved = UserDefaults.standard.object(forKey: "isGuestUser") as? Bool {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isGuest = saved
                }
            }
        }
        // Sheets
        .sheet(isPresented: $showSavedAddressesSheet) {
            AddAddressView(
                showHeader: true,
                onBack: {
                    showSavedAddressesSheet = false
                },
                onCartTap: onCartTap,
                onStarTap: onStarTap
            )
        }
        .sheet(isPresented: $showFavoritesSheet) {
            FavouritePizzaListView(
                showHeader: true,
                onBack: {
                    showFavoritesSheet = false
                },
                onCartTap: onCartTap,
                onStarTap: onStarTap,
                onBuildNewPizza: {
                    showFavoritesSheet = false
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let rootNav = windowScene.windows.first?.rootViewController as? UINavigationController,
                       let tabVC = rootNav.viewControllers.first as? UITabBarController {
                        tabVC.selectedIndex = 1
                    }
                }
            )
        }
        .fullScreenCover(isPresented: $showWalletSheet) {
            AddWalletBalanceView(
                showHeader: true,
                onBack: {
                    showWalletSheet = false
                },
                onCartTap: onCartTap,
                onStarTap: onStarTap
            )
        }
        .fullScreenCover(isPresented: $showActivitySheet) {
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
        .sheet(isPresented: $showSavedDealsSheet) {
            SaveDealsView(
                showHeader: true,
                initialFilter: .allOffers,
                onBack: {
                    showSavedDealsSheet = false
                },
                onCartTap: onCartTap,
                onStarTap: onStarTap
            )
        }
        .sheet(isPresented: $showGroupOrdersSheet) {
            GroupDealView(
                showHeader: true,
                onBack: {
                    showGroupOrdersSheet = false
                },
                onNavigateToMenu: {
                    showGroupOrdersSheet = false
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let rootNav = windowScene.windows.first?.rootViewController as? UINavigationController,
                       let tabVC = rootNav.viewControllers.first as? UITabBarController {
                        tabVC.selectedIndex = 1
                    }
                },
                onCartTap: onCartTap,
                onStarTap: onStarTap
            )
        }
        // Alerts
        .alert(isPresented: $showSignOutAlert) {
            Alert(
                title: Text("Sign Out"),
                message: Text("Are you sure you want to sign out of your MOD account?"),
                primaryButton: .destructive(Text("Sign Out")) {
                    UserDefaults.standard.set(true, forKey: "isGuestUser")
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        isGuest = true
                    }
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
                    dealsManager.resetToDefaults()
                    groupOrderManager.resetToDefaults()
                    profileCompletionPercent = 60
                    orderUpdatesEnabled = true
                    offersAndNewsEnabled = true
                    dealAlertsEnabled = false
                    selectedAllergens = ["Milk"]
                    allergiesText = "Milk"
                    selectedDietaryRestrictions = []
                    dietaryText = "None added"
                    infoAlertTitle = "Demo Data Reset"
                    infoAlertMessage = "All demo data has been restored to default values."
                    showInfoAlert = true
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    // MARK: - 0. Custom Top Navigation Bar
    
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
            
            // Right: Star / Person & Cart Icons
            HStack(spacing: 16) {
                if isGuest {
                    Button(action: {
                        redirectToLogin()
                    }) {
                        Image(systemName: "person")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(Color("app_black"))
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
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
                }
                
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
            if isGuest {
                guestHeroTopSection
            } else {
                loggedInHeroTopSection
            }
            
            // Stat Boxes
            if isGuest {
                guestStatBoxes
            } else {
                loggedInStatBoxes
            }
            
            // Profile Completion Section
            profileCompletionSection
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
    
    private var guestHeroTopSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 14) {
                // Circle Avatar with outline person
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.14))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: "person")
                        .font(.system(size: 24, weight: .regular))
                        .foregroundColor(.white)
                }
                
                // Name & Subtext
                VStack(alignment: .leading, spacing: 4) {
                    Text("GUEST")
                        .font(.oswaldBold(size: 24))
                        .foregroundColor(.white)
                    
                    Text("Ordering as a guest on this device")
                        .font(.barlowRegular(size: 13))
                        .foregroundColor(Color.white.opacity(0.7))
                }
                
                Spacer()
            }
            
            // SIGN IN OR JOIN Button
            Button(action: {
                redirectToLogin()
            }) {
                Text("SIGN IN OR JOIN")
                    .font(.oswaldMedium(size: 12))
                    .tracking(0.8)
                    .foregroundColor(Color(red: 0x8C / 255.0, green: 0x1E / 255.0, blue: 0x2A / 255.0))
                    .padding(.horizontal, 16)
                    .frame(height: 30)
                    .background(
                        Capsule()
                            .fill(Color.white)
                    )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private var loggedInHeroTopSection: some View {
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
    }
    
    private var guestStatBoxes: some View {
        HStack(spacing: 8) {
            statBox(value: "0", label: "Orders")
            statBox(value: "0", label: "Favorites")
            statBox(value: "0", label: "Addresses")
        }
    }
    
    private var loggedInStatBoxes: some View {
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
    }
    
    private var profileCompletionSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            if isGuest {
                Text("Profile 0% complete")
                    .font(.barlowSemiBold(size: 13.5))
                    .foregroundColor(.white)
                
                Text("Add: Name, Email, Phone, Birthday, Food preferences")
                    .font(.barlowRegular(size: 12))
                    .foregroundColor(Color.white.opacity(0.7))
                
                // Empty Progress Bar
                Capsule()
                    .fill(Color.white.opacity(0.2))
                    .frame(height: 6)
            } else {
                Text("Profile \(profileCompletionPercent)% complete")
                    .font(.barlowSemiBold(size: 13.5))
                    .foregroundColor(.white)
                
                Text(birthday.isEmpty ? "Add birthday for 40 pts + treat" : "Birthday added! Enjoy your birthday treat")
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
        }
        .padding(.top, 4)
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
    
    // MARK: - 2. Personal Information Card (Snapshot 1)
    
    private var personalInformationCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header Row
            HStack(alignment: .top, spacing: 12) {
                // Pink icon badge
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(red: 0xFD / 255.0, green: 0xEE / 255.0, blue: 0xF0 / 255.0))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: "person")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color("Button_red"))
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text("PERSONAL INFORMATION")
                        .font(.oswaldMedium(size: 16))
                        .tracking(0.6)
                        .foregroundColor(Color("app_black"))
                    
                    Text(isGuest ? "Remembered on this device for faster checkout" : "Used for your receipts and rewards")
                        .font(.barlowRegular(size: 12.5))
                        .foregroundColor(Color("text_gary"))
                }
                
                Spacer()
                
                if !isEditingPersonalInfo {
                    editButton {
                        if isGuest {
                            editFullName = guestFullName
                            editMobileNumber = guestPhone
                            editEmail = guestEmail
                            editBirthday = ""
                        } else {
                            editFullName = fullName
                            editMobileNumber = phone
                            editEmail = email
                            editBirthday = birthday
                        }
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            isEditingPersonalInfo = true
                        }
                    }
                }
            }
            
            if isEditingPersonalInfo {
                // Inline Edit Mode (Snapshot 1)
                personalInfoEditView
            } else {
                // Display Mode
                personalInfoDisplayView
            }
        }
        .padding(18)
        .background(whiteCardBackground)
    }
    
    // Personal Info Display View
    private var personalInfoDisplayView: some View {
        VStack(spacing: 12) {
            if isGuest {
                infoRow(label: "Full name", value: guestFullName.isEmpty ? "Not added" : guestFullName, isBoldValue: true)
                dividerLine
                infoRow(label: "Email", value: guestEmail.isEmpty ? "Not added" : guestEmail, isBoldValue: true)
                dividerLine
                infoRow(label: "Mobile", value: guestPhone.isEmpty ? "Not added" : guestPhone, isBoldValue: true)
            } else {
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
        }
        .padding(.top, 4)
    }
    
    // Personal Info Inline Edit View (Matching Snapshot 1)
    private var personalInfoEditView: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Divider below header
            dividerLine
                .padding(.top, 2)
            
            if isGuest {
                // Guest Fields (Full name, Mobile number, Email)
                VStack(spacing: 12) {
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Full name")
                                .font(.barlowBold(size: 13.5))
                                .foregroundColor(Color("app_black"))
                            
                            TextField("", text: $editFullName)
                                .font(.barlowRegular(size: 15))
                                .foregroundColor(Color("app_black"))
                                .padding(.horizontal, 14)
                                .frame(height: 46)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0), lineWidth: 1.2)
                                        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.white))
                                )
                        }
                        .frame(maxWidth: .infinity)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Mobile number")
                                .font(.barlowBold(size: 13.5))
                                .foregroundColor(Color("app_black"))
                            
                            TextField("", text: $editMobileNumber)
                                .font(.barlowRegular(size: 15))
                                .foregroundColor(Color("app_black"))
                                .keyboardType(.phonePad)
                                .padding(.horizontal, 14)
                                .frame(height: 46)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0), lineWidth: 1.2)
                                        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.white))
                                )
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Email")
                            .font(.barlowBold(size: 13.5))
                            .foregroundColor(Color("app_black"))
                        
                        TextField("", text: $editEmail)
                            .font(.barlowRegular(size: 14))
                            .foregroundColor(Color("app_black"))
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .padding(.horizontal, 14)
                            .frame(height: 46)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0), lineWidth: 1.2)
                                    .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.white))
                            )
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.top, 2)
            } else {
                // 2x2 Grid of Fields for Logged In User
                VStack(spacing: 12) {
                    // Row 1: Full name & Mobile number
                    HStack(alignment: .top, spacing: 12) {
                        // Full name
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Full name")
                                .font(.barlowBold(size: 13.5))
                                .foregroundColor(Color("app_black"))
                            
                            TextField("", text: $editFullName)
                                .font(.barlowRegular(size: 15))
                                .foregroundColor(Color("app_black"))
                                .padding(.horizontal, 14)
                                .frame(height: 46)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0), lineWidth: 1.2)
                                        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.white))
                                )
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Mobile number
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Mobile number")
                                .font(.barlowBold(size: 13.5))
                                .foregroundColor(Color("app_black"))
                            
                            TextField("", text: $editMobileNumber)
                                .font(.barlowRegular(size: 15))
                                .foregroundColor(Color("app_black"))
                                .keyboardType(.phonePad)
                                .padding(.horizontal, 14)
                                .frame(height: 46)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0), lineWidth: 1.2)
                                        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.white))
                                )
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    // Row 2: Email & Birthday
                    HStack(alignment: .top, spacing: 12) {
                        // Email
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Email")
                                .font(.barlowBold(size: 13.5))
                                .foregroundColor(Color("app_black"))
                            
                            TextField("", text: $editEmail)
                                .font(.barlowRegular(size: 14))
                                .foregroundColor(Color("app_black"))
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .padding(.horizontal, 14)
                                .frame(height: 46)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0), lineWidth: 1.2)
                                        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.white))
                                )
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Birthday
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 4) {
                                Text("Birthday")
                                    .font(.barlowBold(size: 13.5))
                                    .foregroundColor(Color("app_black"))
                                
                                Text("for a birthday treat")
                                    .font(.barlowRegular(size: 11.5))
                                    .foregroundColor(Color("text_gary"))
                                    .lineLimit(1)
                            }
                            
                            HStack {
                                TextField("dd/mm/yyyy", text: $editBirthday)
                                    .font(.barlowRegular(size: 14))
                                    .foregroundColor(Color("app_black"))
                                
                                Image(systemName: "calendar")
                                    .font(.system(size: 15, weight: .regular))
                                    .foregroundColor(Color("app_black"))
                            }
                            .padding(.horizontal, 14)
                            .frame(height: 46)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0), lineWidth: 1.2)
                                    .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.white))
                            )
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.top, 2)
            }
            
            // Actions Row: SAVE CHANGES & CANCEL
            HStack(spacing: 16) {
                Button(action: {
                    if isGuest {
                        guestFullName = editFullName
                        guestPhone = editMobileNumber
                        guestEmail = editEmail
                    } else {
                        fullName = editFullName
                        phone = editMobileNumber
                        email = editEmail
                        birthday = editBirthday
                        if !birthday.isEmpty {
                            profileCompletionPercent = min(100, max(profileCompletionPercent, 80))
                        }
                        if !fullName.isEmpty {
                            initialLetter = String(fullName.prefix(1)).uppercased()
                        }
                    }
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        isEditingPersonalInfo = false
                    }
                }) {
                    Text("SAVE CHANGES")
                        .font(.oswaldMedium(size: 13.5))
                        .tracking(0.8)
                        .foregroundColor(.white)
                        .padding(.horizontal, 22)
                        .frame(height: 42)
                        .background(
                            Capsule()
                                .fill(Color(red: 0x8C / 255.0, green: 0x1E / 255.0, blue: 0x2A / 255.0))
                                .shadow(color: Color(red: 0x8C / 255.0, green: 0x1E / 255.0, blue: 0x2A / 255.0).opacity(0.35), radius: 6, x: 0, y: 3)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    if isGuest {
                        editFullName = guestFullName
                        editMobileNumber = guestPhone
                        editEmail = guestEmail
                    } else {
                        editFullName = fullName
                        editMobileNumber = phone
                        editEmail = email
                        editBirthday = birthday
                    }
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        isEditingPersonalInfo = false
                    }
                }) {
                    Text("CANCEL")
                        .font(.oswaldMedium(size: 13.5))
                        .tracking(0.8)
                        .foregroundColor(Color("app_black"))
                        .padding(.horizontal, 8)
                        .frame(height: 42)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
            }
            .padding(.top, 6)
        }
    }
    
    private func infoRow(label: String, value: String, isPlaceholder: Bool = false, isBoldValue: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label)
                .font(.barlowRegular(size: 12.5))
                .foregroundColor(Color("text_gary"))
            
            Text(value)
                .font((isBoldValue || !isPlaceholder) ? .barlowBold(size: 14.5) : .barlowRegular(size: 13.5))
                .foregroundColor(isPlaceholder ? Color("text_gary") : Color("app_black"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - 3. Allergies & Dietary Restrictions Card (Snapshot 2)
    
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
                    
                    Text(isEditingAllergies ? "Help us flag items and prepare your order with care" : "Helps us flag items and prepare your order with care")
                        .font(.barlowRegular(size: 12.5))
                        .foregroundColor(Color("text_gary"))
                }
                
                Spacer()
                
                if !isEditingAllergies {
                    editButton {
                        savedAllergens = selectedAllergens
                        savedOtherNotes = otherAllergiesNotes
                        savedDietary = selectedDietaryRestrictions
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            isEditingAllergies = true
                        }
                    }
                }
            }
            
            if isEditingAllergies {
                // Inline Edit Mode (Snapshot 2)
                allergiesEditView
            } else {
                // Display Mode
                allergiesDisplayView
            }
        }
        .padding(18)
        .background(whiteCardBackground)
    }
    
    // Allergies Display View
    private var allergiesDisplayView: some View {
        VStack(alignment: .leading, spacing: 12) {
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
            Text(isGuest ? "Used to pre-fill checkout, filter the menu and flag items. Kept on this device only." : "Shared kitchens: Cross-contact with allergens is possible. For severe allergies, please speak with our team.")
                .font(.barlowRegular(size: 12))
                .foregroundColor(Color("text_gary"))
                .lineSpacing(2)
        }
    }
    
    // Allergies Inline Edit View (Matching Snapshot 2)
    private var allergiesEditView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Divider below header
            dividerLine
                .padding(.top, 2)
            
            // Allergies Section
            VStack(alignment: .leading, spacing: 10) {
                Text("Allergies")
                    .font(.barlowBold(size: 15))
                    .foregroundColor(Color("app_black"))
                
                Text("We'll pre-select these at checkout and flag items that contain them.")
                    .font(.barlowRegular(size: 12.5))
                    .foregroundColor(Color("text_gary"))
                    .lineSpacing(2)
                
                // 3 Rows of Allergen Pills
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(0..<allergenRows.count, id: \.self) { rowIndex in
                        HStack(spacing: 8) {
                            ForEach(allergenRows[rowIndex], id: \.self) { allergen in
                                allergenPill(allergen)
                            }
                        }
                    }
                }
                .padding(.top, 2)
                
                // Other allergies or notes
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 4) {
                        Text("Other allergies or notes")
                            .font(.barlowBold(size: 13.5))
                            .foregroundColor(Color("app_black"))
                        
                        Text("optional")
                            .font(.barlowRegular(size: 12))
                            .foregroundColor(Color("text_gary"))
                    }
                    
                    TextField("e.g. mustard, celery", text: $otherAllergiesNotes)
                        .font(.barlowRegular(size: 14))
                        .foregroundColor(Color("app_black"))
                        .padding(.horizontal, 14)
                        .frame(height: 46)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0), lineWidth: 1.2)
                                .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.white))
                        )
                }
                .padding(.top, 4)
            }
            
            // Dietary restrictions Section
            VStack(alignment: .leading, spacing: 12) {
                Text("Dietary restrictions")
                    .font(.barlowBold(size: 15))
                    .foregroundColor(Color("app_black"))
                
                // 5 Checkbox cards
                VStack(spacing: 10) {
                    ForEach(dietaryOptions) { option in
                        dietaryOptionCard(option)
                    }
                }
            }
            
            // Warning Note
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "info.circle")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(red: 0x93 / 255.0, green: 0x5E / 255.0, blue: 0x28 / 255.0))
                    .padding(.top, 2)
                
                Text("Our kitchens share equipment and ingredients. Your preferences help us flag items, but we can't guarantee an allergen-free meal.")
                    .font(.barlowRegular(size: 12.5))
                    .foregroundColor(Color(red: 0x8C / 255.0, green: 0x55 / 255.0, blue: 0x28 / 255.0))
                    .lineSpacing(2)
            }
            .padding(.top, 2)
            
            // Actions Row: SAVE PREFERENCES & CANCEL
            HStack(spacing: 16) {
                Button(action: {
                    // Update allergiesText summary
                    if selectedAllergens.isEmpty && otherAllergiesNotes.isEmpty {
                        allergiesText = "None added"
                    } else {
                        var parts = Array(selectedAllergens).sorted()
                        if !otherAllergiesNotes.isEmpty {
                            parts.append(otherAllergiesNotes)
                        }
                        allergiesText = parts.joined(separator: ", ")
                    }
                    
                    // Update dietaryText summary
                    if selectedDietaryRestrictions.isEmpty {
                        dietaryText = "None added"
                    } else {
                        dietaryText = dietaryOptions
                            .filter { selectedDietaryRestrictions.contains($0.id) }
                            .map { $0.title }
                            .joined(separator: ", ")
                    }
                    
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        isEditingAllergies = false
                    }
                }) {
                    Text("SAVE PREFERENCES")
                        .font(.oswaldMedium(size: 13.5))
                        .tracking(0.8)
                        .foregroundColor(.white)
                        .padding(.horizontal, 22)
                        .frame(height: 42)
                        .background(
                            Capsule()
                                .fill(Color(red: 0x8C / 255.0, green: 0x1E / 255.0, blue: 0x2A / 255.0))
                                .shadow(color: Color(red: 0x8C / 255.0, green: 0x1E / 255.0, blue: 0x2A / 255.0).opacity(0.35), radius: 6, x: 0, y: 3)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    selectedAllergens = savedAllergens
                    otherAllergiesNotes = savedOtherNotes
                    selectedDietaryRestrictions = savedDietary
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        isEditingAllergies = false
                    }
                }) {
                    Text("CANCEL")
                        .font(.oswaldMedium(size: 13.5))
                        .tracking(0.8)
                        .foregroundColor(Color("app_black"))
                        .padding(.horizontal, 8)
                        .frame(height: 42)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
            }
            .padding(.top, 4)
        }
    }
    
    // Allergen Pill Component
    private func allergenPill(_ allergen: String) -> some View {
        let isSelected = selectedAllergens.contains(allergen)
        return Button(action: {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                if isSelected {
                    selectedAllergens.remove(allergen)
                } else {
                    selectedAllergens.insert(allergen)
                }
            }
        }) {
            Text(allergen)
                .font(.barlowSemiBold(size: 13))
                .foregroundColor(Color("app_black"))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    Capsule()
                        .stroke(
                            isSelected ? Color(red: 0x8C / 255.0, green: 0x1E / 255.0, blue: 0x2A / 255.0) : Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0),
                            lineWidth: isSelected ? 2.0 : 1.2
                        )
                        .background(Capsule().fill(Color.white))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // Dietary Option Checkbox Card Component
    private func dietaryOptionCard(_ option: DietaryOptionItem) -> some View {
        let isSelected = selectedDietaryRestrictions.contains(option.id)
        return Button(action: {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                if isSelected {
                    selectedDietaryRestrictions.remove(option.id)
                } else {
                    selectedDietaryRestrictions.insert(option.id)
                }
            }
        }) {
            HStack(alignment: .center, spacing: 14) {
                // Checkbox
                ZStack {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .stroke(
                            isSelected ? Color("Button_red") : Color(red: 0xC0 / 255.0, green: 0xB8 / 255.0, blue: 0xAC / 255.0),
                            lineWidth: 1.5
                        )
                        .frame(width: 18, height: 18)
                    
                    if isSelected {
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(Color("Button_red"))
                            .frame(width: 18, height: 18)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(option.title)
                        .font(.barlowBold(size: 14))
                        .foregroundColor(Color("app_black"))
                    
                    Text(option.subtitle)
                        .font(.barlowRegular(size: 12))
                        .foregroundColor(Color("text_gary"))
                }
                
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0), lineWidth: 1.2)
                    .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.white))
            )
        }
        .buttonStyle(PlainButtonStyle())
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
                
                if isGuest {
                    toggleRow(
                        isOn: $guestOffersEmailEnabled,
                        title: "Offers & news by email",
                        subtitle: "Sign in to get offers"
                    )
                    
                    toggleRow(
                        isOn: $dealAlertsEnabled,
                        title: "Deal alerts on this device",
                        subtitle: "Occasional notifications about local offers"
                    )
                } else {
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
            }
            .padding(.top, 4)
        }
        .padding(18)
        .background(whiteCardBackground)
    }
    
    private func toggleRow(isOn: Binding<Bool>, title: String, subtitle: String) -> some View {
        HStack(alignment: .center, spacing: 12) {
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
    
    // MARK: - 5. Earn on Every Order Card (Guest)
    
    private var earnOnEveryOrderCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Pale Pink star badge
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color(red: 0xFD / 255.0, green: 0xEE / 255.0, blue: 0xF0 / 255.0))
                    .frame(width: 36, height: 36)
                
                Image(systemName: "star")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color(red: 0x8C / 255.0, green: 0x1E / 255.0, blue: 0x2A / 255.0))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("EARN ON EVERY ORDER")
                    .font(.oswaldMedium(size: 16))
                    .tracking(0.6)
                    .foregroundColor(Color("app_black"))
                
                Text("10 pts per $1, a free pizza at 1,500 pts, wallet and member-only deals.")
                    .font(.barlowRegular(size: 12.5))
                    .foregroundColor(Color("text_gary"))
                    .lineSpacing(2)
            }
            
            // Full width capsule button
            Button(action: {
                redirectToLogin()
            }) {
                Text("JOIN MOD REWARDS")
                    .font(.oswaldMedium(size: 14))
                    .tracking(0.8)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(
                        Capsule()
                            .fill(Color(red: 0x8C / 255.0, green: 0x1E / 255.0, blue: 0x2A / 255.0))
                            .shadow(color: Color(red: 0x8C / 255.0, green: 0x1E / 255.0, blue: 0x2A / 255.0).opacity(0.35), radius: 6, x: 0, y: 3)
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 2)
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
                subtitle: isGuest ? "\(addressManager.addresses.count) saved" : "\(addressManager.addresses.count) saved",
                action: {
                    showSavedAddressesSheet = true
                }
            )
            
            dividerLine
            
            menuRow(
                iconName: "heart",
                title: "Favorites & saved pizzas",
                subtitle: isGuest ? "\(savedFavoritesCount == 0 ? 0 : savedFavoritesCount) favorites" : "\(savedFavoritesCount) favorite pizza",
                action: {
                    showFavoritesSheet = true
                }
            )
            
            dividerLine
            
            menuRow(
                iconName: "doc.text",
                title: "Orders & receipts",
                subtitle: isGuest ? "0 orders" : "\(ordersCount) orders",
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
                subtitle: isGuest ? "\(dealsManager.savedDealsCount) saved" : "\(dealsManager.savedDealsCount) saved",
                action: {
                    showSavedDealsSheet = true
                }
            )
            
            dividerLine
            
            menuRow(
                iconName: "person.2",
                title: "Group orders",
                subtitle: isGuest ? "Host-paid group orders" : (groupOrderManager.activeGroups.isEmpty ? "Host and join group orders" : "\(groupOrderManager.activeGroups.count) active group"),
                action: {
                    showGroupOrdersSheet = true
                }
            )
            
            if !isGuest {
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
    
    // MARK: - Member Pass Sheet
    
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
    
    // MARK: - Login Redirection Helper
    
    private func redirectToLogin() {
        if let appDelegate = kSharedAppDelegate {
            appDelegate.moveToAuth(initialDestination: .login)
        } else {
            AccountSheetManager.shared.handleStarTap()
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
        Group {
            UserProfileView(initialIsGuest: true)
                .previewDisplayName("Guest Profile")
            
            UserProfileView(initialIsGuest: false)
                .previewDisplayName("Logged-in Profile")
        }
    }
}

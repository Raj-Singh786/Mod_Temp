//
//  SendRewardsScreen.swift
//  MOD
//
//  Created by Rajpal singh on 10/11/26.
//

import SwiftUI

// MARK: - Models

struct RewardRecipient: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let initials: String
    let phone: String
    let isMember: Bool
    let hasHeartBadge: Bool
    let isAddButton: Bool
}

enum CardGreetingTheme: String, CaseIterable, Identifiable {
    case pizzaNight = "Pizza Night on Me!"
    case happyBirthday = "Happy Birthday!"
    case thankYou = "Thank You!"
    case gameDay = "Game Day Treat"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .pizzaNight: return "🍕"
        case .happyBirthday: return "🎂"
        case .thankYou: return "🙏"
        case .gameDay: return "🏈"
        }
    }

    var subtitle: String {
        switch self {
        case .pizzaNight: return "Best for weekend slices"
        case .happyBirthday: return "Celebration treat"
        case .thankYou: return "Express gratitude"
        case .gameDay: return "Tailgate wings & crust"
        }
    }
}

// MARK: - Send Rewards & Points Screen

struct SendRewardsScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) private var presentationMode

    // User Balance Properties
    var userPoints: Int = 445
    var onDone: () -> Void = {}

    // Recipient State
    @State private var searchText: String = ""
    @State private var selectedRecipient: RewardRecipient = RewardRecipient(
        name: "Alex M.",
        initials: "AM",
        phone: "+1 415 555–0192",
        isMember: true,
        hasHeartBadge: false,
        isAddButton: false
    )

    // Transfer Amount State
    @State private var transferPoints: Int = 100
    @State private var selectedQuickAmount: Int? = 100

    // Theme & Personal Note State
    @State private var selectedTheme: CardGreetingTheme = .pizzaNight
    @State private var personalNote: String = "Here's some Hut Points for your Friday pizza craving! Enjoy 🍕"
    private let noteCharacterLimit: Int = 120

    // Sheet & Alert States
    @State private var showHelpAlert: Bool = false
    @State private var showQRScannerAlert: Bool = false
    @State private var showAddRecipientSheet: Bool = false
    @State private var showSuccessAlert: Bool = false
    @State private var isSending: Bool = false

    // App Colors
    private let modRed = Color(red: 0.88, green: 0.12, blue: 0.22)
    private let screenBg = Color(red: 0.98, green: 0.98, blue: 0.99)
    private let borderGray = Color(red: 0.91, green: 0.91, blue: 0.93)
    private let textDark = Color(red: 0.10, green: 0.12, blue: 0.18)
    private let successGreen = Color(red: 0.12, green: 0.65, blue: 0.38)
    private let successGreenBg = Color(red: 0.90, green: 0.98, blue: 0.94)
    private let lightBlueBg = Color(red: 0.94, green: 0.96, blue: 0.99)
    private let goldPillBg = Color(red: 1.0, green: 0.94, blue: 0.85)

    // Calculated Remaining Balance
    private var remainingBalance: Int {
        max(userPoints - transferPoints, 0)
    }

    // Recent Pizza Buddies matching snapshot
    private let recentBuddies: [RewardRecipient] = [
        RewardRecipient(
            name: "Mom",
            initials: "M",
            phone: "+1 415 555–0188",
            isMember: true,
            hasHeartBadge: true,
            isAddButton: false
        ),
        RewardRecipient(
            name: "Alex M.",
            initials: "AM",
            phone: "+1 415 555–0192",
            isMember: true,
            hasHeartBadge: false,
            isAddButton: false
        ),
        RewardRecipient(
            name: "Jessica T.",
            initials: "JT",
            phone: "+1 415 555–0143",
            isMember: true,
            hasHeartBadge: false,
            isAddButton: false
        ),
        RewardRecipient(
            name: "Marcus R.",
            initials: "MR",
            phone: "+1 415 555–0177",
            isMember: true,
            hasHeartBadge: false,
            isAddButton: false
        ),
        RewardRecipient(
            name: "Add",
            initials: "+",
            phone: "",
            isMember: false,
            hasHeartBadge: false,
            isAddButton: true
        )
    ]

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // 1. Navigation Header
            navigationHeader

            // 2. Scrollable Body
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 18) {
                    // Top Card: Hut Rewards Balance Card
                    rewardsBalanceCard
                        .padding(.top, 10)

                    // Section 1: Recipient
                    recipientSection

                    // Section 2: Transfer Amount
                    transferAmountSection

                    // Section 3: Card Theme & Note
                    cardThemeAndNoteSection

                    // Transfer Summary Box
                    transferSummarySection

                    // Primary Action Button (Send Points)
                    actionButtonSection

                    // Bottom Clearance
                    Color.clear.frame(height: 32)
                }
                .padding(.horizontal, 16)
            }
            .background(screenBg)
        }
        .background(screenBg.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
        .alert(isPresented: $showHelpAlert) {
            Alert(
                title: Text("Sending Points"),
                message: Text("You can send your MOD Points to any friend or family member instantly with zero transfer fees."),
                dismissButton: .default(Text("Got It"))
            )
        }
        .alert(isPresented: $showQRScannerAlert) {
            Alert(
                title: Text("Scan QR Code"),
                message: Text("Point camera at your friend's MOD Rewards member QR code to autofill recipient."),
                dismissButton: .default(Text("OK"))
            )
        }
        .alert(isPresented: $showSuccessAlert) {
            Alert(
                title: Text("Points Sent! 🍕"),
                message: Text("Successfully transferred \(transferPoints) PTS to \(selectedRecipient.name). Your remaining balance is \(remainingBalance) PTS."),
                dismissButton: .default(Text("Done")) {
                    onDone()
                    dismiss()
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }

    // MARK: - 1. Navigation Header

    private var navigationHeader: some View {
        HStack {
            // Back Button
            Button(action: {
                onDone()
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

            Text("Send Rewards & Points")
                .font(Font.appFont(.jakartaBold, size: 17))
                .foregroundColor(textDark)

            Spacer()

            // Help Question Mark Button
            Button(action: {
                showHelpAlert = true
            }) {
                Image(systemName: "questionmark.circle")
                    .font(Font.appFont(.jakartaSemiBold, size: 18))
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

    // MARK: - Top Card: HUT REWARDS BALANCE Card

    private var rewardsBalanceCard: some View {
        VStack(spacing: 12) {
            // Top Row: Title + Tag Icon
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("HUT REWARDS BALANCE")
                        .font(Font.appFont(.jakartaBold, size: 11))
                        .foregroundColor(Color(red: 0.45, green: 0.48, blue: 0.55))
                        .tracking(0.5)

                    HStack(alignment: .firstTextBaseline, spacing: 5) {
                        Text("\(userPoints)")
                            .font(Font.appFont(.jakartaExtraBold, size: 30))
                            .foregroundColor(modRed)

                        Text("PTS")
                            .font(Font.appFont(.jakartaBold, size: 15))
                            .foregroundColor(modRed)

                        Text("Available")
                            .font(Font.appFont(.jakartaMedium, size: 13))
                            .foregroundColor(.gray)
                    }
                }

                Spacer()

                // Tag Icon Badge
                ZStack {
                    Circle()
                        .fill(Color(red: 1.0, green: 0.92, blue: 0.93))
                        .frame(width: 38, height: 38)

                    Image(systemName: "tag.fill")
                        .font(.system(size: 15))
                        .foregroundColor(modRed)
                }
            }

            // Bottom Estimated Remaining Row
            HStack {
                HStack(spacing: 5) {
                    Image(systemName: "creditcard")
                        .font(.system(size: 12))
                        .foregroundColor(successGreen)

                    Text("Est. balance after transfer:")
                        .font(Font.appFont(.jakartaRegular, size: 12))
                        .foregroundColor(.gray)
                }

                Spacer()

                // 345 PTS Pill Badge
                Text("\(remainingBalance) PTS")
                    .font(Font.appFont(.jakartaBold, size: 12))
                    .foregroundColor(Color(red: 0.18, green: 0.28, blue: 0.52))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(red: 0.92, green: 0.95, blue: 0.99))
                    .cornerRadius(8)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(18)
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(borderGray, lineWidth: 1))
        .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 2)
    }

    // MARK: - Section 1: Recipient

    private var recipientSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header Row: Number "1" + Title + Instant Delivery Badge
            HStack {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(modRed)
                            .frame(width: 22, height: 22)
                        Text("1")
                            .font(Font.appFont(.jakartaBold, size: 12))
                            .foregroundColor(.white)
                    }

                    Text("Recipient")
                        .font(Font.appFont(.jakartaBold, size: 16))
                        .foregroundColor(textDark)
                }

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 11))
                    Text("Instant Delivery")
                        .font(Font.appFont(.jakartaBold, size: 11.5))
                }
                .foregroundColor(successGreen)
            }

            // Search Bar with QR Scanner
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)

                TextField("Search by name, phone (+1...), or email", text: $searchText)
                    .font(Font.appFont(.jakartaRegular, size: 13))

                Button(action: {
                    showQRScannerAlert = true
                }) {
                    Image(systemName: "qrcode.viewfinder")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(modRed)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(borderGray, lineWidth: 1))

            // Recent Pizza Buddies Horizontal Carousel
            VStack(alignment: .leading, spacing: 8) {
                Text("Recent Pizza Buddies")
                    .font(Font.appFont(.jakartaSemiBold, size: 12.5))
                    .foregroundColor(Color(red: 0.35, green: 0.38, blue: 0.44))

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(recentBuddies) { buddy in
                            buddyAvatarItem(buddy: buddy)
                        }
                    }
                    .padding(.horizontal, 2)
                    .padding(.vertical, 4)
                }
            }

            // Selected Recipient Box (Alex M. • MOD Member)
            selectedRecipientCard
        }
    }

    // MARK: Buddy Avatar Item

    private func buddyAvatarItem(buddy: RewardRecipient) -> some View {
        let isSelected = selectedRecipient.name == buddy.name && !buddy.isAddButton

        return Button(action: {
            if buddy.isAddButton {
                showQRScannerAlert = true
            } else {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                    selectedRecipient = buddy
                }
            }
        }) {
            VStack(spacing: 6) {
                ZStack(alignment: .bottomTrailing) {
                    if buddy.isAddButton {
                        // Dashed "+ Add" Button
                        Circle()
                            .stroke(style: StrokeStyle(lineWidth: 1.2, dash: [4, 3]))
                            .foregroundColor(Color.gray.opacity(0.55))
                            .frame(width: 52, height: 52)
                            .overlay(
                                Image(systemName: "person.badge.plus")
                                    .font(.system(size: 17))
                                    .foregroundColor(.gray)
                            )
                    } else {
                        // Avatar Photo
                        Circle()
                            .fill(Color(red: 0.92, green: 0.93, blue: 0.96))
                            .frame(width: 52, height: 52)
                            .overlay(
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(Color(red: 0.70, green: 0.73, blue: 0.80))
                                    .padding(6)
                            )
                            .overlay(
                                Circle()
                                    .stroke(isSelected ? modRed : Color.clear, lineWidth: 2)
                            )

                        // Badges: Heart for Mom, Checkmark for Selected
                        if isSelected {
                            Circle()
                                .fill(successGreen)
                                .frame(width: 16, height: 16)
                                .overlay(
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 9, weight: .black))
                                        .foregroundColor(.white)
                                )
                                .offset(x: 2, y: 2)
                        } else if buddy.hasHeartBadge {
                            Circle()
                                .fill(modRed)
                                .frame(width: 16, height: 16)
                                .overlay(
                                    Image(systemName: "heart.fill")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundColor(.white)
                                )
                                .offset(x: 2, y: 2)
                        }
                    }
                }

                Text(buddy.isAddButton ? "+ Add" : buddy.name)
                    .font(Font.appFont(isSelected ? .jakartaBold : .jakartaMedium, size: 11.5))
                    .foregroundColor(isSelected ? modRed : textDark)
                    .lineLimit(1)
            }
            .frame(width: 60)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: Selected Recipient Card

    private var selectedRecipientCard: some View {
        HStack(spacing: 12) {
            // Coral Initials Circle
            ZStack {
                Circle()
                    .fill(Color(red: 1.0, green: 0.92, blue: 0.93))
                    .frame(width: 44, height: 44)

                Text(selectedRecipient.initials)
                    .font(Font.appFont(.jakartaBold, size: 14))
                    .foregroundColor(modRed)
            }

            // Name + Member Badge + Phone
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(selectedRecipient.name)
                        .font(Font.appFont(.jakartaBold, size: 14.5))
                        .foregroundColor(textDark)

                    if selectedRecipient.isMember {
                        HStack(spacing: 3) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 10))
                            Text("MOD Member")
                                .font(Font.appFont(.jakartaBold, size: 10))
                        }
                        .foregroundColor(successGreen)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2.5)
                        .background(successGreenBg)
                        .cornerRadius(6)
                    }
                }

                Text(selectedRecipient.phone)
                    .font(Font.appFont(.jakartaRegular, size: 12))
                    .foregroundColor(.gray)
            }

            Spacer()

            // Change Button
            Button(action: {
                // Toggle to next friend or search
                if let idx = recentBuddies.firstIndex(of: selectedRecipient) {
                    let nextIdx = (idx + 1) % (recentBuddies.count - 1)
                    selectedRecipient = recentBuddies[nextIdx]
                }
            }) {
                Text("Change")
                    .font(Font.appFont(.jakartaBold, size: 12))
                    .foregroundColor(Color(red: 0.35, green: 0.38, blue: 0.44))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(red: 0.94, green: 0.95, blue: 0.98))
                    .cornerRadius(8)
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(red: 1.0, green: 0.90, blue: 0.91), lineWidth: 1.2)
        )
    }

    // MARK: - Section 2: Transfer Amount

    private var transferAmountSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header Row: Number "2" + Title + Min/Max
            HStack {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(modRed)
                            .frame(width: 22, height: 22)
                        Text("2")
                            .font(Font.appFont(.jakartaBold, size: 12))
                            .foregroundColor(.white)
                    }

                    Text("Transfer Amount")
                        .font(Font.appFont(.jakartaBold, size: 16))
                        .foregroundColor(textDark)
                }

                Spacer()

                Text("Min 10 • Max \(userPoints)")
                    .font(Font.appFont(.jakartaMedium, size: 12))
                    .foregroundColor(.gray)
            }

            // Points Input Card
            VStack(spacing: 14) {
                Text("POINTS TO SEND")
                    .font(Font.appFont(.jakartaBold, size: 11))
                    .foregroundColor(Color(red: 0.45, green: 0.48, blue: 0.55))
                    .tracking(0.5)

                // Large Number Display with Underline
                VStack(spacing: 4) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("\(transferPoints)")
                            .font(Font.appFont(.jakartaExtraBold, size: 40))
                            .foregroundColor(modRed)

                        Text("PTS")
                            .font(Font.appFont(.jakartaBold, size: 20))
                            .foregroundColor(modRed)
                    }

                    // Red underline
                    Rectangle()
                        .fill(modRed)
                        .frame(width: 140, height: 2)
                }

                // Quick Denominations (+25, +50, +100, Send All)
                HStack(spacing: 8) {
                    quickAmountChip(amount: 25, label: "+25")
                    quickAmountChip(amount: 50, label: "+50")
                    quickAmountChip(amount: 100, label: "+100")
                    quickAmountChip(amount: userPoints, label: "Send All (\(userPoints))", isGold: true)
                }

                // Perk Value Estimation Card
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.98, green: 0.70, blue: 0.20))
                            .frame(width: 20, height: 20)

                        Image(systemName: "star.fill")
                            .font(.system(size: 9.5))
                            .foregroundColor(.white)
                    }

                    Text(perkDescription)
                        .font(Font.appFont(.jakartaMedium, size: 12))
                        .foregroundColor(Color(red: 0.25, green: 0.28, blue: 0.35))
                        .lineLimit(2)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(lightBlueBg)
                .cornerRadius(10)

                // Zero Transaction Fees Banner
                HStack(spacing: 5) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 12))
                        .foregroundColor(successGreen)

                    Text("Free peer transfer with zero transaction fees")
                        .font(Font.appFont(.jakartaMedium, size: 11.5))
                        .foregroundColor(successGreen)
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(18)
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(borderGray, lineWidth: 1))
            .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 2)
        }
    }

    // Dynamic Perk Description
    private var perkDescription: String {
        if transferPoints >= 300 {
            return "≈ Free Medium 2-Topping Pizza perk"
        } else if transferPoints >= 100 {
            return "≈ Free Stuffed Garlic Knots or 20% off meal perk"
        } else if transferPoints >= 50 {
            return "≈ Free 2L Chilled Soda or side dip perk"
        } else {
            return "≈ Toward delicious free pizza rewards perk"
        }
    }

    private func quickAmountChip(amount: Int, label: String, isGold: Bool = false) -> some View {
        let isSelected = selectedQuickAmount == amount && transferPoints == amount

        return Button(action: {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                transferPoints = min(amount, userPoints)
                selectedQuickAmount = amount
            }
        }) {
            Text(label)
                .font(Font.appFont(.jakartaBold, size: 12))
                .foregroundColor(isSelected ? .white : (isGold ? Color(red: 0.55, green: 0.38, blue: 0.05) : Color(red: 0.22, green: 0.28, blue: 0.45)))
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(isSelected ? modRed : (isGold ? goldPillBg : lightBlueBg))
                .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Section 3: Card Theme & Note

    private var cardThemeAndNoteSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header Row: Number "3" + Title + Optional
            HStack {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(modRed)
                            .frame(width: 22, height: 22)
                        Text("3")
                            .font(Font.appFont(.jakartaBold, size: 12))
                            .foregroundColor(.white)
                    }

                    Text("Card Theme & Note")
                        .font(Font.appFont(.jakartaBold, size: 16))
                        .foregroundColor(textDark)
                }

                Spacer()

                Text("Optional")
                    .font(Font.appFont(.jakartaMedium, size: 12))
                    .foregroundColor(.gray)
            }

            // 2x2 Grid of Card Themes
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(CardGreetingTheme.allCases) { theme in
                    cardThemeItem(theme: theme)
                }
            }

            // Personal Message Text Box
            VStack(alignment: .trailing, spacing: 4) {
                TextField("Add a personal note...", text: $personalNote)
                    .font(Font.appFont(.jakartaRegular, size: 13))
                    .foregroundColor(textDark)
                    .padding(12)

                Text("\(personalNote.count)/\(noteCharacterLimit)")
                    .font(Font.appFont(.jakartaRegular, size: 11))
                    .foregroundColor(.gray)
                    .padding(.trailing, 10)
                    .padding(.bottom, 6)
            }
            .background(Color.white)
            .cornerRadius(14)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(borderGray, lineWidth: 1))
        }
    }

    private func cardThemeItem(theme: CardGreetingTheme) -> some View {
        let isSelected = selectedTheme == theme

        return Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTheme = theme
            }
        }) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(theme.emoji)
                        .font(.system(size: 18))

                    Spacer()

                    if isSelected {
                        Circle()
                            .fill(modRed)
                            .frame(width: 14, height: 14)
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.system(size: 8, weight: .black))
                                    .foregroundColor(.white)
                            )
                    }
                }

                Text(theme.rawValue)
                    .font(Font.appFont(.jakartaBold, size: 13))
                    .foregroundColor(textDark)

                Text(theme.subtitle)
                    .font(Font.appFont(.jakartaRegular, size: 11))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? modRed : borderGray, lineWidth: isSelected ? 1.5 : 1)
            )
            .shadow(color: isSelected ? modRed.opacity(0.08) : Color.clear, radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Transfer Summary Section

    private var transferSummarySection: some View {
        VStack(spacing: 10) {
            // Header Row: Transfer Summary + Zero Fees
            HStack {
                Text("Transfer Summary")
                    .font(Font.appFont(.jakartaBold, size: 14))
                    .foregroundColor(textDark)

                Spacer()

                Text("Zero Fees")
                    .font(Font.appFont(.jakartaBold, size: 11))
                    .foregroundColor(successGreen)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(successGreenBg)
                    .cornerRadius(6)
            }

            summaryRow(title: "Points to Transfer", value: "\(transferPoints) PTS")
            summaryRow(title: "Transfer Fee", value: "0 PTS (Free)", isGreen: true)
            summaryRow(title: "Remaining in Account", value: "\(remainingBalance) PTS")

            Divider()
                .padding(.vertical, 2)

            // Delivery Method Line
            HStack(spacing: 5) {
                Text("Delivery Method")
                    .font(Font.appFont(.jakartaRegular, size: 12.5))
                    .foregroundColor(.gray)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 11))
                        .foregroundColor(successGreen)

                    Text("Instant to \(selectedRecipient.name)'s MOD Wallet")
                        .font(Font.appFont(.jakartaBold, size: 12))
                        .foregroundColor(textDark)
                }
            }

            // Notification Info Line
            HStack(alignment: .top, spacing: 6) {
                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: 12))
                    .foregroundColor(modRed)

                Text("\(selectedRecipient.name) will receive an instant SMS notification & Hut in-app alert upon confirmation.")
                    .font(Font.appFont(.jakartaRegular, size: 11))
                    .foregroundColor(Color(red: 0.35, green: 0.38, blue: 0.44))
                    .lineSpacing(1.5)
            }
            .padding(.top, 4)
        }
        .padding(14)
        .background(Color(red: 0.95, green: 0.97, blue: 1.0))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(borderGray, lineWidth: 1))
    }

    private func summaryRow(title: String, value: String, isGreen: Bool = false) -> some View {
        HStack {
            Text(title)
                .font(Font.appFont(.jakartaRegular, size: 12.5))
                .foregroundColor(.gray)

            Spacer()

            Text(value)
                .font(Font.appFont(.jakartaBold, size: 13))
                .foregroundColor(isGreen ? successGreen : textDark)
        }
    }

    // MARK: - Action Button Section

    private var actionButtonSection: some View {
        VStack(spacing: 8) {
            Button(action: {
                isSending = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    isSending = false
                    showSuccessAlert = true
                }
            }) {
                HStack(spacing: 8) {
                    if isSending {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Send \(transferPoints) Points to \(selectedRecipient.name)")
                            .font(Font.appFont(.jakartaBold, size: 15))

                        Image(systemName: "arrow.right")
                            .font(.system(size: 13, weight: .bold))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(modRed)
                .cornerRadius(14)
                .shadow(color: modRed.opacity(0.35), radius: 8, x: 0, y: 4)
            }
            .disabled(isSending || transferPoints <= 0 || transferPoints > userPoints)

            Text("Points are deducted immediately and cannot be reversed once confirmed.")
                .font(Font.appFont(.jakartaRegular, size: 11))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 4)
    }
}

// MARK: - Preview

#Preview {
    SendRewardsScreen(userPoints: 445)
}

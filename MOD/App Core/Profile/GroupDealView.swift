//
//  GroupDealView.swift
//  MOD
//
//  Created by Rajpal singh on 18/11/26.
//

import SwiftUI
import Combine

// MARK: - Typealiases for Flexible Naming

typealias GroupOrderView = GroupDealView
typealias GroupOrdersView = GroupDealView

// MARK: - Group Food & Participant Models

struct GroupFoodItem: Identifiable, Hashable {
    let id: String
    var title: String
    var price: Double
    var customizations: String?
}

struct GroupParticipantItem: Identifiable, Hashable {
    let id: String
    var name: String
    var isHost: Bool = false
    var isReady: Bool = false
    var items: [GroupFoodItem] = []
    
    var totalSpent: Double {
        items.reduce(0.0) { $0 + $1.price }
    }
}

// MARK: - Group Order Item Model

struct GroupOrderItem: Identifiable, Hashable {
    let id: String
    var name: String
    var hostName: String
    var budgetPerPerson: String
    var selectionsCloseIn: String
    var fulfillmentType: String
    var locationName: String
    var pickupTimeText: String
    var shareLink: String
    var isClosed: Bool = false
    var participants: [GroupParticipantItem] = []
    var deadlineDate: Date = Date().addingTimeInterval(1800)
    var createdAt: Date = Date()
    
    var participantsCount: Int {
        participants.count
    }
    
    var readyCount: Int {
        participants.filter { $0.isReady }.count
    }
    
    var totalFoodSubtotal: Double {
        participants.reduce(0.0) { $0 + $1.totalSpent }
    }
    
    var budgetAmount: Double {
        let cleaned = budgetPerPerson.replacingOccurrences(of: "$", with: "")
        return Double(cleaned) ?? 30.0
    }
}

// MARK: - Group Ordering Active Session Model

struct GroupOrderingSession: Identifiable, Hashable {
    let id: String // equals groupId
    var groupName: String
    var participantName: String
}

// MARK: - Group Order Manager Singleton

final class GroupOrderManager: ObservableObject {
    static let shared = GroupOrderManager()
    
    @Published var activeGroups: [GroupOrderItem] = []
    @Published var currentSession: GroupOrderingSession? = nil
    
    func createGroup(
        name: String,
        hostName: String,
        budget: String,
        duration: String,
        fulfillmentType: String = "Pickup",
        location: String = "Capitol Hill",
        timeText: String = "Tue, Nov 17, 9:15 PM PST"
    ) -> GroupOrderItem {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalName = trimmedName.isEmpty ? "Pizza Zombies" : trimmedName
        let trimmedHost = hostName.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalHost = trimmedHost.isEmpty ? "raj" : trimmedHost
        let code = String(Int.random(in: 1000...9999))
        let link = "https://modpizza.com/group/join?id=MOD-GRP-\(code)"
        
        let durationMinutes: TimeInterval = {
            if duration.contains("15") { return 15 * 60 }
            if duration.contains("45") { return 45 * 60 }
            if duration.contains("1 hour") { return 60 * 60 }
            if duration.contains("2 hours") { return 120 * 60 }
            return 30 * 60
        }()
        
        let newGroup = GroupOrderItem(
            id: UUID().uuidString,
            name: finalName,
            hostName: finalHost,
            budgetPerPerson: budget,
            selectionsCloseIn: duration,
            fulfillmentType: fulfillmentType,
            locationName: location,
            pickupTimeText: timeText,
            shareLink: link,
            isClosed: false,
            participants: [
                GroupParticipantItem(
                    id: UUID().uuidString,
                    name: finalHost,
                    isHost: true,
                    isReady: false,
                    items: []
                )
            ],
            deadlineDate: Date().addingTimeInterval(durationMinutes),
            createdAt: Date()
        )
        activeGroups.insert(newGroup, at: 0)
        return newGroup
    }
    
    func addParticipant(groupId: String, name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if let idx = activeGroups.firstIndex(where: { $0.id == groupId }) {
            guard !activeGroups[idx].participants.contains(where: { $0.name.lowercased() == trimmed.lowercased() }) else { return }
            let p = GroupParticipantItem(
                id: UUID().uuidString,
                name: trimmed,
                isHost: false,
                isReady: false,
                items: []
            )
            activeGroups[idx].participants.append(p)
        }
    }
    
    func toggleReady(groupId: String, participantName: String) {
        if let gIdx = activeGroups.firstIndex(where: { $0.id == groupId }) {
            if let pIdx = activeGroups[gIdx].participants.firstIndex(where: { $0.name.lowercased() == participantName.lowercased() }) {
                activeGroups[gIdx].participants[pIdx].isReady.toggle()
            }
        }
    }
    
    func addFoodItem(groupId: String, participantName: String, title: String, price: Double, customizations: String? = nil) {
        if let gIdx = activeGroups.firstIndex(where: { $0.id == groupId }) {
            if let pIdx = activeGroups[gIdx].participants.firstIndex(where: { $0.name.lowercased() == participantName.lowercased() }) {
                let item = GroupFoodItem(
                    id: UUID().uuidString,
                    title: title,
                    price: price,
                    customizations: customizations
                )
                activeGroups[gIdx].participants[pIdx].items.append(item)
            }
        }
    }
    
    func addFoodItemToCurrentSession(title: String, price: Double, customizations: String? = nil) {
        guard let session = currentSession else { return }
        addFoodItem(groupId: session.id, participantName: session.participantName, title: title, price: price, customizations: customizations)
    }
    
    func add15Minutes(groupId: String) {
        if let idx = activeGroups.firstIndex(where: { $0.id == groupId }) {
            activeGroups[idx].deadlineDate = activeGroups[idx].deadlineDate.addingTimeInterval(15 * 60)
        }
    }
    
    func closeGroup(id: String) {
        if let idx = activeGroups.firstIndex(where: { $0.id == id }) {
            activeGroups[idx].isClosed = true
        }
        if currentSession?.id == id || activeGroups.isEmpty {
            currentSession = nil
        }
    }
    
    func cancelGroup(id: String) {
        activeGroups.removeAll(where: { $0.id == id })
        if currentSession?.id == id || activeGroups.isEmpty {
            currentSession = nil
        }
    }
    
    func removeGroup(id: String) {
        activeGroups.removeAll(where: { $0.id == id })
        if currentSession?.id == id || activeGroups.isEmpty {
            currentSession = nil
        }
    }
    
    func resetToDefaults() {
        activeGroups.removeAll()
        currentSession = nil
    }
}

// MARK: - GroupDealView

struct GroupDealView: View {
    
    // MARK: - Configuration & Callbacks
    
    var showHeader: Bool = true
    var onBack: (() -> Void)? = nil
    var onNavigateToMenu: (() -> Void)? = nil
    var onCartTap: (() -> Void)? = nil
    var onStarTap: (() -> Void)? = nil
    
    // MARK: - Observed State
    
    @ObservedObject private var groupManager = GroupOrderManager.shared
    
    // Active Customization View (Snapshot 1)
    @State private var activeCustomizationGroup: GroupOrderItem? = nil
    
    // MARK: - Form State (Matching Snapshot media_1794984104027_e93cc68b.png)
    
    @State private var groupName: String = ""
    @State private var hostName: String = "raj"
    @State private var selectedBudget: String = "$20"
    @State private var selectedDuration: String = "30 minutes"
    
    // Dropdown / Picker Options
    private let budgetOptions: [String] = ["$15", "$20", "$25", "$30", "$40", "No limit"]
    private let durationOptions: [String] = ["15 minutes", "30 minutes", "45 minutes", "1 hour", "2 hours", "End of day"]
    
    // Alert & Share State
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    @State private var showShareSheet: Bool = false
    @State private var shareSheetURL: String = ""
    
    // MARK: - Body
    
    var body: some View {
        if let currentGroup = activeCustomizationGroup {
            GroupDealCustomizationView(
                group: currentGroup,
                onBack: {
                    activeCustomizationGroup = nil
                },
                onNavigateToMenu: {
                    activeCustomizationGroup = nil
                    if let onNavigateToMenu = onNavigateToMenu {
                        onNavigateToMenu()
                    } else if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                              let rootNav = windowScene.windows.first?.rootViewController as? UINavigationController,
                              let tabVC = rootNav.viewControllers.first as? UITabBarController {
                        tabVC.selectedIndex = 1
                    }
                },
                onCartTap: onCartTap,
                onStarTap: onStarTap
            )
        } else if showHeader {
            ZStack {
                Color("app_background")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top Custom Navigation Bar
                    customNavigationBar
                    
                    // Scrollable Main Content
                    ScrollView(showsIndicators: false) {
                        contentStack
                            .padding(.horizontal, 16)
                            .padding(.top, 10)
                            .padding(.bottom, 36)
                    }
                }
            }
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .sheet(isPresented: $showShareSheet) {
                GroupShareActivityView(activityItems: [URL(string: shareSheetURL) ?? shareSheetURL])
            }
        } else {
            contentStack
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text(alertTitle),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
                .sheet(isPresented: $showShareSheet) {
                    GroupShareActivityView(activityItems: [URL(string: shareSheetURL) ?? shareSheetURL])
                }
        }
    }
    
    // MARK: - Content Stack
    
    private var contentStack: some View {
        VStack(alignment: .leading, spacing: 18) {
            // 1. Header Section
            headerSection
            
            // 2. Groups Section: Shows Active Groups or Empty State Card (Snapshot)
            if groupManager.activeGroups.isEmpty {
                emptyGroupOrdersCard
            } else {
                activeGroupsSection
            }
            
            // 3. "NEW GROUP ORDER" Form Card (Snapshot)
            newGroupOrderCard
        }
    }
    
    // MARK: - 0. Custom Top Navigation Bar (Snapshot media_1794984104027_e93cc68b.png)
    
    private var customNavigationBar: some View {
        HStack(alignment: .center) {
            // Left: Back Button
            Button(action: {
                if let onBack = onBack {
                    onBack()
                } else if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                          let rootNav = windowScene.windows.first?.rootViewController as? UINavigationController {
                    rootNav.popViewController(animated: true)
                }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 15, weight: .bold))
                    
                    Text("Back")
                        .font(.barlowSemiBold(size: 16))
                }
                .foregroundColor(Color("Button_red"))
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            // Center: Screen Title
            Text("Group orders")
                .font(.barlowBold(size: 17))
                .foregroundColor(Color("app_black"))
            
            Spacer()
            
            // Right: Star & Cart Actions
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
                        alertTitle = "Your Cart"
                        alertMessage = "Cart is currently empty."
                        showAlert = true
                    }
                }) {
                    Image(systemName: "cart")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(Color("Button_red"))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 12)
        .background(Color("app_background"))
    }
    
    // MARK: - 1. Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("GROUP ORDERS")
                .font(.oswaldBold(size: 32))
                .tracking(0.8)
                .foregroundColor(Color("app_black"))
            
            Text("One host pays. Everyone picks their own food. Tax, delivery and tip are applied once.")
                .font(.barlowRegular(size: 14.5))
                .foregroundColor(Color("text_gary"))
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(2)
        }
        .padding(.top, 4)
    }
    
    // MARK: - 2. "NO GROUP ORDERS YET" Empty State Card (Snapshot)
    
    private var emptyGroupOrdersCard: some View {
        VStack(spacing: 14) {
            // Soft Pink Circle Badge with Group Icon
            ZStack {
                Circle()
                    .fill(Color(red: 0xF9 / 255.0, green: 0xEE / 255.0, blue: 0xEE / 255.0))
                    .frame(width: 66, height: 66)
                
                Image(systemName: "person.2")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(Color("Button_red"))
            }
            .padding(.top, 4)
            
            // Title
            Text("NO GROUP ORDERS YET")
                .font(.oswaldBold(size: 19))
                .tracking(0.6)
                .foregroundColor(Color("app_black"))
            
            // Subtitle
            Text("Create one, share the link, and let everyone add their own food.")
                .font(.barlowRegular(size: 13.5))
                .foregroundColor(Color("text_gary"))
                .multilineTextAlignment(.center)
                .lineSpacing(2)
                .padding(.horizontal, 16)
                .padding(.bottom, 6)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(
                    style: StrokeStyle(lineWidth: 1.2, dash: [4, 4])
                )
                .foregroundColor(Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0))
        )
    }
    
    // MARK: - 2b. Active Groups Section (When Groups Exist)
    
    private var activeGroupsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ACTIVE GROUP ORDERS (\(groupManager.activeGroups.count))")
                .font(.oswaldBold(size: 14))
                .tracking(0.6)
                .foregroundColor(Color("app_black"))
            
            ForEach(groupManager.activeGroups) { group in
                activeGroupCard(group: group)
            }
        }
    }
    
    private func activeGroupCard(group: GroupOrderItem) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header Row: Group Name & Status Badge
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(group.name.uppercased())
                        .font(.oswaldBold(size: 18))
                        .tracking(0.4)
                        .foregroundColor(Color("app_black"))
                    
                    Text("Host: \(group.hostName) · \(group.participantsCount) participant")
                        .font(.barlowRegular(size: 13))
                        .foregroundColor(Color("text_gary"))
                }
                
                Spacer()
                
                // Status Badge
                Text(group.isClosed ? "CLOSED" : "OPEN")
                    .font(.oswaldBold(size: 11))
                    .tracking(0.6)
                    .foregroundColor(group.isClosed ? Color("text_gary") : .white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(group.isClosed ? Color(red: 0xEE / 255.0, green: 0xEE / 255.0, blue: 0xEE / 255.0) : Color(red: 0x3E / 255.0, green: 0x76 / 255.0, blue: 0x3B / 255.0))
                    )
            }
            
            Divider()
                .background(Color(red: 0xF0 / 255.0, green: 0xEB / 255.0, blue: 0xE1 / 255.0))
            
            // Meta Info: Budget & Window
            HStack(spacing: 16) {
                HStack(spacing: 5) {
                    Image(systemName: "dollarsign.circle")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color("text_gary"))
                    
                    Text("Budget: \(group.budgetPerPerson)/person")
                        .font(.barlowMedium(size: 12.5))
                        .foregroundColor(Color("app_black"))
                }
                
                HStack(spacing: 5) {
                    Image(systemName: "clock")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color("text_gary"))
                    
                    Text("Closes in \(group.selectionsCloseIn)")
                        .font(.barlowMedium(size: 12.5))
                        .foregroundColor(Color("app_black"))
                }
            }
            
            // Location Setup Note
            HStack(spacing: 6) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 13))
                    .foregroundColor(Color("Button_red"))
                
                Text("\(group.fulfillmentType) from \(group.locationName)")
                    .font(.barlowRegular(size: 12.5))
                    .foregroundColor(Color("text_gary"))
            }
            
            // Action Buttons: Share Invite & Cancel
            HStack(spacing: 10) {
                Button(action: {
                    UIPasteboard.general.string = group.shareLink
                    shareSheetURL = group.shareLink
                    showShareSheet = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 12, weight: .bold))
                        
                        Text("SHARE INVITE")
                            .font(.oswaldMedium(size: 13))
                            .tracking(0.6)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .frame(height: 36)
                    .background(
                        Capsule()
                            .fill(Color("Button_red"))
                            .shadow(color: Color("Button_red").opacity(0.3), radius: 4, x: 0, y: 2)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    UIPasteboard.general.string = group.shareLink
                    alertTitle = "Link Copied"
                    alertMessage = "Group invite link copied to clipboard:\n\(group.shareLink)"
                    showAlert = true
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 12, weight: .medium))
                        
                        Text("COPY LINK")
                            .font(.oswaldMedium(size: 13))
                            .tracking(0.6)
                    }
                    .foregroundColor(Color("app_black"))
                    .padding(.horizontal, 14)
                    .frame(height: 36)
                    .background(
                        Capsule()
                            .stroke(Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0), lineWidth: 1.2)
                            .background(Capsule().fill(Color.white))
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        groupManager.removeGroup(id: group.id)
                    }
                }) {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .foregroundColor(Color("text_gary"))
                        .padding(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.top, 4)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.2)
                )
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            activeCustomizationGroup = group
        }
    }
    
    // MARK: - 3. "NEW GROUP ORDER" Form Card (Snapshot)
    
    private var newGroupOrderCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Card Title Row
            HStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color("Button_red"))
                
                Text("NEW GROUP ORDER")
                    .font(.oswaldBold(size: 17))
                    .tracking(0.6)
                    .foregroundColor(Color("app_black"))
            }
            
            // Field 1: Group name
            VStack(alignment: .leading, spacing: 6) {
                Text("Group name")
                    .font(.barlowBold(size: 13.5))
                    .foregroundColor(Color("app_black"))
                
                TextField("Friday team lunch", text: $groupName)
                    .font(.barlowMedium(size: 15))
                    .foregroundColor(Color("app_black"))
                    .padding(.horizontal, 14)
                    .frame(height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0), lineWidth: 1.2)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color.white)
                            )
                    )
            }
            
            // Field 2: Your name (host)
            VStack(alignment: .leading, spacing: 6) {
                Text("Your name (host)")
                    .font(.barlowBold(size: 13.5))
                    .foregroundColor(Color("app_black"))
                
                TextField("raj", text: $hostName)
                    .font(.barlowMedium(size: 15))
                    .foregroundColor(Color("app_black"))
                    .padding(.horizontal, 14)
                    .frame(height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0), lineWidth: 1.2)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color.white)
                            )
                    )
            }
            
            // Field 3 & 4: Food budget per person & Selections close in (2 columns)
            HStack(spacing: 12) {
                // Left Column: Budget
                VStack(alignment: .leading, spacing: 6) {
                    Text("Food budget per person")
                        .font(.barlowBold(size: 13))
                        .foregroundColor(Color("app_black"))
                        .lineLimit(1)
                    
                    Menu {
                        ForEach(budgetOptions, id: \.self) { option in
                            Button(action: {
                                selectedBudget = option
                            }) {
                                HStack {
                                    Text(option)
                                    if selectedBudget == option {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedBudget)
                                .font(.barlowMedium(size: 15))
                                .foregroundColor(Color("app_black"))
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color("text_gary"))
                        }
                        .padding(.horizontal, 14)
                        .frame(height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0), lineWidth: 1.2)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Color.white)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .frame(maxWidth: .infinity)
                
                // Right Column: Selections close in
                VStack(alignment: .leading, spacing: 6) {
                    Text("Selections close in")
                        .font(.barlowBold(size: 13))
                        .foregroundColor(Color("app_black"))
                        .lineLimit(1)
                    
                    Menu {
                        ForEach(durationOptions, id: \.self) { option in
                            Button(action: {
                                selectedDuration = option
                            }) {
                                HStack {
                                    Text(option)
                                    if selectedDuration == option {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedDuration)
                                .font(.barlowMedium(size: 15))
                                .foregroundColor(Color("app_black"))
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color("text_gary"))
                        }
                        .padding(.horizontal, 14)
                        .frame(height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0), lineWidth: 1.2)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Color.white)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .frame(maxWidth: .infinity)
            }
            
            // Info Callout Box (Snapshot)
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "info.circle")
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 0x4A / 255.0, green: 0x6E / 255.0, blue: 0x75 / 255.0))
                    .padding(.top, 1)
                
                (
                    Text("Uses your current setup: ")
                        .font(.barlowRegular(size: 13))
                        .foregroundColor(Color("app_black"))
                    + Text("Pickup")
                        .font(.barlowBold(size: 13))
                        .foregroundColor(Color("app_black"))
                    + Text(" from ")
                        .font(.barlowRegular(size: 13))
                        .foregroundColor(Color("app_black"))
                    + Text("Capitol Hill")
                        .font(.barlowBold(size: 13))
                        .foregroundColor(Color("app_black"))
                    + Text(", Tue, Nov 17, 9:15 PM PST.")
                        .font(.barlowRegular(size: 13))
                        .foregroundColor(Color("app_black"))
                )
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(2)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(red: 0xF8 / 255.0, green: 0xF6 / 255.0, blue: 0xF0 / 255.0))
            )
            
            // CREATE GROUP Button
            Button(action: {
                handleCreateGroup()
            }) {
                Text("CREATE GROUP")
                    .font(.oswaldBold(size: 16))
                    .tracking(0.8)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        Capsule()
                            .fill(Color("Button_red"))
                            .shadow(color: Color("Button_red").opacity(0.35), radius: 6, x: 0, y: 3)
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 4)
            
            // Bottom Disclaimer Note (Snapshot)
            Text("Invitations, cross-device sync and individual payments aren't implemented. Participants join via same-browser windows.")
                .font(.barlowRegular(size: 11.5))
                .foregroundColor(Color("text_gary"))
                .multilineTextAlignment(.center)
                .lineSpacing(2)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 8)
                .padding(.top, 2)
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
    
    // MARK: - Actions
    
    private func handleCreateGroup() {
        let created = groupManager.createGroup(
            name: groupName,
            hostName: hostName,
            budget: selectedBudget,
            duration: selectedDuration
        )
        
        // Reset name for next creation
        groupName = ""
        
        // Immediately open GroupDealCustomizationView (Snapshot 1)
        activeCustomizationGroup = created
    }
}

// MARK: - Share Sheet Activity View

struct GroupShareActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Previews

struct GroupDealView_Previews: PreviewProvider {
    static var previews: some View {
        GroupDealView(showHeader: true)
    }
}

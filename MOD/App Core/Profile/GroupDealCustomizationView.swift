//
//  GroupDealCustomizationView.swift
//  MOD
//
//  Created by Rajpal singh on 18/11/26.
//

import SwiftUI
import Combine

// MARK: - Typealiases for Flexible Naming

typealias GroupOrderCustomizationView = GroupDealCustomizationView
typealias GroupCustomizationView = GroupDealCustomizationView

// MARK: - GroupDealCustomizationView

struct GroupDealCustomizationView: View {
    
    // MARK: - Parameters & Callbacks
    
    var group: GroupOrderItem
    var onBack: (() -> Void)? = nil
    var onNavigateToMenu: (() -> Void)? = nil
    var onCartTap: (() -> Void)? = nil
    var onStarTap: (() -> Void)? = nil
    
    // MARK: - Observed State
    
    @ObservedObject private var groupManager = GroupOrderManager.shared
    
    // MARK: - Local State
    
    @State private var newParticipantName: String = ""
    @State private var selectedActAsParticipant: String = "raj"
    @State private var remainingTimeFormatted: String = "29m 26s left"
    
    // Alerts
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    @State private var showCancelConfirmation: Bool = false
    @State private var showCheckoutView: Bool = false
    
    // Timer
    @State private var timerSubscription: AnyCancellable? = nil
    
    // Dynamic Group Reference
    private var currentGroup: GroupOrderItem {
        groupManager.activeGroups.first(where: { $0.id == group.id }) ?? group
    }
    
    // Ready for Checkout Condition (Food added + Marked Ready)
    private var isReadyForCheckout: Bool {
        guard currentGroup.totalFoodSubtotal > 0 else { return false }
        let participantsWithFood = currentGroup.participants.filter { !$0.items.isEmpty }
        if participantsWithFood.isEmpty {
            return currentGroup.readyCount > 0 && currentGroup.readyCount == currentGroup.participantsCount
        }
        return participantsWithFood.allSatisfy { $0.isReady }
    }
    
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
                    VStack(alignment: .leading, spacing: 16) {
                        // 1. Header Section (Title, Status, Details)
                        headerSection
                        
                        // 2. Participant Cards
                        participantsSection
                        
                        // 3. Add Participant Input Card
                        addParticipantCard
                        
                        // 4. GROUP SUMMARY Card
                        groupSummaryCard
                        
                        Spacer()
                            .frame(height: 36)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                }
            }
            
            // Cancel Group Bottom Sheet Popup (Snapshot media_1794985738615_608dc5c7.png)
            if showCancelConfirmation {
                cancelGroupBottomSheet
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            selectedActAsParticipant = currentGroup.hostName
            startCountdownTimer()
        }
        .onDisappear {
            timerSubscription?.cancel()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .fullScreenCover(isPresented: $showCheckoutView) {
            CheckoutView(
                onBack: {
                    showCheckoutView = false
                },
                onOrderPlaced: {
                    showCheckoutView = false
                    groupManager.cancelGroup(id: currentGroup.id)
                    onBack?()
                },
                customNavTitle: "Group Checkout - \(currentGroup.name)",
                customHeaderTitle: "Group Checkout - \(currentGroup.name)",
                groupOrder: currentGroup
            )
        }
    }
    
    // MARK: - 0. Custom Top Navigation Bar (Snapshot media_1794984655276_93fc21e2.png)
    
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
            Text("Group order")
                .font(.barlowBold(size: 17))
                .foregroundColor(Color("app_black"))
            
            Spacer()
            
            // Right: Star & Cart
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
                        alertMessage = "Items added to this group will appear here."
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
            // Group Title
            Text(currentGroup.name.uppercased())
                .font(.oswaldBold(size: 32))
                .tracking(0.8)
                .foregroundColor(Color("app_black"))
            
            // Status Pill (Open)
            HStack(spacing: 6) {
                Circle()
                    .fill(Color("Button_red"))
                    .frame(width: 7, height: 7)
                
                Text(currentGroup.isClosed ? "Closed" : "Open")
                    .font(.barlowBold(size: 13))
                    .foregroundColor(Color("Button_red"))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(Color(red: 0xF9 / 255.0, green: 0xEE / 255.0, blue: 0xEE / 255.0))
            )
            
            // Setup Info String
            Text("· \(currentGroup.locationName) · \(currentGroup.fulfillmentType) · \(currentGroup.pickupTimeText)")
                .font(.barlowRegular(size: 13.5))
                .foregroundColor(Color("text_gary"))
                .padding(.top, 2)
        }
        .padding(.top, 2)
    }
    
    // MARK: - 2. Participants Section
    
    private var participantsSection: some View {
        VStack(spacing: 14) {
            ForEach(currentGroup.participants) { participant in
                participantCard(participant: participant)
            }
        }
    }
    
    private func participantCard(participant: GroupParticipantItem) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header Row: Avatar, Name, Host Badge, Budget Subtitle, Status
            HStack(alignment: .top, spacing: 12) {
                // Circle Avatar with initial letter
                ZStack {
                    Circle()
                        .fill(Color(red: 0x8C / 255.0, green: 0x1E / 255.0, blue: 0x2A / 255.0))
                        .frame(width: 44, height: 44)
                    
                    Text(String(participant.name.prefix(1)).uppercased())
                        .font(.oswaldBold(size: 20))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(participant.name.uppercased())
                            .font(.oswaldBold(size: 18))
                            .tracking(0.4)
                            .foregroundColor(Color("app_black"))
                        
                        if participant.isHost {
                            Text("HOST")
                                .font(.oswaldMedium(size: 11))
                                .tracking(0.6)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(
                                    Capsule()
                                        .fill(Color(red: 0x8C / 255.0, green: 0x1E / 255.0, blue: 0x2A / 255.0))
                                )
                        }
                    }
                    
                    Text(String(format: "$%.2f of %@ budget", participant.totalSpent, currentGroup.budgetPerPerson))
                        .font(.barlowRegular(size: 13))
                        .foregroundColor(Color("text_gary"))
                }
                
                Spacer()
                
                // Status (Choosing... or Ready)
                Text(participant.isReady ? "Ready" : "Choosing...")
                    .font(participant.isReady ? .barlowBold(size: 13.5) : .barlowMedium(size: 13.5))
                    .foregroundColor(participant.isReady ? Color(red: 0x3E / 255.0, green: 0x76 / 255.0, blue: 0x3B / 255.0) : Color("text_gary"))
                    .padding(.top, 2)
            }
            
            // Progress Bar Line
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(red: 0xEE / 255.0, green: 0xEE / 255.0, blue: 0xEE / 255.0))
                        .frame(height: 4)
                    
                    let progress = min(CGFloat(participant.totalSpent / max(currentGroup.budgetAmount, 1.0)), 1.0)
                    Capsule()
                        .fill(Color("Button_red"))
                        .frame(width: geo.size.width * progress, height: 4)
                }
            }
            .frame(height: 4)
            
            // Food Items List or Empty Callout
            if participant.items.isEmpty {
                Text("No food added yet.")
                    .font(.barlowRegular(size: 13.5))
                    .foregroundColor(Color("text_gary"))
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(participant.items) { item in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.title)
                                    .font(.barlowSemiBold(size: 14))
                                    .foregroundColor(Color("app_black"))
                                
                                if let custom = item.customizations, !custom.isEmpty {
                                    Text(custom)
                                        .font(.barlowRegular(size: 12))
                                        .foregroundColor(Color("text_gary"))
                                }
                            }
                            
                            Spacer()
                            
                            Text(String(format: "$%.2f", item.price))
                                .font(.barlowBold(size: 14))
                                .foregroundColor(Color("app_black"))
                        }
                    }
                }
            }
            
            // Action Buttons: + ADD FOOD & MARK READY
            HStack(spacing: 12) {
                // + ADD FOOD Button
                Button(action: {
                    groupManager.currentSession = GroupOrderingSession(
                        id: currentGroup.id,
                        groupName: currentGroup.name,
                        participantName: participant.name
                    )
                    if let onNavigateToMenu = onNavigateToMenu {
                        onNavigateToMenu()
                    } else if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                              let rootNav = windowScene.windows.first?.rootViewController as? UINavigationController,
                              let tabVC = rootNav.viewControllers.first as? UITabBarController {
                        tabVC.selectedIndex = 1
                    }
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .bold))
                        
                        Text("ADD FOOD")
                            .font(.oswaldBold(size: 13.5))
                            .tracking(0.6)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .frame(height: 38)
                    .background(
                        Capsule()
                            .fill(Color("Button_red"))
                            .shadow(color: Color("Button_red").opacity(0.3), radius: 4, x: 0, y: 2)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // MARK READY Button
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        groupManager.toggleReady(groupId: currentGroup.id, participantName: participant.name)
                    }
                }) {
                    Text(participant.isReady ? "NOT READY" : "MARK READY")
                        .font(.oswaldBold(size: 13.5))
                        .tracking(0.6)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .frame(height: 38)
                        .background(
                            Capsule()
                                .fill(participant.isReady ? Color(red: 0x3E / 255.0, green: 0x76 / 255.0, blue: 0x3B / 255.0) : Color(red: 0x22 / 255.0, green: 0x22 / 255.0, blue: 0x24 / 255.0))
                        )
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
            }
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
    }
    
    // MARK: - 3. Add Participant Input Card (Snapshot)
    
    private var addParticipantCard: some View {
        HStack(spacing: 10) {
            TextField("Add a participant by name", text: $newParticipantName)
                .font(.barlowMedium(size: 14.5))
                .foregroundColor(Color("app_black"))
                .padding(.horizontal, 14)
                .frame(height: 46)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0), lineWidth: 1.2)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.white)
                        )
                )
            
            Button(action: {
                let trimmed = newParticipantName.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        groupManager.addParticipant(groupId: currentGroup.id, name: trimmed)
                        newParticipantName = ""
                    }
                }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .bold))
                    
                    Text("ADD")
                        .font(.oswaldBold(size: 13.5))
                        .tracking(0.6)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 18)
                .frame(height: 46)
                .background(
                    Capsule()
                        .fill(Color(red: 0x22 / 255.0, green: 0x22 / 255.0, blue: 0x24 / 255.0))
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.2)
                )
                .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
        )
    }
    
    // MARK: - 4. GROUP SUMMARY Card (Snapshot)
    
    private var groupSummaryCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Title
            Text("GROUP SUMMARY")
                .font(.oswaldBold(size: 18))
                .tracking(0.6)
                .foregroundColor(Color("app_black"))
            
            // Row 1: Deadline
            HStack(alignment: .top) {
                Text("Deadline")
                    .font(.barlowRegular(size: 13.5))
                    .foregroundColor(Color("text_gary"))
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(currentGroup.deadlineDate.formatted(date: .abbreviated, time: .shortened) + " PST")
                        .font(.barlowBold(size: 13.5))
                        .foregroundColor(Color("app_black"))
                    
                    Text(remainingTimeFormatted)
                        .font(.barlowBold(size: 13))
                        .foregroundColor(Color("Button_red"))
                }
            }
            
            // Row 2: Budget
            HStack {
                Text("Budget")
                    .font(.barlowRegular(size: 13.5))
                    .foregroundColor(Color("text_gary"))
                
                Spacer()
                
                Text("\(currentGroup.budgetPerPerson) per person")
                    .font(.barlowBold(size: 13.5))
                    .foregroundColor(Color("app_black"))
            }
            
            // Row 3: Food subtotal
            HStack {
                Text("Food subtotal")
                    .font(.barlowRegular(size: 13.5))
                    .foregroundColor(Color("text_gary"))
                
                Spacer()
                
                Text(String(format: "$%.2f", currentGroup.totalFoodSubtotal))
                    .font(.barlowBold(size: 14.5))
                    .foregroundColor(Color("app_black"))
            }
            
            // Row 4: Ready
            HStack {
                Text("Ready")
                    .font(.barlowRegular(size: 13.5))
                    .foregroundColor(Color("text_gary"))
                
                Spacer()
                
                Text("\(currentGroup.readyCount) of \(currentGroup.participantsCount)")
                    .font(.barlowBold(size: 13.5))
                    .foregroundColor(Color("app_black"))
            }
            
            // Row 5: Act as (local demo)
            VStack(alignment: .leading, spacing: 6) {
                Text("Act as (local demo)")
                    .font(.barlowBold(size: 13.5))
                    .foregroundColor(Color("app_black"))
                
                Menu {
                    ForEach(currentGroup.participants) { p in
                        Button(action: {
                            selectedActAsParticipant = p.name
                        }) {
                            HStack {
                                Text(p.name + (p.isHost ? " (Host)" : ""))
                                if selectedActAsParticipant == p.name {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedActAsParticipant)
                            .font(.barlowMedium(size: 15))
                            .foregroundColor(Color("app_black"))
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color("text_gary"))
                    }
                    .padding(.horizontal, 14)
                    .frame(height: 46)
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
            .padding(.top, 4)
            
            // Warning or Status Callout
            if currentGroup.totalFoodSubtotal == 0 {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 13))
                        .foregroundColor(Color(red: 0xB8 / 255.0, green: 0x7A / 255.0, blue: 0x22 / 255.0))
                    
                    Text("No one has added food yet.")
                        .font(.barlowRegular(size: 13))
                        .foregroundColor(Color(red: 0x8C / 255.0, green: 0x5D / 255.0, blue: 0x1A / 255.0))
                }
                .padding(.vertical, 2)
            } else if !isReadyForCheckout {
                HStack(spacing: 8) {
                    Image(systemName: "clock")
                        .font(.system(size: 13))
                        .foregroundColor(Color(red: 0xB8 / 255.0, green: 0x7A / 255.0, blue: 0x22 / 255.0))
                    
                    Text("Food added! Click \"MARK READY\" to activate checkout.")
                        .font(.barlowRegular(size: 13))
                        .foregroundColor(Color(red: 0x8C / 255.0, green: 0x5D / 255.0, blue: 0x1A / 255.0))
                }
                .padding(.vertical, 2)
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 13))
                        .foregroundColor(Color(red: 0x3E / 255.0, green: 0x76 / 255.0, blue: 0x3B / 255.0))
                    
                    Text(String(format: "All participants ready! $%.2f ready for checkout.", currentGroup.totalFoodSubtotal))
                        .font(.barlowRegular(size: 13))
                        .foregroundColor(Color(red: 0x3E / 255.0, green: 0x76 / 255.0, blue: 0x3B / 255.0))
                }
                .padding(.vertical, 2)
            }
            
            // CHECK OUT GROUP Button (Inactive until food added and marked ready)
            Button(action: {
                if isReadyForCheckout {
                    showCheckoutView = true
                } else if currentGroup.totalFoodSubtotal == 0 {
                    alertTitle = "Cart is Empty"
                    alertMessage = "Please add food for at least one participant before checking out."
                    showAlert = true
                } else {
                    alertTitle = "Mark Ready Required"
                    alertMessage = "Participants must click \"MARK READY\" before proceeding to checkout."
                    showAlert = true
                }
            }) {
                Text(String(format: "CHECK OUT GROUP · $%.2f+", currentGroup.totalFoodSubtotal))
                    .font(.oswaldBold(size: 15))
                    .tracking(0.8)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        Capsule()
                            .fill(isReadyForCheckout ? Color("Button_red") : Color(red: 0xC5 / 255.0, green: 0x8B / 255.0, blue: 0x94 / 255.0))
                            .shadow(color: isReadyForCheckout ? Color("Button_red").opacity(0.35) : Color.clear, radius: 6, x: 0, y: 3)
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 4)
            
            // Actions Row: +15 MIN & CANCEL GROUP (Snapshot)
            HStack {
                Button(action: {
                    withAnimation {
                        groupManager.add15Minutes(groupId: currentGroup.id)
                        updateCountdown()
                    }
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: "clock")
                            .font(.system(size: 13, weight: .bold))
                        
                        Text("+15 MIN")
                            .font(.oswaldBold(size: 13.5))
                            .tracking(0.6)
                    }
                    .foregroundColor(Color("app_black"))
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        showCancelConfirmation = true
                    }
                }) {
                    Text("CANCEL GROUP")
                        .font(.oswaldBold(size: 13.5))
                        .tracking(0.6)
                        .foregroundColor(Color("Button_red"))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 4)
            .padding(.top, 2)
            
            // Bottom Disclaimer Note (Snapshot)
            Text("Tax, delivery and tip are applied once at host checkout. One offer or reward for the whole order. Points go to the paying member host.")
                .font(.barlowRegular(size: 11.5))
                .foregroundColor(Color("text_gary"))
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
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
    
    // MARK: - Cancel Group Bottom Sheet Popup (Snapshot media_1794985738615_608dc5c7.png)
    
    private var cancelGroupBottomSheet: some View {
        ZStack(alignment: .bottom) {
            // Dimmed semi-transparent backdrop
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .transition(.opacity)
                .onTapGesture {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        showCancelConfirmation = false
                    }
                }
            
            // Slide-up bottom sheet card
            VStack(alignment: .leading, spacing: 0) {
                // Top grab handle
                HStack {
                    Spacer()
                    Capsule()
                        .fill(Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0))
                        .frame(width: 44, height: 5)
                    Spacer()
                }
                .padding(.top, 12)
                .padding(.bottom, 18)
                
                // Header row: Title & Close Circular Button
                HStack(alignment: .center) {
                    Text("CANCEL THIS GROUP?")
                        .font(.oswaldBold(size: 22))
                        .tracking(0.6)
                        .foregroundColor(Color("app_black"))
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            showCancelConfirmation = false
                        }
                    }) {
                        ZStack {
                            Circle()
                                .stroke(Color(red: 0x8C / 255.0, green: 0x1E / 255.0, blue: 0x2A / 255.0), lineWidth: 2)
                                .frame(width: 42, height: 42)
                                .background(Circle().fill(Color.white))
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color("app_black"))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 22)
                
                // Description Text
                Text("Everyone’s selections will be discarded. This can’t be undone.")
                    .font(.barlowRegular(size: 15.5))
                    .foregroundColor(Color("app_black"))
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 22)
                    .padding(.top, 14)
                    .padding(.bottom, 28)
                
                // Bottom Action Buttons: KEEP GROUP & CANCEL GROUP
                HStack(spacing: 16) {
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            showCancelConfirmation = false
                        }
                    }) {
                        Text("KEEP GROUP")
                            .font(.oswaldBold(size: 15))
                            .tracking(0.8)
                            .foregroundColor(Color("app_black"))
                            .padding(.vertical, 12)
                            .padding(.horizontal, 10)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            showCancelConfirmation = false
                            groupManager.cancelGroup(id: currentGroup.id)
                            onBack?()
                        }
                    }) {
                        Text("CANCEL GROUP")
                            .font(.oswaldBold(size: 15))
                            .tracking(0.8)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .frame(height: 48)
                            .background(
                                Capsule()
                                    .fill(Color(red: 0x8C / 255.0, green: 0x1E / 255.0, blue: 0x2A / 255.0))
                                    .shadow(color: Color("Button_red").opacity(0.3), radius: 6, x: 0, y: 3)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 28)
            }
            .background(
                RoundedCornerShape(radius: 26, corners: [.topLeft, .topRight])
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.12), radius: 16, x: 0, y: -4)
            )
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Countdown Timer Logic
    
    private func startCountdownTimer() {
        updateCountdown()
        timerSubscription = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                updateCountdown()
            }
    }
    
    private func updateCountdown() {
        let diff = currentGroup.deadlineDate.timeIntervalSince(Date())
        if diff > 0 {
            let minutes = Int(diff) / 60
            let seconds = Int(diff) % 60
            remainingTimeFormatted = "\(minutes)m \(seconds)s left"
        } else {
            remainingTimeFormatted = "Closed"
        }
    }
}

// MARK: - Rounded Corner Shape

struct RoundedCornerShape: Shape {
    var radius: CGFloat = 26
    var corners: UIRectCorner = [.topLeft, .topRight]

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Previews

struct GroupDealCustomizationView_Previews: PreviewProvider {
    static var previews: some View {
        GroupDealCustomizationView(
            group: GroupOrderItem(
                id: "test",
                name: "Pizza Zombies",
                hostName: "raj",
                budgetPerPerson: "$30.00",
                selectionsCloseIn: "30 minutes",
                fulfillmentType: "Pickup",
                locationName: "Capitol Hill",
                pickupTimeText: "Tue, Nov 17, 9:15 PM PST",
                shareLink: "https://modpizza.com/group/join?id=MOD-GRP-8921",
                isClosed: false,
                participants: [
                    GroupParticipantItem(
                        id: "p1",
                        name: "raj",
                        isHost: true,
                        isReady: false,
                        items: []
                    )
                ],
                deadlineDate: Date().addingTimeInterval(1766),
                createdAt: Date()
            )
        )
    }
}

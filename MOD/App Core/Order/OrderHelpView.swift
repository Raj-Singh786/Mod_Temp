//
//  OrderHelpView.swift
//  MOD
//
//  Created by Rajpal singh on 17/11/26.
//

import SwiftUI

// MARK: - Help Issue Option Enum

enum HelpIssueType: String, CaseIterable, Identifiable {
    case lateDelivery = "Late delivery"
    case missingItems = "Missing or incorrect items"
    case question = "Question about my order"
    case refund = "Request a refund"
    
    var id: String { rawValue }
}

// MARK: - Support Request Model

struct SupportRequestItem: Identifiable, Hashable {
    let id: String = UUID().uuidString
    let issue: HelpIssueType
    let details: String
    let timestamp: String
    let status: String = "Under review"
}

// MARK: - OrderHelpView

struct OrderHelpView: View {
    
    // MARK: - Configuration
    
    var orderId: String = "MOD-604894"
    var storeName: String = "Capitol Hill"
    var statusText: String = "Scheduled"
    var isOrderCompleted: Bool = false
    
    var onBack: (() -> Void)? = nil
    var onStarTap: (() -> Void)? = nil
    var onCartTap: (() -> Void)? = nil
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - State
    
    @State private var selectedIssue: HelpIssueType = .lateDelivery
    @State private var detailsText: String = ""
    @State private var submittedRequests: [SupportRequestItem] = []
    @State private var ratingStars: Int = 0
    @State private var showLiveChatSheet: Bool = false
    @State private var showCallSupportAlert: Bool = false
    @State private var toastMessage: String? = nil
    
    // MARK: - Initializers
    
    init(
        orderId: String = "MOD-604894",
        storeName: String = "Capitol Hill",
        statusText: String = "Scheduled",
        isOrderCompleted: Bool = false,
        onBack: (() -> Void)? = nil,
        onStarTap: (() -> Void)? = nil,
        onCartTap: (() -> Void)? = nil
    ) {
        self.orderId = orderId
        self.storeName = storeName
        self.statusText = statusText
        self.isOrderCompleted = isOrderCompleted
        self.onBack = onBack
        self.onStarTap = onStarTap
        self.onCartTap = onCartTap
    }
    
    init(
        order: OrderHistoryItem,
        onBack: (() -> Void)? = nil,
        onStarTap: (() -> Void)? = nil,
        onCartTap: (() -> Void)? = nil
    ) {
        self.orderId = order.id
        self.storeName = order.storeName
        self.statusText = order.status.rawValue
        self.isOrderCompleted = !order.status.isInProgress
        self.onBack = onBack
        self.onStarTap = onStarTap
        self.onCartTap = onCartTap
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
                    VStack(alignment: .leading, spacing: 18) {
                        // Header Titles
                        headerSection
                        
                        // Card 1: What Went Wrong?
                        whatWentWrongCard
                        
                        // Card 2: Rate This Order
                        rateThisOrderCard
                        
                        // Card 3: Requests
                        requestsCard
                        
                        // Card 4: Live Help
                        liveHelpCard
                        
                        Spacer()
                            .frame(height: 36)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
            
            // Toast Notification Overlay
            if let toast = toastMessage {
                VStack {
                    Spacer()
                    Text(toast)
                        .font(.barlowMedium(size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(Color("app_black").opacity(0.92))
                                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                        )
                        .padding(.bottom, 24)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .animation(.easeInOut(duration: 0.25), value: toastMessage)
            }
        }
        .sheet(isPresented: $showLiveChatSheet) {
            HelpChatView(
                onDismiss: {
                    showLiveChatSheet = false
                }
            )
            .presentationDetents([.fraction(0.85), .large])
            .presentationDragIndicator(.hidden)
        }
        .alert(isPresented: $showCallSupportAlert) {
            Alert(
                title: Text("Call Support"),
                message: Text("Would you like to call MOD Pizza Guest Support at (888) 555-0199?"),
                primaryButton: .default(Text("Call (Sample)")) {
                    showToast("Connecting to MOD Guest Support...")
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    // MARK: - Custom Top Navigation Bar
    
    private var customNavigationBar: some View {
        HStack(alignment: .center) {
            // Left: Red Back Chevron + "Back"
            Button(action: {
                if let onBack = onBack {
                    onBack()
                } else {
                    dismiss()
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
            Text("Help")
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
                
                Button(action: {
                    onCartTap?()
                }) {
                    Image(systemName: "cart")
                        .font(.system(size: 19, weight: .regular))
                        .foregroundColor(Color("Button_red"))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .frame(width: 70, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
        .padding(.bottom, 10)
        .background(Color("app_background"))
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("ORDER HELP")
                .font(.oswaldMedium(size: 32))
                .tracking(0.8)
                .foregroundColor(Color("app_black"))
            
            Text("\(orderId) · \(storeName) · \(statusText)")
                .font(.barlowRegular(size: 14))
                .foregroundColor(Color("text_gary"))
        }
        .padding(.top, 4)
    }
    
    // MARK: - Card 1: What Went Wrong?
    
    private var whatWentWrongCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header Row
            HStack(spacing: 8) {
                Image(systemName: "questionmark.circle")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color("Button_red"))
                
                Text("WHAT WENT WRONG?")
                    .font(.oswaldMedium(size: 16))
                    .tracking(0.6)
                    .foregroundColor(Color("app_black"))
            }
            
            // Radio Buttons
            VStack(spacing: 10) {
                ForEach(HelpIssueType.allCases) { issue in
                    issueRadioRow(issue)
                }
            }
            
            // Textarea: Tell us more
            VStack(alignment: .leading, spacing: 6) {
                Text("Tell us more")
                    .font(.barlowBold(size: 13))
                    .foregroundColor(Color("app_black"))
                
                ZStack(alignment: .topLeading) {
                    if detailsText.isEmpty {
                        Text("Share any details that help us make it right.")
                            .font(.barlowRegular(size: 14))
                            .foregroundColor(Color("text_gary").opacity(0.6))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                    }
                    
                    TextEditor(text: $detailsText)
                        .font(.barlowRegular(size: 14))
                        .foregroundColor(Color("app_black"))
                        .scrollContentBackground(.hidden)
                        .padding(6)
                        .frame(minHeight: 90)
                }
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0), lineWidth: 1.2)
                        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.white))
                )
            }
            .padding(.top, 4)
            
            // SEND TO SUPPORT Button
            Button(action: {
                handleSendToSupport()
            }) {
                Text("SEND TO SUPPORT")
                    .font(.oswaldMedium(size: 14))
                    .tracking(0.8)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .frame(height: 44)
                    .background(
                        Capsule()
                            .fill(Color("Button_red"))
                            .shadow(color: Color("Button_red").opacity(0.3), radius: 4, x: 0, y: 2)
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 2)
            
            // Footnote
            Text("Saved on this browser. A refund request goes to review — it isn't an instant cancellation. Partial refunds aren't supported in this prototype.")
                .font(.barlowRegular(size: 11.5))
                .foregroundColor(Color("text_gary"))
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
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
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        )
    }
    
    private func issueRadioRow(_ issue: HelpIssueType) -> some View {
        let isSelected = selectedIssue == issue
        
        return Button(action: {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                selectedIssue = issue
            }
        }) {
            HStack(spacing: 12) {
                // Radio Circle
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color("Button_red") : Color(red: 0xBE / 255.0, green: 0xB8 / 255.0, blue: 0xAE / 255.0), lineWidth: 1.5)
                        .frame(width: 18, height: 18)
                    
                    if isSelected {
                        Circle()
                            .fill(Color("Button_red"))
                            .frame(width: 8, height: 8)
                    }
                }
                
                Text(issue.rawValue)
                    .font(isSelected ? .barlowMedium(size: 14) : .barlowRegular(size: 14))
                    .foregroundColor(Color("app_black"))
                
                Spacer()
            }
            .padding(.horizontal, 14)
            .frame(height: 46)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? Color(red: 0xFD / 255.0, green: 0xF2 / 255.0, blue: 0xF4 / 255.0) : Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isSelected ? Color("Button_red") : Color(red: 0xE8 / 255.0, green: 0xE2 / 255.0, blue: 0xD8 / 255.0), lineWidth: 1.2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Card 2: Rate This Order
    
    private var rateThisOrderCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "star")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color("Button_red"))
                
                Text("RATE THIS ORDER")
                    .font(.oswaldMedium(size: 16))
                    .tracking(0.6)
                    .foregroundColor(Color("app_black"))
            }
            
            if isOrderCompleted {
                VStack(alignment: .leading, spacing: 8) {
                    Text("How was your experience with this order?")
                        .font(.barlowRegular(size: 13))
                        .foregroundColor(Color("text_gary"))
                    
                    HStack(spacing: 8) {
                        ForEach(1...5, id: \.self) { star in
                            Button(action: {
                                ratingStars = star
                                showToast("Thank you for rating \(star) stars!")
                            }) {
                                Image(systemName: star <= ratingStars ? "star.fill" : "star")
                                    .font(.system(size: 22))
                                    .foregroundColor(star <= ratingStars ? Color(red: 0xDE / 255.0, green: 0xB1 / 255.0, blue: 0x58 / 255.0) : Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.top, 2)
                }
            } else {
                Text("You can rate this order once it's completed.")
                    .font(.barlowRegular(size: 13))
                    .foregroundColor(Color("text_gary"))
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.2)
                )
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        )
    }
    
    // MARK: - Card 3: Requests
    
    private var requestsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("REQUESTS")
                .font(.oswaldMedium(size: 16))
                .tracking(0.6)
                .foregroundColor(Color("app_black"))
            
            if submittedRequests.isEmpty {
                Text("No requests yet.")
                    .font(.barlowRegular(size: 13))
                    .foregroundColor(Color("text_gary"))
            } else {
                VStack(spacing: 10) {
                    ForEach(submittedRequests) { request in
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(request.issue.rawValue)
                                    .font(.barlowBold(size: 14))
                                    .foregroundColor(Color("app_black"))
                                
                                if !request.details.isEmpty {
                                    Text(request.details)
                                        .font(.barlowRegular(size: 12.5))
                                        .foregroundColor(Color("text_gary"))
                                        .lineLimit(2)
                                }
                                
                                Text(request.timestamp)
                                    .font(.barlowRegular(size: 11))
                                    .foregroundColor(Color("text_gary"))
                            }
                            
                            Spacer()
                            
                            Text(request.status)
                                .font(.barlowBold(size: 11))
                                .foregroundColor(Color(red: 0x8C / 255.0, green: 0x58 / 255.0, blue: 0x22 / 255.0))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(
                                    Capsule()
                                        .fill(Color(red: 0xF7 / 255.0, green: 0xEE / 255.0, blue: 0xDD / 255.0))
                                )
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 0xFA / 255.0, green: 0xF7 / 255.0, blue: 0xF2 / 255.0))
                        )
                    }
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.2)
                )
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        )
    }
    
    // MARK: - Card 4: Live Help
    
    private var liveHelpCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header Row
            HStack(spacing: 8) {
                Image(systemName: "bubble.left")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color("Button_red"))
                
                Text("LIVE HELP")
                    .font(.oswaldMedium(size: 16))
                    .tracking(0.6)
                    .foregroundColor(Color("app_black"))
            }
            
            // Subtitle
            Text("Chat with simulated delivery support.")
                .font(.barlowRegular(size: 13))
                .foregroundColor(Color("text_gary"))
            
            // OPEN CHAT Button
            Button(action: {
                showLiveChatSheet = true
            }) {
                Text("OPEN CHAT")
                    .font(.oswaldMedium(size: 14))
                    .tracking(0.8)
                    .foregroundColor(Color("app_black"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background(
                        Capsule()
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0), lineWidth: 1.2)
                    )
            }
            .buttonStyle(PlainButtonStyle())
            
            // CALL SUPPORT (SAMPLE) Button
            Button(action: {
                showCallSupportAlert = true
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "phone")
                        .font(.system(size: 13, weight: .medium))
                    
                    Text("CALL SUPPORT (SAMPLE)")
                        .font(.oswaldMedium(size: 13))
                        .tracking(0.8)
                }
                .foregroundColor(Color("app_black"))
                .frame(maxWidth: .infinity)
                .padding(.top, 4)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.2)
                )
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        )
    }
    
    // MARK: - Actions
    
    private func handleSendToSupport() {
        let details = detailsText.trimmingCharacters(in: .whitespacesAndNewlines)
        let newRequest = SupportRequestItem(
            issue: selectedIssue,
            details: details,
            timestamp: "Just now"
        )
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            submittedRequests.insert(newRequest, at: 0)
            detailsText = ""
        }
        showToast("Support request for '\(selectedIssue.rawValue)' submitted!")
    }
    
    private func showToast(_ message: String) {
        toastMessage = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            if toastMessage == message {
                toastMessage = nil
            }
        }
    }
}

// MARK: - SwiftUI Preview

struct OrderHelpView_Previews: PreviewProvider {
    static var previews: some View {
        OrderHelpView()
    }
}

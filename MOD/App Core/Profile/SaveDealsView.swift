//
//  SaveDealsView.swift
//  MOD
//
//  Created by Rajpal singh on 18/11/26.
//

import SwiftUI
import Combine

// MARK: - Typealiases for Flexible Naming

typealias SavedDealsView = SaveDealsView
typealias OffersView = SaveDealsView

// MARK: - Offer Model

struct DealOfferItem: Identifiable, Hashable {
    let id: String
    var stubTop: String
    var stubMiddle: String?
    var stubBottom: String
    var title: String
    var description: String
    var code: String
    var secondaryBadgeText: String?
    var isMemberBadge: Bool = false
    var minimumSpend: String?
    var requirementNote: String
    var isPickupOnly: Bool = false
    var isSaved: Bool = false
}

// MARK: - Filter Enum

enum DealsFilterType: String, CaseIterable {
    case allOffers = "All offers"
    case pickup = "Pickup"
    case saved = "Saved"
}

// MARK: - Deals Manager Singleton

final class DealsManager: ObservableObject {
    static let shared = DealsManager()
    
    @Published var offers: [DealOfferItem] = [
        DealOfferItem(
            id: "deal-1",
            stubTop: "FREE",
            stubMiddle: nil,
            stubBottom: "DESSERT",
            title: "FREE DESSERT WITH ANY PIZZA",
            description: "Buy any pizza and get one dessert on us (up to $5.00).",
            code: "SWEETDEAL",
            secondaryBadgeText: nil,
            isMemberBadge: false,
            minimumSpend: nil,
            requirementNote: "Add a pizza and a dessert to use this deal",
            isPickupOnly: false,
            isSaved: false
        ),
        DealOfferItem(
            id: "deal-2",
            stubTop: "2 for",
            stubMiddle: "$25",
            stubBottom: "PIZZAS",
            title: "ANY 2 PIZZAS FOR $25",
            description: "Two of any pizza, any size, for $25 total.",
            code: "2PIZZA25",
            secondaryBadgeText: nil,
            isMemberBadge: false,
            minimumSpend: nil,
            requirementNote: "Add 2 more pizzas to use this deal",
            isPickupOnly: false,
            isSaved: false
        ),
        DealOfferItem(
            id: "deal-3",
            stubTop: "$5",
            stubMiddle: nil,
            stubBottom: "OFF",
            title: "$5 OFF PICKUP ORDERS",
            description: "Grab it yourself and save $5 on $20+.",
            code: "PICKUP5",
            secondaryBadgeText: "Pickup only",
            isMemberBadge: false,
            minimumSpend: "Min $20.00",
            requirementNote: "Add $20.00 more food to reach the $20.00 minimum",
            isPickupOnly: true,
            isSaved: false
        ),
        DealOfferItem(
            id: "deal-4",
            stubTop: "$10",
            stubMiddle: nil,
            stubBottom: "OFF",
            title: "$10 OFF — MEMBERS ONLY",
            description: "A thank-you coupon assigned to your rewards account.",
            code: "MEMBER10",
            secondaryBadgeText: "Member",
            isMemberBadge: true,
            minimumSpend: "Min $30.00",
            requirementNote: "Add $30.00 more food to reach the $30.00 minimum",
            isPickupOnly: false,
            isSaved: true
        ),
        DealOfferItem(
            id: "deal-5",
            stubTop: "$3",
            stubMiddle: nil,
            stubBottom: "OFF",
            title: "$3 OFF SALAD WITH PIZZA",
            description: "Add any fresh side salad to your pizza for $3 off.",
            code: "GREENS3",
            secondaryBadgeText: nil,
            isMemberBadge: false,
            minimumSpend: nil,
            requirementNote: "Add a salad and a pizza to use this deal",
            isPickupOnly: false,
            isSaved: false
        ),
        DealOfferItem(
            id: "deal-6",
            stubTop: "FREE",
            stubMiddle: nil,
            stubBottom: "DELIVERY",
            title: "FREE DELIVERY ON $25+",
            description: "Delivery fee waived for orders $25 and above.",
            code: "MODDELIV",
            secondaryBadgeText: nil,
            isMemberBadge: false,
            minimumSpend: "Min $25.00",
            requirementNote: "Select delivery at checkout",
            isPickupOnly: false,
            isSaved: false
        ),
        DealOfferItem(
            id: "deal-7",
            stubTop: "BOGO",
            stubMiddle: "50%",
            stubBottom: "OFF",
            title: "BOGO 50% OFF MOD PIZZA",
            description: "Buy one 11\" pizza, get a second 50% off.",
            code: "BOGO50",
            secondaryBadgeText: nil,
            isMemberBadge: false,
            minimumSpend: nil,
            requirementNote: "Add two 11\" pizzas to use this deal",
            isPickupOnly: false,
            isSaved: false
        )
    ]
    
    var savedDealsCount: Int {
        offers.filter { $0.isSaved }.count
    }
    
    var pickupDealsCount: Int {
        offers.filter { $0.isPickupOnly }.count
    }
    
    func toggleSaved(id: String) {
        if let idx = offers.firstIndex(where: { $0.id == id }) {
            offers[idx].isSaved.toggle()
        }
    }
    
    func resetToDefaults() {
        for idx in offers.indices {
            offers[idx].isSaved = (offers[idx].id == "deal-4")
        }
    }
}

// MARK: - SaveDealsView

struct SaveDealsView: View {
    
    // MARK: - Configuration & Callbacks
    
    var showHeader: Bool = true
    var initialFilter: DealsFilterType = .allOffers
    var onBack: (() -> Void)? = nil
    var onCartTap: (() -> Void)? = nil
    var onStarTap: (() -> Void)? = nil
    var onApplyDeal: ((DealOfferItem) -> Void)? = nil
    
    // MARK: - Observed State
    
    @ObservedObject private var dealsManager = DealsManager.shared
    
    // MARK: - Local State
    
    @State private var selectedFilter: DealsFilterType = .allOffers
    
    // Alerts & Terms Modal
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    @State private var selectedTermsOffer: DealOfferItem? = nil
    @State private var showTermsSheet: Bool = false
    
    // MARK: - Filtered Offers
    
    private var filteredOffers: [DealOfferItem] {
        switch selectedFilter {
        case .allOffers:
            return dealsManager.offers
        case .pickup:
            return dealsManager.offers.filter { $0.isPickupOnly }
        case .saved:
            return dealsManager.offers.filter { $0.isSaved }
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        if showHeader {
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
            .onAppear {
                selectedFilter = initialFilter
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .sheet(isPresented: $showTermsSheet) {
                termsAndDetailsSheet
            }
        } else {
            contentStack
                .onAppear {
                    selectedFilter = initialFilter
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text(alertTitle),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
                .sheet(isPresented: $showTermsSheet) {
                    termsAndDetailsSheet
                }
        }
    }
    
    // MARK: - 0. Custom Top Navigation Bar (Snapshot media_1794983697133_a77fc6c2.jpg)
    
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
                        .font(.barlowBold(size: 16))
                }
                .foregroundColor(Color("Button_red"))
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            // Center: Title
            Text("Offers")
                .font(.oswaldMedium(size: 18))
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
                
                TopCartButton(action: onCartTap)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
        .padding(.bottom, 10)
        .background(Color("app_background"))
    }
    
    // MARK: - Content Stack
    
    private var contentStack: some View {
        VStack(alignment: .leading, spacing: 18) {
            // Screen Header: OFFERS & Eligibility subtitle
            headerSection
            
            // Segmented Filter Pills: All offers (7), Pickup (1), Saved (1)
            filterPillsSection
            
            // List of Voucher Ticket Offer Cards
            offersListSection
        }
    }
    
    // MARK: - 1. Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("OFFERS")
                .font(.oswaldMedium(size: 32))
                .tracking(0.8)
                .foregroundColor(Color("app_black"))
            
            Text("Eligibility updates live with your cart, store and fulfillment.")
                .font(.barlowRegular(size: 14))
                .foregroundColor(Color("text_gary"))
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 4)
    }
    
    // MARK: - 2. Filter Pills Section
    
    private var filterPillsSection: some View {
        HStack(spacing: 10) {
            filterPill(
                type: .allOffers,
                title: "All offers",
                count: dealsManager.offers.count
            )
            
            filterPill(
                type: .pickup,
                title: "Pickup",
                count: dealsManager.pickupDealsCount
            )
            
            filterPill(
                type: .saved,
                title: "Saved",
                count: dealsManager.savedDealsCount
            )
            
            Spacer()
        }
    }
    
    private func filterPill(type: DealsFilterType, title: String, count: Int) -> some View {
        let isSelected = (selectedFilter == type)
        return Button(action: {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                selectedFilter = type
            }
        }) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.barlowSemiBold(size: 13.5))
                    .foregroundColor(isSelected ? .white : Color("app_black"))
                
                // Count Circle Badge
                Text("\(count)")
                    .font(.barlowBold(size: 11))
                    .foregroundColor(isSelected ? .white : Color("app_black"))
                    .frame(width: 18, height: 18)
                    .background(
                        Circle()
                            .fill(isSelected ? Color.white.opacity(0.25) : Color(red: 0xF0 / 255.0, green: 0xEA / 255.0, blue: 0xDE / 255.0))
                    )
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color(red: 0x8C / 255.0, green: 0x1E / 255.0, blue: 0x2A / 255.0) : Color.white)
                    .overlay(
                        Capsule()
                            .stroke(
                                isSelected ? Color.clear : Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0),
                                lineWidth: 1.2
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - 3. Offers List Section
    
    private var offersListSection: some View {
        VStack(spacing: 16) {
            if filteredOffers.isEmpty {
                VStack(spacing: 8) {
                    Text("No offers found")
                        .font(.barlowBold(size: 15))
                        .foregroundColor(Color("app_black"))
                    
                    Text("Tap the heart icon on any coupon to save it here for fast access at checkout.")
                        .font(.barlowRegular(size: 13))
                        .foregroundColor(Color("text_gary"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .padding(32)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.2)
                        )
                )
            } else {
                ForEach(filteredOffers) { offer in
                    offerCard(offer)
                }
            }
        }
    }
    
    // Single Offer Card
    private func offerCard(_ offer: DealOfferItem) -> some View {
        HStack(spacing: 0) {
            // Left Ticket Stub (Dark Charcoal with serrated right edge)
            ticketStubView(offer: offer)
                .frame(width: 96)
            
            // Perforated Vertical Divider
            perforatedLine
                .frame(width: 2)
            
            // Right Content Area (White background)
            VStack(alignment: .leading, spacing: 8) {
                // Header Row: Title & Heart Button
                HStack(alignment: .top, spacing: 8) {
                    Text(offer.title)
                        .font(.oswaldMedium(size: 16))
                        .tracking(0.5)
                        .foregroundColor(Color("app_black"))
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer()
                    
                    // Heart Button
                    Button(action: {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                            dealsManager.toggleSaved(id: offer.id)
                        }
                    }) {
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                .frame(width: 28, height: 28)
                            
                            Image(systemName: offer.isSaved ? "heart.fill" : "heart")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(offer.isSaved ? Color("Button_red") : Color(red: 0x70 / 255.0, green: 0x70 / 255.0, blue: 0x70 / 255.0))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Description
                Text(offer.description)
                    .font(.barlowRegular(size: 12.5))
                    .foregroundColor(Color("text_gary"))
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Promo Code & Badges Row
                HStack(spacing: 8) {
                    // Promo code box
                    Text(offer.code)
                        .font(.system(size: 11.5, weight: .bold, design: .monospaced))
                        .tracking(0.8)
                        .foregroundColor(Color("app_black"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(Color(red: 0xF7 / 255.0, green: 0xF1 / 255.0, blue: 0xE6 / 255.0))
                        )
                    
                    // Optional secondary badge (Pickup only / Member)
                    if let badge = offer.secondaryBadgeText {
                        if offer.isMemberBadge {
                            // Member Badge (Red Capsule)
                            Text(badge)
                                .font(.barlowBold(size: 11))
                                .foregroundColor(.white)
                                .padding(.horizontal, 9)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(Color(red: 0x8C / 255.0, green: 0x1E / 255.0, blue: 0x2A / 255.0)))
                        } else {
                            // Pickup only Badge (Light Gold Capsule)
                            Text(badge)
                                .font(.barlowBold(size: 10.5))
                                .foregroundColor(Color(red: 0x93 / 255.0, green: 0x5E / 255.0, blue: 0x28 / 255.0))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(
                                    Capsule()
                                        .fill(Color(red: 0xFE / 255.0, green: 0xF5 / 255.0, blue: 0xE7 / 255.0))
                                )
                        }
                    }
                }
                
                // Minimum spend if any
                if let minSpend = offer.minimumSpend {
                    Text(minSpend)
                        .font(.barlowRegular(size: 12))
                        .foregroundColor(Color("text_gary"))
                }
                
                // Requirement Note
                HStack(alignment: .top, spacing: 5) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(red: 0x93 / 255.0, green: 0x5E / 255.0, blue: 0x28 / 255.0))
                        .padding(.top, 1)
                    
                    Text(offer.requirementNote)
                        .font(.barlowBold(size: 12))
                        .foregroundColor(Color(red: 0x93 / 255.0, green: 0x5E / 255.0, blue: 0x28 / 255.0))
                        .lineSpacing(1.5)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Actions Row: APPLY & DETAILS & TERMS
                HStack(spacing: 16) {
                    // APPLY Button
                    Button(action: {
                        if let onApplyDeal = onApplyDeal {
                            onApplyDeal(offer)
                        } else {
                            alertTitle = "Deal Applied"
                            alertMessage = "Coupon '\(offer.code)' has been applied to your order."
                            showAlert = true
                        }
                    }) {
                        Text("APPLY")
                            .font(.oswaldMedium(size: 13))
                            .tracking(0.8)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .frame(height: 34)
                            .background(
                                Capsule()
                                    .fill(Color(red: 0x8C / 255.0, green: 0x1E / 255.0, blue: 0x2A / 255.0))
                                    .shadow(color: Color(red: 0x8C / 255.0, green: 0x1E / 255.0, blue: 0x2A / 255.0).opacity(0.35), radius: 4, x: 0, y: 2)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // DETAILS & TERMS Button
                    Button(action: {
                        selectedTermsOffer = offer
                        showTermsSheet = true
                    }) {
                        Text("DETAILS & TERMS")
                            .font(.oswaldMedium(size: 13))
                            .tracking(0.8)
                            .foregroundColor(Color("app_black"))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.top, 2)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.2)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }
    
    // Left Ticket Stub View
    private func ticketStubView(offer: DealOfferItem) -> some View {
        ZStack {
            Color(red: 0x22 / 255.0, green: 0x22 / 255.0, blue: 0x24 / 255.0)
            
            VStack(spacing: 2) {
                Text(offer.stubTop)
                    .font(.oswaldBold(size: offer.stubTop.contains("$") ? 28 : (offer.stubTop.count > 4 ? 18 : 22)))
                    .foregroundColor(.white)
                
                if let middle = offer.stubMiddle {
                    Text(middle)
                        .font(.oswaldBold(size: 24))
                        .foregroundColor(.white)
                }
                
                Text(offer.stubBottom)
                    .font(.oswaldMedium(size: 11))
                    .tracking(1.2)
                    .foregroundColor(Color.white.opacity(0.85))
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 6)
        }
    }
    
    // Perforated Dashed Line
    private var perforatedLine: some View {
        VStack(spacing: 4) {
            ForEach(0..<18, id: \.self) { _ in
                Circle()
                    .fill(Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0))
                    .frame(width: 2, height: 2)
            }
        }
        .frame(maxHeight: .infinity)
        .background(Color(red: 0x22 / 255.0, green: 0x22 / 255.0, blue: 0x24 / 255.0))
    }
    
    // MARK: - Terms & Details Sheet
    
    private var termsAndDetailsSheet: some View {
        NavigationView {
            ZStack {
                Color("app_background").ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        if let offer = selectedTermsOffer {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(offer.title)
                                    .font(.oswaldMedium(size: 24))
                                    .foregroundColor(Color("app_black"))
                                
                                Text("Code: \(offer.code)")
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                    .foregroundColor(Color("Button_red"))
                            }
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Offer Details")
                                    .font(.oswaldMedium(size: 16))
                                    .foregroundColor(Color("app_black"))
                                
                                Text(offer.description)
                                    .font(.barlowRegular(size: 14))
                                    .foregroundColor(Color("text_gary"))
                                
                                Text("Terms & Conditions")
                                    .font(.oswaldMedium(size: 16))
                                    .foregroundColor(Color("app_black"))
                                    .padding(.top, 8)
                                
                                Text("• Valid at participating MOD Pizza locations in the United States.\n• One coupon redemption per order.\n• Cannot be combined with any other coupon, discount, or promotional bundle.\n• Not redeemable for cash or gift card purchases.\n• Taxes and applicable fees not included in discount calculation.\n• Offer subject to change or cancellation without notice.")
                                    .font(.barlowRegular(size: 13.5))
                                    .foregroundColor(Color("text_gary"))
                                    .lineSpacing(4)
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.2)
                                    )
                            )
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Offer Terms")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showTermsSheet = false
                    }
                    .font(.barlowBold(size: 16))
                    .foregroundColor(Color("Button_red"))
                }
            }
        }
    }
}

// MARK: - SwiftUI Preview

struct SaveDealsView_Previews: PreviewProvider {
    static var previews: some View {
        SaveDealsView(showHeader: true)
    }
}

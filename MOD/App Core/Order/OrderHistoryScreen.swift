//
//  OrderHistoryScreen.swift
//  MOD
//
//  Created by Rajpal singh on 10/11/26.
//

import SwiftUI

// MARK: - Enums & Models

enum OrderHistoryTab: String, CaseIterable {
    case active = "Active (2)"
    case completed = "Completed"
}

enum CompletedOrderFilter: String, CaseIterable {
    case all = "All (8)"
    case last30Days = "Last 30 Days"
    case year2023 = "2023"
    case filter = "Filter"
}

enum OrderStatusType: String {
    case inPreparation = "In Preparation"
    case onTheWay = "On the way 🛵"
    case delivered = "Delivered"
    case cancelled = "Cancelled & Refunded"

    var badgeColor: Color {
        switch self {
        case .inPreparation:
            return Color(red: 0.95, green: 0.55, blue: 0.10)
        case .onTheWay:
            return Color(red: 0.12, green: 0.65, blue: 0.38)
        case .delivered:
            return Color(red: 0.12, green: 0.65, blue: 0.38)
        case .cancelled:
            return Color(red: 0.85, green: 0.40, blue: 0.15)
        }
    }

    var badgeBgColor: Color {
        switch self {
        case .inPreparation:
            return Color(red: 1.0, green: 0.96, blue: 0.88)
        case .onTheWay:
            return Color(red: 0.90, green: 0.98, blue: 0.94)
        case .delivered:
            return Color(red: 0.90, green: 0.98, blue: 0.94)
        case .cancelled:
            return Color(red: 1.0, green: 0.94, blue: 0.92)
        }
    }
}

struct HistoryOrder: Identifiable {
    let id: String // e.g. "PH-18602842"
    let status: OrderStatusType
    let price: Double
    let originalPrice: Double?
    let dateText: String
    let itemsCountText: String
    let itemNames: [String] // Names only per user instructions
    let deliveryAddress: String?
    let ratingText: String?
    let pointsEarned: Int?
    let refundInfo: String?
    let isActive: Bool
}

// MARK: - Order History Screen

struct OrderHistoryScreen: View {
    @Environment(\.dismiss) private var dismiss

    // Tab & Filter States
    @State private var selectedTab: OrderHistoryTab = .active
    @State private var selectedFilter: CompletedOrderFilter = .all
    @State private var searchText: String = ""
    @State private var isSearching: Bool = false

    // Navigation & Sheet States
    @State private var selectedOrderToTrack: HistoryOrder? = nil
    @State private var navigateToTrackOrder: Bool = false
    @State private var selectedReceiptOrder: HistoryOrder? = nil
    @State private var showReceiptSheet: Bool = false
    @State private var showReorderSuccessAlert: Bool = false
    @State private var reorderedItemName: String = ""
    @State private var showSupportAlert: Bool = false
    @State private var showEditReviewAlert: Bool = false

    // Theme Colors
    private let modRed = Color(red: 0.78, green: 0.08, blue: 0.18)
    private let screenBg = Color(red: 0.98, green: 0.98, blue: 0.99)
    private let borderGray = Color(red: 0.91, green: 0.91, blue: 0.93)
    private let successGreen = Color(red: 0.12, green: 0.65, blue: 0.38)

    // MARK: - Sample Order Data
    // Note: Instead of images, item names are cleanly listed

    private let activeOrders: [HistoryOrder] = [
        HistoryOrder(
            id: "PH-18602842",
            status: .inPreparation,
            price: 28.50,
            originalPrice: nil,
            dateText: "Today, 7:15 PM",
            itemsCountText: "5 Items",
            itemNames: [
                "Pan Pepperoni Lover's Pizza",
                "Garlic Parmesan Breadsticks",
                "Marinara Dipping Sauce",
                "Cream Cheese Swirl Side",
                "Coca-Cola Original (Can)"
            ],
            deliveryAddress: "450 Sutter St, Apt 8B",
            ratingText: nil,
            pointsEarned: 140,
            refundInfo: nil,
            isActive: true
        ),
        HistoryOrder(
            id: "PH-85912830",
            status: .onTheWay,
            price: 46.90,
            originalPrice: nil,
            dateText: "Today, 6:45 PM",
            itemsCountText: "3 Items (2 Large + 1 Drink)",
            itemNames: [
                "2x Medium Artisan Thin Crust Pizzas",
                "Stuffed Cheesy Bacon Bread",
                "Mountain Dew (2 Liter)"
            ],
            deliveryAddress: "450 Sutter St, Apt 8B",
            ratingText: nil,
            pointsEarned: 180,
            refundInfo: nil,
            isActive: true
        )
    ]

    private let completedOrders: [HistoryOrder] = [
        HistoryOrder(
            id: "PH-47192518",
            status: .delivered,
            price: 34.20,
            originalPrice: nil,
            dateText: "Today, 2:15 PM • Handover",
            itemsCountText: "3 Items Total",
            itemNames: [
                "1 Large Pepperoni Lover's Pizza",
                "Garlic Breadsticks (8 pcs)",
                "2x Coca-Cola Original (Can)"
            ],
            deliveryAddress: "Delivered to Home • 450 Sutter St, Apt 8B, San Francisco, CA 94108",
            ratingText: "★ Rated: ★★★★★ (5.0)",
            pointsEarned: 140,
            refundInfo: nil,
            isActive: false
        ),
        HistoryOrder(
            id: "PH-39201944",
            status: .delivered,
            price: 52.80,
            originalPrice: nil,
            dateText: "Wed, Oct 18 • 8:30 PM",
            itemsCountText: "4 Items Total",
            itemNames: [
                "2x Medium Super Supreme Pizzas",
                "Stuffed Cheesy Breadsticks",
                "Mountain Dew (Chilled)"
            ],
            deliveryAddress: "Delivered to Home • 450 Sutter St, Apt 8B",
            ratingText: nil,
            pointsEarned: 52,
            refundInfo: nil,
            isActive: false
        ),
        HistoryOrder(
            id: "PH-58719204",
            status: .cancelled,
            price: 24.90,
            originalPrice: 24.90,
            dateText: "Fri, Oct 08 • 6:45 PM",
            itemsCountText: "1 Item Total",
            itemNames: [
                "1 Medium Veggie Lover's Pizza + 1 Drink"
            ],
            deliveryAddress: nil,
            ratingText: nil,
            pointsEarned: nil,
            refundInfo: "Refunded $24.90 to Visa •••• 1234",
            isActive: false
        ),
        HistoryOrder(
            id: "PH-47192510",
            status: .delivered,
            price: 14.90,
            originalPrice: nil,
            dateText: "Sun, Sep 15 • 1:20 PM",
            itemsCountText: "1 Item Total",
            itemNames: [
                "Garlic Breadsticks with Marinara Dip"
            ],
            deliveryAddress: "Delivered to Home • 450 Sutter St",
            ratingText: "★ Rate",
            pointsEarned: 30,
            refundInfo: nil,
            isActive: false
        )
    ]

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Push Navigation to Track Live Order
                if let order = selectedOrderToTrack {
                    NavigationLink(
                        destination: TrackOrderScreen(
                            orderNumber: order.id,
                            totalBaseAmount: order.price,
                            pointsEarned: order.pointsEarned ?? 140
                        ),
                        isActive: $navigateToTrackOrder
                    ) {
                        EmptyView()
                    }
                    .hidden()
                }

                // 1. Navigation Header
                navigationHeader

                // 2. Segmented Tab Selector (Active vs Completed)
                tabSegmentControl
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 10)

                // 3. Search Bar (when active)
                if isSearching {
                    searchBarView
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                }

                // 4. Scrollable List of Orders
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 14) {
                        if selectedTab == .active {
                            activeOrdersContent
                        } else {
                            completedOrdersContent
                        }

                        // Bottom Clearance so TabBar doesn't overlap cards
                        Color.clear.frame(height: 100)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 6)
                }
                .background(screenBg)
            }
            .background(screenBg.edgesIgnoringSafeArea(.all))
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarHidden(true)
        .sheet(isPresented: $showReceiptSheet) {
            if let order = selectedReceiptOrder {
                OrderReceiptSheet(order: order)
            }
        }
        .alert(isPresented: $showReorderSuccessAlert) {
            Alert(
                title: Text("Items Added to Cart!"),
                message: Text("Items from order #\(reorderedItemName) have been re-added to your cart."),
                dismissButton: .default(Text("OK"))
            )
        }
        .alert(isPresented: $showSupportAlert) {
            Alert(
                title: Text("Order Support"),
                message: Text("Connecting with MOD Customer Care for this order..."),
                dismissButton: .default(Text("OK"))
            )
        }
        .alert(isPresented: $showEditReviewAlert) {
            Alert(
                title: Text("Edit Review"),
                message: Text("You rated this order 5 stars! Edit review functionality is open."),
                dismissButton: .default(Text("Close"))
            )
        }
    }

    // MARK: - 1. Navigation Header

    private var navigationHeader: some View {
        HStack {
            // Back Button (hidden if root in TabBar)
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.black)
                    .frame(width: 38, height: 38)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
            }

            Spacer()

            Text("My Orders")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)

            Spacer()

            // Search Icon Toggle Button
            Button(action: {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    isSearching.toggle()
                }
            }) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15, weight: .bold))
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

    // MARK: - 2. Segmented Tab Selector

    private var tabSegmentControl: some View {
        HStack(spacing: 0) {
            ForEach(OrderHistoryTab.allCases, id: \.self) { tab in
                let isSelected = selectedTab == tab
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                }) {
                    HStack(spacing: 6) {
                        Text(tab.rawValue)
                            .font(.system(size: 13.5, weight: isSelected ? .bold : .semibold))
                            .foregroundColor(isSelected ? .black : .gray)

                        if tab == .completed {
                            Circle()
                                .fill(successGreen)
                                .frame(width: 6, height: 6)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 38)
                    .background(isSelected ? Color.white : Color.clear)
                    .cornerRadius(10)
                    .shadow(color: isSelected ? Color.black.opacity(0.08) : Color.clear, radius: 4, x: 0, y: 2)
                }
            }
        }
        .padding(3)
        .background(Color(red: 0.92, green: 0.93, blue: 0.95))
        .cornerRadius(12)
    }

    // MARK: - 3. Search Bar View

    private var searchBarView: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)

            TextField("Search by item name or order number...", text: $searchText)
                .font(.system(size: 13.5))

            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white)
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(borderGray, lineWidth: 1))
    }

    // MARK: - 4. Active Orders List Content

    private var activeOrdersContent: some View {
        VStack(spacing: 14) {
            let filtered = activeOrders.filter { order in
                matchesSearch(order: order)
            }

            if filtered.isEmpty {
                emptyStateView(message: "No active orders right now.")
            } else {
                ForEach(filtered) { order in
                    activeOrderCard(order: order)
                }
            }
        }
    }

    // MARK: Active Order Card
    // Note: Instead of images, item names are displayed cleanly.
    // Per instructions: Only single button titled "Track Live Order"

    private func activeOrderCard(order: HistoryOrder) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header Row: Order Number + Status + Price + Time
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Text("ORDER")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.gray)
                        Text("#\(order.id)")
                            .font(.system(size: 13, weight: .heavy))
                            .foregroundColor(.black)
                    }

                    HStack(spacing: 5) {
                        Circle()
                            .fill(order.status.badgeColor)
                            .frame(width: 6, height: 6)

                        Text(order.status.rawValue)
                            .font(.system(size: 11.5, weight: .bold))
                            .foregroundColor(order.status.badgeColor)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(order.status.badgeBgColor)
                    .cornerRadius(6)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("$\(String(format: "%.2f", order.price))")
                        .font(.system(size: 16, weight: .heavy))
                        .foregroundColor(modRed)

                    Text(order.dateText)
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
            }

            Divider()

            // Item Names List (No images, clean readable item names)
            VStack(alignment: .leading, spacing: 6) {
                Text(order.itemsCountText)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color.black.opacity(0.85))

                VStack(alignment: .leading, spacing: 3) {
                    ForEach(order.itemNames, id: \.self) { itemName in
                        HStack(alignment: .top, spacing: 6) {
                            Text("•")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(modRed)

                            Text(itemName)
                                .font(.system(size: 12.5, weight: .medium))
                                .foregroundColor(Color(red: 0.25, green: 0.28, blue: 0.32))
                                .lineLimit(1)
                        }
                    }
                }
            }
            .padding(.vertical, 2)

            // ONLY SINGLE BUTTON: "Track Live Order" per user requirements
            Button(action: {
                selectedOrderToTrack = order
                navigateToTrackOrder = true
            }) {
                HStack(spacing: 8) {
                    Text("Track Live Order")
                        .font(.system(size: 14.5, weight: .bold))

                    Image(systemName: "arrow.right")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(modRed)
                .cornerRadius(12)
                .shadow(color: modRed.opacity(0.35), radius: 6, x: 0, y: 3)
            }
            .padding(.top, 4)
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(borderGray, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }

    // MARK: - 5. Completed Orders List Content

    private var completedOrdersContent: some View {
        VStack(spacing: 14) {
            // Horizontal Filter Chips
            filterChipsRow

            let filtered = completedOrders.filter { order in
                matchesSearch(order: order)
            }

            if filtered.isEmpty {
                emptyStateView(message: "No completed orders found.")
            } else {
                ForEach(filtered) { order in
                    completedOrderCard(order: order)
                }
            }

            // Bottom Dotted Help Card
            missingOrdersHelpCard
        }
    }

    // MARK: Filter Chips Row
    private var filterChipsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(CompletedOrderFilter.allCases, id: \.self) { filter in
                    let isSelected = selectedFilter == filter
                    Button(action: {
                        selectedFilter = filter
                    }) {
                        HStack(spacing: 4) {
                            if filter == .filter {
                                Image(systemName: "slider.horizontal.3")
                                    .font(.system(size: 11))
                            }

                            Text(filter.rawValue)
                                .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                        }
                        .foregroundColor(isSelected ? .white : .black)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(isSelected ? Color(red: 0.15, green: 0.18, blue: 0.22) : Color.white)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(borderGray, lineWidth: isSelected ? 0 : 1)
                        )
                    }
                }
            }
        }
    }

    // MARK: Completed Order Card
    // Note: Displays item names only (no images)
    private func completedOrderCard(order: HistoryOrder) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header Row: Order Number + Handover Time + Price + Status Badge
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("ORDER #\(order.id)")
                        .font(.system(size: 12.5, weight: .bold))
                        .foregroundColor(Color.gray)

                    Text(order.dateText)
                        .font(.system(size: 13.5, weight: .bold))
                        .foregroundColor(.black)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    if let origPrice = order.originalPrice, order.status == .cancelled {
                        Text("$\(String(format: "%.2f", origPrice))")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.gray)
                            .strikethrough()
                    } else {
                        Text("$\(String(format: "%.2f", order.price))")
                            .font(.system(size: 16, weight: .heavy))
                            .foregroundColor(.black)
                    }

                    // Status Pill
                    HStack(spacing: 4) {
                        Circle()
                            .fill(order.status.badgeColor)
                            .frame(width: 5, height: 5)
                        Text(order.status.rawValue)
                            .font(.system(size: 10.5, weight: .bold))
                            .foregroundColor(order.status.badgeColor)
                    }
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(order.status.badgeBgColor)
                    .cornerRadius(6)
                }
            }

            // Delivered Address (if available)
            if let addr = order.deliveryAddress {
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(modRed)

                    Text(addr)
                        .font(.system(size: 11.5))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }

            Divider()

            // Item Names List (Item names only, no images)
            VStack(alignment: .leading, spacing: 4) {
                Text(order.itemsCountText)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.black)

                Text(order.itemNames.joined(separator: ", "))
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }

            // Points Banner (if any)
            if let points = order.pointsEarned {
                HStack(spacing: 6) {
                    Text("✨")
                        .font(.system(size: 12))
                    Text("Earned \(points) Hut Points")
                        .font(.system(size: 11.5, weight: .bold))
                        .foregroundColor(Color(red: 0.65, green: 0.45, blue: 0.05))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color(red: 0.99, green: 0.96, blue: 0.88))
                .cornerRadius(8)
            }

            // Refund Info (if cancelled)
            if let refund = order.refundInfo {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(successGreen)
                    Text(refund)
                        .font(.system(size: 11.5, weight: .medium))
                        .foregroundColor(Color(red: 0.15, green: 0.40, blue: 0.35))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(red: 0.92, green: 0.97, blue: 0.95))
                .cornerRadius(8)
            }

            // Rating Strip (if rated)
            if let rating = order.ratingText {
                HStack {
                    Text(rating)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(red: 0.75, green: 0.50, blue: 0.05))

                    Spacer()

                    Button(action: {
                        showEditReviewAlert = true
                    }) {
                        Text("Edit review")
                            .font(.system(size: 11.5, weight: .bold))
                            .foregroundColor(Color.black.opacity(0.75))
                    }
                }
                .padding(.vertical, 2)
            }

            // Action Buttons Row (Reorder | Receipt / Help)
            HStack(spacing: 10) {
                if order.status == .cancelled {
                    // Full Width Reorder Items Button
                    Button(action: {
                        reorderedItemName = order.id
                        showReorderSuccessAlert = true
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 12, weight: .bold))
                            Text("Reorder Items")
                                .font(.system(size: 13, weight: .bold))
                        }
                        .foregroundColor(modRed)
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(modRed, lineWidth: 1.2)
                        )
                    }
                } else {
                    // Reorder Red Button
                    Button(action: {
                        reorderedItemName = order.id
                        showReorderSuccessAlert = true
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 12, weight: .bold))
                            Text("Reorder")
                                .font(.system(size: 13, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .background(modRed)
                        .cornerRadius(10)
                        .shadow(color: modRed.opacity(0.3), radius: 5, x: 0, y: 2)
                    }

                    // Secondary Button (Receipt or Help)
                    if order.id.contains("47192518") {
                        Button(action: {
                            selectedReceiptOrder = order
                            showReceiptSheet = true
                        }) {
                            HStack(spacing: 5) {
                                Image(systemName: "doc.text")
                                    .font(.system(size: 12, weight: .medium))
                                Text("Receipt")
                                    .font(.system(size: 13, weight: .bold))
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 42)
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(borderGray, lineWidth: 1))
                        }
                    } else {
                        Button(action: {
                            showSupportAlert = true
                        }) {
                            HStack(spacing: 5) {
                                Image(systemName: "headphones")
                                    .font(.system(size: 12, weight: .medium))
                                Text("Help / Support")
                                    .font(.system(size: 13, weight: .bold))
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 42)
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(borderGray, lineWidth: 1))
                        }
                    }
                }
            }
            .padding(.top, 4)
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(borderGray, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }

    // MARK: Missing Orders Helper Card
    private var missingOrdersHelpCard: some View {
        VStack(spacing: 6) {
            (
                Text("Missing an older order? Check orders placed via guest checkout or ")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                + Text("Contact Care.")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(modRed)
            )
            .multilineTextAlignment(.center)
            .lineSpacing(2)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                .foregroundColor(Color.gray.opacity(0.35))
        )
        .padding(.top, 4)
    }

    // MARK: Empty State
    private func emptyStateView(message: String) -> some View {
        VStack(spacing: 10) {
            Text("📋")
                .font(.system(size: 40))
                .padding(.top, 30)

            Text("No Orders Found")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.black)

            Text(message)
                .font(.system(size: 13))
                .foregroundColor(.gray)
                .padding(.bottom, 30)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: Search Helper
    private func matchesSearch(order: HistoryOrder) -> Bool {
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty { return true }
        let query = searchText.lowercased()
        if order.id.lowercased().contains(query) { return true }
        return order.itemNames.contains { $0.lowercased().contains(query) }
    }
}

// MARK: - Order Receipt Sheet Modal

struct OrderReceiptSheet: View {
    @Environment(\.dismiss) private var dismiss
    var order: HistoryOrder

    private let modRed = Color(red: 0.78, green: 0.08, blue: 0.18)

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    VStack(spacing: 4) {
                        Text("ORDER RECEIPT")
                            .font(.system(size: 12, weight: .heavy))
                            .foregroundColor(.gray)
                            .tracking(1)

                        Text("#\(order.id)")
                            .font(.system(size: 20, weight: .bold))

                        Text(order.dateText)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 10)

                    Divider()

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Items Ordered")
                            .font(.system(size: 14, weight: .bold))

                        ForEach(order.itemNames, id: \.self) { item in
                            HStack {
                                Text("• " + item)
                                    .font(.system(size: 13))
                                Spacer()
                            }
                        }
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(12)

                    VStack(spacing: 8) {
                        HStack {
                            Text("Total Paid")
                                .font(.system(size: 15, weight: .bold))
                            Spacer()
                            Text("$\(String(format: "%.2f", order.price))")
                                .font(.system(size: 16, weight: .heavy))
                                .foregroundColor(modRed)
                        }
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(12)
                }
                .padding(16)
            }
            .background(Color(red: 0.98, green: 0.98, blue: 0.99).edgesIgnoringSafeArea(.all))
            .navigationBarTitle("Receipt", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() }.foregroundColor(modRed).font(.system(size: 15, weight: .bold)))
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        OrderHistoryScreen()
    }
}

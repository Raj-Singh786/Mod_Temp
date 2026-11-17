//
//  OrderHistoryView.swift
//  MOD
//
//  Created by Rajpal singh on 17/11/26.
//

import SwiftUI

// MARK: - Order Filter Enum

enum OrderFilterSegment: String, CaseIterable, Identifiable {
    case inProgress = "In progress"
    case past = "Past"
    case all = "All"
    
    var id: String { rawValue }
}

// MARK: - Order Status Enum

enum OrderStatus: String, CaseIterable, Hashable {
    case received = "Order received"
    case accepted = "Order accepted"
    case inOven = "In the oven"
    case ready = "Ready for pickup"
    case delivered = "Delivered"
    case pickedUp = "Picked up"
    case cancelled = "Cancelled"
    
    var isInProgress: Bool {
        switch self {
        case .received, .accepted, .inOven, .ready:
            return true
        case .delivered, .pickedUp, .cancelled:
            return false
        }
    }
    
    var isCancelled: Bool {
        self == .cancelled
    }
}

// MARK: - Order Fulfillment Type

enum OrderFulfillmentType: String, Hashable {
    case pickup = "In-store pickup"
    case delivery = "Delivery"
}

// MARK: - Order History Item Model

struct OrderHistoryItem: Identifiable, Hashable {
    let id: String
    var status: OrderStatus
    let dateString: String
    let storeName: String
    let fulfillment: OrderFulfillmentType
    let itemsDescription: String
    let totalAmount: Double
    var isGoTo: Bool = false
    let itemsDetail: [String]
}

// MARK: - OrderHistoryView

struct OrderHistoryView: View {
    
    // MARK: - Callbacks
    
    var onCartTap: (() -> Void)? = nil
    var onStarTap: (() -> Void)? = nil
    var onStartNewOrder: (() -> Void)? = nil
    
    // MARK: - State
    
    @State private var selectedFilter: OrderFilterSegment = .inProgress
    @State private var orders: [OrderHistoryItem] = [
        OrderHistoryItem(
            id: "MOD-010358",
            status: .accepted,
            dateString: "Nov 16, 2026",
            storeName: "Capitol Hill",
            fulfillment: .pickup,
            itemsDescription: "1× Aloha, 1× No Name Cake",
            totalAmount: 16.46,
            isGoTo: false,
            itemsDetail: [
                "1× Aloha (11\") - $10.99",
                "1× No Name Cake - $3.49",
                "Sales Tax - $1.98"
            ]
        ),
        OrderHistoryItem(
            id: "MOD-840068",
            status: .delivered,
            dateString: "Nov 13, 2026",
            storeName: "Capitol Hill",
            fulfillment: .delivery,
            itemsDescription: "1× Carnivore, 1× Build Your Pizza, 2× No Name Cake, 2× House-Made Lemonade",
            totalAmount: 54.61,
            isGoTo: true,
            itemsDetail: [
                "1× Carnivore Pizza (11\") - $10.99",
                "1× Build Your Pizza (11\") - $10.99",
                "2× No Name Cake - $6.98",
                "2× House-Made Lemonade - $7.98",
                "Delivery Fee - $3.99",
                "Tip - $7.00",
                "Sales Tax - $6.68"
            ]
        ),
        OrderHistoryItem(
            id: "MOD-667859",
            status: .pickedUp,
            dateString: "Nov 4, 2026",
            storeName: "Capitol Hill",
            fulfillment: .pickup,
            itemsDescription: "1× Veg Out, 1× Italian Chop",
            totalAmount: 27.86,
            isGoTo: false,
            itemsDetail: [
                "1× Veg Out Pizza (11\") - $10.99",
                "1× Italian Chop Salad - $12.49",
                "Sales Tax - $4.38"
            ]
        ),
        OrderHistoryItem(
            id: "MOD-521904",
            status: .pickedUp,
            dateString: "Oct 28, 2026",
            storeName: "Capitol Hill",
            fulfillment: .pickup,
            itemsDescription: "1× Maddy, 1× Cinnamon Cinnasquares",
            totalAmount: 19.98,
            isGoTo: false,
            itemsDetail: [
                "1× Maddy Pizza (11\") - $9.99",
                "1× Cinnamon Cinnasquares - $5.99",
                "Sales Tax - $4.00"
            ]
        )
    ]
    
    // Sheet Presentations
    @State private var activeTrackingOrder: OrderHistoryItem? = nil
    @State private var activeDetailsOrder: OrderHistoryItem? = nil
    @State private var activeReceiptOrder: OrderHistoryItem? = nil
    @State private var activeHelpOrder: OrderHistoryItem? = nil
    
    // Cancel & Toast Alerts
    @State private var orderToCancel: OrderHistoryItem? = nil
    @State private var showCancelConfirmation: Bool = false
    @State private var toastMessage: String? = nil
    
    // MARK: - Computed Filtered List
    
    private var inProgressCount: Int {
        orders.filter { $0.status.isInProgress }.count
    }
    
    private var pastCount: Int {
        orders.filter { !$0.status.isInProgress }.count
    }
    
    private var allCount: Int {
        orders.count
    }
    
    private var displayedOrders: [OrderHistoryItem] {
        switch selectedFilter {
        case .inProgress:
            return orders.filter { $0.status.isInProgress }
        case .past:
            return orders.filter { !$0.status.isInProgress }
        case .all:
            return orders
        }
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
                        
                        // Segmented Control (In progress 1, Past 3, All 4)
                        segmentedFilterBar
                        
                        // Orders List
                        if displayedOrders.isEmpty {
                            emptyStateView
                        } else {
                            VStack(spacing: 16) {
                                ForEach(displayedOrders) { order in
                                    orderCard(order)
                                }
                            }
                        }
                        
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
                        .padding(.horizontal, 20)
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
        .toolbar(.hidden, for: .navigationBar)
        .sheet(item: $activeTrackingOrder) { order in
            OrderTrackingSheet(order: order)
        }
        .sheet(item: $activeDetailsOrder) { order in
            OrderDetailsSheet(order: order)
        }
        .fullScreenCover(item: $activeReceiptOrder) { order in
            ReceiptView(
                order: order,
                onBack: {
                    activeReceiptOrder = nil
                },
                onStarTap: onStarTap,
                onCartTap: onCartTap
            )
        }
        .sheet(item: $activeHelpOrder) { order in
            OrderHelpSheet(order: order)
        }
        .alert(isPresented: $showCancelConfirmation) {
            Alert(
                title: Text("Cancel Order"),
                message: Text("Are you sure you want to cancel order \(orderToCancel?.id ?? "")? A refund will be issued to your payment method."),
                primaryButton: .destructive(Text("Cancel Order")) {
                    if let target = orderToCancel,
                       let idx = orders.firstIndex(where: { $0.id == target.id }) {
                        orders[idx].status = .cancelled
                        showToast("Order \(target.id) cancelled.")
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    // MARK: - Custom Top Navigation Bar
    
    private var customNavigationBar: some View {
        HStack(alignment: .center) {
            // Left Placeholder to center title
            Color.clear
                .frame(width: 70, height: 32)
            
            Spacer()
            
            // Center: Orders Title
            Text("Orders")
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
            Text("ORDERS")
                .font(.oswaldMedium(size: 32))
                .tracking(0.8)
                .foregroundColor(Color("app_black"))
            
            Text("Member order history on this browser")
                .font(.barlowRegular(size: 16))
                .foregroundColor(Color("text_gary"))
        }
        .padding(.top, 4)
    }
    
    // MARK: - Segmented Filter Bar
    
    private var segmentedFilterBar: some View {
        HStack(spacing: 10) {
            filterPill(segment: .inProgress, count: inProgressCount)
            filterPill(segment: .past, count: pastCount)
            filterPill(segment: .all, count: allCount)
            Spacer()
        }
        .padding(.top, 2)
    }
    
    private func filterPill(segment: OrderFilterSegment, count: Int) -> some View {
        let isSelected = selectedFilter == segment
        
        return Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedFilter = segment
            }
        }) {
            HStack(spacing: 6) {
                Text(segment.rawValue)
                    .font(.barlowSemiBold(size: 14))
                
                Text("\(count)")
                    .font(.barlowBold(size: 12))
                    .foregroundColor(isSelected ? .white : Color("app_black"))
                    .frame(width: 20, height: 20)
                    .background(
                        Circle()
                            .fill(isSelected ? Color.black.opacity(0.18) : Color(red: 0xF0 / 255.0, green: 0xEA / 255.0, blue: 0xDE / 255.0))
                    )
            }
            .foregroundColor(isSelected ? .white : Color("app_black"))
            .padding(.horizontal, 14)
            .frame(height: 38)
            .background(
                Capsule()
                    .fill(isSelected ? Color("Button_red") : Color.white)
                    .shadow(color: isSelected ? Color("Button_red").opacity(0.3) : Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Order Card
    
    private func orderCard(_ order: OrderHistoryItem) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            // Top Row: Order ID + Status Badge
            HStack(alignment: .center) {
                Text(order.id)
                    .font(.oswaldLight(size: 20))
                    .tracking(0.5)
                    .foregroundColor(Color("app_black"))
                
                Spacer()
                
                statusBadge(for: order.status)
            }
            
            // Metadata: Date · Store · Pickup/Delivery
            Text("\(order.dateString) · \(order.storeName) · \(order.fulfillment.rawValue)")
                .font(.barlowRegular(size: 13.5))
                .foregroundColor(Color("text_gary"))
            
            // Items Summary
            Text(order.itemsDescription)
                .font(.barlowRegular(size: 14))
                .foregroundColor(Color("app_black"))
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
            
            // Thin Divider
            Rectangle()
                .fill(Color(red: 0xF0 / 255.0, green: 0xEA / 255.0, blue: 0xDE / 255.0))
                .frame(height: 1)
                .padding(.vertical, 2)
            
            // Price Display
            Text("$\(String(format: "%.2f", order.totalAmount))")
                .font(.oswaldBold(size: 18))
                .foregroundColor(Color("app_black"))
            
            // Action Buttons Section
            VStack(alignment: .leading, spacing: 12) {
                // Row 1: Primary Action (TRACK / DETAILS) + RECEIPT + HELP
                HStack(spacing: 16) {
                    if order.status.isInProgress {
                        // TRACK Button
                        Button(action: {
                            activeTrackingOrder = order
                        }) {
                            Text("TRACK")
                                .font(.oswaldMedium(size: 13.5))
                                .tracking(1.0)
                                .foregroundColor(.white)
                                .padding(.horizontal, 22)
                                .frame(height: 38)
                                .background(
                                    Capsule()
                                        .fill(Color("Button_red"))
                                        .shadow(color: Color("Button_red").opacity(0.3), radius: 4, x: 0, y: 2)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    } else {
                        // DETAILS Button
                        Button(action: {
                            activeDetailsOrder = order
                        }) {
                            Text("DETAILS")
                                .font(.oswaldMedium(size: 13.5))
                                .tracking(0.8)
                                .foregroundColor(Color("app_black"))
                                .padding(.horizontal, 18)
                                .frame(height: 38)
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
                    }
                    
                    // RECEIPT Button
                    Button(action: {
                        activeReceiptOrder = order
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: "doc.text")
                                .font(.system(size: 13, weight: .medium))
                            
                            Text("RECEIPT")
                                .font(.oswaldMedium(size: 13.5))
                                .tracking(0.8)
                        }
                        .foregroundColor(Color("app_black"))
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // HELP Button
                    Button(action: {
                        activeHelpOrder = order
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: "questionmark.circle")
                                .font(.system(size: 14, weight: .medium))
                            
                            Text("HELP")
                                .font(.oswaldMedium(size: 13.5))
                                .tracking(0.8)
                        }
                        .foregroundColor(Color("app_black"))
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                }
                
                // Row 2: REORDER + CANCEL ORDER or Go-to order / MAKE GO-TO
                HStack(spacing: 14) {
                    // REORDER Button
                    Button(action: {
                        showToast("Added \(order.id) items to your cart!")
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: 12, weight: .bold))
                            
                            Text("REORDER")
                                .font(.oswaldMedium(size: 13.5))
                                .tracking(0.8)
                        }
                        .foregroundColor(Color("app_black"))
                        .padding(.horizontal, 16)
                        .frame(height: 38)
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
                    
                    if order.status.isInProgress {
                        // CANCEL ORDER Button
                        Button(action: {
                            orderToCancel = order
                            showCancelConfirmation = true
                        }) {
                            HStack(spacing: 5) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 11, weight: .bold))
                                
                                Text("CANCEL ORDER")
                                    .font(.oswaldMedium(size: 13.5))
                                    .tracking(0.8)
                            }
                            .foregroundColor(Color("Button_red"))
                        }
                        .buttonStyle(PlainButtonStyle())
                    } else {
                        // Go-to order / MAKE GO-TO
                        if order.isGoTo {
                            HStack(spacing: 5) {
                                Image(systemName: "star")
                                    .font(.system(size: 12, weight: .semibold))
                                
                                Text("Go-to order")
                                    .font(.barlowBold(size: 13))
                            }
                            .foregroundColor(Color(red: 0x4B / 255.0, green: 0x6E / 255.0, blue: 0x24 / 255.0))
                            .padding(.horizontal, 12)
                            .frame(height: 34)
                            .background(
                                Capsule()
                                    .fill(Color(red: 0xEE / 255.0, green: 0xF7 / 255.0, blue: 0xD8 / 255.0))
                            )
                        } else {
                            Button(action: {
                                toggleGoTo(order)
                            }) {
                                HStack(spacing: 5) {
                                    Image(systemName: "star")
                                        .font(.system(size: 13, weight: .medium))
                                    
                                    Text("MAKE GO-TO")
                                        .font(.oswaldMedium(size: 13.5))
                                        .tracking(0.8)
                                }
                                .foregroundColor(Color("app_black"))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    
                    Spacer()
                }
                
                // Row 3: For In Progress orders, MAKE GO-TO is placed on its own row (Snapshot 1)
                if order.status.isInProgress {
                    Button(action: {
                        toggleGoTo(order)
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: order.isGoTo ? "star.fill" : "star")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(order.isGoTo ? Color("Button_red") : Color("app_black"))
                            
                            Text(order.isGoTo ? "SAVED TO GO-TO" : "MAKE GO-TO")
                                .font(.oswaldMedium(size: 13.5))
                                .tracking(0.8)
                                .foregroundColor(Color("app_black"))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.top, 2)
                }
            }
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
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        )
    }
    
    // MARK: - Status Badge
    
    @ViewBuilder
    private func statusBadge(for status: OrderStatus) -> some View {
        if status.isInProgress {
            HStack(spacing: 5) {
                Circle()
                    .fill(Color("Button_red"))
                    .frame(width: 6, height: 6)
                
                Text(status.rawValue)
                    .font(.barlowBold(size: 12))
                    .foregroundColor(Color("Button_red"))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(Color(red: 0xFD / 255.0, green: 0xED / 255.0, blue: 0xEF / 255.0))
            )
        } else if status == .delivered || status == .pickedUp {
            Text(status.rawValue)
                .font(.barlowBold(size: 12))
                .foregroundColor(Color(red: 0x4B / 255.0, green: 0x6E / 255.0, blue: 0x24 / 255.0))
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(Color(red: 0xEE / 255.0, green: 0xF7 / 255.0, blue: 0xD8 / 255.0))
                )
        } else {
            Text(status.rawValue)
                .font(.barlowBold(size: 12))
                .foregroundColor(Color("text_gary"))
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(Color(red: 0xF0 / 255.0, green: 0xEA / 255.0, blue: 0xDE / 255.0))
                )
        }
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "list.clipboard")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(Color("text_gary").opacity(0.6))
                .padding(.top, 40)
            
            Text("No \(selectedFilter.rawValue.lowercased()) orders found")
                .font(.oswaldMedium(size: 20))
                .foregroundColor(Color("app_black"))
            
            Text("When you place an order, it will appear here so you can track progress and reorder easily.")
                .font(.barlowRegular(size: 14))
                .foregroundColor(Color("text_gary"))
                .multilineTextAlignment(.center)
                .lineSpacing(2)
                .padding(.horizontal, 24)
            
            Button(action: {
                onStartNewOrder?()
            }) {
                Text("START AN ORDER")
                    .font(.oswaldMedium(size: 14.5))
                    .tracking(1.0)
                    .foregroundColor(.white)
                    .padding(.horizontal, 28)
                    .frame(height: 46)
                    .background(
                        Capsule()
                            .fill(Color("Button_red"))
                            .shadow(color: Color("Button_red").opacity(0.35), radius: 6, x: 0, y: 3)
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 10)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }
    
    // MARK: - Helpers
    
    private func toggleGoTo(_ order: OrderHistoryItem) {
        if let idx = orders.firstIndex(where: { $0.id == order.id }) {
            orders[idx].isGoTo.toggle()
            if orders[idx].isGoTo {
                showToast("Saved \(order.id) as a Go-to order!")
            }
        }
    }
    
    private func showToast(_ text: String) {
        toastMessage = text
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            if toastMessage == text {
                toastMessage = nil
            }
        }
    }
}

// MARK: - Order Tracking Sheet

struct OrderTrackingSheet: View {
    let order: OrderHistoryItem
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                // Order Header
                VStack(alignment: .leading, spacing: 4) {
                    Text(order.id)
                        .font(.oswaldLight(size: 26))
                        .foregroundColor(Color("app_black"))
                    
                    Text("\(order.storeName) · \(order.fulfillment.rawValue)")
                        .font(.oswaldExtraLight(size: 14))
                        .foregroundColor(Color("text_gary"))
                }
                .padding(.top, 10)
                
                // Live Progress Stepper
                VStack(alignment: .leading, spacing: 18) {
                    trackingStepRow(title: "Order placed", time: "12:15 PM", isCompleted: true, isCurrent: false)
                    trackingStepRow(title: "Order accepted", time: "12:18 PM", isCompleted: true, isCurrent: true)
                    trackingStepRow(title: "In the oven", time: "Est. 12:35 PM", isCompleted: false, isCurrent: false)
                    trackingStepRow(title: "Ready for pickup", time: "Est. 12:45 PM", isCompleted: false, isCurrent: false)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color(red: 0xF9 / 255.0, green: 0xF5 / 255.0, blue: 0xEE / 255.0))
                )
                
                // Items in order
                VStack(alignment: .leading, spacing: 8) {
                    Text("ITEMS IN THIS ORDER")
                        .font(.oswaldMedium(size: 14))
                        .foregroundColor(Color("text_gary"))
                    
                    Text(order.itemsDescription)
                        .font(.barlowRegular(size: 15))
                        .foregroundColor(Color("app_black"))
                }
                .padding(.top, 6)
                
                Spacer()
            }
            .padding(20)
            .navigationTitle("Live Order Tracking")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.barlowBold(size: 15))
                    .foregroundColor(Color("Button_red"))
                }
            }
        }
    }
    
    private func trackingStepRow(title: String, time: String, isCompleted: Bool, isCurrent: Bool) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(isCompleted ? Color("Button_red") : Color(red: 0xDE / 255.0, green: 0xD7 / 255.0, blue: 0xCC / 255.0))
                    .frame(width: 26, height: 26)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                } else if isCurrent {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 8, height: 8)
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.barlowSemiBold(size: 15))
                    .foregroundColor(isCompleted || isCurrent ? Color("app_black") : Color("text_gary"))
                
                Text(time)
                    .font(.barlowRegular(size: 12.5))
                    .foregroundColor(Color("text_gary"))
            }
            
            Spacer()
        }
    }
}

// MARK: - Order Details Sheet

struct OrderDetailsSheet: View {
    let order: OrderHistoryItem
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    // Top Info
                    VStack(alignment: .leading, spacing: 4) {
                        Text(order.id)
                            .font(.oswaldBold(size: 26))
                            .foregroundColor(Color("app_black"))
                        
                        Text("\(order.dateString) · \(order.storeName)")
                            .font(.barlowRegular(size: 14))
                            .foregroundColor(Color("text_gary"))
                    }
                    
                    Divider()
                    
                    // Line Items
                    VStack(alignment: .leading, spacing: 10) {
                        Text("ORDER SUMMARY")
                            .font(.oswaldMedium(size: 14))
                            .foregroundColor(Color("text_gary"))
                        
                        ForEach(order.itemsDetail, id: \.self) { item in
                            HStack {
                                Text(item)
                                    .font(.barlowRegular(size: 14.5))
                                    .foregroundColor(Color("app_black"))
                                Spacer()
                            }
                            .padding(.vertical, 2)
                        }
                    }
                    
                    Divider()
                    
                    // Total
                    HStack {
                        Text("Total Paid")
                            .font(.oswaldMedium(size: 18))
                            .foregroundColor(Color("app_black"))
                        Spacer()
                        Text("$\(String(format: "%.2f", order.totalAmount))")
                            .font(.oswaldBold(size: 22))
                            .foregroundColor(Color("Button_red"))
                    }
                }
                .padding(20)
            }
            .navigationTitle("Order Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Close") {
                        dismiss()
                    }
                    .font(.barlowBold(size: 15))
                    .foregroundColor(Color("Button_red"))
                }
            }
        }
    }
}

// MARK: - Order Receipt Sheet

struct OrderReceiptSheet: View {
    let order: OrderHistoryItem
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Store Logo & Address
                    VStack(spacing: 4) {
                        Image("app_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 38, height: 44)
                        
                        Text("MOD PIZZA")
                            .font(.oswaldMedium(size: 20))
                            .foregroundColor(Color("app_black"))
                        
                        Text("Store: \(order.storeName)")
                            .font(.barlowRegular(size: 13))
                            .foregroundColor(Color("text_gary"))
                        
                        Text(order.dateString)
                            .font(.barlowRegular(size: 12.5))
                            .foregroundColor(Color("text_gary"))
                    }
                    .padding(.top, 10)
                    
                    Divider()
                    
                    // Order ID & Receipt Number
                    VStack(spacing: 2) {
                        Text("Receipt #\(order.id.replacingOccurrences(of: "MOD-", with: "RCPT-"))")
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundColor(Color("app_black"))
                    }
                    
                    // Items List
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(order.itemsDetail, id: \.self) { detail in
                            Text(detail)
                                .font(.barlowRegular(size: 14))
                                .foregroundColor(Color("app_black"))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 8)
                    
                    Divider()
                    
                    // Total Amount
                    HStack {
                        Text("TOTAL")
                            .font(.oswaldMedium(size: 18))
                        Spacer()
                        Text("$\(String(format: "%.2f", order.totalAmount))")
                            .font(.oswaldBold(size: 20))
                    }
                    .foregroundColor(Color("app_black"))
                    .padding(.horizontal, 8)
                    
                    // Barcode Sample
                    VStack(spacing: 6) {
                        BarcodeGraphicView()
                            .frame(height: 48)
                            .padding(.horizontal, 10)
                        
                        Text(order.id)
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                            .foregroundColor(Color("text_gary"))
                    }
                    .padding(.top, 12)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
                )
                .padding(16)
            }
            .background(Color("app_background").ignoresSafeArea())
            .navigationTitle("Digital Receipt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.barlowBold(size: 15))
                    .foregroundColor(Color("Button_red"))
                }
            }
        }
    }
}

// MARK: - Order Help Sheet

struct OrderHelpSheet: View {
    let order: OrderHistoryItem
    @Environment(\.dismiss) private var dismiss
    @State private var submitted: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 18) {
                Text("How can we help with order \(order.id)?")
                    .font(.oswaldMedium(size: 20))
                    .foregroundColor(Color("app_black"))
                    .padding(.top, 10)
                
                if submitted {
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 44))
                            .foregroundColor(Color(red: 0x4B / 255.0, green: 0x6E / 255.0, blue: 0x24 / 255.0))
                        
                        Text("Support Request Sent")
                            .font(.oswaldMedium(size: 18))
                        
                        Text("Our store team will contact you shortly regarding order \(order.id).")
                            .font(.barlowRegular(size: 14))
                            .foregroundColor(Color("text_gary"))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
                } else {
                    helpOptionButton(title: "Missing an item from my order")
                    helpOptionButton(title: "Incorrect ingredients or toppings")
                    helpOptionButton(title: "Order was delayed")
                    helpOptionButton(title: "Delivery issue or damaged food")
                    helpOptionButton(title: "Call \(order.storeName) store directly")
                }
                
                Spacer()
            }
            .padding(20)
            .navigationTitle("Order Help")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Close") {
                        dismiss()
                    }
                    .font(.barlowBold(size: 15))
                    .foregroundColor(Color("Button_red"))
                }
            }
        }
    }
    
    private func helpOptionButton(title: String) -> some View {
        Button(action: {
            withAnimation {
                submitted = true
            }
        }) {
            HStack {
                Text(title)
                    .font(.barlowMedium(size: 15))
                    .foregroundColor(Color("app_black"))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("text_gary"))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(red: 0xF9 / 255.0, green: 0xF5 / 255.0, blue: 0xEE / 255.0))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - SwiftUI Preview

struct OrderHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        OrderHistoryView()
    }
}

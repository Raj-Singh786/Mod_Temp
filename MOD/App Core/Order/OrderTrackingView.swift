//
//  OrderTrackingView.swift
//  MOD
//
//  Created by Rajpal singh on 17/11/26.
//

import SwiftUI

// MARK: - Track Order Item Model

struct TrackOrderItem: Identifiable, Hashable {
    var id: String = UUID().uuidString
    let title: String
    let quantity: Int
    let price: Double
    
    var formattedPrice: String {
        String(format: "$%.2f", price * Double(quantity))
    }
}

// MARK: - Tracking Progress Step

enum OrderTrackingProgressStage: Int, CaseIterable, Identifiable {
    case received = 0
    case accepted = 1
    case preparing = 2
    case inTheOven = 3
    case readyForPickup = 4
    case pickedUp = 5
    
    var id: Int { rawValue }
    
    var labelLines: [String] {
        switch self {
        case .received:
            return ["Order", "received"]
        case .accepted:
            return ["Order", "accepted"]
        case .preparing:
            return ["Preparing", ""]
        case .inTheOven:
            return ["In the", "oven"]
        case .readyForPickup:
            return ["Ready for", "pickup"]
        case .pickedUp:
            return ["Picked", "up"]
        }
    }
}

// MARK: - OrderTrackingView

struct OrderTrackingView: View {
    
    // MARK: - Environment & Callbacks
    
    @Environment(\.dismiss) private var dismiss
    
    var onBack: (() -> Void)? = nil
    var onCartTap: (() -> Void)? = nil
    
    // MARK: - Configurable Order Properties
    
    var orderId: String = "MOD-628250"
    var storeName: String = "Capitol Hill"
    var storeAddress: String = "1302 Pine St, Seattle, WA 98101"
    var fulfillmentText: String = "In-store pickup"
    var scheduledTimeText: String = "Tue, Nov 17, 9:15\nPM PST"
    var preparationTimeText: String = "Tue, Nov 17, 9:00 PM PST"
    
    // Customer Info
    var customerName: String = "Logan"
    var customerPhone: String = "7580880463"
    var customerEmail: String = "risabhputta213@gmail.com"
    var allergensText: String = "Peanuts"
    
    // Financials
    var items: [TrackOrderItem] = [
        TrackOrderItem(title: "Build Your Pizza", quantity: 1, price: 11.99)
    ]
    var subtotal: Double = 11.99
    var tax: Double = 1.05
    var tip: Double = 2.40
    var total: Double = 15.44
    var earnedPoints: Int = 110
    
    // MARK: - Interactive State
    
    @State private var currentStage: OrderTrackingProgressStage = .received
    @State private var isOrderCancelled: Bool = false
    
    // Sheets
    @State private var showCancelOrderSheet: Bool = false
    @State private var showEditToppingsSheet: Bool = false
    @State private var showReceiptSheet: Bool = false
    @State private var showHelpSheet: Bool = false
    @State private var showCancelAlert: Bool = false
    
    // MARK: - Initializer
    
    init(
        orderId: String = "MOD-628250",
        storeName: String = "Capitol Hill",
        storeAddress: String = "1302 Pine St, Seattle, WA 98101",
        fulfillmentText: String = "In-store pickup",
        scheduledTimeText: String = "Tue, Nov 17, 9:15\nPM PST",
        preparationTimeText: String = "Tue, Nov 17, 9:00 PM PST",
        customerName: String = "Logan",
        customerPhone: String = "7580880463",
        customerEmail: String = "risabhputta213@gmail.com",
        allergensText: String = "Peanuts",
        items: [TrackOrderItem] = [
            TrackOrderItem(title: "Build Your Pizza", quantity: 1, price: 11.99)
        ],
        subtotal: Double = 11.99,
        tax: Double = 1.05,
        tip: Double = 2.40,
        total: Double = 15.44,
        earnedPoints: Int = 110,
        onBack: (() -> Void)? = nil,
        onCartTap: (() -> Void)? = nil
    ) {
        self.orderId = orderId
        self.storeName = storeName
        self.storeAddress = storeAddress
        self.fulfillmentText = fulfillmentText
        self.scheduledTimeText = scheduledTimeText
        self.preparationTimeText = preparationTimeText
        self.customerName = customerName
        self.customerPhone = customerPhone
        self.customerEmail = customerEmail
        self.allergensText = allergensText
        self.items = items
        self.subtotal = subtotal
        self.tax = tax
        self.tip = tip
        self.total = total
        self.earnedPoints = earnedPoints
        self.onBack = onBack
        self.onCartTap = onCartTap
    }
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color("app_background")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 1. Custom Navigation Bar
                    customNavigationBar
                    
                    // 2. Main Scrollable Content
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 18) {
                            // Big Screen Header
                            screenHeaderSection
                            
                            // Card 1: SCHEDULED FOR & Stepper
                            statusTimelineCard
                            
                            // Card 2: IN-STORE PICKUP AT STORE
                            pickupLocationCard
                            
                            // Card 3: CHANGE TOPPINGS
                            if !isOrderCancelled {
                                changeToppingsCard
                            }
                            
                            // Card 4: YOUR ORDER
                            yourOrderCard
                            
                            // Card 5: CONTACT & NOTES
                            contactNotesCard
                            
                            // Bottom Spacer
                            Spacer()
                                .frame(height: 50)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 6)
                        .padding(.bottom, 24)
                        .frame(width: geometry.size.width)
                    }
                    .clipped()
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        // Sheets
        .sheet(isPresented: $showReceiptSheet) {
            ReceiptView(receipt: makeReceiptData())
        }
        .sheet(isPresented: $showHelpSheet) {
            OrderHelpView(
                orderId: orderId,
                storeName: storeName,
                statusText: isOrderCancelled ? "Cancelled" : "Scheduled",
                isOrderCompleted: isOrderCancelled,
                onBack: { showHelpSheet = false }
            )
        }
        .sheet(isPresented: $showCancelOrderSheet) {
            CancelOrderView(
                order: OrderHistoryItem(
                    id: orderId,
                    status: .accepted,
                    dateString: "Nov 17, 2026",
                    storeName: storeName,
                    fulfillment: .pickup,
                    itemsDescription: items.map { "\($0.quantity)× \($0.title)" }.joined(separator: ", "),
                    totalAmount: total,
                    isGoTo: false,
                    itemsDetail: items.map { "\($0.quantity)× \($0.title) - $\(String(format: "%.2f", $0.price))" }
                ),
                onConfirmCancel: { reason in
                    withAnimation {
                        isOrderCancelled = true
                        showCancelOrderSheet = false
                    }
                },
                onKeepOrder: {
                    showCancelOrderSheet = false
                }
            )
        }
        .fullScreenCover(isPresented: $showEditToppingsSheet) {
            MenuCustomizationView(
                pizzaTitle: "Build Your Pizza",
                pizzaCategory: "PIZZAS",
                pizzaDescription: "Build your own with 40+ toppings and 8 finishing sauces — all for one price. Supports independent half-and-half recipes.",
                pizzaImageName: "PizzaOn",
                showRecipeStyle: false,
                onBack: {
                    showEditToppingsSheet = false
                }
            )
        }
    }
    
    // MARK: - 1. Top Custom Navigation Bar
    
    private var customNavigationBar: some View {
        HStack(alignment: .center) {
            // Left: < Back button
            Button(action: {
                if let onBack = onBack {
                    onBack()
                } else {
                    dismiss()
                }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 14, weight: .bold))
                    
                    Text("Back")
                        .font(.barlowMedium(size: 15))
                }
                .foregroundColor(Color("Button_red"))
            }
            .buttonStyle(PlainButtonStyle())
            .frame(width: 75, alignment: .leading)
            
            Spacer()
            
            // Center: Screen Title
            Text("Order tracking")
                .font(.oswaldBold(size: 17))
                .tracking(0.5)
                .foregroundColor(Color("app_black"))
            
            Spacer()
            
            // Right: Profile + Cart Icon
            HStack(spacing: 16) {
                Image(systemName: "person")
                    .font(.system(size: 19, weight: .regular))
                    .foregroundColor(Color("app_black"))
                    .frame(width: 32, height: 32)
                
                TopCartButton(action: onCartTap)
            }
            .frame(width: 75, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
        .padding(.bottom, 10)
        .background(Color("app_background"))
    }
    
    // MARK: - 2. Screen Header Section
    
    private var screenHeaderSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(isOrderCancelled ? "ORDER CANCELLED" : "ORDER SCHEDULED")
                .font(.oswaldBold(size: 28))
                .tracking(0.6)
                .foregroundColor(isOrderCancelled ? Color("Button_red") : Color("app_black"))
            
            HStack(spacing: 4) {
                Text("Order")
                    .font(.barlowRegular(size: 14))
                    .foregroundColor(Color("text_gary"))
                
                Text(orderId)
                    .font(.barlowBold(size: 14))
                    .foregroundColor(Color("app_black"))
                
                Text("· \(storeName) · \(fulfillmentText)")
                    .font(.barlowRegular(size: 14))
                    .foregroundColor(Color("text_gary"))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Card 1: Status & Timeline Card
    
    private var statusTimelineCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            // Header Row: SCHEDULED FOR + "Scheduled" Pill
            HStack(alignment: .center) {
                Text(isOrderCancelled ? "CANCELLED" : "SCHEDULED FOR")
                    .font(.barlowBold(size: 11.5))
                    .tracking(0.8)
                    .foregroundColor(Color("Button_red"))
                
                Spacer()
                
                Text(isOrderCancelled ? "Cancelled" : "Scheduled")
                    .font(.barlowMedium(size: 12))
                    .foregroundColor(isOrderCancelled ? Color("Button_red") : Color(red: 0x1B / 255.0, green: 0x6C / 255.0, blue: 0x86 / 255.0))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(isOrderCancelled ? Color(red: 0xFD / 255.0, green: 0xEA / 255.0, blue: 0xEC / 255.0) : Color(red: 0xDD / 255.0, green: 0xF2 / 255.0, blue: 0xF8 / 255.0))
                    )
            }
            
            // Big Date & Time
            Text(scheduledTimeText)
                .font(.oswaldBold(size: 32))
                .tracking(0.4)
                .foregroundColor(Color("app_black"))
                .lineSpacing(-3)
            
            // 6-Step Horizontal Progress Stepper
            stepperProgressBar
                .padding(.top, 4)
                .padding(.bottom, 2)
            
            // Action Button: CANCEL ORDER (or Cancelled Notice)
            if isOrderCancelled {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color("Button_red"))
                    Text("This order has been cancelled and refunded.")
                        .font(.barlowMedium(size: 13))
                        .foregroundColor(Color("Button_red"))
                }
                .padding(.vertical, 4)
            } else {
                Button(action: {
                    showCancelOrderSheet = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "xmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color("Button_red"))
                        
                        Text("CANCEL ORDER")
                            .font(.oswaldBold(size: 13.5))
                            .tracking(0.8)
                            .foregroundColor(Color("Button_red"))
                    }
                    .padding(.horizontal, 18)
                    .frame(height: 38)
                    .background(
                        Capsule()
                            .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.2)
                            .background(Capsule().fill(Color.white))
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Explanatory Copy
            VStack(alignment: .leading, spacing: 3) {
                Text("You can change or cancel until the store accepts your order.")
                    .font(.barlowRegular(size: 12))
                    .foregroundColor(Color("text_gary"))
                
                Text("We'll start preparing \(preparationTimeText). You can change this order until the store accepts it.")
                    .font(.barlowRegular(size: 12))
                    .foregroundColor(Color("text_gary"))
                    .lineSpacing(2)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.2)
                )
                .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 1)
        )
    }
    
    // MARK: - 6-Step Horizontal Progress Stepper Bar
    
    private var stepperProgressBar: some View {
        GeometryReader { geo in
            let totalSteps = OrderTrackingProgressStage.allCases.count
            let circleSize: CGFloat = 18
            let stepSpacing = (geo.size.width - circleSize) / CGFloat(totalSteps - 1)
            
            ZStack(alignment: .topLeading) {
                // Connecting background line behind circles
                Rectangle()
                    .fill(Color(red: 0xE8 / 255.0, green: 0xE2 / 255.0, blue: 0xD6 / 255.0))
                    .frame(height: 2.0)
                    .offset(x: circleSize / 2, y: circleSize / 2 - 1.0)
                    .frame(width: geo.size.width - circleSize)
                
                // Completed line
                if !isOrderCancelled {
                    let completedWidth = CGFloat(currentStage.rawValue) * stepSpacing
                    Rectangle()
                        .fill(Color("Button_red"))
                        .frame(width: completedWidth, height: 2.0)
                        .offset(x: circleSize / 2, y: circleSize / 2 - 1.0)
                }
                
                // Steps (Circles & Labels)
                HStack(spacing: 0) {
                    ForEach(OrderTrackingProgressStage.allCases) { stage in
                        let isCompleted = stage.rawValue < currentStage.rawValue
                        let isCurrent = stage.rawValue == currentStage.rawValue
                        
                        VStack(spacing: 6) {
                            // Circle Indicator
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: circleSize, height: circleSize)
                                
                                Circle()
                                    .stroke(
                                        isCurrent ? Color("Button_red") : (isCompleted ? Color("Button_red") : Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0)),
                                        lineWidth: isCurrent ? 2.2 : 1.5
                                    )
                                    .frame(width: circleSize, height: circleSize)
                                
                                if isCompleted {
                                    Circle()
                                        .fill(Color("Button_red"))
                                        .frame(width: 8, height: 8)
                                } else if isCurrent {
                                    Circle()
                                        .fill(Color("Button_red"))
                                        .frame(width: 6, height: 6)
                                }
                            }
                            
                            // Multi-line Label below circle
                            VStack(spacing: 1) {
                                Text(stage.labelLines[0])
                                    .font(isCurrent ? .barlowBold(size: 9.5) : .barlowRegular(size: 9.5))
                                    .foregroundColor(isCurrent ? Color("app_black") : Color("text_gary"))
                                    .lineLimit(1)
                                
                                Text(stage.labelLines[1])
                                    .font(isCurrent ? .barlowBold(size: 9.5) : .barlowRegular(size: 9.5))
                                    .foregroundColor(isCurrent ? Color("app_black") : Color("text_gary"))
                                    .lineLimit(1)
                            }
                            .multilineTextAlignment(.center)
                            .frame(width: circleSize + 36)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .frame(height: 52)
    }
    
    // MARK: - Card 2: Pickup Location Card
    
    private var pickupLocationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header Row: Building Icon + IN-STORE PICKUP AT CAPITOL HILL
            HStack(spacing: 8) {
                Image(systemName: "storefront")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color("Button_red"))
                
                Text("\(fulfillmentText.uppercased()) AT \(storeName.uppercased())")
                    .font(.oswaldMedium(size: 15.5))
                    .tracking(0.8)
                    .foregroundColor(Color("app_black"))
            }
            
            // Address Line
            Text(storeAddress)
                .font(.barlowRegular(size: 13.5))
                .foregroundColor(Color("text_gary"))
            
            // Blue Info Box
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "info.circle")
                    .font(.system(size: 15))
                    .foregroundColor(Color(red: 0x2D / 255.0, green: 0x76 / 255.0, blue: 0x8E / 255.0))
                    .padding(.top, 1)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Pickup shelf is left of the ordering counter.")
                        .font(.barlowRegular(size: 12.5))
                        .foregroundColor(Color(red: 0x1F / 255.0, green: 0x5A / 255.0, blue: 0x6F / 255.0))
                    
                    Text("Show your order name or number.")
                        .font(.barlowRegular(size: 12.5))
                        .foregroundColor(Color(red: 0x1F / 255.0, green: 0x5A / 255.0, blue: 0x6F / 255.0))
                }
                .lineSpacing(2)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(red: 0xEA / 255.0, green: 0xF5 / 255.0, blue: 0xFA / 255.0))
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.2)
                )
                .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 1)
        )
    }
    
    // MARK: - Card 3: Change Toppings Card
    
    private var changeToppingsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header Row: Red Pencil Icon + CHANGE TOPPINGS
            HStack(spacing: 8) {
                Image(systemName: "pencil")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color("Button_red"))
                
                Text("CHANGE TOPPINGS")
                    .font(.oswaldMedium(size: 15.5))
                    .tracking(0.8)
                    .foregroundColor(Color("app_black"))
            }
            
            // Description Text
            Text("You can tweak toppings and portions until the store accepts your order. Size, crust and price stay the same.")
                .font(.barlowRegular(size: 13))
                .foregroundColor(Color("text_gary"))
                .lineSpacing(2)
            
            // Red Capsule Button: EDIT TOPPINGS
            Button(action: {
                showEditToppingsSheet = true
            }) {
                Text("EDIT TOPPINGS")
                    .font(.oswaldBold(size: 14))
                    .tracking(0.8)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .frame(height: 42)
                    .background(
                        Capsule()
                            .fill(Color("Button_red"))
                            .shadow(color: Color("Button_red").opacity(0.25), radius: 4, x: 0, y: 2)
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 2)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(red: 0xFF / 255.0, green: 0xFB / 255.0, blue: 0xFC / 255.0))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color(red: 0xF3 / 255.0, green: 0xC8 / 255.0, blue: 0xD0 / 255.0), lineWidth: 1.2)
                )
                .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 1)
        )
    }
    
    // MARK: - Card 4: YOUR ORDER Card
    
    private var yourOrderCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            Text("YOUR ORDER")
                .font(.oswaldMedium(size: 17))
                .tracking(0.6)
                .foregroundColor(Color("app_black"))
            
            // Items List
            VStack(spacing: 8) {
                ForEach(items) { item in
                    HStack {
                        HStack(spacing: 6) {
                            Text("\(item.quantity)×")
                                .font(.barlowBold(size: 13.5))
                                .foregroundColor(Color("Button_red"))
                            
                            Text(item.title)
                                .font(.barlowSemiBold(size: 14))
                                .foregroundColor(Color("app_black"))
                        }
                        
                        Spacer()
                        
                        Text(item.formattedPrice)
                            .font(.barlowBold(size: 14))
                            .foregroundColor(Color("app_black"))
                    }
                }
            }
            
            Divider()
                .background(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0))
            
            // Price Breakdown Table
            VStack(spacing: 7) {
                summaryRow(title: "Subtotal", amount: String(format: "$%.2f", subtotal))
                summaryRow(title: "Estimated tax", amount: String(format: "$%.2f", tax))
                summaryRow(title: "Tip", amount: String(format: "$%.2f", tip))
            }
            
            Divider()
                .background(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0))
            
            // Total Row
            HStack {
                Text("Total")
                    .font(.barlowBold(size: 15))
                    .foregroundColor(Color("app_black"))
                
                Spacer()
                
                Text(String(format: "$%.2f", total))
                    .font(.oswaldBold(size: 16))
                    .foregroundColor(Color("app_black"))
            }
            
            // Rewards Banner 1: Enrolled Info
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "star")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(red: 0x8B / 255.0, green: 0x63 / 255.0, blue: 0x1D / 255.0))
                    .padding(.top, 1)
                
                Text("You're enrolled in MOD Rewards as ")
                    .font(.barlowRegular(size: 12))
                    .foregroundColor(Color(red: 0x5A / 255.0, green: 0x42 / 255.0, blue: 0x13 / 255.0))
                + Text(customerEmail)
                    .font(.barlowMedium(size: 12))
                    .foregroundColor(Color(red: 0x5A / 255.0, green: 0x42 / 255.0, blue: 0x13 / 255.0))
                + Text(". No promo emails.")
                    .font(.barlowRegular(size: 12))
                    .foregroundColor(Color(red: 0x5A / 255.0, green: 0x42 / 255.0, blue: 0x13 / 255.0))
            }
            .padding(11)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(red: 0xFB / 255.0, green: 0xF4 / 255.0, blue: 0xE4 / 255.0))
            )
            
            // Rewards Banner 2: Points added
            HStack(spacing: 8) {
                Image(systemName: "star")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(red: 0x8B / 255.0, green: 0x63 / 255.0, blue: 0x1D / 255.0))
                
                Text("\(earnedPoints) pts")
                    .font(.barlowBold(size: 12))
                    .foregroundColor(Color(red: 0x5A / 255.0, green: 0x42 / 255.0, blue: 0x13 / 255.0))
                + Text(" will be added when this order is completed")
                    .font(.barlowRegular(size: 12))
                    .foregroundColor(Color(red: 0x5A / 255.0, green: 0x42 / 255.0, blue: 0x13 / 255.0))
            }
            .padding(11)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(red: 0xFB / 255.0, green: 0xF4 / 255.0, blue: 0xE4 / 255.0))
            )
            
            // Action Buttons: RECEIPT & GET HELP
            HStack(spacing: 12) {
                // Receipt Button
                Button(action: {
                    showReceiptSheet = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 13, weight: .medium))
                        
                        Text("RECEIPT")
                            .font(.oswaldMedium(size: 13))
                            .tracking(0.6)
                    }
                    .foregroundColor(Color("app_black"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 38)
                    .background(
                        Capsule()
                            .stroke(Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0), lineWidth: 1.0)
                            .background(Capsule().fill(Color.white))
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // Get Help Button
                Button(action: {
                    showHelpSheet = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 13, weight: .medium))
                        
                        Text("GET HELP")
                            .font(.oswaldMedium(size: 13))
                            .tracking(0.6)
                    }
                    .foregroundColor(Color("app_black"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 38)
                    .background(
                        Capsule()
                            .stroke(Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0), lineWidth: 1.0)
                            .background(Capsule().fill(Color.white))
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.top, 4)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.2)
                )
                .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 1)
        )
    }
    
    private func summaryRow(title: String, amount: String) -> some View {
        HStack {
            Text(title)
                .font(.barlowRegular(size: 13.5))
                .foregroundColor(Color("app_black"))
            
            Spacer()
            
            Text(amount)
                .font(.barlowMedium(size: 13.5))
                .foregroundColor(Color("app_black"))
        }
    }
    
    // MARK: - Card 5: CONTACT & NOTES Card
    
    private var contactNotesCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            Text("CONTACT & NOTES")
                .font(.oswaldMedium(size: 16))
                .tracking(0.8)
                .foregroundColor(Color("app_black"))
            
            // Information Rows
            VStack(spacing: 10) {
                contactRow(label: "Name", value: customerName)
                contactRow(label: "Phone", value: customerPhone)
                contactRow(label: "Email", value: customerEmail)
                contactRow(label: "Allergens", value: allergensText)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.2)
                )
                .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 1)
        )
    }
    
    private func contactRow(label: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .font(.barlowRegular(size: 13.5))
                .foregroundColor(Color("text_gary"))
                .frame(width: 85, alignment: .leading)
            
            Spacer()
            
            Text(value)
                .font(.barlowSemiBold(size: 13.5))
                .foregroundColor(Color("app_black"))
                .multilineTextAlignment(.trailing)
        }
    }
    
    // MARK: - Receipt Data Builder
    
    private func makeReceiptData() -> ReceiptData {
        ReceiptData(
            invoiceNumber: "INV-\(Int.random(in: 4000000...5000000))",
            revision: "1",
            orderId: orderId,
            dateFormatted: "Nov 17, 2026 9:15 PM PST",
            statusText: isOrderCancelled ? "Cancelled" : "Scheduled",
            customerName: customerName,
            customerEmail: customerEmail,
            customerPhone: customerPhone,
            storeName: "MOD \(storeName)",
            storeAddress: storeAddress,
            fulfillmentMethod: fulfillmentText,
            items: items.map {
                ReceiptLineItem(name: $0.title, customization: nil, quantity: $0.quantity, price: $0.price)
            },
            pointsText: "\(earnedPoints) earned · 10/$1",
            subtotal: subtotal,
            tax: tax,
            tip: tip,
            total: total,
            serviceCredit: 0.0,
            giftWalletFunds: 0.0,
            paymentMethodName: "Card (simulated)",
            paymentMethodAmount: total
        )
    }
}

// MARK: - Previews

struct OrderTrackingView_Previews: PreviewProvider {
    static var previews: some View {
        OrderTrackingView()
    }
}

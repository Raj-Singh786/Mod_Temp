//
//  OrderSetupView.swift
//  MOD
//
//  Created by Rajpal singh on 16/11/26.
//

import SwiftUI

// MARK: - Store Model

struct OrderStoreItem: Identifiable, Equatable {
    let id: String
    let name: String
    let cityState: String
    let distance: String
    let isNearest: Bool
    let address: String
    let hours: String
    let pickupText: String
    let deliveryFeeText: String
    let prepTimeText: String
    let statusText: String
    let isAvailable: Bool
    
    var displayName: String {
        "\(name), \(cityState.components(separatedBy: ",").first ?? cityState)"
    }
}

// MARK: - Pickup Option Model

struct OrderPickupOptionItem: Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let iconName: String
}

// MARK: - Diagonal Striped Pattern (for disabled store)

struct DiagonalStripesShape: Shape {
    let spacing: CGFloat
    
    init(spacing: CGFloat = 16) {
        self.spacing = spacing
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let total = rect.width + rect.height
        for x in stride(from: -rect.height, to: total, by: spacing) {
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x + rect.height, y: rect.height))
        }
        return path
    }
}

// MARK: - OrderSetupView

struct OrderSetupView: View {
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Configuration / Inputs
    
    var initialOrderType: Int = 0 // 0: Pickup, 1: Delivery
    var currentStoreName: String = "Capitol Hill, Seattle"
    var currentDeliveryAddress: String = "Add a delivery address"
    var currentPickupOption: String = "In-store pickup"
    var currentWhenText: String = "ASAP unavailable"
    
    var onDone: ((_ orderType: Int, _ storeName: String, _ pickupOption: String, _ address: String, _ when: String) -> Void)? = nil
    
    // MARK: - State
    
    @State private var selectedOrderType: Int = 0 // 0: Pickup, 1: Delivery
    @State private var searchZipCode: String = ""
    @State private var selectedStoreId: String = "1"
    @State private var selectedPickupOptionId: String = "instore"
    @State private var isLocationFilterActive: Bool = true
    @State private var selectedWhenOption: Int = 1 // 0: ASAP, 1: Schedule for later
    
    // Delivery Address fields
    @State private var deliveryStreetAddress: String = ""
    @State private var deliveryInstructions: String = "Leave at door"
    
    // MARK: - Store List
    
    private let stores: [OrderStoreItem] = [
        OrderStoreItem(
            id: "1",
            name: "Capitol Hill",
            cityState: "Seattle, WA",
            distance: "0.4 mi",
            isNearest: true,
            address: "1302 Pine St, Seattle, WA 98101",
            hours: "9:00 AM - 12:00 AM store time · now 11:48 PM PST",
            pickupText: "Pickup",
            deliveryFeeText: "Delivery $3.99",
            prepTimeText: "~15 min prep",
            statusText: "Scheduled only",
            isAvailable: true
        ),
        OrderStoreItem(
            id: "2",
            name: "Bellevue Square",
            cityState: "Bellevue, WA",
            distance: "5.4 mi",
            isNearest: false,
            address: "575 Bellevue Sq, Bellevue, WA 98004",
            hours: "10:00 AM - 10:00 PM store time · now 11:48 PM PST",
            pickupText: "Pickup",
            deliveryFeeText: "Delivery $2.99",
            prepTimeText: "~20 min prep",
            statusText: "Scheduled only",
            isAvailable: true
        ),
        OrderStoreItem(
            id: "3",
            name: "South Congress",
            cityState: "Austin, TX",
            distance: "1,770 mi",
            isNearest: false,
            address: "1500 S Congress Ave, Austin, TX 78704",
            hours: "10:00 AM - 10:00 PM store time · now 1:48 AM CST",
            pickupText: "Pickup",
            deliveryFeeText: "No delivery",
            prepTimeText: "~15 min prep",
            statusText: "Scheduled only",
            isAvailable: true
        ),
        OrderStoreItem(
            id: "4",
            name: "Union Square",
            cityState: "New York, NY",
            distance: "2,401 mi",
            isNearest: false,
            address: "30 E 14th St, New York, NY 10003",
            hours: "11:00 AM - 11:00 PM store time · now 2:48 AM EST",
            pickupText: "Pickup",
            deliveryFeeText: "Delivery $4.99",
            prepTimeText: "~20 min prep",
            statusText: "Not accepting orders",
            isAvailable: false
        )
    ]
    
    // MARK: - Pickup Options
    
    private let pickupOptions: [OrderPickupOptionItem] = [
        OrderPickupOptionItem(
            id: "instore",
            title: "In-store pickup",
            subtitle: "Grab it from the pickup shelf",
            iconName: "storefront.fill"
        ),
        OrderPickupOptionItem(
            id: "curbside",
            title: "Curbside pickup",
            subtitle: "We bring it to your car",
            iconName: "box.truck"
        ),
        OrderPickupOptionItem(
            id: "drivethru",
            title: "Drive-thru",
            subtitle: "Pick up at the window",
            iconName: "clock"
        )
    ]
    
    // MARK: - Initializer
    
    init(
        initialOrderType: Int = 0,
        currentStoreName: String = "Capitol Hill, Seattle",
        currentDeliveryAddress: String = "Add a delivery address",
        currentPickupOption: String = "In-store pickup",
        currentWhenText: String = "ASAP unavailable",
        onDone: ((_ orderType: Int, _ storeName: String, _ pickupOption: String, _ address: String, _ when: String) -> Void)? = nil
    ) {
        self.initialOrderType = initialOrderType
        self.currentStoreName = currentStoreName
        self.currentDeliveryAddress = currentDeliveryAddress
        self.currentPickupOption = currentPickupOption
        self.currentWhenText = currentWhenText
        self.onDone = onDone
        
        _selectedOrderType = State(initialValue: initialOrderType)
        _deliveryStreetAddress = State(initialValue: currentDeliveryAddress == "Add a delivery address" ? "" : currentDeliveryAddress)
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Sheet Grab Bar & Header
                headerView
                
                // Scrollable Content
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        // 1. Pickup vs Delivery Segmented Switcher
                        segmentedSwitcher
                        
                        // 2. STORE Section
                        storeSection
                        
                        // 3. Conditional: Pickup Options vs Delivery Address
                        if selectedOrderType == 0 {
                            pickupOptionsSection
                        } else {
                            deliveryAddressSection
                        }
                        
                        // 4. WHEN Section
                        whenSection
                        
                        // Bottom spacer so content is not hidden by sticky DONE button
                        Spacer()
                            .frame(height: 90)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
            
            // Bottom Sticky Done Button
            bottomActionBar
        }
        .onAppear {
            selectedOrderType = initialOrderType
            // Match current store
            if let matched = stores.first(where: { currentStoreName.contains($0.name) }) {
                selectedStoreId = matched.id
            }
            // Match current pickup option
            if let opt = pickupOptions.first(where: { $0.title == currentPickupOption }) {
                selectedPickupOptionId = opt.id
            }
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(spacing: 10) {
            // Sheet Grab Handle
            Capsule()
                .fill(Color.gray.opacity(0.35))
                .frame(width: 38, height: 4.5)
                .padding(.top, 8)
            
            // Header Bar
            HStack(alignment: .center) {
                Text("ORDER SETUP")
                    .font(.oswaldBold(size: 22))
                    .tracking(0.6)
                    .foregroundColor(Color("app_black"))
                
                Spacer()
                
                // Close (X) Button
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color("app_black"))
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                                .background(Circle().fill(Color.white))
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 6)
        }
        .background(Color.white)
    }
    
    // MARK: - Segmented Switcher (Pickup vs Delivery)
    
    private var segmentedSwitcher: some View {
        HStack(spacing: 0) {
            // Pickup
            Button(action: {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.8)) {
                    selectedOrderType = 0
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "bag")
                        .font(.system(size: 14.5, weight: .semibold))
                    Text("Pickup")
                        .font(.barlowSemiBold(size: 15))
                }
                .foregroundColor(selectedOrderType == 0 ? Color("Button_red") : Color("app_black"))
                .frame(maxWidth: .infinity)
                .frame(height: 42)
                .background(
                    Group {
                        if selectedOrderType == 0 {
                            Capsule()
                                .fill(Color.white)
                                .overlay(
                                    Capsule()
                                        .stroke(Color("Button_red"), lineWidth: 1.8)
                                )
                                .shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: 1)
                        } else {
                            Color.clear
                        }
                    }
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // Delivery
            Button(action: {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.8)) {
                    selectedOrderType = 1
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "box.truck")
                        .font(.system(size: 14.5, weight: .semibold))
                    Text("Delivery")
                        .font(.barlowSemiBold(size: 15))
                }
                .foregroundColor(selectedOrderType == 1 ? Color("Button_red") : Color("app_black"))
                .frame(maxWidth: .infinity)
                .frame(height: 42)
                .background(
                    Group {
                        if selectedOrderType == 1 {
                            Capsule()
                                .fill(Color.white)
                                .overlay(
                                    Capsule()
                                        .stroke(Color("Button_red"), lineWidth: 1.8)
                                )
                                .shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: 1)
                        } else {
                            Color.clear
                        }
                    }
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(3)
        .background(
            Capsule()
                .fill(Color(red: 0xF3 / 255.0, green: 0xEB / 255.0, blue: 0xDF / 255.0))
        )
    }
    
    // MARK: - STORE Section
    
    private var storeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title
            Text("STORE")
                .font(.oswaldBold(size: 16))
                .tracking(0.6)
                .foregroundColor(Color("app_black"))
            
            // Search by ZIP code & Search Button
            HStack(spacing: 8) {
                HStack {
                    TextField("Search by ZIP code", text: $searchZipCode)
                        .font(.barlowRegular(size: 14))
                        .foregroundColor(Color("app_black"))
                }
                .padding(.horizontal, 14)
                .frame(height: 42)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color.white))
                )
                
                // Black Search Button
                Button(action: {
                    // Filter or search action
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 12, weight: .bold))
                        Text("SEARCH")
                            .font(.oswaldBold(size: 13))
                            .tracking(0.8)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .frame(height: 42)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color("app_black"))
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // USE MY CURRENT LOCATION Button
            Button(action: {
                withAnimation {
                    isLocationFilterActive = true
                    selectedStoreId = "1"
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "scope")
                        .font(.system(size: 14, weight: .bold))
                    Text("USE MY CURRENT LOCATION")
                        .font(.oswaldBold(size: 13.5))
                        .tracking(0.8)
                }
                .foregroundColor(Color("app_black"))
                .frame(maxWidth: .infinity)
                .frame(height: 42)
                .background(
                    Capsule()
                        .stroke(Color.gray.opacity(0.35), lineWidth: 1)
                        .background(Capsule().fill(Color.white))
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // Nearest Location Banner
            if isLocationFilterActive {
                HStack(alignment: .center, spacing: 8) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color(red: 0x4A / 255.0, green: 0x7E / 255.0, blue: 0x8F / 255.0))
                    
                    VStack(alignment: .leading, spacing: 1) {
                        HStack(spacing: 3) {
                            Text("Nearest to")
                                .font(.barlowRegular(size: 12.5))
                                .foregroundColor(Color(red: 0x2C / 255.0, green: 0x5D / 255.0, blue: 0x6E / 255.0))
                            Text("Current location (simulated:")
                                .font(.barlowBold(size: 12.5))
                                .foregroundColor(Color(red: 0x2C / 255.0, green: 0x5D / 255.0, blue: 0x6E / 255.0))
                        }
                        Text("Capitol Hill, Seattle)")
                            .font(.barlowBold(size: 12.5))
                            .foregroundColor(Color(red: 0x2C / 255.0, green: 0x5D / 255.0, blue: 0x6E / 255.0))
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            isLocationFilterActive = false
                        }
                    }) {
                        Text("Clear")
                            .font(.barlowBold(size: 13))
                            .foregroundColor(Color("Button_red"))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(red: 0xEE / 255.0, green: 0xF6 / 255.0, blue: 0xF9 / 255.0))
                )
            }
            
            // Stores List
            VStack(spacing: 12) {
                ForEach(stores) { store in
                    storeCardView(store: store)
                }
            }
        }
    }
    
    // MARK: - Store Card View
    
    private func storeCardView(store: OrderStoreItem) -> some View {
        let isSelected = selectedStoreId == store.id
        
        return Button(action: {
            guard store.isAvailable else { return }
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                selectedStoreId = store.id
            }
        }) {
            HStack(alignment: .top, spacing: 12) {
                // Radio Button
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color("Button_red") : Color.gray.opacity(0.45), lineWidth: 1.6)
                        .frame(width: 17, height: 17)
                    
                    if isSelected {
                        Circle()
                            .fill(Color("Button_red"))
                            .frame(width: 9, height: 9)
                    }
                }
                .padding(.top, 2)
                
                // Store Details
                VStack(alignment: .leading, spacing: 5) {
                    // Title & Distance Badge
                    HStack(spacing: 6) {
                        Text("\(store.name) · \(store.cityState)")
                            .font(.barlowBold(size: 14.5))
                            .foregroundColor(Color("app_black"))
                        
                        if store.isNearest {
                            Text("Nearest · \(store.distance)")
                                .font(.barlowBold(size: 11))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(Color("Button_red")))
                        } else {
                            Text(store.distance)
                                .font(.barlowBold(size: 11))
                                .foregroundColor(Color("app_black"))
                                .padding(.horizontal, 7)
                                .padding(.vertical, 2.5)
                                .background(Capsule().fill(Color(red: 0xF0 / 255.0, green: 0xEA / 255.0, blue: 0xDF / 255.0)))
                        }
                        
                        Spacer()
                    }
                    
                    // Address
                    Text(store.address)
                        .font(.barlowRegular(size: 12))
                        .foregroundColor(Color("text_gary"))
                    
                    // Hours Row
                    HStack(spacing: 5) {
                        Image(systemName: "clock")
                            .font(.system(size: 11))
                            .foregroundColor(Color("text_gary"))
                        Text(store.hours)
                            .font(.barlowRegular(size: 11.5))
                            .foregroundColor(Color("text_gary"))
                            .lineLimit(1)
                    }
                    
                    // Badges Row
                    HStack(spacing: 8) {
                        // Pickup
                        Text(store.pickupText)
                            .font(.barlowSemiBold(size: 11.5))
                            .foregroundColor(Color("app_black"))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(Color(red: 0xF6 / 255.0, green: 0xF1 / 255.0, blue: 0xE7 / 255.0))
                            )
                        
                        // Delivery fee
                        Text(store.deliveryFeeText)
                            .font(.barlowSemiBold(size: 11.5))
                            .foregroundColor(Color("app_black"))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(Color(red: 0xF6 / 255.0, green: 0xF1 / 255.0, blue: 0xE7 / 255.0))
                            )
                        
                        // Prep time
                        Text(store.prepTimeText)
                            .font(.barlowRegular(size: 11.5))
                            .foregroundColor(Color("text_gary"))
                    }
                    .padding(.top, 2)
                    
                    // Status Badge (Scheduled only / Not accepting orders)
                    if store.statusText == "Scheduled only" {
                        Text(store.statusText)
                            .font(.barlowSemiBold(size: 11))
                            .foregroundColor(Color(red: 0x9E / 255.0, green: 0x66 / 255.0, blue: 0x22 / 255.0))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(Color(red: 0xFE / 255.0, green: 0xF3 / 255.0, blue: 0xDB / 255.0))
                            )
                            .padding(.top, 2)
                    } else if store.statusText == "Not accepting orders" {
                        Text(store.statusText)
                            .font(.barlowSemiBold(size: 11))
                            .foregroundColor(Color(red: 0xB0 / 255.0, green: 0x55 / 255.0, blue: 0x20 / 255.0))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(Color(red: 0xFE / 255.0, green: 0xEB / 255.0, blue: 0xDD / 255.0))
                            )
                            .padding(.top, 2)
                    }
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                ZStack {
                    if !store.isAvailable {
                        // Diagonal striped pattern for disabled store
                        DiagonalStripesShape(spacing: 14)
                            .stroke(Color.gray.opacity(0.12), lineWidth: 2)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    } else if isSelected {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(red: 0xFF / 255.0, green: 0xFA / 255.0, blue: 0xFA / 255.0))
                    } else {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.white)
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isSelected ? Color("Button_red") : Color.gray.opacity(0.25), lineWidth: isSelected ? 1.6 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .opacity(store.isAvailable ? 1.0 : 0.85)
    }
    
    // MARK: - PICKUP OPTION Section
    
    private var pickupOptionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pickup option")
                .font(.barlowBold(size: 14.5))
                .foregroundColor(Color("app_black"))
            
            VStack(spacing: 10) {
                ForEach(pickupOptions) { option in
                    let isOptSelected = selectedPickupOptionId == option.id
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                            selectedPickupOptionId = option.id
                        }
                    }) {
                        HStack(spacing: 14) {
                            Image(systemName: option.iconName)
                                .font(.system(size: 18))
                                .foregroundColor(Color("Button_red"))
                                .frame(width: 24, height: 24)
                            
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
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(isOptSelected ? Color("Button_red") : Color.gray.opacity(0.25), lineWidth: isOptSelected ? 1.6 : 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            // Pickup Shelf Info Callout Box
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "info.circle")
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 0x4A / 255.0, green: 0x7E / 255.0, blue: 0x8F / 255.0))
                    .padding(.top, 1)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Pickup shelf is left of the ordering counter.")
                        .font(.barlowSemiBold(size: 13))
                        .foregroundColor(Color(red: 0x2C / 255.0, green: 0x5D / 255.0, blue: 0x6E / 255.0))
                    Text("Show your order name or number.")
                        .font(.barlowRegular(size: 12))
                        .foregroundColor(Color(red: 0x2C / 255.0, green: 0x5D / 255.0, blue: 0x6E / 255.0))
                }
                
                Spacer()
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color(red: 0xEE / 255.0, green: 0xF6 / 255.0, blue: 0xF9 / 255.0))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color(red: 0xD7 / 255.0, green: 0xE8 / 255.0, blue: 0xEF / 255.0), lineWidth: 1)
            )
        }
    }
    
    // MARK: - DELIVERY ADDRESS Section
    
    private var deliveryAddressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("DELIVERY ADDRESS")
                .font(.oswaldBold(size: 16))
                .tracking(0.6)
                .foregroundColor(Color("app_black"))
            
            VStack(alignment: .leading, spacing: 10) {
                // Address input
                HStack(spacing: 12) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 18))
                        .foregroundColor(Color("Button_red"))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Deliver to · Leave at door")
                            .font(.barlowRegular(size: 12))
                            .foregroundColor(Color("text_gary"))
                        
                        TextField("Enter street address or apartment", text: $deliveryStreetAddress)
                            .font(.barlowBold(size: 14.5))
                            .foregroundColor(Color("app_black"))
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color("Button_red"), lineWidth: 1.5)
                )
                
                // Delivery Instruction Chips
                HStack(spacing: 8) {
                    ForEach(["Leave at door", "Hand it to me", "Meet outside"], id: \.self) { instruction in
                        Button(action: {
                            deliveryInstructions = instruction
                        }) {
                            Text(instruction)
                                .font(.barlowSemiBold(size: 12))
                                .foregroundColor(deliveryInstructions == instruction ? Color("Button_red") : Color("app_black"))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(
                                    Capsule()
                                        .fill(deliveryInstructions == instruction ? Color(red: 0xFF / 255.0, green: 0xFA / 255.0, blue: 0xFA / 255.0) : Color(red: 0xF4 / 255.0, green: 0xEF / 255.0, blue: 0xE6 / 255.0))
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(deliveryInstructions == instruction ? Color("Button_red") : Color.clear, lineWidth: 1)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.top, 2)
            }
        }
    }
    
    // MARK: - WHEN Section
    
    private var whenSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Title
            Text("WHEN · AMERICA/LOS ANGELES STORE TIME")
                .font(.oswaldMedium(size: 13))
                .tracking(0.6)
                .foregroundColor(Color("app_black"))
            
            // Time Segment Switcher
            HStack(spacing: 0) {
                // ASAP unavailable
                Button(action: {
                    // Closed right now
                }) {
                    Text("ASAP · unavailable now")
                        .font(.barlowMedium(size: 13))
                        .foregroundColor(Color("text_gary"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background(
                            Capsule()
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(true)
                
                // Schedule for later
                Button(action: {
                    selectedWhenOption = 1
                }) {
                    Text("Schedule for later")
                        .font(.barlowBold(size: 13))
                        .foregroundColor(Color("app_black"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background(Color.clear)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(3)
            .background(
                Capsule()
                    .fill(Color(red: 0xF5 / 255.0, green: 0xEF / 255.0, blue: 0xE6 / 255.0))
            )
            
            // Amber Closed Warning Note
            VStack(alignment: .leading, spacing: 2) {
                Text("Closed for ASAP orders right now — schedule for later.")
                    .font(.barlowRegular(size: 12))
                    .foregroundColor(Color(red: 0x9E / 255.0, green: 0x66 / 255.0, blue: 0x22 / 255.0))
                Text("Choose \"Schedule for later\" to pick a time.")
                    .font(.barlowRegular(size: 12))
                    .foregroundColor(Color(red: 0x9E / 255.0, green: 0x66 / 255.0, blue: 0x22 / 255.0))
            }
            .padding(.top, 2)
        }
    }
    
    // MARK: - Bottom Action Bar
    
    private var bottomActionBar: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.gray.opacity(0.2))
            
            Button(action: {
                let chosenStore = stores.first(where: { $0.id == selectedStoreId })?.displayName ?? currentStoreName
                let chosenPickup = pickupOptions.first(where: { $0.id == selectedPickupOptionId })?.title ?? currentPickupOption
                let chosenAddress = deliveryStreetAddress.isEmpty ? "Add a delivery address" : deliveryStreetAddress
                let chosenWhen = selectedWhenOption == 0 ? "ASAP · ~15 min" : "ASAP unavailable"
                
                onDone?(selectedOrderType, chosenStore, chosenPickup, chosenAddress, chosenWhen)
                dismiss()
            }) {
                Text("DONE")
                    .font(.oswaldBold(size: 16))
                    .tracking(1.0)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        Capsule()
                            .fill(Color("Button_red"))
                            .shadow(color: Color("Button_red").opacity(0.35), radius: 6, x: 0, y: 3)
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 14)
        }
        .background(
            Color.white
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: -2)
        )
    }
}

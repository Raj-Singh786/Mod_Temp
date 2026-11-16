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

// MARK: - Schedule Date & Time Slot Models

struct OrderScheduleDateItem: Identifiable, Equatable {
    let id: Int
    let title: String
    let subtitle: String
}

struct OrderTimeSlotItem: Identifiable, Equatable {
    let id: String
    let startTime: String
    let endTime: String
    
    var displayTime: String {
        "\(startTime) -\(endTime)"
    }
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
    var autoScrollToWhen: Bool = false
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
    @State private var isScheduleExpanded: Bool = false
    @State private var selectedDateIndex: Int = 0
    @State private var selectedSlotId: String = "10:15 AM"
    
    // Delivery Address fields
    @State private var deliveryStreetAddress: String = ""
    @State private var deliveryInstructions: String = "Leave at door"
    
    // MARK: - Dates List (Dynamic from Store TimeZone)
    
    private var scheduleDates: [OrderScheduleDateItem] {
        let activeStoreName = stores.first(where: { $0.id == selectedStoreId })?.name ?? currentStoreName
        let storeTZ = AppTimeManager.shared.timeZone(forStore: activeStoreName)
        return AppTime.scheduleDates(for: storeTZ)
    }
    
    // MARK: - Morning Slots
    
    private let morningSlots: [OrderTimeSlotItem] = [
        OrderTimeSlotItem(id: "9:15 AM", startTime: "9:15 AM", endTime: "9:30"),
        OrderTimeSlotItem(id: "9:30 AM", startTime: "9:30 AM", endTime: "9:45"),
        OrderTimeSlotItem(id: "9:45 AM", startTime: "9:45 AM", endTime: "10:00"),
        OrderTimeSlotItem(id: "10:00 AM", startTime: "10:00 AM", endTime: "10:15"),
        OrderTimeSlotItem(id: "10:15 AM", startTime: "10:15 AM", endTime: "10:30"),
        OrderTimeSlotItem(id: "10:30 AM", startTime: "10:30 AM", endTime: "10:45"),
        OrderTimeSlotItem(id: "10:45 AM", startTime: "10:45 AM", endTime: "11:00"),
        OrderTimeSlotItem(id: "11:00 AM", startTime: "11:00 AM", endTime: "11:15"),
        OrderTimeSlotItem(id: "11:15 AM", startTime: "11:15 AM", endTime: "11:30"),
        OrderTimeSlotItem(id: "11:30 AM", startTime: "11:30 AM", endTime: "11:45"),
        OrderTimeSlotItem(id: "11:45 AM", startTime: "11:45 AM", endTime: "12:00")
    ]
    
    // MARK: - Afternoon Slots
    
    private let afternoonSlots: [OrderTimeSlotItem] = [
        OrderTimeSlotItem(id: "12:00 PM", startTime: "12:00 PM", endTime: "12:15"),
        OrderTimeSlotItem(id: "12:15 PM", startTime: "12:15 PM", endTime: "12:30"),
        OrderTimeSlotItem(id: "12:30 PM", startTime: "12:30 PM", endTime: "12:45"),
        OrderTimeSlotItem(id: "12:45 PM", startTime: "12:45 PM", endTime: "1:00"),
        OrderTimeSlotItem(id: "1:00 PM", startTime: "1:00 PM", endTime: "1:15"),
        OrderTimeSlotItem(id: "1:15 PM", startTime: "1:15 PM", endTime: "1:30"),
        OrderTimeSlotItem(id: "1:30 PM", startTime: "1:30 PM", endTime: "1:45"),
        OrderTimeSlotItem(id: "1:45 PM", startTime: "1:45 PM", endTime: "2:00"),
        OrderTimeSlotItem(id: "2:00 PM", startTime: "2:00 PM", endTime: "2:15"),
        OrderTimeSlotItem(id: "2:15 PM", startTime: "2:15 PM", endTime: "2:30"),
        OrderTimeSlotItem(id: "2:30 PM", startTime: "2:30 PM", endTime: "2:45"),
        OrderTimeSlotItem(id: "2:45 PM", startTime: "2:45 PM", endTime: "3:00"),
        OrderTimeSlotItem(id: "3:00 PM", startTime: "3:00 PM", endTime: "3:15"),
        OrderTimeSlotItem(id: "3:15 PM", startTime: "3:15 PM", endTime: "3:30"),
        OrderTimeSlotItem(id: "3:30 PM", startTime: "3:30 PM", endTime: "3:45"),
        OrderTimeSlotItem(id: "3:45 PM", startTime: "3:45 PM", endTime: "4:00"),
        OrderTimeSlotItem(id: "4:00 PM", startTime: "4:00 PM", endTime: "4:15"),
        OrderTimeSlotItem(id: "4:15 PM", startTime: "4:15 PM", endTime: "4:30"),
        OrderTimeSlotItem(id: "4:30 PM", startTime: "4:30 PM", endTime: "4:45"),
        OrderTimeSlotItem(id: "4:45 PM", startTime: "4:45 PM", endTime: "5:00")
    ]
    
    // MARK: - Evening Slots
    
    private let eveningSlots: [OrderTimeSlotItem] = [
        OrderTimeSlotItem(id: "5:00 PM", startTime: "5:00 PM", endTime: "5:15"),
        OrderTimeSlotItem(id: "5:15 PM", startTime: "5:15 PM", endTime: "5:30"),
        OrderTimeSlotItem(id: "5:30 PM", startTime: "5:30 PM", endTime: "5:45"),
        OrderTimeSlotItem(id: "5:45 PM", startTime: "5:45 PM", endTime: "6:00"),
        OrderTimeSlotItem(id: "6:00 PM", startTime: "6:00 PM", endTime: "6:15"),
        OrderTimeSlotItem(id: "6:15 PM", startTime: "6:15 PM", endTime: "6:30"),
        OrderTimeSlotItem(id: "6:30 PM", startTime: "6:30 PM", endTime: "6:45"),
        OrderTimeSlotItem(id: "6:45 PM", startTime: "6:45 PM", endTime: "7:00"),
        OrderTimeSlotItem(id: "7:00 PM", startTime: "7:00 PM", endTime: "7:15"),
        OrderTimeSlotItem(id: "7:15 PM", startTime: "7:15 PM", endTime: "7:30"),
        OrderTimeSlotItem(id: "7:30 PM", startTime: "7:30 PM", endTime: "7:45"),
        OrderTimeSlotItem(id: "7:45 PM", startTime: "7:45 PM", endTime: "8:00"),
        OrderTimeSlotItem(id: "8:00 PM", startTime: "8:00 PM", endTime: "8:15"),
        OrderTimeSlotItem(id: "8:15 PM", startTime: "8:15 PM", endTime: "8:30"),
        OrderTimeSlotItem(id: "8:30 PM", startTime: "8:30 PM", endTime: "8:45"),
        OrderTimeSlotItem(id: "8:45 PM", startTime: "8:45 PM", endTime: "9:00"),
        OrderTimeSlotItem(id: "9:00 PM", startTime: "9:00 PM", endTime: "9:15"),
        OrderTimeSlotItem(id: "9:15 PM", startTime: "9:15 PM", endTime: "9:30"),
        OrderTimeSlotItem(id: "9:30 PM", startTime: "9:30 PM", endTime: "9:45"),
        OrderTimeSlotItem(id: "9:45 PM", startTime: "9:45 PM", endTime: "10:00"),
        OrderTimeSlotItem(id: "10:00 PM", startTime: "10:00 PM", endTime: "10:15"),
        OrderTimeSlotItem(id: "10:15 PM", startTime: "10:15 PM", endTime: "10:30"),
        OrderTimeSlotItem(id: "10:30 PM", startTime: "10:30 PM", endTime: "10:45"),
        OrderTimeSlotItem(id: "10:45 PM", startTime: "10:45 PM", endTime: "11:00"),
        OrderTimeSlotItem(id: "11:00 PM", startTime: "11:00 PM", endTime: "11:15"),
        OrderTimeSlotItem(id: "11:15 PM", startTime: "11:15 PM", endTime: "11:30"),
        OrderTimeSlotItem(id: "11:30 PM", startTime: "11:30 PM", endTime: "11:45")
    ]
    
    // MARK: - Store List
    
    private var stores: [OrderStoreItem] {
        [
            OrderStoreItem(
                id: "1",
                name: "Capitol Hill",
                cityState: "Seattle, WA",
                distance: "0.4 mi",
                isNearest: true,
                address: "1302 Pine St, Seattle, WA 98101",
                hours: AppTimeManager.shared.storeHoursLiveString(storeName: "Capitol Hill", openTime: "9:00 AM", closeTime: "12:00 AM"),
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
                hours: AppTimeManager.shared.storeHoursLiveString(storeName: "Bellevue Square", openTime: "10:00 AM", closeTime: "10:00 PM"),
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
                hours: AppTimeManager.shared.storeHoursLiveString(storeName: "South Congress", openTime: "10:00 AM", closeTime: "10:00 PM"),
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
                hours: AppTimeManager.shared.storeHoursLiveString(storeName: "Union Square", openTime: "11:00 AM", closeTime: "11:00 PM"),
                pickupText: "Pickup",
                deliveryFeeText: "Delivery $4.99",
                prepTimeText: "~20 min prep",
                statusText: "Not accepting orders",
                isAvailable: false
            )
        ]
    }
    
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
        autoScrollToWhen: Bool = false,
        currentStoreName: String = "Capitol Hill, Seattle",
        currentDeliveryAddress: String = "Add a delivery address",
        currentPickupOption: String = "In-store pickup",
        currentWhenText: String = "ASAP unavailable",
        onDone: ((_ orderType: Int, _ storeName: String, _ pickupOption: String, _ address: String, _ when: String) -> Void)? = nil
    ) {
        self.initialOrderType = initialOrderType
        self.autoScrollToWhen = autoScrollToWhen
        self.currentStoreName = currentStoreName
        self.currentDeliveryAddress = currentDeliveryAddress
        self.currentPickupOption = currentPickupOption
        self.currentWhenText = currentWhenText
        self.onDone = onDone
        
        _selectedOrderType = State(initialValue: initialOrderType)
        _deliveryStreetAddress = State(initialValue: currentDeliveryAddress == "Add a delivery address" ? "" : currentDeliveryAddress)
        _isScheduleExpanded = State(initialValue: autoScrollToWhen)
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
                ScrollViewReader { scrollProxy in
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
                            
                            // 4. WHEN Section (with expandable time slots)
                            whenSection(scrollProxy: scrollProxy)
                            
                            // Bottom spacer so content is not hidden by sticky DONE button
                            Spacer()
                                .frame(height: 90)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    }
                    .onAppear {
                        selectedOrderType = initialOrderType
                        if autoScrollToWhen {
                            selectedWhenOption = 1
                            isScheduleExpanded = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    scrollProxy.scrollTo("when_section", anchor: .top)
                                }
                            }
                        }
                    }
                }
            }
            
            // Bottom Sticky Done Button
            bottomActionBar
        }
        .onAppear {
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
    
    // MARK: - WHEN Section (Collapsible & Expandable with Time Slots)
    
    private func whenSection(scrollProxy: ScrollViewProxy) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title dynamically reflects the active store's timezone (USA, UK, Australia, etc.)
            let activeStoreName = stores.first(where: { $0.id == selectedStoreId })?.name ?? currentStoreName
            let storeTZ = AppTimeManager.shared.timeZone(forStore: activeStoreName)
            Text("WHEN · \(AppTimeManager.shared.headerName(for: storeTZ)) STORE TIME")
                .font(.oswaldMedium(size: 13))
                .tracking(0.6)
                .foregroundColor(Color("app_black"))
            
            // Time Segment Switcher
            HStack(spacing: 0) {
                // ASAP unavailable
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        selectedWhenOption = 0
                        isScheduleExpanded = false
                    }
                }) {
                    Text("ASAP · unavailable now")
                        .font(.barlowMedium(size: 13))
                        .foregroundColor(Color("text_gary"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background(
                            Group {
                                if selectedWhenOption == 0 && !isScheduleExpanded {
                                    Capsule()
                                        .fill(Color.white)
                                        .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
                                } else {
                                    Color.clear
                                }
                            }
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(true)
                
                // Schedule for later
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        selectedWhenOption = 1
                        isScheduleExpanded = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            scrollProxy.scrollTo("when_section", anchor: .top)
                        }
                    }
                }) {
                    Text("Schedule for later")
                        .font(.barlowBold(size: 13))
                        .foregroundColor(Color("app_black"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background(
                            Group {
                                if selectedWhenOption == 1 && isScheduleExpanded {
                                    Capsule()
                                        .fill(Color.white)
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
                    .fill(Color(red: 0xF5 / 255.0, green: 0xEF / 255.0, blue: 0xE6 / 255.0))
            )
            
            // Collapsible Schedule Content (Snap 1 & Snap 2)
            if isScheduleExpanded {
                collapsibleScheduleView
            } else {
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
        .id("when_section")
    }
    
    // MARK: - Collapsible Schedule View (Snap 1 & Snap 2)
    
    private var collapsibleScheduleView: some View {
        VStack(alignment: .leading, spacing: 14) {
            // 1. Next Available Box
            Button(action: {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                    selectedDateIndex = 0
                    selectedSlotId = "9:15 AM"
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "clock")
                        .font(.system(size: 18))
                        .foregroundColor(Color("Button_red"))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Next available")
                            .font(.barlowBold(size: 15))
                            .foregroundColor(Color("app_black"))
                        Text("\(scheduleDates.first?.title ?? "Today") · 9:15 AM")
                            .font(.barlowRegular(size: 13))
                            .foregroundColor(Color("text_gary"))
                    }
                    
                    Spacer()
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // 2. Dates Horizontal Selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(scheduleDates) { dateItem in
                        let isDateSelected = selectedDateIndex == dateItem.id
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                selectedDateIndex = dateItem.id
                            }
                        }) {
                            VStack(spacing: 3) {
                                Text(dateItem.title)
                                    .font(.barlowBold(size: 14.5))
                                Text(dateItem.subtitle)
                                    .font(.barlowRegular(size: 12))
                            }
                            .foregroundColor(isDateSelected ? .white : Color("app_black"))
                            .padding(.vertical, 10)
                            .padding(.horizontal, 16)
                            .frame(minWidth: 84)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(isDateSelected ? Color("Button_red") : Color.white)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(isDateSelected ? Color("Button_red") : Color.gray.opacity(0.25), lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding(.vertical, 2)
            
            // 3. MORNING Slots Grid
            timeSlotGridSection(title: "MORNING", slots: morningSlots)
            
            // 4. AFTERNOON Slots Grid
            timeSlotGridSection(title: "AFTERNOON", slots: afternoonSlots)
            
            // 5. EVENING Slots Grid
            timeSlotGridSection(title: "EVENING", slots: eveningSlots)
            
            // 6. 15-minute windows disclaimer
            Text("15-minute windows in store time. We hold your time until checkout and recheck it when you pay. Use arrow keys to move between times.")
                .font(.barlowRegular(size: 12))
                .foregroundColor(Color("text_gary"))
                .lineSpacing(3)
                .padding(.top, 4)
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
    
    // MARK: - Time Slot Grid Section
    
    private func timeSlotGridSection(title: String, slots: [OrderTimeSlotItem]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.oswaldBold(size: 13))
                .tracking(0.8)
                .foregroundColor(Color("text_gary"))
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                ForEach(slots) { slot in
                    let isSlotSelected = selectedSlotId == slot.id
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                            selectedSlotId = slot.id
                        }
                    }) {
                        VStack(spacing: 2) {
                            Text(slot.startTime)
                                .font(.barlowBold(size: 13.5))
                            Text("-\(slot.endTime)")
                                .font(.barlowRegular(size: 11.5))
                        }
                        .foregroundColor(isSlotSelected ? .white : Color("app_black"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(isSlotSelected ? Color("Button_red") : Color.white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(isSlotSelected ? Color("Button_red") : Color.gray.opacity(0.25), lineWidth: isSlotSelected ? 2 : 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
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
                
                let chosenWhen: String
                if isScheduleExpanded || selectedWhenOption == 1 {
                    let dateTitle = scheduleDates.indices.contains(selectedDateIndex) ? scheduleDates[selectedDateIndex].title : "Today"
                    let allSlots = morningSlots + afternoonSlots + eveningSlots
                    let slotObj = allSlots.first(where: { $0.id == selectedSlotId })
                    let endTime = slotObj?.endTime
                    chosenWhen = AppTime.scheduleString(dateTitle: dateTitle, slotStartTime: slotObj?.startTime ?? selectedSlotId, slotEndTime: endTime)
                } else {
                    chosenWhen = selectedOrderType == 0 ? "ASAP · ~15 min" : "ASAP unavailable"
                }
                
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

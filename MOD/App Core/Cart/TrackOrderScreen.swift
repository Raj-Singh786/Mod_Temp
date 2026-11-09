//
//  TrackOrderScreen.swift
//  MOD
//
//  Created by Rajpal singh on 09/11/26.
//

import SwiftUI

// MARK: - Track Order Screen

struct TrackOrderScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) private var presentationMode

    // Order Properties
    var orderNumber: String = "PH-89421"
    var customerName: String = "Alex"
    var deliveryAddress: String = "450 Sutter St, Apt 8B, San Francisco, CA 94108"
    var storeName: String = "Pizza Hut Store"
    var driverName: String = "Marcus D."
    var driverRating: Double = 4.9
    var driverVehicle: String = "White Honda PCX • Lic #7XYZ89"
    var driverPhoto: String = "profile"
    var estimatedDeliveryTime: String = "5:30 PM"
    var estimatedMinutesRange: String = "10–15 mins"
    var minutesAway: Int = 12
    var totalBaseAmount: Double = 30.59
    var pointsEarned: Int = 140

    // Interactive States
    @State private var selectedTip: Double = 3.00
    @State private var customTipAmount: String = ""
    @State private var showCustomTipField: Bool = false
    @State private var isOrderSummaryExpanded: Bool = false
    @State private var showDriverChatSheet: Bool = false
    @State private var showCallAlert: Bool = false
    @State private var showHelpSheet: Bool = false
    @State private var mapPulsing: Bool = false
    @State private var driverPulsing: Bool = false
    @State private var mapZoomLevel: CGFloat = 1.0

    // Theme Colors
    private let modRed = Color(red: 0.78, green: 0.08, blue: 0.18)
    private let screenBg = Color(red: 0.98, green: 0.98, blue: 0.99)
    private let successGreen = Color(red: 0.12, green: 0.65, blue: 0.38)
    private let pillPink = Color(red: 1.0, green: 0.93, blue: 0.94)
    private let borderGray = Color(red: 0.91, green: 0.91, blue: 0.93)

    // Calculated Total including Tip
    private var grandTotalWithTip: Double {
        totalBaseAmount + (selectedTip > 0 ? selectedTip : 0.0)
    }

    var body: some View {
        VStack(spacing: 0) {
            // 1. Navigation Header
            navigationHeader

            // 2. Scrollable Body containing Live Map and Order Info
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    // Live Stylized Route Map
                    liveMapSection
                        .frame(height: 310)

                    // Bottom Order Status & Details Sheet Content
                    bottomSheetContent
                        .offset(y: -16)
                }
            }
            .background(screenBg)
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                mapPulsing = true
                driverPulsing = true
            }
        }
        .sheet(isPresented: $showDriverChatSheet) {
            DriverChatModal(driverName: driverName, driverPhoto: driverPhoto)
        }
        .alert(isPresented: $showCallAlert) {
            Alert(
                title: Text("Call Driver"),
                message: Text("Would you like to call \(driverName) at +1 (555) 789-0123?"),
                primaryButton: .default(Text("Call")) {
                    // Initiate Phone Call
                    if let url = URL(string: "tel://5557890123"), UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .actionSheet(isPresented: $showHelpSheet) {
            ActionSheet(
                title: Text("Need Help with Order #\(orderNumber)?"),
                message: Text("Our delivery support team is ready to assist you right away."),
                buttons: [
                    .default(Text("Message Delivery Support")) {},
                    .default(Text("Report Delay / Missing Item")) {},
                    .default(Text("Special Drop-off Instructions")) {},
                    .cancel()
                ]
            )
        }
    }

    // MARK: - 1. Navigation Header

    private var navigationHeader: some View {
        HStack {
            // Back Button
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                    .frame(width: 38, height: 38)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
            }

            Spacer()

            // Title & Order ID
            VStack(spacing: 2) {
                Text("Track Order")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.black)

                Text("Order #\(orderNumber)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
            }

            Spacer()

            // Trailing Brand Logo Icon
            ZStack {
                Circle()
                    .fill(pillPink)
                    .frame(width: 36, height: 36)

                Text("🍕")
                    .font(.system(size: 16))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 2)
    }

    // MARK: - 2. Live Map Section (Matching Snapshot Geometry & Route)

    private var liveMapSection: some View {
        ZStack {
            // Map Canvas: City Grid & Live Delivery Route
            MapCanvasView(driverPulsing: driverPulsing, mapPulsing: mapPulsing, modRed: modRed)
                .scaleEffect(mapZoomLevel)
                .clipped()

            // Floating Top-Left Pill: "12 mins away • On the way"
            VStack {
                HStack {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(successGreen)
                            .frame(width: 7, height: 7)

                        Text("\(minutesAway) mins away • On the way")
                            .font(.system(size: 12.5, weight: .bold))
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 3)

                    Spacer()
                }
                .padding(.top, 14)
                .padding(.leading, 14)

                Spacer()
            }

            // Floating Bottom-Right Controls: Recenter & Layers
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        // Recenter Button
                        Button(action: {
                            withAnimation(.spring()) {
                                mapZoomLevel = 1.0
                            }
                        }) {
                            Image(systemName: "scope")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
                                .frame(width: 36, height: 36)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 2)
                        }

                        // Layers Button
                        Button(action: {
                            withAnimation(.spring()) {
                                mapZoomLevel = mapZoomLevel == 1.0 ? 1.15 : 1.0
                            }
                        }) {
                            Image(systemName: "square.2.layers.3d")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
                                .frame(width: 36, height: 36)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 2)
                        }
                    }
                    .padding(.trailing, 16)
                    .padding(.bottom, 24)
                }
            }
        }
    }

    // MARK: - 3. Bottom Sheet Content

    private var bottomSheetContent: some View {
        VStack(spacing: 16) {
            // Drag Handle Pill
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 44, height: 5)
                .padding(.top, 10)

            // ETA Headline & Status Strip
            etaHeaderSection

            // Progress Timeline Stepper
            progressStepperSection

            // Driver Profile Card
            driverInfoCard

            // Driver Tipping Card
            tipDriverCard

            // Delivery Address Card
            deliveryAddressCard

            // Rewards Earned Banner
            modPointsBanner

            // Order Summary Accordion
            orderSummaryAccordion

            // Big Red Help Button (with clearance for TabBar & Home Indicator)
            needHelpButton
                .padding(.bottom, 96)
        }
        .padding(.horizontal, 16)
        .background(
            Color.white
                .clipShape(RoundedCornerShape(corners: [.topLeft, .topRight], radius: 24))
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: -4)
        )
    }

    // MARK: - 3.1 ETA Header Section

    private var etaHeaderSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Status Badges Row
            HStack {
                HStack(spacing: 5) {
                    Circle()
                        .fill(successGreen)
                        .frame(width: 6, height: 6)

                    Text("On Schedule")
                        .font(.system(size: 11.5, weight: .bold))
                        .foregroundColor(successGreen)
                }
                .padding(.horizontal, 9)
                .padding(.vertical, 4)
                .background(Color(red: 0.90, green: 0.98, blue: 0.94))
                .cornerRadius(12)

                Text(estimatedMinutesRange)
                    .font(.system(size: 12.5, weight: .medium))
                    .foregroundColor(.gray)

                Spacer()

                // Pizza Badge
                ZStack {
                    Circle()
                        .fill(pillPink)
                        .frame(width: 32, height: 32)
                    Text("🍕")
                        .font(.system(size: 14))
                }
            }

            // Headline
            Text("Estimated Delivery: \(estimatedDeliveryTime)")
                .font(.system(size: 21, weight: .bold))
                .foregroundColor(.black)

            // Red Progress Bar (approx 75% complete)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.18))
                        .frame(height: 5)

                    Capsule()
                        .fill(modRed)
                        .frame(width: geo.size.width * 0.72, height: 5)
                }
            }
            .frame(height: 5)
            .padding(.top, 4)
        }
    }

    // MARK: - 3.2 Progress Stepper (Confirmed -> In Oven -> On The Way -> Delivered)

    private var progressStepperSection: some View {
        let steps = [
            (title: "Confirmed", time: "9:48 PM", isDone: true, isCurrent: false, icon: "checkmark"),
            (title: "In Oven", time: "9:56 PM", isDone: true, isCurrent: false, icon: "checkmark"),
            (title: "On the way", time: "10:03 PM", isDone: true, isCurrent: true, icon: "bicycle"),
            (title: "Delivered", time: "10:15 PM", isDone: false, isCurrent: false, icon: "house.fill")
        ]

        return HStack(alignment: .top, spacing: 0) {
            ForEach(0..<steps.count, id: \.self) { index in
                let step = steps[index]
                VStack(spacing: 6) {
                    // Node Circle
                    ZStack {
                        if step.isCurrent {
                            Circle()
                                .fill(modRed)
                                .frame(width: 28, height: 28)
                                .shadow(color: modRed.opacity(0.35), radius: 5, x: 0, y: 2)

                            Image(systemName: "bicycle")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        } else if step.isDone {
                            Circle()
                                .fill(successGreen)
                                .frame(width: 28, height: 28)

                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .heavy))
                                .foregroundColor(.white)
                        } else {
                            Circle()
                                .stroke(Color.gray.opacity(0.35), lineWidth: 1.5)
                                .background(Circle().fill(Color.gray.opacity(0.06)))
                                .frame(width: 28, height: 28)

                            Image(systemName: "house.fill")
                                .font(.system(size: 11))
                                .foregroundColor(Color.gray.opacity(0.5))
                        }
                    }

                    // Title
                    Text(step.title)
                        .font(.system(size: 11, weight: step.isCurrent ? .bold : (step.isDone ? .semibold : .medium)))
                        .foregroundColor(step.isCurrent ? modRed : (step.isDone ? .black : .gray))
                        .lineLimit(1)

                    // Time
                    Text(step.time)
                        .font(.system(size: 10, weight: step.isCurrent ? .bold : .regular))
                        .foregroundColor(step.isCurrent ? modRed : .gray)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 8)
    }

    // MARK: - 3.3 Driver Info Card

    private var driverInfoCard: some View {
        HStack(spacing: 12) {
            // Driver Avatar with Verified Badge
            ZStack(alignment: .bottomTrailing) {
                if let _ = UIImage(named: driverPhoto) {
                    Image(driverPhoto)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 48, height: 48)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color(red: 0.94, green: 0.90, blue: 0.88))
                        .frame(width: 48, height: 48)
                    Text("👨🏽‍🍳")
                        .font(.system(size: 24))
                }

                // Green Verified Checkmark
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 15))
                    .foregroundColor(successGreen)
                    .background(Color.white.clipShape(Circle()))
                    .offset(x: 2, y: 2)
            }

            // Driver Name, Rating & Vehicle
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(driverName)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.black)

                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(Color(red: 0.95, green: 0.65, blue: 0.10))

                        Text(String(format: "%.1f", driverRating))
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color(red: 0.55, green: 0.35, blue: 0.05))
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color(red: 0.99, green: 0.95, blue: 0.82))
                    .cornerRadius(6)
                }

                Text(driverVehicle)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }

            Spacer()

            // Chat Button
            Button(action: {
                showDriverChatSheet = true
            }) {
                Image(systemName: "message.fill")
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 0.25, green: 0.28, blue: 0.35))
                    .frame(width: 38, height: 38)
                    .background(Color.gray.opacity(0.10))
                    .clipShape(Circle())
            }

            // Call Button (Red Circle)
            Button(action: {
                showCallAlert = true
            }) {
                Image(systemName: "phone.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .frame(width: 38, height: 38)
                    .background(modRed)
                    .clipShape(Circle())
                    .shadow(color: modRed.opacity(0.35), radius: 5, x: 0, y: 2)
            }
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(borderGray, lineWidth: 1)
        )
    }

    // MARK: - 3.4 Driver Tip Card

    private var tipDriverCard: some View {
        VStack(spacing: 12) {
            // Header Row: Icon + Title + Optional Tag
            HStack(alignment: .top, spacing: 10) {
                ZStack {
                    Circle()
                        .fill(pillPink)
                        .frame(width: 34, height: 34)

                    Image(systemName: "heart.fill")
                        .font(.system(size: 14))
                        .foregroundColor(modRed)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Tip \(driverName)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)

                    Text("100% of tips go directly to your driver")
                        .font(.system(size: 11.5))
                        .foregroundColor(.gray)
                }

                Spacer()

                Text("Optional")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color(red: 0.12, green: 0.65, blue: 0.38))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Color(red: 0.90, green: 0.98, blue: 0.94))
                    .cornerRadius(6)
            }

            // Tip Option Pills: $2.00 | $3.00 | $5.00 | Custom
            HStack(spacing: 10) {
                tipButton(amount: 2.00, title: "5%")
                tipButton(amount: 3.00, title: "10%")
                tipButton(amount: 5.00, title: "15%")
                customTipButton
            }

            // Custom Tip Input Field (if selected)
            if showCustomTipField {
                HStack {
                    Text("$")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                    TextField("Enter custom tip", text: $customTipAmount)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 14))
                        .onChange(of: customTipAmount) { newVal in
                            if let val = Double(newVal) {
                                selectedTip = val
                            }
                        }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(red: 0.97, green: 0.97, blue: 0.98))
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(modRed.opacity(0.5), lineWidth: 1))
            }

            // Thank You Footer Note
            Text("Thank you for supporting our delivery team!")
                .font(.system(size: 11.5, weight: .regular))
                .foregroundColor(.gray)
                .padding(.top, 2)
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(borderGray, lineWidth: 1)
        )
    }

    private func tipButton(amount: Double, title: String) -> some View {
        let isSelected = selectedTip == amount && !showCustomTipField

        return Button(action: {
            selectedTip = amount
            showCustomTipField = false
        }) {
            Text(title)
                .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? modRed : .black)
                .frame(maxWidth: .infinity)
                .frame(height: 38)
                .background(isSelected ? pillPink : Color.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? modRed : borderGray, lineWidth: isSelected ? 1.5 : 1)
                )
        }
    }

    private var customTipButton: some View {
        Button(action: {
            showCustomTipField = true
            selectedTip = 0.0
        }) {
            Text("Custom")
                .font(.system(size: 13, weight: showCustomTipField ? .bold : .medium))
                .foregroundColor(showCustomTipField ? modRed : .black)
                .frame(maxWidth: .infinity)
                .frame(height: 38)
                .background(showCustomTipField ? pillPink : Color.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(showCustomTipField ? modRed : borderGray, lineWidth: showCustomTipField ? 1.5 : 1)
                )
        }
    }

    // MARK: - 3.5 Delivery Address & Drop-Off Instruction Card

    private var deliveryAddressCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Top Row: Pin + Address + Contactless Badge
            HStack(alignment: .top, spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(pillPink)
                        .frame(width: 36, height: 36)

                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(modRed)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Delivery Address")
                        .font(.system(size: 13.5, weight: .bold))
                        .foregroundColor(.black)

                    Text("450 Sutter St, Apt 8B")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.black)

                    Text("San Francisco, CA 94108")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }

                Spacer()

                Text("Contactless")
                    .font(.system(size: 10.5, weight: .bold))
                    .foregroundColor(successGreen)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color(red: 0.90, green: 0.98, blue: 0.94))
                    .cornerRadius(8)
            }

            // Instruction Strip
            HStack(spacing: 6) {
                Image(systemName: "info.circle")
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 0.60, green: 0.40, blue: 0.10))

                Text("Instruction: Meet at door • Ring bell 8B")
                    .font(.system(size: 11.5, weight: .medium))
                    .foregroundColor(Color(red: 0.50, green: 0.35, blue: 0.10))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(red: 0.99, green: 0.97, blue: 0.88))
            .cornerRadius(8)
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(borderGray, lineWidth: 1)
        )
    }

    // MARK: - 3.6 MOD Points Banner

    private var modPointsBanner: some View {
        HStack(spacing: 10) {
            Text("🎉")
                .font(.system(size: 18))

            VStack(alignment: .leading, spacing: 2) {
                Text("+\(pointsEarned) MOD Points Earned")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.05))

                Text("Will be automatically credited upon delivery")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }

            Spacer()

            ZStack {
                Circle()
                    .fill(Color(red: 0.98, green: 0.88, blue: 0.65))
                    .frame(width: 26, height: 26)

                Image(systemName: "star.fill")
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 0.75, green: 0.45, blue: 0.05))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(red: 0.99, green: 0.97, blue: 0.92))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(red: 0.95, green: 0.88, blue: 0.72), lineWidth: 1)
        )
    }

    // MARK: - 3.7 Order Summary Accordion

    private var orderSummaryAccordion: some View {
        VStack(spacing: 0) {
            Button(action: {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    isOrderSummaryExpanded.toggle()
                }
            }) {
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "doc.plaintext.fill")
                            .font(.system(size: 15))
                            .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.45))

                        Text("Order Summary (3 items)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.black)
                    }

                    Spacer()

                    Text("$\(String(format: "%.2f", grandTotalWithTip))")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)

                    Image(systemName: isOrderSummaryExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.gray)
                        .padding(.leading, 4)
                }
                .padding(14)
            }

            // Expanded Itemized Receipt Breakdown
            if isOrderSummaryExpanded {
                VStack(spacing: 8) {
                    Divider()
                        .padding(.horizontal, 14)

                    VStack(spacing: 6) {
                        receiptItemRow(title: "1x Pepperoni & Cream Cheese", subtitle: "Medium • Pan Crust", price: 17.90)
                        receiptItemRow(title: "1x Pepperoni Breadsticks", subtitle: "Marinara Dip incl.", price: 5.90)
                        receiptItemRow(title: "2x Coca-Cola Original Can", subtitle: "12 fl oz • Chilled", price: 4.80)
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 4)

                    Divider()
                        .padding(.horizontal, 14)

                    VStack(spacing: 4) {
                        summaryCostRow(label: "Items Subtotal", value: "$28.60")
                        summaryCostRow(label: "Delivery Fee", value: "$2.99")
                        summaryCostRow(label: "Promo (WELCOME10)", value: "-$5.00", isDiscount: true)
                        if selectedTip > 0 {
                            summaryCostRow(label: "Driver Tip", value: "+$\(String(format: "%.2f", selectedTip))", isHighlight: true)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.bottom, 12)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color.white)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(borderGray, lineWidth: 1)
        )
    }

    private func receiptItemRow(title: String, subtitle: String, price: Double) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12.5, weight: .semibold))
                    .foregroundColor(.black)
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }
            Spacer()
            Text("$\(String(format: "%.2f", price))")
                .font(.system(size: 12.5, weight: .bold))
                .foregroundColor(.black)
        }
    }

    private func summaryCostRow(label: String, value: String, isDiscount: Bool = false, isHighlight: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.system(size: 12, weight: (isDiscount || isHighlight) ? .bold : .medium))
                .foregroundColor(isDiscount ? successGreen : (isHighlight ? modRed : .black))
        }
    }

    // MARK: - 3.8 Big Red Help Button

    private var needHelpButton: some View {
        Button(action: {
            showHelpSheet = true
        }) {
            HStack(spacing: 8) {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 16))

                Text("Need Help with this Order?")
                    .font(.system(size: 15, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(modRed)
            .cornerRadius(14)
            .shadow(color: modRed.opacity(0.35), radius: 8, x: 0, y: 4)
        }
    }
}

// MARK: - Map Canvas View (Custom Vector Map Matching Snapshot)

struct MapCanvasView: View {
    var driverPulsing: Bool
    var mapPulsing: Bool
    var modRed: Color

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                // Background Base
                Color(red: 0.93, green: 0.95, blue: 0.97)

                // City Blocks & Green Parks
                drawCityBlocks(w: w, h: h)

                // White Road Grid Lines
                drawStreetRoads(w: w, h: h)

                // Active Route Path
                drawRoutePath(w: w, h: h)

                // Store Origin Pin (Top Left)
                storeOriginPin(x: w * 0.16, y: h * 0.40)

                // Destination Pin (Bottom Right)
                destinationPin(x: w * 0.81, y: h * 0.68)

                // Driver Position with Pulsing Aura
                driverMarker(x: w * 0.60, y: h * 0.50)
            }
        }
    }

    // MARK: City Blocks & Parks
    @ViewBuilder
    private func drawCityBlocks(w: CGFloat, h: CGFloat) -> some View {
        Canvas { context, size in
            // Park 1 (Top-Left)
            let parkColor = Color(red: 0.86, green: 0.94, blue: 0.89)
            context.fill(Path(CGRect(x: w * 0.05, y: h * 0.12, width: w * 0.22, height: h * 0.18)), with: .color(parkColor))
            context.fill(Path(CGRect(x: w * 0.05, y: h * 0.68, width: w * 0.20, height: h * 0.22)), with: .color(parkColor))
            context.fill(Path(CGRect(x: w * 0.78, y: h * 0.18, width: w * 0.18, height: h * 0.24)), with: .color(parkColor))
        }
    }

    // MARK: Street Roads Network
    @ViewBuilder
    private func drawStreetRoads(w: CGFloat, h: CGFloat) -> some View {
        Canvas { context, size in
            let roadWhite = Color.white
            let roadStroke = StrokeStyle(lineWidth: 16, lineCap: .round, lineJoin: .round)

            // Horizontal Avenues
            var p1 = Path()
            p1.move(to: CGPoint(x: 0, y: h * 0.35))
            p1.addLine(to: CGPoint(x: w, y: h * 0.35))
            context.stroke(p1, with: .color(roadWhite), style: roadStroke)

            var p2 = Path()
            p2.move(to: CGPoint(x: 0, y: h * 0.65))
            p2.addLine(to: CGPoint(x: w, y: h * 0.65))
            context.stroke(p2, with: .color(roadWhite), style: roadStroke)

            // Vertical Streets
            var pv1 = Path()
            pv1.move(to: CGPoint(x: w * 0.33, y: 0))
            pv1.addLine(to: CGPoint(x: w * 0.33, y: h))
            context.stroke(pv1, with: .color(roadWhite), style: roadStroke)

            var pv2 = Path()
            pv2.move(to: CGPoint(x: w * 0.54, y: 0))
            pv2.addLine(to: CGPoint(x: w * 0.54, y: h))
            context.stroke(pv2, with: .color(roadWhite), style: roadStroke)

            var pv3 = Path()
            pv3.move(to: CGPoint(x: w * 0.74, y: 0))
            pv3.addLine(to: CGPoint(x: w * 0.74, y: h))
            context.stroke(pv3, with: .color(roadWhite), style: roadStroke)

            // Main Diagonal Highway
            var pd = Path()
            pd.move(to: CGPoint(x: 0, y: h * 0.85))
            pd.addLine(to: CGPoint(x: w * 0.88, y: 0))
            context.stroke(pd, with: .color(roadWhite), style: StrokeStyle(lineWidth: 22, lineCap: .round))
        }
    }

    // MARK: Route Path (Solid completed + Dashed remaining)
    @ViewBuilder
    private func drawRoutePath(w: CGFloat, h: CGFloat) -> some View {
        // Path 1: Solid Red Route (Store to Driver)
        Path { path in
            path.move(to: CGPoint(x: w * 0.16, y: h * 0.40))
            path.addLine(to: CGPoint(x: w * 0.32, y: h * 0.40))
            path.addLine(to: CGPoint(x: w * 0.60, y: h * 0.50))
        }
        .stroke(modRed, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))

        // Path 2: Dashed Crimson Route (Driver to Destination)
        Path { path in
            path.move(to: CGPoint(x: w * 0.60, y: h * 0.50))
            path.addLine(to: CGPoint(x: w * 0.74, y: h * 0.54))
            path.addLine(to: CGPoint(x: w * 0.75, y: h * 0.68))
            path.addLine(to: CGPoint(x: w * 0.81, y: h * 0.68))
        }
        .stroke(modRed, style: StrokeStyle(lineWidth: 3.5, lineCap: .round, lineJoin: .round, dash: [6, 4]))
    }

    // MARK: Store Origin Pin
    @ViewBuilder
    private func storeOriginPin(x: CGFloat, y: CGFloat) -> some View {
        ZStack {
            // Dark Store Tag
            VStack(spacing: 0) {
                Text("Pizza Hut Store")
                    .font(.system(size: 9.5, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Color(red: 0.15, green: 0.18, blue: 0.22))
                    .cornerRadius(4)
                    .offset(x: 10, y: -22)

                // Store Pin Circle
                ZStack {
                    Circle()
                        .fill(modRed)
                        .frame(width: 22, height: 22)
                        .overlay(Circle().stroke(Color.white, lineWidth: 3))
                        .shadow(color: Color.black.opacity(0.18), radius: 4, x: 0, y: 2)

                    Circle()
                        .fill(Color.white)
                        .frame(width: 6, height: 6)
                }
            }
        }
        .position(x: x, y: y)
    }

    // MARK: Driver Location Marker (Motorcycle Icon with Pulsing Halo)
    @ViewBuilder
    private func driverMarker(x: CGFloat, y: CGFloat) -> some View {
        ZStack {
            // Pulsing Concentric Outer Ring
            Circle()
                .fill(modRed.opacity(0.15))
                .frame(width: 52, height: 52)
                .scaleEffect(driverPulsing ? 1.25 : 0.95)

            // Middle Halo
            Circle()
                .fill(modRed.opacity(0.25))
                .frame(width: 38, height: 38)

            // Core Driver Red Circle
            Circle()
                .fill(modRed)
                .frame(width: 26, height: 26)
                .overlay(Circle().stroke(Color.white, lineWidth: 2.5))
                .shadow(color: modRed.opacity(0.4), radius: 6, x: 0, y: 3)

            // Bike Icon
            Image(systemName: "bicycle")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white)
        }
        .position(x: x, y: y)
    }

    // MARK: Destination Pin
    @ViewBuilder
    private func destinationPin(x: CGFloat, y: CGFloat) -> some View {
        ZStack {
            // Destination Rings
            Circle()
                .fill(modRed.opacity(0.18))
                .frame(width: 44, height: 44)
                .scaleEffect(mapPulsing ? 1.15 : 0.95)

            Circle()
                .fill(modRed)
                .frame(width: 20, height: 20)
                .overlay(Circle().stroke(Color.white, lineWidth: 2.5))
                .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)

            Circle()
                .fill(Color.white)
                .frame(width: 6, height: 6)

            // Address Label Tag
            HStack(spacing: 4) {
                Image(systemName: "scope")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(modRed)

                Text("450 Sutter St")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.black)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
            .offset(x: 28, y: 18)
        }
        .position(x: x, y: y)
    }
}

// MARK: - Driver Chat Modal Sheet

struct DriverChatModal: View {
    @Environment(\.dismiss) private var dismiss

    var driverName: String
    var driverPhoto: String

    @State private var messageText: String = ""
    @State private var messages: [ChatMessage] = [
        ChatMessage(text: "Hi Alex! I just picked up your order from the oven. On my way now!", isUser: false, time: "10:04 PM"),
        ChatMessage(text: "Awesome, thank you Marcus!", isUser: true, time: "10:05 PM")
    ]

    private let modRed = Color(red: 0.78, green: 0.08, blue: 0.18)

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Chat List
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(messages) { msg in
                            HStack {
                                if msg.isUser { Spacer() }

                                VStack(alignment: msg.isUser ? .trailing : .leading, spacing: 3) {
                                    Text(msg.text)
                                        .font(.system(size: 14))
                                        .foregroundColor(msg.isUser ? .white : .black)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 10)
                                        .background(msg.isUser ? modRed : Color(red: 0.94, green: 0.94, blue: 0.96))
                                        .cornerRadius(16)

                                    Text(msg.time)
                                        .font(.system(size: 10))
                                        .foregroundColor(.gray)
                                }

                                if !msg.isUser { Spacer() }
                            }
                        }
                    }
                    .padding(16)
                }

                // Quick Reply Chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        quickChip("I'm at the door")
                        quickChip("Please ring the bell")
                        quickChip("Leave it on the porch")
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }

                // Message Input Row
                HStack(spacing: 10) {
                    TextField("Message \(driverName)...", text: $messageText)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color(red: 0.95, green: 0.95, blue: 0.97))
                        .cornerRadius(20)

                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(messageText.isEmpty ? .gray.opacity(0.4) : modRed)
                    }
                    .disabled(messageText.isEmpty)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.white)
            }
            .navigationBarTitle("Chat with \(driverName)", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() }.foregroundColor(modRed).font(.system(size: 15, weight: .bold)))
        }
    }

    private func quickChip(_ text: String) -> some View {
        Button(action: {
            messageText = text
        }) {
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.black)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.gray.opacity(0.12))
                .cornerRadius(16)
        }
    }

    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let newMsg = ChatMessage(text: messageText, isUser: true, time: "Just now")
        messages.append(newMsg)
        messageText = ""
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let time: String
}

// MARK: - Custom Rounded Corner Shape

struct RoundedCornerShape: Shape {
    var corners: UIRectCorner = .allCorners
    var radius: CGFloat = 16

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        TrackOrderScreen()
    }
}

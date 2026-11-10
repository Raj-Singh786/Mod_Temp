//
//  ConfirmOrderScreen.swift
//  MOD
//
//  Created by Rajpal singh on 09/11/26.
//

import SwiftUI

// MARK: - Order Confirmed Screen

struct ConfirmOrderScreen: View {
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.dismiss) private var dismiss

    // Order Properties
    var orderNumber: String = "PH-89421"
    var customerName: String = "Alex"
    var contactNumber: String = ""
    var deliveryAddress: String = "450 Sutter St, Apt 8B, San Francisco, CA 94108"
    var orderType: CartOrderType = .delivery
    var itemCount: Int = 3
    var paymentMethod: String = "Apple Pay"
    var totalAmount: Double = 30.59
    var estimatedArrival: String = "10:15 PM"
    var pointsEarned: Int = 140

    // Animation & Feedback State
    @State private var checkmarkScale: CGFloat = 0.6
    @State private var checkmarkOpacity: Double = 0.0
    @State private var haloPulsing: Bool = false
    @State private var showHelpSheet: Bool = false
    @State private var showTrackOrderScreen: Bool = false

    // App Colors
    private let modRed = Color(red: 0.78, green: 0.08, blue: 0.18)
    private let screenBg = Color(red: 0.98, green: 0.98, blue: 0.99)
    private let successGreen = Color(red: 0.12, green: 0.65, blue: 0.38)
    private let pillPink = Color(red: 1.0, green: 0.93, blue: 0.94)

    // Formatted Address Splitting
    private var primaryAddressLine: String {
        let parts = deliveryAddress.components(separatedBy: ",")
        if parts.count >= 2 {
            return "\(parts[0].trimmingCharacters(in: .whitespaces)), \(parts[1].trimmingCharacters(in: .whitespaces))"
        }
        return deliveryAddress
    }

    private var secondaryAddressLine: String {
        let parts = deliveryAddress.components(separatedBy: ",")
        if parts.count >= 3 {
            return parts.dropFirst(2).joined(separator: ",").trimmingCharacters(in: .whitespaces)
        }
        return "San Francisco, CA 94108"
    }

    private var isGuest: Bool {
        (UserDefaults.standard.object(forKey: "isGuestUser") as? Bool) ?? true
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                // Top Celebration Graphic
                celebrationGraphicSection

                // Title & Order Summary Text
                headerInfoSection

                // Card 1: Live Status Progress Stepper
                liveStatusCard

                // Card 2: Delivery / Pickup Details
                orderDetailsCard

                // Bottom Action Buttons
                actionButtonsSection

                // Optional subtle support link (Call restaurant removed as requested)
                supportFooterSection

                // Bottom Safe Spacing (Clearance for TabBar & Home Indicator)
                Color.clear.frame(height: 96)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
        .background(screenBg.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.65)) {
                checkmarkScale = 1.0
                checkmarkOpacity = 1.0
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                haloPulsing = true
            }
        }
        .fullScreenCover(isPresented: $showTrackOrderScreen) {
            TrackOrderScreen(
                orderNumber: orderNumber,
                customerName: customerName,
                deliveryAddress: deliveryAddress,
                estimatedDeliveryTime: estimatedArrival,
                totalBaseAmount: totalAmount,
                pointsEarned: pointsEarned
            )
        }
        .actionSheet(isPresented: $showHelpSheet) {
            ActionSheet(
                title: Text("Need Help with Order #\(orderNumber)?"),
                message: Text("Our customer support team is available 24/7 to assist you."),
                buttons: [
                    .default(Text("Live Chat Support")) {},
                    .default(Text("Report an Issue with this Order")) {},
                    .cancel()
                ]
            )
        }
    }

    // MARK: - 1. Celebration Graphic Section

    private var celebrationGraphicSection: some View {
        ZStack {
            // Outer soft rose glow ring
            Circle()
                .fill(Color(red: 1.0, green: 0.93, blue: 0.94).opacity(haloPulsing ? 0.95 : 0.65))
                .frame(width: 156, height: 156)
                .scaleEffect(haloPulsing ? 1.05 : 0.98)

            // Middle soft ring
            Circle()
                .fill(Color(red: 1.0, green: 0.88, blue: 0.90).opacity(0.95))
                .frame(width: 120, height: 120)

            // Core Red Circle
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.88, green: 0.10, blue: 0.20),
                            Color(red: 0.74, green: 0.05, blue: 0.14)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 86, height: 86)
                .shadow(color: modRed.opacity(0.40), radius: 12, x: 0, y: 6)

            // Center White Checkmark
            Image(systemName: "checkmark")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.white)
                .scaleEffect(checkmarkScale)
                .opacity(checkmarkOpacity)

            // Floating Badge 1 (Top-Right): Pizza Icon
            ZStack {
                Circle()
                    .fill(Color(red: 0.98, green: 0.73, blue: 0.16))
                    .frame(width: 32, height: 32)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2.5))
                    .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)

                Text("🍕")
                    .font(.system(size: 15))
            }
            .offset(x: 36, y: -36)

            // Floating Badge 2 (Bottom-Left): Timer Icon
            ZStack {
                Circle()
                    .fill(Color(red: 0.14, green: 0.72, blue: 0.44))
                    .frame(width: 32, height: 32)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2.5))
                    .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)

                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            .offset(x: -36, y: 36)
        }
        .padding(.top, 18)
        .padding(.bottom, 4)
    }

    // MARK: - 2. Header Info Section

    private var headerInfoSection: some View {
        VStack(spacing: 6) {
            // Title
            Text("Order Confirmed!")
                .font(.system(size: 25, weight: .bold))
                .foregroundColor(.black)

            // Order Number
            Text("ORDER #\(orderNumber)")
                .font(.system(size: 13, weight: .heavy))
                .foregroundColor(modRed)
                .tracking(0.8)

            // Personalized Message
            (
                Text("Awesome, ")
                + Text(customerName.isEmpty ? "Friend" : customerName).bold()
                + Text("! Your order has been placed and is currently being freshly prepared in our oven.")
            )
            .font(.system(size: 13.5))
            .foregroundColor(.gray)
            .multilineTextAlignment(.center)
            .lineSpacing(3)
            .padding(.horizontal, 20)
            .padding(.top, 4)

            // Rewards Points Pill Banner
            HStack(spacing: 6) {
                Text("🎉")
                    .font(.system(size: 13))

                (
                    Text("You earned ")
                        .font(.system(size: 12.5, weight: .medium))
                        .foregroundColor(.black)
                    + Text("+\(pointsEarned) Hut Points")
                        .font(.system(size: 12.5, weight: .bold))
                        .foregroundColor(modRed)
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(red: 0.99, green: 0.98, blue: 0.93))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(red: 0.96, green: 0.88, blue: 0.65), lineWidth: 1)
            )
            .padding(.top, 6)
        }
    }

    // MARK: - 3. Card 1: Live Status Card

    private var liveStatusCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            // Header Row
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(successGreen)
                        .frame(width: 7, height: 7)

                    Text("LIVE STATUS")
                        .font(.system(size: 11.5, weight: .heavy))
                        .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.45))
                        .tracking(0.6)
                }

                Spacer()

                Text("Est. Arrival: \(estimatedArrival)")
                    .font(.system(size: 11.5, weight: .bold))
                    .foregroundColor(modRed)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(pillPink)
                    .cornerRadius(8)
            }

            // Horizontal Stepper Progress Pipeline
            stepperView
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.gray.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 3)
    }

    private var stepperView: some View {
        let steps = [
            (title: "Received", icon: "checkmark", isDone: true, isCurrent: false),
            (title: "In Oven", icon: "flame.fill", isDone: true, isCurrent: true),
            (title: orderType == .pickup ? "Ready" : "On The Way", icon: orderType == .pickup ? "bag.fill" : "car.fill", isDone: false, isCurrent: false),
            (title: orderType == .pickup ? "Picked Up" : "Delivered", icon: "house.fill", isDone: false, isCurrent: false)
        ]

        return VStack(spacing: 8) {
            // Stepper Circles & Lines
            HStack(spacing: 0) {
                ForEach(0..<steps.count, id: \.self) { index in
                    let step = steps[index]

                    // Step Node Circle
                    ZStack {
                        Circle()
                            .fill(step.isDone ? modRed : Color.gray.opacity(0.14))
                            .frame(width: 28, height: 28)

                        Image(systemName: step.icon)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(step.isDone ? .white : .gray.opacity(0.65))
                    }

                    // Connector line between nodes
                    if index < steps.count - 1 {
                        let nextStep = steps[index + 1]
                        Rectangle()
                            .fill(step.isDone && nextStep.isDone ? modRed : Color.gray.opacity(0.22))
                            .frame(height: 2.5)
                    }
                }
            }
            .padding(.horizontal, 10)

            // Step Labels
            HStack(spacing: 0) {
                ForEach(0..<steps.count, id: \.self) { index in
                    let step = steps[index]
                    Text(step.title)
                        .font(.system(size: 11, weight: step.isCurrent ? .bold : (step.isDone ? .semibold : .regular)))
                        .foregroundColor(step.isCurrent ? modRed : (step.isDone ? .black : .gray))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }

    // MARK: - 4. Card 2: Order Details Card

    private var orderDetailsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Top Location Row
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(pillPink)
                        .frame(width: 36, height: 36)

                    Image(systemName: orderType == .pickup ? "storefront.fill" : "mappin.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(modRed)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(orderType == .pickup ? "PICKUP LOCATION" : "DELIVERY ADDRESS")
                        .font(.system(size: 11, weight: .heavy))
                        .foregroundColor(Color.gray)
                        .tracking(0.5)

                    Text(orderType == .pickup ? "Downtown Hut #1204" : primaryAddressLine)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)

                    Text(orderType == .pickup ? "452 Market St, San Francisco, CA (0.8 mi away)" : secondaryAddressLine)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }

                Spacer()

                Text(orderType == .pickup ? "10–15 mins" : "25–35 mins")
                    .font(.system(size: 11.5, weight: .bold))
                    .foregroundColor(successGreen)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(Color(red: 0.90, green: 0.98, blue: 0.94))
                    .cornerRadius(6)
            }

            Divider()

            // Bottom Summary Row: Items Count • Payment Method • Price
            HStack {
                Text("\(itemCount) Items  •  Paid with \(paymentMethod)")
                    .font(.system(size: 12.5, weight: .medium))
                    .foregroundColor(.gray)

                Spacer()

                Text("$\(String(format: "%.2f", totalAmount))")
                    .font(.system(size: 15.5, weight: .heavy))
                    .foregroundColor(.black)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.gray.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 3)
    }

    // MARK: - 5. Bottom Action Buttons

    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            // Track Your Order Button (Primary Red)
            Button(action: handleTrackOrder) {
                HStack(spacing: 8) {
                    Text("Track Your Order")
                        .font(.system(size: 15, weight: .bold))

                    Image(systemName: "arrow.right")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(modRed)
                .cornerRadius(14)
                .shadow(color: modRed.opacity(0.35), radius: 8, x: 0, y: 4)
            }

            // Back to Home Button (Secondary Soft Light Gray)
            Button(action: handleBackToHome) {
                Text("Back to Home")
                    .font(.system(size: 14.5, weight: .bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color(red: 0.94, green: 0.94, blue: 0.96))
                    .cornerRadius(14)
            }
        }
        .padding(.top, 4)
    }

    // MARK: - 6. Support Footer Section
    // NOTE: Call Restaurant line & phone icon removed per user instructions

    private var supportFooterSection: some View {
        Button(action: {
            showHelpSheet = true
        }) {
            Text("Need Help?")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color.gray)
                .padding(.vertical, 4)
        }
    }

    // MARK: - Actions

    private func handleTrackOrder() {
        showTrackOrderScreen = true
    }

    private func handleBackToHome() {
        // Return to TabBar root (Home Screen)
        kSharedAppDelegate?.moveToTabBar(isGuest: isGuest)
    }
}

// MARK: - Order Tracking Sheet Modal

struct OrderTrackingModal: View {
    @Environment(\.dismiss) private var dismiss

    var orderNumber: String
    var orderType: CartOrderType
    var estimatedArrival: String
    var deliveryAddress: String

    private let modRed = Color(red: 0.78, green: 0.08, blue: 0.18)
    private let successGreen = Color(red: 0.12, green: 0.65, blue: 0.38)

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Kitchen Status Animation Header
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color(red: 1.0, green: 0.93, blue: 0.94))
                                .frame(width: 80, height: 80)

                            Image(systemName: "flame.fill")
                                .font(.system(size: 36))
                                .foregroundColor(modRed)
                        }
                        .padding(.top, 10)

                        Text("Fresh in the Oven!")
                            .font(.system(size: 20, weight: .bold))

                        Text("Estimated arrival at \(estimatedArrival)")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                    }

                    // Timeline Cards
                    VStack(alignment: .leading, spacing: 16) {
                        timelineItem(time: "Just Now", title: "Order Confirmed", desc: "Your order #\(orderNumber) has been received.", isDone: true)
                        timelineItem(time: "2 mins ago", title: "Dough Prepped & Topped", desc: "Hand-stretched dough with fresh artisan toppings.", isDone: true)
                        timelineItem(time: "In Progress", title: "Baking at 500°F", desc: "Currently baking in our stone deck oven.", isDone: true, isCurrent: true)
                        timelineItem(time: "Upcoming", title: orderType == .pickup ? "Ready for Pickup" : "Driver Out for Delivery", desc: orderType == .pickup ? "Fresh & boxed at front counter." : "Driver will deliver safely to your door.", isDone: false)
                    }
                    .padding(18)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                    .padding(.horizontal, 16)
                }
            }
            .background(Color(red: 0.98, green: 0.98, blue: 0.99).edgesIgnoringSafeArea(.all))
            .navigationBarTitle("Track Order #\(orderNumber)", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() }.foregroundColor(modRed).font(.system(size: 15, weight: .bold)))
        }
    }

    private func timelineItem(time: String, title: String, desc: String, isDone: Bool, isCurrent: Bool = false) -> some View {
        HStack(alignment: .top, spacing: 14) {
            VStack {
                Circle()
                    .fill(isCurrent ? modRed : (isDone ? successGreen : Color.gray.opacity(0.3)))
                    .frame(width: 14, height: 14)
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 2, height: 36)
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(isCurrent ? modRed : .black)

                    Spacer()

                    Text(time)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.gray)
                }

                Text(desc)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
        }
    }
}

// MARK: - Typealias for Convenience
typealias OrderConfirmedScreen = ConfirmOrderScreen

// MARK: - Preview

#Preview {
    NavigationView {
        ConfirmOrderScreen()
    }
}

//
//  TopUpReceiptScreen.swift
//  MOD
//
//  Created by Rajpal singh on 10/11/26.
//

import SwiftUI

// MARK: - Top-Up Receipt Screen

struct TopUpReceiptScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) private var presentationMode

    // Transaction Details
    var transactionId: String = "TXN-MOD-984210"
    var reloadAmount: Double = 50.00
    var previousBalance: Double = 48.50
    var newBalance: Double = 98.50
    var paymentMethodName: String = "Apple Pay"
    var pointsEarned: Int = 25
    var isAutoReloadEnabled: Bool = true
    var dateString: String = "Today, 10:15 AM"
    var onDone: () -> Void = {}
    var onOrderNow: () -> Void = {}

    // Animation & Feedback States
    @State private var checkmarkScale: CGFloat = 0.5
    @State private var checkmarkOpacity: Double = 0.0
    @State private var haloPulsing: Bool = false
    @State private var showCopiedAlert: Bool = false
    @State private var showShareSheet: Bool = false
    @State private var showSupportAlert: Bool = false

    // Theme Colors
    private let modRed = Color(red: 0.88, green: 0.12, blue: 0.18)
    private let darkBgStart = Color(red: 0.09, green: 0.11, blue: 0.18)
    private let darkBgEnd = Color(red: 0.13, green: 0.15, blue: 0.24)
    private let screenBg = Color(red: 0.98, green: 0.98, blue: 0.99)
    private let borderGray = Color(red: 0.91, green: 0.91, blue: 0.93)
    private let textDark = Color(red: 0.10, green: 0.12, blue: 0.18)
    private let tealBonus = Color(red: 0.08, green: 0.60, blue: 0.55)
    private let tealBonusBg = Color(red: 0.90, green: 0.97, blue: 0.96)
    private let successGreen = Color(red: 0.12, green: 0.65, blue: 0.38)
    private let successGreenBg = Color(red: 0.90, green: 0.98, blue: 0.94)

    var body: some View {
        VStack(spacing: 0) {
            // 1. Navigation Header
            navigationHeader

            // 2. Scrollable Receipt Content
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 18) {
                    // Success Graphic with Pulsing Halo
                    successCelebrationSection
                        .padding(.top, 12)

                    // Hero Digital Receipt Card
                    receiptTicketCard

                    // Action Buttons (Order with Wallet & Done)
                    actionButtonsSection

                    // Footer Support Link
                    supportFooterSection

                    // Clearance at bottom
                    Color.clear.frame(height: 36)
                }
                .padding(.horizontal, 18)
            }
            .background(screenBg)
        }
        .background(screenBg.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.65)) {
                checkmarkScale = 1.0
                checkmarkOpacity = 1.0
            }
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                haloPulsing = true
            }
        }
        .alert(isPresented: $showCopiedAlert) {
            Alert(
                title: Text("Copied!"),
                message: Text("Transaction ID #\(transactionId) copied to clipboard."),
                dismissButton: .default(Text("OK"))
            )
        }
        .alert(isPresented: $showSupportAlert) {
            Alert(
                title: Text("Need Help?"),
                message: Text("Contact MOD Care with reference #\(transactionId) for instant reload verification."),
                primaryButton: .default(Text("Call Care")),
                secondaryButton: .cancel()
            )
        }
    }

    // MARK: - 1. Navigation Header

    private var navigationHeader: some View {
        HStack {
            // Close Button
            Button(action: {
                onDone()
                dismiss()
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark")
                    .font(Font.appFont(.jakartaBold, size: 14))
                    .foregroundColor(.black)
                    .frame(width: 38, height: 38)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
            }

            Spacer()

            Text("Top-Up Receipt")
                .font(Font.appFont(.jakartaBold, size: 18))
                .foregroundColor(textDark)

            Spacer()

            // Share / Export Button
            Button(action: {
                shareReceipt()
            }) {
                Image(systemName: "square.and.arrow.up")
                    .font(Font.appFont(.jakartaSemiBold, size: 15))
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

    // MARK: - 2. Success Celebration Section

    private var successCelebrationSection: some View {
        VStack(spacing: 8) {
            // Glowing Animated Halo Icon
            ZStack {
                // Outer Pulse Ring
                Circle()
                    .fill(successGreen.opacity(haloPulsing ? 0.12 : 0.04))
                    .frame(width: 86, height: 86)
                    .scaleEffect(haloPulsing ? 1.12 : 0.95)

                // Middle Ring
                Circle()
                    .fill(successGreen.opacity(0.18))
                    .frame(width: 68, height: 68)

                // Inner Solid Green Circle
                Circle()
                    .fill(successGreen)
                    .frame(width: 50, height: 50)
                    .shadow(color: successGreen.opacity(0.35), radius: 6, x: 0, y: 3)

                // Checkmark
                Image(systemName: "checkmark")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .scaleEffect(checkmarkScale)
                    .opacity(checkmarkOpacity)
            }
            .padding(.bottom, 4)

            // Success Title
            Text("Top-Up Successful!")
                .font(Font.appFont(.jakartaExtraBold, size: 22))
                .foregroundColor(textDark)

            // Subtitle
            Text("Your MOD Wallet has been reloaded instantly")
                .font(Font.appFont(.jakartaRegular, size: 13.5))
                .foregroundColor(.gray)

            // Transaction ID with Tap-To-Copy
            Button(action: {
                UIPasteboard.general.string = transactionId
                showCopiedAlert = true
            }) {
                HStack(spacing: 5) {
                    Text(transactionId)
                        .font(Font.appFont(.jakartaBold, size: 12))
                        .foregroundColor(Color(red: 0.35, green: 0.38, blue: 0.44))

                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4.5)
                .background(Color.white)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(borderGray, lineWidth: 1))
            }
            .padding(.top, 2)
        }
    }

    // MARK: - 3. Digital Receipt Ticket Card

    private var receiptTicketCard: some View {
        VStack(spacing: 0) {
            // TOP SECTION: Amount & New Balance Summary
            VStack(spacing: 12) {
                // Large Reload Amount Display
                VStack(spacing: 4) {
                    Text("AMOUNT ADDED")
                        .font(Font.appFont(.jakartaBold, size: 11))
                        .foregroundColor(Color(red: 0.45, green: 0.48, blue: 0.52))
                        .tracking(0.6)

                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("+$")
                            .font(Font.appFont(.jakartaBold, size: 28))
                            .foregroundColor(successGreen)

                        Text(String(format: "%.2f", reloadAmount))
                            .font(Font.appFont(.jakartaExtraBold, size: 38))
                            .foregroundColor(textDark)

                        Text("USD")
                            .font(Font.appFont(.jakartaBold, size: 13))
                            .foregroundColor(.gray)
                    }
                }

                // Points Bonus Earned Strip (if points earned)
                if pointsEarned > 0 {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(tealBonus)

                        Text("+\(pointsEarned) Hut Points Earned & Credited!")
                            .font(Font.appFont(.jakartaBold, size: 12))
                            .foregroundColor(tealBonus)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(tealBonusBg)
                    .cornerRadius(10)
                }

                // Balance Comparison Box
                HStack(spacing: 12) {
                    // Previous Balance
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Previous Balance")
                            .font(Font.appFont(.jakartaRegular, size: 11))
                            .foregroundColor(.gray)
                        Text("$\(String(format: "%.2f", previousBalance))")
                            .font(Font.appFont(.jakartaBold, size: 14))
                            .foregroundColor(textDark)
                    }

                    Spacer()

                    Image(systemName: "arrow.right")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color(red: 0.65, green: 0.68, blue: 0.72))

                    Spacer()

                    // Updated Balance
                    VStack(alignment: .trailing, spacing: 2) {
                        HStack(spacing: 4) {
                            Image(systemName: "wallet.pass.fill")
                                .font(.system(size: 10))
                                .foregroundColor(modRed)
                            Text("Updated Balance")
                                .font(Font.appFont(.jakartaBold, size: 11))
                                .foregroundColor(modRed)
                        }
                        Text("$\(String(format: "%.2f", newBalance))")
                            .font(Font.appFont(.jakartaExtraBold, size: 16))
                            .foregroundColor(modRed)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(red: 0.98, green: 0.98, blue: 0.99))
                .cornerRadius(10)
            }
            .padding(18)

            // RECEIPT NOTCHED DIVIDER
            receiptNotchedDivider

            // BOTTOM SECTION: Breakdown & Payment Information
            VStack(spacing: 12) {
                receiptDetailRow(title: "Date & Time", value: dateString)

                receiptDetailRow(
                    title: "Payment Source",
                    value: paymentMethodName,
                    badge: "Instant",
                    badgeColor: successGreen,
                    badgeBg: successGreenBg
                )

                receiptDetailRow(title: "Reload Amount", value: "$\(String(format: "%.2f", reloadAmount))")

                receiptDetailRow(title: "Processing Fee", value: "Free ($0.00)", isHighlight: false)

                if isAutoReloadEnabled {
                    receiptDetailRow(
                        title: "Auto-Reload",
                        value: "Active ($25 < $10)",
                        badge: "Smart",
                        badgeColor: modRed,
                        badgeBg: Color(red: 1.0, green: 0.92, blue: 0.94)
                    )
                }

                Divider()
                    .padding(.vertical, 4)

                // Total Charged Row
                HStack {
                    Text("Total Charged")
                        .font(Font.appFont(.jakartaBold, size: 15))
                        .foregroundColor(textDark)

                    Spacer()

                    Text("$\(String(format: "%.2f", reloadAmount))")
                        .font(Font.appFont(.jakartaExtraBold, size: 18))
                        .foregroundColor(textDark)
                }

                // Status Strip
                HStack(spacing: 6) {
                    Circle()
                        .fill(successGreen)
                        .frame(width: 6, height: 6)

                    Text("Payment Completed & Verified")
                        .font(Font.appFont(.jakartaBold, size: 11.5))
                        .foregroundColor(successGreen)

                    Spacer()

                    Text("100% Secure")
                        .font(Font.appFont(.jakartaRegular, size: 11))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(successGreenBg)
                .cornerRadius(8)
                .padding(.top, 4)
            }
            .padding(18)
        }
        .background(Color.white)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(borderGray, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
    }

    // MARK: Receipt Notched Divider Component

    private var receiptNotchedDivider: some View {
        HStack(spacing: 0) {
            // Left circular notch cutout
            Circle()
                .fill(screenBg)
                .frame(width: 18, height: 18)
                .offset(x: -9)

            // Dashed Divider line
            Line()
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [5, 4]))
                .frame(height: 1)
                .foregroundColor(borderGray)

            // Right circular notch cutout
            Circle()
                .fill(screenBg)
                .frame(width: 18, height: 18)
                .offset(x: 9)
        }
        .frame(height: 18)
    }

    // MARK: Detail Row Helper

    private func receiptDetailRow(
        title: String,
        value: String,
        badge: String? = nil,
        badgeColor: Color = .gray,
        badgeBg: Color = .clear,
        isHighlight: Bool = false
    ) -> some View {
        HStack(alignment: .center) {
            Text(title)
                .font(Font.appFont(.jakartaRegular, size: 13))
                .foregroundColor(.gray)

            Spacer()

            if let b = badge {
                Text(b)
                    .font(Font.appFont(.jakartaBold, size: 10))
                    .foregroundColor(badgeColor)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(badgeBg)
                    .cornerRadius(4)
            }

            Text(value)
                .font(Font.appFont(.jakartaSemiBold, size: 13.5))
                .foregroundColor(isHighlight ? modRed : textDark)
        }
    }

    // MARK: - 4. Action Buttons Section

    private var actionButtonsSection: some View {
        VStack(spacing: 10) {
            // Primary Button: Order Food with Wallet
            Button(action: {
                onOrderNow()
                onDone()
                dismiss()
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "fork.knife")
                        .font(.system(size: 14, weight: .bold))

                    Text("Order Food with Wallet")
                        .font(Font.appFont(.jakartaBold, size: 15))

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

            // Secondary Button: Back to Home / Done
            Button(action: {
                onDone()
                dismiss()
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Done")
                    .font(Font.appFont(.jakartaBold, size: 15))
                    .foregroundColor(textDark)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.white)
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(borderGray, lineWidth: 1)
                    )
            }
        }
        .padding(.top, 4)
    }

    // MARK: - 5. Support Footer Section

    private var supportFooterSection: some View {
        Button(action: {
            showSupportAlert = true
        }) {
            HStack(spacing: 5) {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 12))
                Text("Need help with this transaction? Contact Support")
                    .font(Font.appFont(.jakartaMedium, size: 12))
            }
            .foregroundColor(Color(red: 0.45, green: 0.48, blue: 0.55))
        }
        .padding(.top, 4)
    }

    // MARK: - Share Receipt Action

    private func shareReceipt() {
        let textToShare = """
        MOD Pizza Wallet Top-Up Receipt
        Transaction ID: #\(transactionId)
        Amount Reloaded: $\(String(format: "%.2f", reloadAmount)) USD
        New Wallet Balance: $\(String(format: "%.2f", newBalance)) USD
        Points Earned: +\(pointsEarned) Hut Points
        Payment Method: \(paymentMethodName)
        Status: Confirmed & Paid
        """
        let av = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(av, animated: true, completion: nil)
        }
    }
}

// MARK: - Dashed Line Shape

private struct Line2: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.height / 2))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height / 2))
        return path
    }
}

// MARK: - Preview

#Preview {
    TopUpReceiptScreen(
        transactionId: "TXN-MOD-984210",
        reloadAmount: 50.00,
        previousBalance: 48.50,
        newBalance: 98.50,
        paymentMethodName: "Apple Pay",
        pointsEarned: 25,
        isAutoReloadEnabled: true,
        dateString: "Today, 10:15 AM"
    )
}

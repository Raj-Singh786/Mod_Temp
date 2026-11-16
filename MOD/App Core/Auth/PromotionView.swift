//
//  PromotionView.swift
//  MOD
//
//  Created by Rajpal singh on 15/11/26.
//

import SwiftUI

struct PromotionView: View {
    
    // MARK: - Properties
    
    var points: Int = 1240
    var targetPoints: Int = 1500
    var tierName: String = "Silver"
    
    // MARK: - Callbacks
    
    var onSignInWithCode: (() -> Void)? = nil
    var onContinueAsGuest: (() -> Void)? = nil
    var onPageSelected: ((Int) -> Void)? = nil
    
    // MARK: - Computed Properties
    
    private var pointsToFreePizza: Int {
        max(0, targetPoints - points)
    }
    
    private var progressRatio: CGFloat {
        guard targetPoints > 0 else { return 0 }
        return min(CGFloat(points) / CGFloat(targetPoints), 1.0)
    }
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background Color
                Color("app_background")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top Header Bar
                    headerBar
                        .padding(.top, geometry.safeAreaInsets.top > 0 ? 4 : 12)
                        .padding(.horizontal, 24)
                    
                    Spacer(minLength: 16)
                    
                    // Center Content (Card + Headlines)
                    VStack(spacing: 0) {
                        // MOD Rewards Card
                        rewardsCard(width: min(geometry.size.width - 56, 340.0))
                            .padding(.bottom, 28)
                        
                        // Middle Headline
                        Text("EARN AS YOU EAT")
                            .font(.oswaldMedium(size: min(geometry.size.width * 0.082, 32.0)))
                            .foregroundColor(Color("app_black"))
                            .tracking(0.6)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        // Middle Description
                        Text("Points on every order, a free pizza at 1,500 points,\nplus a digital wallet and member pass.")
                            .font(.barlowRegular(size: 15.5))
                            .foregroundColor(Color("text_gary"))
                            .lineSpacing(4.5)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 10)
                            .padding(.horizontal, 28)
                    }
                    
                    Spacer(minLength: 16)
                    
                    // Page Indicator (Page 2 of 2)
                    pageIndicator
                        .padding(.bottom, 22)
                    
                    // Action Buttons + Footnote
                    VStack(spacing: 12) {
                        // Sign In With A Code Button
                        signInButton
                        
                        // Continue As Guest Button
                        guestButton
                        
                        // Footnote Info
                        Text("Passwordless: we email or text you a one-time code.")
                            .font(.barlowRegular(size: 13))
                            .foregroundColor(Color("text_gary"))
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, geometry.safeAreaInsets.bottom > 0 ? 12 : 24)
                }
            }
        }
    }
    
    // MARK: - Header Bar
    
    private var headerBar: some View {
        HStack(alignment: .center) {
            Image("app_logo")
                .resizable()
                .scaledToFit()
                .frame(width: 35, height: 42)
                .accessibilityLabel("MOD Pizza Logo")
            
            Spacer()
        }
    }
    
    // MARK: - Rewards Card
    
    private func rewardsCard(width: CGFloat) -> some View {
        let cardHeight: CGFloat = 205.0
        
        return VStack(alignment: .leading, spacing: 0) {
            // Tier Subtitle
            Text("MOD Rewards · \(tierName)")
                .font(.barlowRegular(size: 14))
                .foregroundColor(Color(red: 0xB0 / 255.0, green: 0xA5 / 255.0, blue: 0xA7 / 255.0))
            
            Spacer(minLength: 10)
            
            // Large Points Counter
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(formatPoints(points))
                    .font(.oswaldMedium(size: 44))
                    .foregroundColor(.white)
                
                Text("pts")
                    .font(.oswaldMedium(size: 32))
                    .foregroundColor(.white)
            }
            
            Spacer(minLength: 14)
            
            // Custom Progress Bar
            GeometryReader { barGeometry in
                ZStack(alignment: .leading) {
                    // Track Background (Dark Plum)
                    Capsule()
                        .fill(Color(red: 0x4A / 255.0, green: 0x24 / 255.0, blue: 0x2B / 255.0))
                        .frame(height: 8)
                    
                    // Filled Progress Track (Gold)
                    Capsule()
                        .fill(Color(red: 0xFB / 255.0, green: 0xCF / 255.0, blue: 0x62 / 255.0))
                        .frame(width: barGeometry.size.width * progressRatio, height: 8)
                }
            }
            .frame(height: 8)
            
            Spacer(minLength: 10)
            
            // Goal Description
            Text("\(pointsToFreePizza) pts to a free pizza")
                .font(.barlowRegular(size: 13.5))
                .foregroundColor(Color(red: 0xB8 / 255.0, green: 0xAE / 255.0, blue: 0xB0 / 255.0))
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 22)
        .frame(width: width, height: cardHeight)
        .background(
            // Dark Wine / Burgundy 3D Gradient
            LinearGradient(
                colors: [
                    Color(red: 0x2A / 255.0, green: 0x20 / 255.0, blue: 0x22 / 255.0),
                    Color(red: 0x48 / 255.0, green: 0x22 / 255.0, blue: 0x2A / 255.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            // Subtle 3D Rim Stroke
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.14),
                            Color.white.opacity(0.03)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        // 3D Card Shadows
        .shadow(
            color: Color(red: 0x30 / 255.0, green: 0x14 / 255.0, blue: 0x1B / 255.0).opacity(0.28),
            radius: 22,
            x: 0,
            y: 14
        )
        .shadow(
            color: Color.black.opacity(0.12),
            radius: 6,
            x: 0,
            y: 3
        )
    }
    
    // MARK: - Page Indicator
    
    private var pageIndicator: some View {
        HStack(spacing: 6) {
            // Page 1 (Inactive Dot)
            Circle()
                .fill(Color("Button_red").opacity(0.25))
                .frame(width: 6, height: 6)
                .onTapGesture {
                    onPageSelected?(0)
                }
            
            // Page 2 (Active Pill)
            Capsule()
                .fill(Color("Button_red"))
                .frame(width: 22, height: 6)
        }
    }
    
    // MARK: - Buttons
    
    private var signInButton: some View {
        Button(action: {
            onSignInWithCode?()
        }) {
            HStack(spacing: 8) {
                Image(systemName: "star")
                    .font(.system(size: 15, weight: .semibold))
                
                Text("SIGN IN WITH A CODE")
                    .font(.oswaldMedium(size: 16))
                    .tracking(1.2)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                Capsule()
                    .fill(Color("Button_red"))
            )
            .shadow(color: Color("Button_red").opacity(0.35), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private var guestButton: some View {
        Button(action: {
            onContinueAsGuest?()
        }) {
            Text("CONTINUE AS GUEST")
                .font(.oswaldMedium(size: 16))
                .tracking(1.2)
                .foregroundColor(Color("app_black"))
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    Capsule()
                        .fill(Color.white)
                )
                .overlay(
                    Capsule()
                        .stroke(Color(red: 0xD8 / 255.0, green: 0xCF / 255.0, blue: 0xC2 / 255.0), lineWidth: 1.5)
                )
                .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    // MARK: - Helpers
    
    private func formatPoints(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

// MARK: - SwiftUI Preview

#Preview {
    PromotionView(
        onSignInWithCode: { print("Sign in tapped") },
        onContinueAsGuest: { print("Continue as guest tapped") }
    )
}

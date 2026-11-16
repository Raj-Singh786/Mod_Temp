//
//  RewardsCoordinatorView.swift
//  MOD
//
//  Created by Rajpal singh on 16/11/26.
//

import SwiftUI

// MARK: - Screen State

enum RewardsScreenState {
    case join
    case memberPass
}

// MARK: - Simulated Barcode Graphic

struct BarcodeGraphicView: View {
    // Sequence of bar widths creating an authentic barcode pattern
    private let barPattern: [CGFloat] = [
        3, 1, 2, 4, 1, 2, 3, 1, 4, 2, 1, 3, 2, 1, 4, 1, 3, 2, 1, 2,
        4, 1, 3, 2, 1, 4, 2, 1, 3, 1, 2, 4, 2, 1, 3, 1, 4, 2, 1, 3,
        2, 1, 4, 1, 3, 2, 1, 2, 4, 1, 3, 2, 1, 4, 2, 1, 3, 1, 2, 4
    ]
    
    var body: some View {
        HStack(spacing: 2.2) {
            ForEach(0..<barPattern.count, id: \.self) { index in
                Rectangle()
                    .fill(Color.black)
                    .frame(width: barPattern[index], height: 58)
            }
        }
    }
}

// MARK: - RewardsCoordinatorView

struct RewardsCoordinatorView: View {
    
    // MARK: - State
    
    @State private var screenState: RewardsScreenState = .join
    @State private var fullName: String = "Raj"
    @State private var email: String = "raj@example.com"
    @State private var sendOffersByEmail: Bool = false
    
    var onBackToHome: (() -> Void)? = nil
    
    var body: some View {
        ZStack {
            Color("app_background")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Custom Navigation Bar
                customNavigationBar
                
                // Content Switcher
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        if screenState == .join {
                            joinRewardsContent
                        } else {
                            memberPassContent
                        }
                        
                        Spacer()
                            .frame(height: 32)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                }
            }
        }
    }
    
    // MARK: - Custom Top Navigation Bar
    
    private var customNavigationBar: some View {
        HStack(alignment: .center) {
            // Left: Back Button
            Button(action: {
                if screenState == .memberPass {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        screenState = .join
                    }
                } else {
                    if let onBack = onBackToHome {
                        onBack()
                    } else if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                              let rootNav = windowScene.windows.first?.rootViewController as? UINavigationController,
                              let tabVC = rootNav.viewControllers.first as? UITabBarController {
                        tabVC.selectedIndex = 0
                    }
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
            Text(screenState == .join ? "Join" : "Member pass")
                .font(.oswaldMedium(size: 17))
                .foregroundColor(Color("app_black"))
            
            Spacer()
            
            // Right: Star & Cart Icons
            HStack(spacing: 16) {
                // Star Button
                Button(action: {
                    // Star action
                }) {
                    Image(systemName: "star")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(Color("app_black"))
                }
                .buttonStyle(PlainButtonStyle())
                
                // Cart Button (Red)
                Button(action: {
                    // Cart action
                }) {
                    Image(systemName: "cart")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(Color("Button_red"))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
        .padding(.bottom, 10)
        .background(Color("app_background"))
    }
    
    // MARK: - 1. Join Rewards Content (Snapshot 1)
    
    private var joinRewardsContent: some View {
        VStack(alignment: .leading, spacing: 18) {
            // Header Titles
            VStack(alignment: .leading, spacing: 6) {
                Text("JOIN MOD REWARDS")
                    .font(.oswaldMedium(size: 32))
                    .tracking(0.6)
                    .foregroundColor(Color("app_black"))
                
                Text("Sample enrollment — no account is created and nothing is sent.")
                    .font(.barlowRegular(size: 14))
                    .foregroundColor(Color("text_gary"))
                    .lineSpacing(2)
            }
            .padding(.top, 4)
            
            // Enrollment Form Card
            VStack(alignment: .leading, spacing: 16) {
                // Full name Field
                VStack(alignment: .leading, spacing: 6) {
                    Text("Full name")
                        .font(.barlowBold(size: 13.5))
                        .foregroundColor(Color("app_black"))
                    
                    TextField("", text: $fullName)
                        .font(.barlowRegular(size: 15))
                        .foregroundColor(Color("app_black"))
                        .padding(.horizontal, 14)
                        .frame(height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0), lineWidth: 1.2)
                                .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.white))
                        )
                }
                
                // Email Field
                VStack(alignment: .leading, spacing: 6) {
                    Text("Email")
                        .font(.barlowBold(size: 13.5))
                        .foregroundColor(Color("app_black"))
                    
                    TextField("", text: $email)
                        .font(.barlowRegular(size: 15))
                        .foregroundColor(Color("app_black"))
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding(.horizontal, 14)
                        .frame(height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0), lineWidth: 1.2)
                                .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.white))
                        )
                }
                
                // Checkbox Row
                Button(action: {
                    sendOffersByEmail.toggle()
                }) {
                    HStack(alignment: .top, spacing: 10) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .stroke(Color.gray.opacity(0.45), lineWidth: 1.5)
                                .frame(width: 18, height: 18)
                            
                            if sendOffersByEmail {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(Color("Button_red"))
                            }
                        }
                        .padding(.top, 2)
                        
                        Text("Yes, send me offers and news by email (optional)")
                            .font(.barlowRegular(size: 13))
                            .foregroundColor(Color("app_black"))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 2)
                
                // Actions Row
                HStack(spacing: 16) {
                    // COMPLETE ENROLLMENT Button
                    Button(action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            screenState = .memberPass
                        }
                    }) {
                        Text("COMPLETE ENROLLMENT")
                            .font(.oswaldMedium(size: 14.5))
                            .tracking(0.8)
                            .foregroundColor(.white)
                            .padding(.horizontal, 22)
                            .frame(height: 46)
                            .background(
                                Capsule()
                                    .fill(Color("Button_red"))
                                    .shadow(color: Color("Button_red").opacity(0.35), radius: 6, x: 0, y: 3)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // CANCEL Button
                    Button(action: {
                        if let onBack = onBackToHome {
                            onBack()
                        } else if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                  let rootNav = windowScene.windows.first?.rootViewController as? UINavigationController,
                                  let tabVC = rootNav.viewControllers.first as? UITabBarController {
                            tabVC.selectedIndex = 0
                        }
                    }) {
                        Text("CANCEL")
                            .font(.oswaldMedium(size: 14.5))
                            .tracking(0.8)
                            .foregroundColor(Color("app_black"))
                            .padding(.horizontal, 8)
                            .frame(height: 46)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                }
                .padding(.top, 4)
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDF / 255.0), lineWidth: 1.2)
                    )
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
            )
            
            // "WHAT YOU GET" Section
            VStack(alignment: .leading, spacing: 14) {
                Text("WHAT YOU GET")
                    .font(.oswaldMedium(size: 18))
                    .tracking(0.6)
                    .foregroundColor(Color("app_black"))
                
                VStack(alignment: .leading, spacing: 12) {
                    benefitRow(text: "10 points per $1 on food")
                    benefitRow(text: "Free pizza at 1,500 points")
                    benefitRow(text: "Silver and Gold earning multipliers")
                    benefitRow(text: "Member coupons, wallet and digital pass")
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDF / 255.0), lineWidth: 1.2)
                    )
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
            )
        }
    }
    
    private func benefitRow(text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color("Button_red"))
            
            Text(text)
                .font(.barlowMedium(size: 14.5))
                .foregroundColor(Color("app_black"))
        }
    }
    
    // MARK: - 2. Member Pass Content (Snapshot 2)
    
    private var memberPassContent: some View {
        VStack(alignment: .leading, spacing: 18) {
            // Header Titles
            VStack(alignment: .leading, spacing: 6) {
                Text("MEMBER PASS")
                    .font(.oswaldMedium(size: 32))
                    .tracking(0.6)
                    .foregroundColor(Color("app_black"))
                
                Text("Show this at the counter to earn on in-store orders.")
                    .font(.barlowRegular(size: 14))
                    .foregroundColor(Color("text_gary"))
            }
            .padding(.top, 4)
            
            // Digital Member Pass Card
            VStack(alignment: .leading, spacing: 16) {
                // Top Row: MOD Logo + "Rewards" + "Silver" Tier Badge
                HStack(alignment: .center) {
                    HStack(spacing: 8) {
                        Image("app_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 38)
                        
                        Text("Rewards")
                            .font(.barlowBold(size: 22))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    // Silver Tier Badge
                    Text("Silver")
                        .font(.barlowBold(size: 12.5))
                        .foregroundColor(Color(red: 0x58 / 255.0, green: 0x40 / 255.0, blue: 0x1E / 255.0))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(Color(red: 0xF5 / 255.0, green: 0xEA / 255.0, blue: 0xD6 / 255.0))
                        )
                }
                
                // Member Name & Points
                VStack(alignment: .leading, spacing: 3) {
                    Text(fullName.isEmpty ? "Raj" : fullName)
                        .font(.oswaldMedium(size: 34))
                        .tracking(0.5)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 4) {
                        Text("1,240")
                            .font(.barlowBold(size: 15))
                            .foregroundColor(.white)
                        Text("pts available")
                            .font(.barlowRegular(size: 15))
                            .foregroundColor(Color.white.opacity(0.75))
                    }
                }
                .padding(.top, 4)
                
                // Barcode White Container
                VStack(spacing: 8) {
                    // Barcode Stripes Graphic
                    BarcodeGraphicView()
                        .padding(.top, 14)
                        .padding(.horizontal, 10)
                    
                    // Barcode Number
                    Text("7730  4821  0093")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(Color("app_black"))
                        .tracking(2.5)
                        .padding(.bottom, 12)
                }
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white)
                )
                
                // Disclaimer below barcode
                Text("Enrolled member · Sample barcode for demonstration — not scannable.")
                    .font(.barlowRegular(size: 11.5))
                    .foregroundColor(Color.white.opacity(0.6))
                    .lineSpacing(2)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: Color(red: 0x18 / 255.0, green: 0x14 / 255.0, blue: 0x16 / 255.0), location: 0.0),
                                .init(color: Color(red: 0x22 / 255.0, green: 0x16 / 255.0, blue: 0x19 / 255.0), location: 0.5),
                                .init(color: Color(red: 0x48 / 255.0, green: 0x17 / 255.0, blue: 0x20 / 255.0), location: 1.0)
                            ],
                            startPoint: .bottomLeading,
                            endPoint: .topTrailing
                        )
                    )
            )
            .shadow(color: Color.black.opacity(0.18), radius: 12, x: 0, y: 6)
            
            // Action Buttons Below Card
            HStack(spacing: 12) {
                // SCAN A RECEIPT INSTEAD
                Button(action: {
                    // Receipt scan action
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "scope")
                            .font(.system(size: 14, weight: .bold))
                        Text("SCAN A RECEIPT INSTEAD")
                            .font(.oswaldMedium(size: 13.5))
                            .tracking(0.8)
                    }
                    .foregroundColor(Color("app_black"))
                    .padding(.horizontal, 16)
                    .frame(height: 44)
                    .background(
                        Capsule()
                            .stroke(Color.gray.opacity(0.35), lineWidth: 1)
                            .background(Capsule().fill(Color.white.opacity(0.6)))
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // ENTER A CODE
                Button(action: {
                    // Enter code action
                }) {
                    Text("ENTER A CODE")
                        .font(.oswaldMedium(size: 13.5))
                        .tracking(0.8)
                        .foregroundColor(Color("app_black"))
                        .padding(.horizontal, 10)
                        .frame(height: 44)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
            }
            .padding(.top, 4)
        }
    }
}

// MARK: - Preview

struct RewardsCoordinatorView_Previews: PreviewProvider {
    static var previews: some View {
        RewardsCoordinatorView()
    }
}

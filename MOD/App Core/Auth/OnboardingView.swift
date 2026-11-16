//
//  OnboardingView.swift
//  MOD
//
//  Created by Rajpal singh on 15/11/26.
//

import SwiftUI

// MARK: - Slide Model

struct OnboardingSlideItem: Identifiable, Equatable {
    let id: Int
    let image: String
    let badgeTop: String?
    let badgeMiddle: String?
    let badgeBottom: String?
    let title: String
    let description: String
}

// MARK: - OnboardingView

struct OnboardingView: View {
    
    // MARK: - Callbacks
    
    var onSkip: (() -> Void)? = nil
    var onFinish: (() -> Void)? = nil
    
    // MARK: - State
    
    @State private var currentPage: Int = 0
    
    // MARK: - Slides Data
    
    let slides: [OnboardingSlideItem] = [
        OnboardingSlideItem(
            id: 0,
            image: "PizzaOn",
            badgeTop: "MADE",
            badgeMiddle: "YOUR",
            badgeBottom: "WAY",
            title: "MADE YOUR WAY",
            description: "Pile on unlimited toppings, split it half and half,\nand save your favourite builds."
        )
    ]
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background Color
                Color("app_background")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top Navigation Bar
                    headerBar
                        .padding(.top, geometry.safeAreaInsets.top > 0 ? 4 : 12)
                        .padding(.horizontal, 24)
                    
                    // Paged Slide Content (Flexibly takes available vertical space)
                    TabView(selection: $currentPage) {
                        ForEach(slides.indices, id: \.self) { index in
                            slideView(for: slides[index], geometry: geometry)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    
                    // Bottom Navigation Controls
                    VStack(spacing: 18) {
                        // Page Indicator Dots
                        pageIndicator
                        
                        // Action Button ("NEXT >")
                        actionButton
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, geometry.safeAreaInsets.bottom > 0 ? 8 : 20)
                }
            }
        }
    }
    
    // MARK: - Header Bar
    
    private var headerBar: some View {
        HStack(alignment: .center) {
            // MOD Shield Logo
            Image("app_logo")
                .resizable()
                .scaledToFit()
                .frame(width: 35, height: 42)
                .accessibilityLabel("MOD Pizza Logo")
            
            Spacer()
            
            // Skip Button
            Button(action: {
                onSkip?()
            }) {
                Text("Skip")
                    .font(.barlowSemiBold(size: 16))
                    .foregroundColor(Color(red: 0x4A / 255.0, green: 0x45 / 255.0, blue: 0x40 / 255.0))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 4)
            }
        }
    }
    
    // MARK: - Slide View
    
    private func slideView(for slide: OnboardingSlideItem, geometry: GeometryProxy) -> some View {
        let screenWidth = geometry.size.width
        let screenHeight = geometry.size.height
        
        // Dynamically scaled hero graphic: generous circular disc following the design snap
        let pizzaSize = min(screenWidth * 0.54, screenHeight * 0.26, 215.0)
        let backgroundDiscSize = pizzaSize * 1.55
        
        return VStack(spacing: 0) {
            Spacer(minLength: 4)
            
            // 3D Hero Graphic Area
            heroGraphic(for: slide, pizzaSize: pizzaSize, discSize: backgroundDiscSize)
                .padding(.top, 2)
                .padding(.bottom, 6)
            
            Spacer(minLength: 10)
            
            // Slide Title & Description (Protected against truncation)
            VStack(spacing: 10) {
                Text(slide.title)
                    .font(.oswaldMedium(size: min(screenWidth * 0.08, 30.0)))
                    .foregroundColor(Color("app_black"))
                    .tracking(0.6)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .minimumScaleFactor(0.85)
                
                Text(slide.description)
                    .font(.barlowRegular(size: 15))
                    .foregroundColor(Color("text_gary"))
                    .lineSpacing(4)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 28)
            }
            .padding(.horizontal, 16)
            
            Spacer(minLength: 12)
        }
    }
    
    // MARK: - 3D Hero Graphic Area
    
    private func heroGraphic(for slide: OnboardingSlideItem, pizzaSize: CGFloat, discSize: CGFloat) -> some View {
        ZStack {
            // 1. 3D Background Circular Plateau / Disc with Multi-Layer Sketch Shadows
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0xF7 / 255.0, green: 0xEE / 255.0, blue: 0xDE / 255.0),
                            Color(red: 0xEB / 255.0, green: 0xDC / 255.0, blue: 0xC6 / 255.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: discSize, height: discSize)
                .overlay(
                    // Subtle 3D Top-Light Bevel Stroke
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.85),
                                    Color(red: 0xD6 / 255.0, green: 0xC4 / 255.0, blue: 0xAE / 255.0).opacity(0.35)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                // Layer 1: Ambient warm reddish/coral glow shadow at bottom (matching mockup)
                .shadow(
                    color: Color("Button_red").opacity(0.18),
                    radius: 28,
                    x: 0,
                    y: 18
                )
                // Layer 2: Soft warm dark ambient shadow
                .shadow(
                    color: Color(red: 0x3A / 255.0, green: 0x24 / 255.0, blue: 0x16 / 255.0).opacity(0.12),
                    radius: 14,
                    x: 0,
                    y: 8
                )
                // Layer 3: Crisp contact drop shadow
                .shadow(
                    color: Color.black.opacity(0.04),
                    radius: 4,
                    x: 0,
                    y: 2
                )
            
            // 2. Elevated 3D Pizza with Deep Shadow onto the Disc
            Image(slide.image)
                .resizable()
                .scaledToFit()
                .frame(width: pizzaSize, height: pizzaSize)
                .clipShape(Circle())
                // Layer 1: Primary deep drop shadow
                .shadow(
                    color: Color(red: 0x22 / 255.0, green: 0x11 / 255.0, blue: 0x06 / 255.0).opacity(0.36),
                    radius: 18,
                    x: 0,
                    y: 12
                )
                // Layer 2: Crisp contact shadow
                .shadow(
                    color: Color.black.opacity(0.18),
                    radius: 6,
                    x: 0,
                    y: 3
                )
            
            // 3. Floating Sticker Badge (Tilted at 4:30 position, outside the pizza on the 3D disc)
            if let top = slide.badgeTop, let middle = slide.badgeMiddle, let bottom = slide.badgeBottom {
                tiltedBadgeSticker(top: top, middle: middle, bottom: bottom)
                    .offset(x: pizzaSize * 0.54, y: pizzaSize * 0.48)
            }
        }
        .frame(width: discSize + 50, height: discSize + 50)
    }
    
    // MARK: - Floating Tilted Badge Sticker
    
    private func tiltedBadgeSticker(top: String, middle: String, bottom: String) -> some View {
        ZStack {
            // White circular badge base
            Circle()
                .fill(Color.white)
                .frame(width: 86, height: 86)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.9), lineWidth: 1.2)
                )
                // 3D elevation drop shadows for the sticker
                .shadow(
                    color: Color(red: 0x25 / 255.0, green: 0x15 / 255.0, blue: 0x0A / 255.0).opacity(0.16),
                    radius: 10,
                    x: 2,
                    y: 6
                )
                .shadow(
                    color: Color.black.opacity(0.08),
                    radius: 3,
                    x: 0,
                    y: 2
                )
            
            // Tilted typography content (-10 degrees)
            VStack(spacing: -1.5) {
                Text(top)
                    .font(.oswaldMedium(size: 11))
                    .tracking(1.6)
                    .foregroundColor(Color("Button_red"))
                
                Text(middle)
                    .font(.oswaldBold(size: 21))
                    .tracking(0.5)
                    .foregroundColor(Color("Button_red"))
                
                Text(bottom)
                    .font(.oswaldMedium(size: 11))
                    .tracking(1.6)
                    .foregroundColor(Color("Button_red"))
            }
            .rotationEffect(.degrees(-10))
        }
    }
    
    // MARK: - Page Indicator
    
    private var pageIndicator: some View {
        HStack(spacing: 6) {
            ForEach(0..<max(2, slides.count), id: \.self) { index in
                if index == currentPage {
                    Capsule()
                        .fill(Color("Button_red"))
                        .frame(width: 22, height: 8)
                        .transition(.identity)
                } else {
                    Circle()
                        .fill(Color("Button_red").opacity(0.25))
                        .frame(width: 6, height: 6)
                        .onTapGesture {
                            if index < slides.count {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                    currentPage = index
                                }
                            } else {
                                onFinish?()
                            }
                        }
                }
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: currentPage)
    }
    
    // MARK: - Action Button
    
    private var actionButton: some View {
        Button(action: {
            handleNextTap()
        }) {
            HStack(spacing: 8) {
                Text(currentPage == slides.count - 1 ? "NEXT" : "NEXT")
                    .font(.oswaldMedium(size: 16))
                    .tracking(1.2)
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
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
    
    // MARK: - Actions
    
    private func handleNextTap() {
        if currentPage < slides.count - 1 {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                currentPage += 1
            }
        } else {
            onFinish?()
        }
    }
}

// MARK: - Button Press Style

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.92 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - SwiftUI Preview

#Preview {
    OnboardingView(
        onSkip: { print("Skipped") },
        onFinish: { print("Finished") }
    )
}

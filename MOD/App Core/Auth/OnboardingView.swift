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
    let badgeTop: String
    let badgeMiddle: String
    let badgeBottom: String
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
                Color("pizza_found")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top Navigation Bar
                    headerBar
                        .padding(.top, 8)
                        .padding(.horizontal, 24)
                    
                    Spacer(minLength: 12)
                    
                    // Paged Slide Content
                    TabView(selection: $currentPage) {
                        ForEach(slides.indices, id: \.self) { index in
                            slideView(for: slides[index], geometry: geometry)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(height: geometry.size.height * 0.62)
                    
                    Spacer(minLength: 8)
                    
                    // Page Indicator Dots
                    pageIndicator
                        .padding(.bottom, 22)
                    
                    // Bottom Action Button
                    actionButton
                        .padding(.horizontal, 24)
                        .padding(.bottom, geometry.safeAreaInsets.bottom > 0 ? 12 : 24)
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
                .frame(width: 40, height: 44)
                .accessibilityLabel("MOD Pizza Logo")
            
            Spacer()
            
            // Skip Button
            Button(action: {
                onSkip?()
            }) {
                Text("Skip")
                    .font(.barlowBold(size: 15))
                    .foregroundColor(Color(red: 0x4A / 255.0, green: 0x45 / 255.0, blue: 0x40 / 255.0))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 4)
            }
        }
    }
    
    // MARK: - Slide View
    
    private func slideView(for slide: OnboardingSlideItem, geometry: GeometryProxy) -> some View {
        let pizzaSize = min(geometry.size.width * 0.68, 260.0)
        let backgroundDiscSize = pizzaSize * 1.34
        
        return VStack(spacing: 0) {
            // Hero Graphic Area
            ZStack {
                // Background Soft Disc
                Circle()
                    .fill(Color.white.opacity(0.35))
                    .frame(width: backgroundDiscSize, height: backgroundDiscSize)
                
                // Pizza Image
                Image(slide.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: pizzaSize, height: pizzaSize)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.18), radius: 18, x: 0, y: 10)
                
                // Floating Badge Sticker (Bottom Right)
                badgeSticker(top: slide.badgeTop, middle: slide.badgeMiddle, bottom: slide.badgeBottom)
                    .offset(x: pizzaSize * 0.38, y: pizzaSize * 0.32)
            }
            .frame(height: backgroundDiscSize + 20)
            
            Spacer(minLength: 16)
            
            // Slide Title
            Text(slide.title)
                .font(.oswaldMedium(size: 32))
                .foregroundColor(Color("app_black"))
                .tracking(0.6)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            
            // Slide Description
            Text(slide.description)
                .font(.barlowRegular(size: 16))
                .foregroundColor(Color("text_gary"))
                .lineSpacing(4)
                .multilineTextAlignment(.center)
                .padding(.top, 10)
                .padding(.horizontal, 32)
        }
    }
    
    // MARK: - Floating Badge Sticker
    
    private func badgeSticker(top: String, middle: String, bottom: String) -> some View {
        ZStack {
            // Sticker White Base
            Circle()
                .fill(Color.white)
                .frame(width: 86, height: 86)
                .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 6)
            
            // Text Content
            VStack(spacing: -1) {
                Text(top)
                    .font(.oswaldMedium(size: 11))
                    .tracking(1.0)
                    .foregroundColor(Color("Button_red"))
                
                Text(middle)
                    .font(.oswaldBold(size: 20))
                    .tracking(0.4)
                    .foregroundColor(Color("Button_red"))
                
                Text(bottom)
                    .font(.oswaldMedium(size: 11))
                    .tracking(1.0)
                    .foregroundColor(Color("Button_red"))
            }
        }
    }
    
    // MARK: - Page Indicator
    
    private var pageIndicator: some View {
        HStack(spacing: 6) {
            ForEach(slides.indices, id: \.self) { index in
                if index == currentPage {
                    Capsule()
                        .fill(Color("Button_red"))
                        .frame(width: 22, height: 6)
                        .transition(.identity)
                } else {
                    Circle()
                        .fill(Color("Button_red").opacity(0.25))
                        .frame(width: 6, height: 6)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                currentPage = index
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

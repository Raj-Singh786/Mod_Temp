//
//  OTPVerificationView.swift
//  MOD
//
//  Created by Rajpal singh on 15/11/26.
//

import SwiftUI
import Combine

struct OTPVerificationView: View {
    
    // MARK: - Properties
    
    let destination: String
    let mode: LoginInputMode
    var codeLength: Int = 6
    
    // MARK: - Callbacks
    
    var onVerificationSuccess: (() -> Void)? = nil
    var onContinueAsGuest: (() -> Void)? = nil
    var onBack: (() -> Void)? = nil
    var onResend: (() -> Void)? = nil
    
    // MARK: - State
    
    @State private var otpCode: String = ""
    @State private var errorMessage: String? = nil
    @State private var secondsRemaining: Int = 30
    @State private var canResend: Bool = false
    @FocusState private var isFieldFocused: Bool
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // MARK: - Computed Properties
    
    private var maskedDestination: String {
        if mode == .email {
            let parts = destination.split(separator: "@")
            guard parts.count == 2 else { return destination }
            let name = parts[0]
            let domain = parts[1]
            let masked = name.count > 2 ? "\(name.prefix(2))••••" : "\(name)••••"
            return "\(masked)@\(domain)"
        } else {
            let digits = destination.filter { $0.isNumber }
            if digits.count >= 4 {
                return "••••••" + digits.suffix(4)
            }
            return destination
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            let safeTop = geometry.safeAreaInsets.top > 0 ? geometry.safeAreaInsets.top : 20.0
            let pizzaSize = min(geometry.size.width * 0.72, 280.0)
            let pizzaTop = safeTop + 10.0
            let topSpacing = pizzaTop + (pizzaSize * 0.50)
            let minCardHeight = geometry.size.height - topSpacing + geometry.safeAreaInsets.bottom + 60
            
            ZStack(alignment: .top) {
                // Background Color
                Color("app_background")
                    .ignoresSafeArea()
                
                // Top Header Graphic (Pizza peaking behind card - half pizza shown, no red zigzag)
                topBackgroundGraphic(pizzaSize: pizzaSize, pizzaTop: pizzaTop, safeTop: safeTop)
                
                // Main Content Card (Scrollable)
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Spacing from top so half of pizza & logo are visible
                        Color.clear
                            .frame(height: topSpacing)
                        
                        // White Content Card
                        cardContent(minHeight: minCardHeight)
                    }
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .onAppear {
                isFieldFocused = true
            }
            .onReceive(timer) { _ in
                if secondsRemaining > 0 {
                    secondsRemaining -= 1
                } else if !canResend {
                    canResend = true
                }
            }
        }
    }
    
    // MARK: - Top Background Graphic
    
    private func topBackgroundGraphic(pizzaSize: CGFloat, pizzaTop: CGFloat, safeTop: CGFloat) -> some View {
        ZStack(alignment: .top) {
            // Centered Pizza Peaking Behind Card (showing top half)
            Image(UIImage(named: "PizzaOn") != nil ? "PizzaOn" : "pizza1")
                .resizable()
                .scaledToFit()
                .frame(width: pizzaSize, height: pizzaSize)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.16), radius: 16, x: 0, y: 8)
                .offset(y: pizzaTop)
            
            // MOD Shield Logo & Optional Back Button at Top
            HStack {
                if let onBack = onBack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color("app_black"))
                            .frame(width: 38, height: 38)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.88))
                                    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.leading, 16)
                }
                
                Spacer()
                
                Image("app_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 42)
                    .accessibilityLabel("MOD Pizza Logo")
                
                Spacer()
                
                if onBack != nil {
                    Color.clear
                        .frame(width: 38, height: 38)
                        .padding(.trailing, 16)
                }
            }
            .padding(.top, safeTop > 20 ? 6 : 14)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Card Content
    
    private func cardContent(minHeight: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Subtitle
            Text("SIGN IN")
                .font(.oswaldMedium(size: 13))
                .tracking(1.4)
                .foregroundColor(Color("Button_red"))
                .padding(.top, 28)
            
            // Headline
            Text("ENTER YOUR CODE")
                .font(.oswaldMedium(size: 32))
                .tracking(0.6)
                .foregroundColor(Color("app_black"))
                .padding(.top, 6)
            
            // Description
            (
                Text("We sent a 6-digit code to ")
                    .font(.barlowRegular(size: 15.5))
                +
                Text(maskedDestination)
                    .font(.barlowBold(size: 15.5))
            )
            .foregroundColor(Color("text_gary"))
            .lineSpacing(3)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.top, 8)
            .padding(.bottom, 24)
            
            // 6-digit Code Input Section
            codeInputSection
                .padding(.bottom, 20)
            
            // Verify & Sign In Button
            verifyButton
                .padding(.bottom, 20)
            
            // Actions Row (Resend Code + Use a Different Number / Email)
            actionRow
                .padding(.bottom, 24)
            
            // "or" Divider
            orDivider
                .padding(.bottom, 24)
            
            // Continue As Guest Button
            continueAsGuestButton
                .padding(.bottom, 36)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .top)
        .background(
            // White card with top-rounded corners extending downward
            CustomTopRoundedCard(cornerRadius: 26)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 18, x: 0, y: -4)
        )
    }
    
    // MARK: - Code Input Section
    
    private var codeInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("6-digit code")
                .font(.barlowSemiBold(size: 14))
                .foregroundColor(Color("app_black"))
            
            ZStack(alignment: .leading) {
                if otpCode.isEmpty {
                    Text("")
                        .foregroundColor(Color("text_gary").opacity(0.5))
                        .padding(.horizontal, 16)
                }
                
                TextField("", text: Binding(
                    get: { otpCode },
                    set: { newValue in
                        let digits = newValue.filter { $0.isNumber }
                        otpCode = String(digits.prefix(codeLength))
                        if !otpCode.isEmpty {
                            errorMessage = nil
                        }
                        if otpCode.count == codeLength {
                            handleVerify()
                        }
                    }
                ))
                .font(.oswaldMedium(size: 25))
                .tracking(10.0)
                .multilineTextAlignment(.center)
                .foregroundColor(Color("app_black"))
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($isFieldFocused)
                .padding(.horizontal, 16)
            }
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(
                        errorMessage != nil ? Color.red : (isFieldFocused ? Color("Button_red").opacity(0.6) : Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC7 / 255.0)),
                        lineWidth: 1.5
                    )
            )
            
            if let error = errorMessage {
                Text(error)
                    .font(.barlowRegular(size: 12.5))
                    .foregroundColor(.red)
                    .padding(.top, 2)
            }
        }
    }
    
    // MARK: - Verify Button
    
    private var verifyButton: some View {
        Button(action: {
            handleVerify()
        }) {
            Text("VERIFY & SIGN IN")
                .font(.oswaldMedium(size: 16))
                .tracking(1.2)
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
    
    // MARK: - Action Row (Resend + Switch Destination)
    
    private var actionRow: some View {
        HStack {
            // Resend Code Button
            Button(action: {
                if canResend {
                    resendCode()
                }
            }) {
                Text(canResend ? "RESEND CODE" : "RESEND CODE (\(secondsRemaining)S)")
                    .font(.oswaldMedium(size: 14))
                    .tracking(1.0)
                    .foregroundColor(canResend ? Color("app_black") : Color("text_gary"))
            }
            .disabled(!canResend)
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            // Use a Different Number / Email Button
            Button(action: {
                onBack?()
            }) {
                Text(mode == .email ? "USE A DIFFERENT EMAIL" : "USE A DIFFERENT NUMBER")
                    .font(.oswaldMedium(size: 14))
                    .tracking(1.0)
                    .foregroundColor(Color("app_black"))
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // MARK: - "or" Divider
    
    private var orDivider: some View {
        HStack(spacing: 14) {
            Rectangle()
                .fill(Color(red: 0xE2 / 255.0, green: 0xDC / 255.0, blue: 0xD2 / 255.0))
                .frame(height: 1)
            
            Text("or")
                .font(.barlowRegular(size: 13))
                .foregroundColor(Color("text_gary"))
            
            Rectangle()
                .fill(Color(red: 0xE2 / 255.0, green: 0xDC / 255.0, blue: 0xD2 / 255.0))
                .frame(height: 1)
        }
    }
    
    // MARK: - Continue As Guest Button
    
    private var continueAsGuestButton: some View {
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
    
    // MARK: - Actions
    
    private func handleVerify() {
        let trimmed = otpCode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count == codeLength else {
            errorMessage = "Please enter the complete \(codeLength)-digit code."
            return
        }
        
        errorMessage = nil
        onVerificationSuccess?()
    }
    
    private func resendCode() {
        otpCode = ""
        secondsRemaining = 30
        canResend = false
        errorMessage = nil
        isFieldFocused = true
        onResend?()
    }
}

// MARK: - Preview

struct OTPVerificationView_Previews: PreviewProvider {
    static var previews: some View {
        OTPVerificationView(
            destination: "+1 (555) 000-0463",
            mode: .sms
        )
    }
}

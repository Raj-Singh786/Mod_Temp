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
            // Everything is sized from the real screen width, so the oversized dome
            // circle can't make the layout wider than the screen.
            let width = geometry.size.width
            
            // Real top inset (status bar / Dynamic Island). The fallback is only for previews.
            let safeTop = geometry.safeAreaInsets.top > 0 ? geometry.safeAreaInsets.top : 47.0
            
            // Layout metrics (same as LoginView)
            let logoStripHeight: CGFloat = 56
            let logoHeight: CGFloat = 34
            let redBandTop = safeTop + logoStripHeight
            let redBandHeight: CGFloat = 200
            let domeDiameter = width * 1.2
            let domeTop: CGFloat = 36
            let pizzaDiameter = min(width * 0.56, 220)
            let pizzaTopInBand: CGFloat = 92
            
            // Card overlaps the lower part of the pizza
            let cardTop = redBandTop + pizzaTopInBand + (pizzaDiameter * 0.38)
            
            ZStack(alignment: .top) {
                // Page background (also shows behind the status bar)
                Color("app_background")
                
                // 1. Beige logo strip: logo centered, back button on the leading side
                ZStack {
                    Color("pizza_found")
                    
                    Image("app_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: logoHeight)
                        .accessibilityLabel("MOD Pizza Logo")
                    
                    if let onBack = onBack {
                        HStack {
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
                            
                            Spacer()
                        }
                        .padding(.leading, 16)
                    }
                }
                .frame(width: width, height: logoStripHeight)
                .offset(y: safeTop)
                
                // 2. Red gradient band with cream dome, pizza, stripes and badge
                ZStack(alignment: .top) {
                    // Gradient: brand red -> deep maroon (#7D1226 is the prototype's theme color)
                    LinearGradient(
                        colors: [
                            Color("Button_red"),
                            Color(red: 0x7D / 255.0, green: 0x12 / 255.0, blue: 0x26 / 255.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    // Cream dome. The extra frame makes it report the band size,
                    // so the oversized circle can't widen the layout.
                    Circle()
                        .fill(Color("pizza_found"))
                        .frame(width: domeDiameter, height: domeDiameter)
                        .frame(width: width, height: redBandHeight, alignment: .top)
                        .offset(y: domeTop)
                    
                    // Pizza
                    Image("PizzaOn")
                        .resizable()
                        .scaledToFit()
                        .frame(width: pizzaDiameter, height: pizzaDiameter)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.18), radius: 10, x: 0, y: 5)
                        .offset(y: pizzaTopInBand)
                    
                    // Top-left accent stripes (red & cream)
                    VStack(alignment: .leading, spacing: 4.5) {
                        Capsule()
                            .fill(Color(red: 0xD7 / 255.0, green: 0x2E / 255.0, blue: 0x48 / 255.0))
                            .frame(width: 38, height: 6)
                        
                        Capsule()
                            .fill(Color("pizza_found"))
                            .frame(width: 38, height: 6)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20)
                    .padding(.top, 22)
                    
                    // Top-right tilted "MADE YOUR WAY" sticker
                    madeYourWayBadge
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing, 14)
                        .padding(.top, 22)
                }
                .frame(width: width, height: redBandHeight, alignment: .top)
                .clipped()
                .offset(y: redBandTop)
                
                // 3. White verification card
                cardContent
                    .padding(.horizontal, 12)
                    .offset(y: cardTop)
            }
            .frame(width: width, height: geometry.size.height, alignment: .top)
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
        // Lets the layout start at the very top of the screen so safeAreaInsets.top
        // is the real inset. .container keeps the keyboard behavior untouched.
        .ignoresSafeArea(.container)
        // Hide the top navigation bar and the back button.
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
    
    // MARK: - "MADE YOUR WAY" Badge
    
    private var madeYourWayBadge: some View {
        VStack(spacing: 1.5) {
            Text("MADE")
                .font(.oswaldBold(size: 10.5))
                .tracking(0.6)
            
            Text("YOUR")
                .font(.oswaldBold(size: 17))
                .tracking(0.6)
            
            Text("WAY")
                .font(.oswaldBold(size: 10.5))
                .tracking(0.6)
        }
        .foregroundColor(Color("Button_red"))
        .frame(width: 72, height: 72)
        .background(
            Circle()
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: -2, y: 4)
        )
        // Negative = counter-clockwise tilt, like the prototype
        .rotationEffect(.degrees(-8))
    }
    
    // MARK: - Card Content (Fixed Card with Rounded Corners)
    
    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Subtitle
            Text("SIGN IN")
                .font(.oswaldMedium(size: 13))
                .tracking(1.4)
                .foregroundColor(Color("Button_red"))
                .padding(.top, 22)
            
            // Headline
            Text("ENTER YOUR CODE")
                .font(.oswaldMedium(size: 30))
                .tracking(0.6)
                .foregroundColor(Color("app_black"))
                .padding(.top, 4)
            
            // Description
            (
                Text("We sent a 6-digit code to ")
                    .font(.barlowRegular(size: 14.5))
                +
                Text(maskedDestination)
                    .font(.barlowBold(size: 14.5))
            )
            .foregroundColor(Color("text_gary"))
            .lineSpacing(2)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.top, 6)
            .padding(.bottom, 18)
            
            // 6-digit Code Input Section
            codeInputSection
                .padding(.bottom, 16)
            
            // Verify & Sign In Button
            verifyButton
                .padding(.bottom, 18)
            
            // Actions Row (Resend Code + Use a Different Number / Email)
            actionRow
                .padding(.bottom, 18)
            
            // "or" Divider
            orDivider
                .padding(.bottom, 16)
            
            // Continue As Guest Button
            continueAsGuestButton
                .padding(.bottom, 24)
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white)
                // Two layered shadows: a tight one for contact, a wide soft one for depth
                .shadow(color: Color.black.opacity(0.10), radius: 6, x: 0, y: 3)
                .shadow(color: Color.black.opacity(0.16), radius: 22, x: 0, y: 12)
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
        NavigationStack {
            OTPVerificationView(
                destination: "+1 (555) 000-0463",
                mode: .sms
            )
        }
    }
}

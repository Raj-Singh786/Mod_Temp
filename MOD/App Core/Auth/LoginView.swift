//
//  LoginView.swift
//  MOD
//
//  Created by Rajpal singh on 15/11/26.
//

import SwiftUI

enum LoginInputMode: String, CaseIterable, Identifiable, Hashable {
    case email = "Email"
    case sms = "Text (SMS)"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .email: return "envelope"
        case .sms: return "phone"
        }
    }
    
    var fieldLabel: String {
        switch self {
        case .email: return "Email address"
        case .sms: return "Mobile number"
        }
    }
    
    var placeholder: String {
        switch self {
        case .email: return "you@example.com"
        case .sms: return "+1 (555) 000-0000"
        }
    }
    
    @ViewBuilder
    var iconView: some View {
        if self == .email, UIImage(named: "email") != nil {
            Image("email")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 17, height: 17)
        } else if self == .sms, UIImage(named: "calling") != nil {
            Image("calling")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 17, height: 17)
        } else {
            Image(systemName: self == .email ? "envelope" : "phone")
                .font(.system(size: 14, weight: .medium))
        }
    }
}

// MARK: - LoginView

struct LoginView: View {
    
    // MARK: - Configuration
    
    var subtitle: String = "SIGN IN"
    var headline: String = "WELCOME BACK"
    
    // MARK: - Callbacks
    
    var onSendCode: ((String, LoginInputMode) -> Void)? = nil
    var onContinueAsGuest: (() -> Void)? = nil
    var onBack: (() -> Void)? = nil
    
    // MARK: - State
    
    @State private var selectedMode: LoginInputMode = .email
    @State private var inputText: String = ""
    @State private var errorMessage: String? = nil
    @FocusState private var isFieldFocused: Bool
    
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
                
                // Top Header Graphic (Pizza peaking from behind card)
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
            
            // MOD Shield Logo Centered at Top
            HStack {
                Spacer()
                
                Image("app_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 42)
                    .accessibilityLabel("MOD Pizza Logo")
                
                Spacer()
            }
            .padding(.top, safeTop > 20 ? 6 : 14)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Card Content
    
    private func cardContent(minHeight: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Subtitle
            Text(subtitle)
                .font(.oswaldMedium(size: 13))
                .tracking(1.4)
                .foregroundColor(Color("Button_red"))
                .padding(.top, 28)
            
            // Headline
            Text(headline)
                .font(.oswaldMedium(size: 32))
                .tracking(0.6)
                .foregroundColor(Color("app_black"))
                .padding(.top, 6)
            
            // Description
            Text("No password needed — we’ll send you a one-time code.")
                .font(.barlowRegular(size: 15.5))
                .foregroundColor(Color("text_gary"))
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 8)
                .padding(.bottom, 22)
            
            // Segmented Switcher (Email vs SMS)
            segmentedSwitcher
                .padding(.bottom, 24)
            
            // Input Field Section
            inputSection
                .padding(.bottom, 20)
            
            // Send Code Button
            sendCodeButton
                .padding(.bottom, 28)
            
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
    
    // MARK: - Segmented Switcher
    
    private var segmentedSwitcher: some View {
        HStack(spacing: 0) {
            ForEach(LoginInputMode.allCases) { mode in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        selectedMode = mode
                        inputText = ""
                        errorMessage = nil
                    }
                }) {
                    HStack(spacing: 6) {
                        mode.iconView
                        
                        Text(mode.rawValue)
                            .font(.barlowSemiBold(size: 15))
                    }
                    .foregroundColor(Color("app_black"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(
                        Group {
                            if selectedMode == mode {
                                Capsule()
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                            } else {
                                Color.clear
                            }
                        }
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(4)
        .background(
            Capsule()
                .fill(Color(red: 0xF2 / 255.0, green: 0xEA / 255.0, blue: 0xDE / 255.0))
        )
    }
    
    // MARK: - Input Section
    
    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(selectedMode.fieldLabel)
                .font(.barlowSemiBold(size: 14))
                .foregroundColor(Color("app_black"))
            
            TextField(selectedMode.placeholder, text: $inputText)
                .font(.barlowRegular(size: 16))
                .foregroundColor(Color("app_black"))
                .keyboardType(selectedMode == .email ? .emailAddress : .phonePad)
                .textContentType(selectedMode == .email ? .emailAddress : .telephoneNumber)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .focused($isFieldFocused)
                .padding(.horizontal, 16)
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
    
    // MARK: - Send Code Button
    
    private var sendCodeButton: some View {
        Button(action: {
            handleSendCode()
        }) {
            Text("SEND CODE")
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
    
    // MARK: - Validation & Actions
    
    private func handleSendCode() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else {
            errorMessage = selectedMode == .email ? "Please enter your email address." : "Please enter your mobile number."
            return
        }
        
        if selectedMode == .email {
            let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,64}$"#
            if trimmed.range(of: emailRegex, options: .regularExpression) == nil {
                errorMessage = "Please enter a valid email address."
                return
            }
        } else {
            guard PhoneValidator.validate(trimmed) != nil else {
                errorMessage = "Please enter a valid mobile number."
                return
            }
        }
        
        errorMessage = nil
        onSendCode?(trimmed, selectedMode)
    }
}

// MARK: - Phone Validator

enum PhoneRegion: String, Hashable {
    case india = "India"
    case us = "US"
}

struct PhoneValidator {
    /// Returns the matching region and the clean 10-digit number, or nil if invalid.
    static func validate(_ input: String) -> (region: PhoneRegion, number: String)? {
        var digits = input.filter { $0.isNumber }

        // India: 10 digits, starts with 6-9. Accepts an optional 91 or 0 prefix.
        var indian = digits
        if indian.hasPrefix("91") && indian.count == 12 { indian.removeFirst(2) }
        else if indian.hasPrefix("0") && indian.count == 11 { indian.removeFirst(1) }

        if indian.range(of: #"^[6-9][0-9]{9}$"#, options: .regularExpression) != nil {
            return (.india, indian)
        }

        // US (NANP): 10 digits, area code and exchange both start with 2-9. Optional 1 prefix.
        if digits.hasPrefix("1") && digits.count == 11 { digits.removeFirst(1) }

        if digits.range(of: #"^[2-9][0-9]{2}[2-9][0-9]{6}$"#, options: .regularExpression) != nil {
            return (.us, digits)
        }

        return nil
    }
}

// MARK: - Top-Rounded Card Shape

struct CustomTopRoundedCard: Shape {
    var cornerRadius: CGFloat = 26
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
        path.addArc(
            center: CGPoint(x: rect.minX + cornerRadius, y: rect.minY + cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
        path.addArc(
            center: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY + cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(270),
            endAngle: .degrees(0),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        
        return path
    }
}

// MARK: - SwiftUI Preview

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(
            onSendCode: { destination, mode in
                print("Sending code to \(destination) via \(mode.rawValue)")
            },
            onContinueAsGuest: {
                print("Continue as guest")
            }
        )
    }
}

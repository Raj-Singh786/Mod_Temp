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
            // Everything is sized from the real screen width. Without this, the oversized
            // dome circle made the layout wider than the screen, which pushed the card
            // against the right edge and shifted the red band.
            let width = geometry.size.width
            
            // Real top inset (status bar / Dynamic Island). The fallback is only for previews.
            let safeTop = geometry.safeAreaInsets.top > 0 ? geometry.safeAreaInsets.top : 47.0
            
            // Layout metrics (measured from the prototype screenshot)
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
                
                // 1. Beige logo strip with the MOD shield centered in it
                ZStack {
                    Color("pizza_found")
                    
                    Image("app_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: logoHeight)
                        .accessibilityLabel("MOD Pizza Logo")
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
                
                // 3. White sign-in card
                cardContent
                    .padding(.horizontal, 12)
                    .offset(y: cardTop)
            }
            .frame(width: width, height: geometry.size.height, alignment: .top)
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
            Text(subtitle)
                .font(.oswaldMedium(size: 13))
                .tracking(1.4)
                .foregroundColor(Color("Button_red"))
                .padding(.top, 22)
            
            // Headline
            Text(headline)
                .font(.oswaldMedium(size: 30))
                .tracking(0.6)
                .foregroundColor(Color("app_black"))
                .padding(.top, 4)
            
            // Description
            Text("No password needed — we’ll send you a one-time code.")
                .font(.barlowRegular(size: 14.5))
                .foregroundColor(Color("text_gary"))
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 6)
                .padding(.bottom, 18)
            
            // Segmented Switcher (Email vs SMS)
            segmentedSwitcher
                .padding(.bottom, 18)
            
            // Input Field Section
            inputSection
                .padding(.bottom, 16)
            
            // Send Code Button
            sendCodeButton
                .padding(.bottom, 20)
            
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
        NavigationStack {
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
}

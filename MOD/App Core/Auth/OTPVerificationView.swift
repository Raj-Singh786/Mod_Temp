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
    
    var onVerificationSuccess: (() -> Void)? = nil
    var onBack: (() -> Void)? = nil
    var onResend: (() -> Void)? = nil
    
    // MARK: - State
    
    @State private var pinDigits: [String] = Array(repeating: "", count: 6)
    @FocusState private var focusedIndex: Int?
    @State private var errorMessage: String? = nil
    @State private var secondsRemaining: Int = 30
    @State private var canResend: Bool = false
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // MARK: - Computed Properties
    
    private var maskedDestination: String {
        if mode == .email {
            let parts = destination.split(separator: "@")
            guard parts.count == 2 else { return destination }
            let name = parts[0]
            let domain = parts[1]
            let masked = name.count > 2 ? "\(name.prefix(2))****" : "\(name)****"
            return "\(masked)@\(domain)"
        } else {
            let digits = destination.filter { $0.isNumber }
            if digits.count > 4 {
                return "•••• ••• " + digits.suffix(4)
            }
            return destination
        }
    }
    
    private var isCodeComplete: Bool {
        pinDigits.allSatisfy { !$0.isEmpty } && pinDigits.count == codeLength
    }
    
    private var codeString: String {
        pinDigits.joined()
    }
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Background Color
                Color("pizza_found")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header Bar (Back button + Logo)
                    headerBar(geometry: geometry)
                        .padding(.top, geometry.safeAreaInsets.top > 0 ? 4 : 12)
                        .padding(.horizontal, 20)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            // Subtitle
                            Text("VERIFICATION")
                                .font(.oswaldMedium(size: 13))
                                .tracking(1.4)
                                .foregroundColor(Color("Button_red"))
                                .padding(.top, 28)
                            
                            // Headline
                            Text("ENTER 6-DIGIT CODE")
                                .font(.oswaldMedium(size: 30))
                                .tracking(0.6)
                                .foregroundColor(Color("app_black"))
                                .padding(.top, 6)
                            
                            // Subtitle
                            Text("We sent a one-time verification code to\n\(maskedDestination)")
                                .font(.barlowRegular(size: 15.5))
                                .foregroundColor(Color("text_gary"))
                                .lineSpacing(3.5)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.top, 8)
                                .padding(.bottom, 28)
                            
                            // 6-digit Code Boxes
                            otpFieldsSection
                                .padding(.bottom, 16)
                            
                            // Error message
                            if let error = errorMessage {
                                Text(error)
                                    .font(.barlowRegular(size: 13))
                                    .foregroundColor(.red)
                                    .padding(.bottom, 14)
                            }
                            
                            // Resend Timer / Button
                            resendSection
                                .padding(.bottom, 32)
                            
                            // Verify Button
                            verifyButton
                                .padding(.bottom, 24)
                        }
                        .padding(.horizontal, 24)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .scrollDismissesKeyboard(.interactively)
                }
            }
            .onAppear {
                focusedIndex = 0
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
    
    // MARK: - Header Bar
    
    private func headerBar(geometry: GeometryProxy) -> some View {
        HStack(alignment: .center) {
            Button(action: {
                onBack?()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color("app_black"))
                    .frame(width: 38, height: 38)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.9))
                            .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                    )
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            Image("app_logo")
                .resizable()
                .scaledToFit()
                .frame(width: 34, height: 40)
                .accessibilityLabel("MOD Pizza Logo")
            
            Spacer()
            
            // Placeholder to keep logo centered
            Color.clear
                .frame(width: 38, height: 38)
        }
    }
    
    // MARK: - OTP Fields Section
    
    private var otpFieldsSection: some View {
        HStack(spacing: 9) {
            ForEach(0..<codeLength, id: \.self) { index in
                singleDigitField(index: index)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    private func singleDigitField(index: Int) -> some View {
        let isFocused = (focusedIndex == index)
        let hasValue = !pinDigits[index].isEmpty
        
        return ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white)
            
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(
                    errorMessage != nil ? Color.red : (isFocused ? Color("Button_red") : (hasValue ? Color("app_black").opacity(0.4) : Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC7 / 255.0))),
                    lineWidth: isFocused ? 2.0 : 1.2
                )
            
            TextField("", text: Binding(
                get: {
                    pinDigits[index]
                },
                set: { newValue in
                    handleDigitInput(newValue, at: index)
                }
            ))
            .keyboardType(.numberPad)
            .textContentType(index == 0 ? .oneTimeCode : .none)
            .multilineTextAlignment(.center)
            .font(.oswaldMedium(size: 24))
            .foregroundColor(Color("app_black"))
            .focused($focusedIndex, equals: index)
        }
        .frame(height: 54)
    }
    
    private func handleDigitInput(_ newValue: String, at index: Int) {
        let digitsOnly = newValue.filter { $0.isNumber }
        
        // Handle paste / SMS autofill of full OTP code
        if digitsOnly.count > 1 {
            for (offset, char) in digitsOnly.prefix(codeLength).enumerated() {
                pinDigits[offset] = String(char)
            }
            focusedIndex = min(digitsOnly.count, codeLength - 1)
            errorMessage = nil
            if isCodeComplete {
                handleVerify()
            }
            return
        }
        
        if let lastDigit = digitsOnly.last {
            pinDigits[index] = String(lastDigit)
            errorMessage = nil
            if index < codeLength - 1 {
                focusedIndex = index + 1
            } else {
                focusedIndex = nil
                if isCodeComplete {
                    handleVerify()
                }
            }
        } else {
            // Deleted
            pinDigits[index] = ""
            if index > 0 {
                focusedIndex = index - 1
            }
        }
    }
    
    // MARK: - Resend Section
    
    private var resendSection: some View {
        HStack(spacing: 6) {
            Text("Didn't receive a code?")
                .font(.barlowRegular(size: 14.5))
                .foregroundColor(Color("text_gary"))
            
            if canResend {
                Button(action: {
                    resendCode()
                }) {
                    Text("Resend code")
                        .font(.barlowSemiBold(size: 14.5))
                        .foregroundColor(Color("Button_red"))
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                Text("Resend in \(secondsRemaining)s")
                    .font(.barlowMedium(size: 14.5))
                    .foregroundColor(Color("text_gary").opacity(0.8))
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
                        .fill(isCodeComplete ? Color("Button_red") : Color("Button_red").opacity(0.45))
                )
                .shadow(color: isCodeComplete ? Color("Button_red").opacity(0.35) : Color.clear, radius: 10, x: 0, y: 5)
        }
        .disabled(!isCodeComplete)
        .buttonStyle(ScaleButtonStyle())
    }
    
    // MARK: - Actions
    
    private func handleVerify() {
        guard isCodeComplete else {
            errorMessage = "Please enter the complete 6-digit code."
            return
        }
        
        errorMessage = nil
        onVerificationSuccess?()
    }
    
    private func resendCode() {
        pinDigits = Array(repeating: "", count: codeLength)
        secondsRemaining = 30
        canResend = false
        focusedIndex = 0
        errorMessage = nil
        onResend?()
    }
}

// MARK: - Preview

#Preview {
    OTPVerificationView(
        destination: "jordan.rivera@example.com",
        mode: .email
    )
}

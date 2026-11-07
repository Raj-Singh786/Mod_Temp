//
//  SignupView.swift
//  MOD
//
//  Created by Rajpal singh on 07/11/26.
//

import SwiftUI

struct SignupView: View {
    @Environment(\.presentationMode) private var presentationMode
    var onDismiss: (() -> Void)? = nil

    // MARK: - Form States
    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var phoneNumber: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    
    // Referral
    @State private var isReferralExpanded: Bool = true
    @State private var referralCode: String = ""
    @State private var isReferralApplied: Bool = false
    
    // Opt-in
    @State private var isDealsOptIn: Bool = true
    
    // Alert
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Top Navigation Bar
            HStack {
                Button(action: dismissView) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(width: 44, height: 44, alignment: .leading)
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    Image("shield-icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                    Text("MOD SignUp")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                // Balance the back button
                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 12)
            .background(Color.white)

            // MARK: - Scrollable Content
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    
                    // 1. Full Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Full Name")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.black)
                        
                        HStack(spacing: 12) {
                            Image(systemName: "person")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
                                .frame(width: 20)
                            
                            TextField("e.g. Marcus Vance", text: $fullName)
                                .font(.system(size: 15))
                        }
                        .padding(.horizontal, 14)
                        .frame(height: 52)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(red: 0.88, green: 0.91, blue: 0.96), lineWidth: 1.2)
                        )
                    }

                    // 2. Email Address
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email Address")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.black)
                        
                        HStack(spacing: 12) {
                            Image(systemName: "envelope")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
                                .frame(width: 20)
                            
                            TextField("name@example.com", text: $email)
                                .font(.system(size: 15))
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                        }
                        .padding(.horizontal, 14)
                        .frame(height: 52)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(red: 0.88, green: 0.91, blue: 0.96), lineWidth: 1.2)
                        )
                    }

                    // 3. Mobile Phone
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Mobile Phone")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.black)
                            Spacer()
                            HStack(spacing: 4) {
                                Text("🚚")
                                    .font(.system(size: 12))
                                Text("For live SMS tracking")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(Color(red: 0.08, green: 0.52, blue: 0.35))
                            }
                        }
                        
                        HStack(spacing: 8) {
                            Text("🇺🇸")
                                .font(.system(size: 16))
                            Text("+1")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.black)
                            
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 1, height: 22)
                                .padding(.horizontal, 4)
                            
                            TextField("(555) 000–0000", text: $phoneNumber)
                                .font(.system(size: 15))
                                .keyboardType(.phonePad)
                        }
                        .padding(.horizontal, 14)
                        .frame(height: 52)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(red: 0.88, green: 0.91, blue: 0.96), lineWidth: 1.2)
                        )
                    }

                    // 4. Create Password
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Create Password")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.black)
                        
                        HStack(spacing: 12) {
                            Image(systemName: "lock")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
                                .frame(width: 20)
                            
                            if isPasswordVisible {
                                TextField("••••••••••••", text: $password)
                                    .font(.system(size: 15))
                            } else {
                                SecureField("••••••••••••", text: $password)
                                    .font(.system(size: 15))
                            }
                            
                            Button(action: { isPasswordVisible.toggle() }) {
                                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
                            }
                        }
                        .padding(.horizontal, 14)
                        .frame(height: 52)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(red: 0.88, green: 0.91, blue: 0.96), lineWidth: 1.2)
                        )
                        
                        // Validation Hint
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color(red: 0.12, green: 0.65, blue: 0.38))
                            Text("Must be 8+ characters and include a number")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
                            Spacer()
                        }
                        .padding(.top, 2)
                    }

                    // 5. Referral Code Accordion
                    VStack(alignment: .leading, spacing: 8) {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isReferralExpanded.toggle()
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "gift")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(Color(red: 0.85, green: 0.1, blue: 0.2))
                                Text("Have an invite / referral code?")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(Color(red: 0.85, green: 0.1, blue: 0.2))
                                Image(systemName: isReferralExpanded ? "chevron.up" : "chevron.down")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(Color(red: 0.85, green: 0.1, blue: 0.2))
                                Spacer()
                            }
                        }

                        if isReferralExpanded {
                            HStack {
                                TextField("Enter referral code", text: $referralCode)
                                    .font(.system(size: 14))
                                    .autocapitalization(.allCharacters)
                                
                                Button(action: applyReferral) {
                                    Text(isReferralApplied ? "Applied" : "Apply")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 7)
                                        .background(isReferralApplied ? Color.green : Color(red: 0.75, green: 0.05, blue: 0.15))
                                        .cornerRadius(6)
                                }
                            }
                            .padding(.leading, 12)
                            .padding(.trailing, 6)
                            .frame(height: 42)
                            .background(Color(red: 0.97, green: 0.98, blue: 0.99))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(red: 0.85, green: 0.88, blue: 0.92), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.top, 4)

                    // 6. Marketing Deals Checkbox
                    Button(action: { isDealsOptIn.toggle() }) {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: isDealsOptIn ? "checkmark.square.fill" : "square")
                                .font(.system(size: 19))
                                .foregroundColor(isDealsOptIn ? Color(red: 0.85, green: 0.1, blue: 0.2) : Color.gray.opacity(0.6))
                            
                            Text("Send me exclusive MOD deals, secret slice drops, and birthday treats. (Opt-out anytime)")
                                .font(.system(size: 13))
                                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                        }
                    }
                    .padding(.top, 4)

                    // 7. Create Account Button
                    Button(action: handleCreateAccount) {
                        HStack(spacing: 8) {
                            Text("Create Account & Claim $20 Perks")
                                .font(.system(size: 15, weight: .bold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color(red: 0.85, green: 0.1, blue: 0.2))
                        .cornerRadius(14)
                    }
                    .padding(.top, 8)

                    // 8. OR Divider
                    Text("OR")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)

                    // 9. Continue with Apple
                    Button(action: handleAppleSignIn) {
                        HStack(spacing: 10) {
                            Image(systemName: "apple.logo")
                                .font(.system(size: 18))
                            Text("Continue with Apple")
                                .font(.system(size: 15, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(red: 0.08, green: 0.11, blue: 0.16))
                        .cornerRadius(14)
                    }

                    // 10. Continue with Google
                    Button(action: handleGoogleSignIn) {
                        HStack(spacing: 10) {
                            GoogleGIcon(size: 18)
                            Text("Continue with Google")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.black)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.white)
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color(red: 0.88, green: 0.91, blue: 0.96), lineWidth: 1.2)
                        )
                    }

                    // 11. Continue As Guest
                    Button(action: handleGuestSignIn) {
                        HStack(spacing: 10) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                            Text("Continue As Guest")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.black)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.white)
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color(red: 0.88, green: 0.91, blue: 0.96), lineWidth: 1.2)
                        )
                    }

                    // 12. Legal Terms & Privacy
                    VStack(spacing: 2) {
                        Text("By creating an account, you agree to MOD Pizza's")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        HStack(spacing: 4) {
                            Button(action: {}) {
                                Text("Terms of Service")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.black)
                                    .underline()
                            }
                            Text("and")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                            Button(action: {}) {
                                Text("Privacy Policy")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.black)
                                    .underline()
                            }
                            Text(".")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
        }
        .background(Color.white.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    // MARK: - Actions

    private func dismissView() {
        if let onDismiss = onDismiss {
            onDismiss()
        } else {
            presentationMode.wrappedValue.dismiss()
        }
    }

    private func applyReferral() {
        let trimmed = referralCode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            showValidationAlert(title: "Referral Code", message: "Please enter a valid referral code.")
            return
        }
        isReferralApplied = true
        showValidationAlert(title: "Success", message: "Referral code applied! You unlocked bonus perks.")
    }

    private func handleCreateAccount() {
        let trimmedName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPhone = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            showValidationAlert(title: "Name Required", message: "Please enter your full name.")
            return
        }
        guard !trimmedEmail.isEmpty, trimmedEmail.contains("@"), trimmedEmail.contains(".") else {
            showValidationAlert(title: "Invalid Email", message: "Please enter a valid email address.")
            return
        }
        guard !trimmedPhone.isEmpty else {
            showValidationAlert(title: "Phone Required", message: "Please enter your mobile phone number.")
            return
        }
        guard password.count >= 8, password.rangeOfCharacter(from: .decimalDigits) != nil else {
            showValidationAlert(title: "Password Too Weak", message: "Password must be at least 8 characters and include a number.")
            return
        }

        // Account created - set user as logged in
        UserDefaults.standard.set(false, forKey: "isGuestUser")
        kSharedAppDelegate?.moveToTabBar(isGuest: false)
    }

    private func handleAppleSignIn() {
        UserDefaults.standard.set(false, forKey: "isGuestUser")
        kSharedAppDelegate?.moveToTabBar(isGuest: false)
    }

    private func handleGoogleSignIn() {
        UserDefaults.standard.set(false, forKey: "isGuestUser")
        kSharedAppDelegate?.moveToTabBar(isGuest: false)
    }

    private func handleGuestSignIn() {
        UserDefaults.standard.set(true, forKey: "isGuestUser")
        kSharedAppDelegate?.moveToTabBar(isGuest: true)
    }

    private func showValidationAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
}

// MARK: - Subviews & Visual Helpers

struct GoogleGIcon: View {
    var size: CGFloat = 18
    
    var body: some View {
        ZStack {
            Text("G")
                .font(.system(size: size, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 0.92, green: 0.26, blue: 0.21),
                            Color(red: 0.96, green: 0.71, blue: 0.0),
                            Color(red: 0.20, green: 0.66, blue: 0.33),
                            Color(red: 0.26, green: 0.52, blue: 0.96)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    SignupView()
}

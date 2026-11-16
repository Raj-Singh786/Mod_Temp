//
//  AuthCoordinatorView.swift
//  MOD
//
//  Created by Rajpal singh on 15/11/26.
//

import SwiftUI

// MARK: - Auth Destinations

enum AuthDestination: Hashable {
    case promotion
    case login
    case otp(destination: String, mode: LoginInputMode)
}

// MARK: - AuthCoordinatorView

struct AuthCoordinatorView: View {
    
    // MARK: - Navigation Path
    
    @State private var navigationPath = NavigationPath()
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            OnboardingView(
                onSkip: {
                    navigationPath.append(AuthDestination.promotion)
                },
                onFinish: {
                    navigationPath.append(AuthDestination.promotion)
                }
            )
            .navigationBarBackButtonHidden(true)
            .navigationDestination(for: AuthDestination.self) { destination in
                switch destination {
                case .promotion:
                    PromotionView(
                        onSignInWithCode: {
                            navigationPath.append(AuthDestination.login)
                        },
                        onContinueAsGuest: {
                            kSharedAppDelegate?.moveToTabBar(isGuest: true)
                        },
                        onPageSelected: { page in
                            if page == 0 && !navigationPath.isEmpty {
                                navigationPath.removeLast()
                            }
                        }
                    )
                    .navigationBarBackButtonHidden(true)
                    
                case .login:
                    LoginView(
                        onSendCode: { destination, mode in
                            navigationPath.append(AuthDestination.otp(destination: destination, mode: mode))
                        },
                        onContinueAsGuest: {
                            kSharedAppDelegate?.moveToTabBar(isGuest: true)
                        }
                    )
                    .navigationBarBackButtonHidden(true)
                    
                case .otp(let destination, let mode):
                    OTPVerificationView(
                        destination: destination,
                        mode: mode,
                        onVerificationSuccess: {
                            kSharedAppDelegate?.moveToTabBar(isGuest: false)
                        },
                        onContinueAsGuest: {
                            kSharedAppDelegate?.moveToTabBar(isGuest: true)
                        },
                        onBack: {
                            if !navigationPath.isEmpty {
                                navigationPath.removeLast()
                            }
                        },
                        onResend: {
                            print("Resend code requested for \(destination)")
                        }
                    )
                    .navigationBarBackButtonHidden(true)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    AuthCoordinatorView()
}

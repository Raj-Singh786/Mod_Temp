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
    case home(isGuest: Bool)
}

// MARK: - AuthCoordinatorView

struct AuthCoordinatorView: View {
    
    // MARK: - Navigation Path
    
    @State private var navigationPath = NavigationPath()
    
    // MARK: - Actions
    
    private func handleMoveToHome(isGuest: Bool) {
        UserDefaults.standard.set(isGuest, forKey: "isGuestUser")
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = windowScene.delegate as? SceneDelegate,
           sceneDelegate.window != nil {
            kSharedAppDelegate?.moveToTabBar(isGuest: isGuest)
        } else {
            navigationPath.append(AuthDestination.home(isGuest: isGuest))
        }
    }
    
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
                            handleMoveToHome(isGuest: true)
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
                            handleMoveToHome(isGuest: true)
                        }
                    )
                    .navigationBarBackButtonHidden(true)
                    
                case .otp(let destination, let mode):
                    OTPVerificationView(
                        destination: destination,
                        mode: mode,
                        onVerificationSuccess: {
                            handleMoveToHome(isGuest: false)
                        },
                        onContinueAsGuest: {
                            handleMoveToHome(isGuest: true)
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
                    
                case .home(let isGuest):
                    HomeView(isGuest: isGuest)
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

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
    
    // MARK: - Initial Destination
    
    var initialDestination: AuthDestination? = nil
    
    // MARK: - Navigation Path
    
    @State private var navigationPath = NavigationPath()
    
    init(initialDestination: AuthDestination? = nil) {
        self.initialDestination = initialDestination
        self._navigationPath = State(initialValue: NavigationPath())
    }
    
    // MARK: - Actions
    
    private func handleMoveToTabBar(isGuest: Bool, selectedIndex: Int = 0) {
        UserDefaults.standard.set(isGuest, forKey: "isGuestUser")
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = windowScene.delegate as? SceneDelegate,
           sceneDelegate.window != nil {
            kSharedAppDelegate?.moveToTabBar(isGuest: isGuest, selectedIndex: selectedIndex)
        } else {
            navigationPath.append(AuthDestination.home(isGuest: isGuest))
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                if initialDestination == .login {
                    LoginView(
                        onSendCode: { destination, mode in
                            navigationPath.append(AuthDestination.otp(destination: destination, mode: mode))
                        },
                        onContinueAsGuest: {
                            handleMoveToTabBar(isGuest: true, selectedIndex: 0)
                        }
                    )
                } else {
                    OnboardingView(
                        onSkip: {
                            navigationPath.append(AuthDestination.promotion)
                        },
                        onFinish: {
                            navigationPath.append(AuthDestination.promotion)
                        }
                    )
                }
            }
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: AuthDestination.self) { destination in
                switch destination {
                case .promotion:
                    PromotionView(
                        onSignInWithCode: {
                            navigationPath.append(AuthDestination.login)
                        },
                        onContinueAsGuest: {
                            handleMoveToTabBar(isGuest: true, selectedIndex: 0)
                        },
                        onPageSelected: { page in
                            if page == 0 && !navigationPath.isEmpty {
                                navigationPath.removeLast()
                            }
                        }
                    )
                    .navigationBarHidden(true)
                    .navigationBarBackButtonHidden(true)
                    .toolbar(.hidden, for: .navigationBar)
                    
                case .login:
                    LoginView(
                        onSendCode: { destination, mode in
                            navigationPath.append(AuthDestination.otp(destination: destination, mode: mode))
                        },
                        onContinueAsGuest: {
                            handleMoveToTabBar(isGuest: true, selectedIndex: 0)
                        }
                    )
                    .navigationBarHidden(true)
                    .navigationBarBackButtonHidden(true)
                    .toolbar(.hidden, for: .navigationBar)
                    
                case .otp(let destination, let mode):
                    OTPVerificationView(
                        destination: destination,
                        mode: mode,
                        onVerificationSuccess: {
                            UserDefaults.standard.set(false, forKey: "isGuestUser")
                            UserDefaults.standard.synchronize()
                            NotificationCenter.default.post(name: .userLoggedInNotification, object: nil)
                            handleMoveToTabBar(isGuest: false, selectedIndex: 0)
                        },
                        onContinueAsGuest: {
                            handleMoveToTabBar(isGuest: true, selectedIndex: 0)
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
                    .navigationBarHidden(true)
                    .navigationBarBackButtonHidden(true)
                    .toolbar(.hidden, for: .navigationBar)
                    
                case .home(let isGuest):
                    HomeView(isGuest: isGuest)
                        .navigationBarBackButtonHidden(true)
                }
            }
        }
    }
}

// MARK: - Preview

struct AuthCoordinatorView_Previews: PreviewProvider {
    static var previews: some View {
        AuthCoordinatorView()
    }
}

//
//  AppDelegate.swift
//  MOD
//
//  Created by Rajpal singh on 04/11/26.
//

import UIKit
import SwiftUI
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        IQKeyboardManager.shared.isEnabled = true
        UIButton.appearance().tintColor = AppColor.button_red
        sleep(3)
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}


extension AppDelegate {
    func moveToTabBar(isGuest: Bool = false, selectedIndex: Int = 0) {
        UserDefaults.standard.set(isGuest, forKey: "isGuestUser")
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let sceneDelegate = windowScene.delegate as? SceneDelegate else { return }
        let tabBarVC = TabBarVC.instantiate(fromAppStoryboard: .Home)
        tabBarVC.myIndex = selectedIndex
        tabBarVC.selectedIndex = selectedIndex
        let navVC = UINavigationController(rootViewController: tabBarVC)
        navVC.isNavigationBarHidden = true
        sceneDelegate.window?.rootViewController = navVC
        tabBarVC.selectedIndex = selectedIndex
    }

    func moveToAuth(initialDestination: AuthDestination = .login) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate else { return }
        let authCoordinator = AuthCoordinatorView(initialDestination: initialDestination)
        let hostingVC = UIHostingController(rootView: authCoordinator)
        let navVC = UINavigationController(rootViewController: hostingVC)
        navVC.isNavigationBarHidden = true
        
        if let window = sceneDelegate.window {
            UIView.transition(with: window, duration: 0.35, options: .transitionCrossDissolve, animations: {
                window.rootViewController = navVC
            })
        } else {
            sceneDelegate.window?.rootViewController = navVC
        }
    }
}

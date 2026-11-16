//
//  TabItem.swift
//  MOD
//
//  Created by Rajpal singh on 07/11/26.
//

import Foundation
import UIKit
import SwiftUI

enum TabItems: String, CaseIterable {

    case Home = "Home"
    case Menu = "Menu"
    case Rewards = "Rewards"
    case Orders = "Orders"
    case Account = "Account"

    var viewController: UIViewController {
        switch self {
        case .Home:
            let isGuest = (UserDefaults.standard.object(forKey: "isGuestUser") as? Bool) ?? true
            return UIHostingController(rootView: HomeView(isGuest: isGuest))

        case .Menu:
            return UIHostingController(rootView: MenuView())

        case .Rewards:
            return UIHostingController(rootView: RewardsCoordinatorView())

        case .Orders:
            return UIViewController()

        case .Account:
            return UIViewController()
        }
    }

    var selectedIcon: UIImage? {
        switch self {
        case .Home:
            return UIImage(systemName: "house.fill")

        case .Menu:
            return UIImage(systemName: "square.grid.2x2.fill")
            
        case .Rewards:
            return UIImage(systemName: "star.fill")

        case .Orders:
            return UIImage(systemName: "doc.text.fill") ?? UIImage(systemName: "list.bullet.clipboard.fill")
            
        case .Account:
            return UIImage(systemName: "person.fill")
        }
    }

    var unSelectedIcon: UIImage? {
        switch self {
        case .Home:
            return UIImage(systemName: "house")

        case .Menu:
            return UIImage(systemName: "square.grid.2x2")

        case .Rewards:
            return UIImage(systemName: "star")

        case .Orders:
            return UIImage(systemName: "doc.text") ?? UIImage(systemName: "list.bullet.clipboard")
            
        case .Account:
            return UIImage(systemName: "person")
        }
    }

    var displayTitle: String {
        return rawValue
    }
}

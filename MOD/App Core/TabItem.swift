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
    case Cart = "Cart"
    case Orders = "Orders"
    case Sign = "Sign In"

    var viewController: UIViewController {
        switch self {
        case .Home:
            let isGuest = (UserDefaults.standard.object(forKey: "isGuestUser") as? Bool) ?? true
            return UIHostingController(rootView: HomeScreen(isGuest: isGuest))
             

        case .Menu:
            return MenuVC.instantiate(fromAppStoryboard: .Home)
            

        case .Cart:
            return CartVC.instantiate(fromAppStoryboard: .Home)

        case .Orders:
             return OrderVC.instantiate(fromAppStoryboard: .Home)
        case .Sign:
            return ProfileVC.instantiate(fromAppStoryboard: .Home)
        }
    }

    var selectedIcon: UIImage? {
        switch self {
        case .Home:
            return UIImage(systemName: "house.fill")

        case .Menu:
            return UIImage(systemName: "fork.knife.fill")
            
        case .Cart:
            return UIImage(systemName: "cart.fill")

        case .Orders:
            return UIImage(systemName: "list.bullet.clipboard.fill")

            
        
            
        case .Sign:
            return UIImage(systemName: "person.fill")
        
        }
    }

    var unSelectedIcon: UIImage? {
        switch self {
        case .Home:
            return UIImage(systemName: "house")

        case .Menu:
            return UIImage(systemName: "fork.knife")

        case .Cart:
            return UIImage(systemName: "cart")

        case .Orders:
            return UIImage(systemName: "list.bullet.clipboard")
            
            case .Sign:
            return UIImage(systemName: "person")
        }
    }

    var displayTitle: String {
        return rawValue
    }
}


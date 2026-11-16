//
//  AppColors.swift
//  MOD
//
//  Created by Rajpal singh on 06/11/26.
//

import Foundation
import UIKit
import SwiftUI

enum AppColor {
    // MARK: - UIKit Colors
    static var mod_red: UIColor {
        UIColor(named: "mod_red") ?? UIColor(named: "Button_red") ?? .systemRed
    }
    
    static var text_gray: UIColor {
        UIColor(named: "text_gray") ?? UIColor(named: "text_gary") ?? .systemGray
    }
    
    static var button_red: UIColor {
        UIColor(named: "Button_red") ?? .systemRed
    }
    
    static var pizza_found: UIColor {
        UIColor(named: "pizza_found") ?? UIColor(red: 0xF3/255.0, green: 0xE8/255.0, blue: 0xD7/255.0, alpha: 1.0)
    }
    
    static var app_background: UIColor {
        UIColor(named: "app_background") ?? pizza_found
    }
    
    
    static var roma_red: UIColor {
        UIColor(named: "roma_red") ?? .systemRed
    }
    
    
    static var kale_green: UIColor {
        UIColor(named: "kale_green") ?? .systemGreen
    }
    
    
    static var app_black: UIColor {
        UIColor(named: "app_black") ?? .black
    }
    
    static var app_white: UIColor {
        UIColor(named: "app_white") ?? .white
    }
    
    static var mod_back: UIColor {
        UIColor(named: "mod_back") ?? UIColor(red: 0xF9/255.0, green: 0xF9/255.0, blue: 0xFF/255.0, alpha: 1.0)
    }
    
    // MARK: - SwiftUI Colors
    static var buttonRedColor: Color { Color("Button_red") }
    static var pizzaFoundColor: Color { Color("pizza_found") }
    static var appBlackColor: Color { Color("app_black") }
    static var appWhiteColor: Color { Color("app_white") }
    static var textGrayColor: Color { Color("text_gary") }
    static var modBackColor: Color { Color("mod_back") }
    static var appbackground: Color { Color("app_background") }
    static var romaRed: Color { Color("roma_red") }
    static var kalegreen: Color { Color("kale_green") }
}

//extension Color {
//    static var appBackground: Color { Color("app_background") }
//    static var pizzaFound: Color { Color("pizza_found") }
//    static var romaRed: Color { Color("roma_red") }
//    static var kaleGreen: Color { Color("kale_green") }
//    static var buttonRed: Color { Color("Button_red") }
//    static var appBlack: Color { Color("app_black") }
//    static var appWhite: Color { Color("app_white") }
//}

//
//  AppFonts.swift
//  MOD
//
//  Created by Rajpal singh on 06/11/26.
//

import Foundation
import UIKit
import SwiftUI

enum AppFonts : String {
    case jakartaRegular = "PlusJakartaSans-Regular"
    case jakartaMedium = "PlusJakartaSans-Medium"
    case jakartaSemiBold = "PlusJakartaSans-SemiBold"
    case jakartaBold = "PlusJakartaSans-Bold"
    case jakartaExtraBold = "PlusJakartaSans-ExtraBold"
}

extension AppFonts {
    
    func withSize(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: self.rawValue, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    func withDefaultSize() -> UIFont {
        return UIFont(name: self.rawValue, size: 12.0) ?? UIFont.systemFont(ofSize: 12.0)
    }

    func swiftUIFont(size: CGFloat) -> Font {
        if UIFont(name: self.rawValue, size: size) != nil {
            return Font.custom(self.rawValue, size: size)
        }
        switch self {
        case .jakartaRegular:
            return .system(size: size, weight: .regular)
        case .jakartaMedium:
            return .system(size: size, weight: .medium)
        case .jakartaSemiBold:
            return .system(size: size, weight: .semibold)
        case .jakartaBold:
            return .system(size: size, weight: .bold)
        case .jakartaExtraBold:
            return .system(size: size, weight: .heavy)
        }
    }
}

extension Font {
    static func appFont(_ font: AppFonts, size: CGFloat) -> Font {
        return font.swiftUIFont(size: size)
    }
}

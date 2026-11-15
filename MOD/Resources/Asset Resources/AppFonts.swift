//
//  AppFonts.swift
//  MOD
//
//  Created by Rajpal singh on 06/11/26.
//

import Foundation
import UIKit
import SwiftUI


enum AppFonts: String {

    // MARK: - Barlow

    case barlowThin = "Barlow-Thin"
    case barlowExtraLight = "Barlow-ExtraLight"
    case barlowLight = "Barlow-Light"
    case barlowRegular = "Barlow-Regular"
    case barlowMedium = "Barlow-Medium"
    case barlowSemiBold = "Barlow-SemiBold"
    case barlowBold = "Barlow-Bold"
    case barlowExtraBold = "Barlow-ExtraBold"
    case barlowBlack = "Barlow-Black"

    // Barlow Italic

    case barlowItalic = "Barlow-Italic"
    case barlowThinItalic = "Barlow-ThinItalic"
    case barlowExtraLightItalic = "Barlow-ExtraLightItalic"
    case barlowLightItalic = "Barlow-LightItalic"
    case barlowMediumItalic = "Barlow-MediumItalic"
    case barlowSemiBoldItalic = "Barlow-SemiBoldItalic"
    case barlowBoldItalic = "Barlow-BoldItalic"
    case barlowExtraBoldItalic = "Barlow-ExtraBoldItalic"
    case barlowBlackItalic = "Barlow-BlackItalic"

    // MARK: - Oswald

    case oswaldExtraLight = "Oswald-ExtraLight"
    case oswaldLight = "Oswald-Light"
    case oswaldRegular = "Oswald-Regular"
    case oswaldMedium = "Oswald-Medium"
    case oswaldSemiBold = "Oswald-SemiBold"
    case oswaldBold = "Oswald-Bold"

}

// MARK: - Font Weight Fallback

extension AppFonts {
    
    private var fallbackWeight: UIFont.Weight {
        
        switch self {
            
        case .barlowThin, .barlowThinItalic:
            return .thin
            
        case .barlowExtraLight, .barlowExtraLightItalic,
                .oswaldExtraLight:
            return .ultraLight
            
        case .barlowLight, .barlowLightItalic,
                .oswaldLight:
            return .light
            
        case .barlowRegular, .barlowItalic,
                .oswaldRegular:
            return .regular
            
        case .barlowMedium, .barlowMediumItalic,
                .oswaldMedium:
            return .medium
            
        case .barlowSemiBold, .barlowSemiBoldItalic,
                .oswaldSemiBold:
            return .semibold
            
        case .barlowBold, .barlowBoldItalic,
                .oswaldBold:
            return .bold
            
        case .barlowExtraBold, .barlowExtraBoldItalic:
            return .heavy
            
        case .barlowBlack, .barlowBlackItalic:
            return .black
        }
    }
    
    // MARK: - UIKit
    
    func withSize(_ fontSize: CGFloat) -> UIFont {
        return UIFont(
            name: rawValue,
            size: fontSize
        ) ?? UIFont.systemFont(
            ofSize: fontSize,
            weight: fallbackWeight
        )
    }
    
    func withDefaultSize() -> UIFont {
        return withSize(12.0)
    }
    
    // MARK: - SwiftUI
    
    
    func swiftUIFont(size: CGFloat) -> Font {
        
        if UIFont(name: rawValue, size: size) != nil {
            return Font.custom(rawValue, size: size)
        }
        
        switch fallbackWeight {
            
        case .thin:
            return .system(size: size, weight: .thin)
            
        case .ultraLight:
            return .system(size: size, weight: .ultraLight)
            
        case .light:
            return .system(size: size, weight: .light)
            
        case .regular:
            return .system(size: size, weight: .regular)
            
        case .medium:
            return .system(size: size, weight: .medium)
            
        case .semibold:
            return .system(size: size, weight: .semibold)
            
        case .bold:
            return .system(size: size, weight: .bold)
            
        case .heavy:
            return .system(size: size, weight: .heavy)
            
        case .black:
            return .system(size: size, weight: .black)
            
        default:
            return .system(size: size, weight: .regular)
        }
    }
}

// MARK: - SwiftUI Convenience

extension Font {

    static func appFont(
        _ font: AppFonts,
        size: CGFloat
    ) -> Font {
        return font.swiftUIFont(size: size)
    }
    
    static func oswaldMedium(size: CGFloat) -> Font {
        .appFont(.oswaldMedium, size: size)
    }
    
    static func oswaldBold(size: CGFloat) -> Font {
        .appFont(.oswaldBold, size: size)
    }
    
    static func oswaldRegular(size: CGFloat) -> Font {
        .appFont(.oswaldRegular, size: size)
    }
    
    static func barlowRegular(size: CGFloat) -> Font {
        .appFont(.barlowRegular, size: size)
    }
    
    static func barlowMedium(size: CGFloat) -> Font {
        .appFont(.barlowMedium, size: size)
    }
    
    static func barlowSemiBold(size: CGFloat) -> Font {
        .appFont(.barlowSemiBold, size: size)
    }
    
    static func barlowBold(size: CGFloat) -> Font {
        .appFont(.barlowBold, size: size)
    }
}

//
//  AppFonts.swift
//  MOD
//
//  Created by Rajpal singh on 06/11/26.
//


import Foundation
import UIKit
import SwiftUI

// MARK: - App Fonts

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

    // MARK: - Barlow Italic

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

    // MARK: - Generic

    static func appFont(
        _ font: AppFonts,
        size: CGFloat
    ) -> Font {
        return font.swiftUIFont(size: size)
    }

    // MARK: - Oswald

    static func oswaldExtraLight(size: CGFloat) -> Font {
        .appFont(.oswaldExtraLight, size: size)
    }

    static func oswaldLight(size: CGFloat) -> Font {
        .appFont(.oswaldLight, size: size)
    }

    static func oswaldRegular(size: CGFloat) -> Font {
        .appFont(.oswaldRegular, size: size)
    }

    static func oswaldMedium(size: CGFloat) -> Font {
        .appFont(.oswaldMedium, size: size)
    }

    static func oswaldSemiBold(size: CGFloat) -> Font {
        .appFont(.oswaldSemiBold, size: size)
    }

    static func oswaldBold(size: CGFloat) -> Font {
        .appFont(.oswaldBold, size: size)
    }

    // MARK: - Barlow

    static func barlowThin(size: CGFloat) -> Font {
        .appFont(.barlowThin, size: size)
    }

    static func barlowExtraLight(size: CGFloat) -> Font {
        .appFont(.barlowExtraLight, size: size)
    }

    static func barlowLight(size: CGFloat) -> Font {
        .appFont(.barlowLight, size: size)
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

    static func barlowExtraBold(size: CGFloat) -> Font {
        .appFont(.barlowExtraBold, size: size)
    }

    static func barlowBlack(size: CGFloat) -> Font {
        .appFont(.barlowBlack, size: size)
    }

    // MARK: - Barlow Italic

    static func barlowItalic(size: CGFloat) -> Font {
        .appFont(.barlowItalic, size: size)
    }

    static func barlowThinItalic(size: CGFloat) -> Font {
        .appFont(.barlowThinItalic, size: size)
    }

    static func barlowExtraLightItalic(size: CGFloat) -> Font {
        .appFont(.barlowExtraLightItalic, size: size)
    }

    static func barlowLightItalic(size: CGFloat) -> Font {
        .appFont(.barlowLightItalic, size: size)
    }

    static func barlowMediumItalic(size: CGFloat) -> Font {
        .appFont(.barlowMediumItalic, size: size)
    }

    static func barlowSemiBoldItalic(size: CGFloat) -> Font {
        .appFont(.barlowSemiBoldItalic, size: size)
    }

    static func barlowBoldItalic(size: CGFloat) -> Font {
        .appFont(.barlowBoldItalic, size: size)
    }

    static func barlowExtraBoldItalic(size: CGFloat) -> Font {
        .appFont(.barlowExtraBoldItalic, size: size)
    }

    static func barlowBlackItalic(size: CGFloat) -> Font {
        .appFont(.barlowBlackItalic, size: size)
    }
}

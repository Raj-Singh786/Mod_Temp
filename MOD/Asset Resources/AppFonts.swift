//
//  AppFonts.swift
//  MOD
//
//  Created by Rajpal singh on 06/11/26.
//

import Foundation
import UIKit
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
    
}

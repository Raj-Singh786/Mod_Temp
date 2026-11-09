//
//  UIButton+Extension.swift
//  Rmpl
//
//  Created by Rajpal singh on 10/08/26.
//

import Foundation
import UIKit

extension UIButton {
    /// animate button on tap
    /// - Parameter button: enter your btn variabe
    static func animateOnClick(button: UIButton) {
        UIView.animate(withDuration: 0.2, animations: {
            // Change the button's transform to scale it down slightly
            button.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { (completed) in
            // After the animation completes, restore the button's original transform
            UIView.animate(withDuration: 0.2) {
                button.transform = .identity
            }
        }
    }
}

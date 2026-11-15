//
//  UIButton+Extension.swift
//  Rmpl
//
//  Created by Rajpal singh on 10/08/26.
//

import Foundation
import UIKit
import SwiftUI

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

    /// Applies default app primary red button styling
    func applyPrimaryRedStyle(cornerRadius: CGFloat = 20, titleColor: UIColor = .white) {
        self.backgroundColor = AppColor.button_red
        self.setTitleColor(titleColor, for: .normal)
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
    }
}

/// A reusable UIButton subclass styled with `AppColor.button_red`.
/// Set the class of any UIButton in Storyboard to `PrimaryButton` in the Identity Inspector.
@IBDesignable
class PrimaryButton: UIButton {

    @IBInspectable var customCornerRadius: CGFloat = 20 {
        didSet { layer.cornerRadius = customCornerRadius }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    private func setup() {
        backgroundColor = AppColor.button_red
        setTitleColor(.white, for: .normal)
        layer.cornerRadius = customCornerRadius
        clipsToBounds = true
    }
}

// MARK: - SwiftUI Button Style

/// A reusable SwiftUI ButtonStyle using `Color.buttonRed`.
/// Usage: `Button("Continue") { ... }.buttonStyle(.primaryRed)`
struct PrimaryRedButtonStyle: ButtonStyle {
    var height: CGFloat = 52
    var cornerRadius: CGFloat = 16

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(Color("Button_red"))
            .cornerRadius(cornerRadius)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

extension ButtonStyle where Self == PrimaryRedButtonStyle {
    static var primaryRed: PrimaryRedButtonStyle { PrimaryRedButtonStyle() }
    
    static func primaryRed(height: CGFloat = 52, cornerRadius: CGFloat = 16) -> PrimaryRedButtonStyle {
        PrimaryRedButtonStyle(height: height, cornerRadius: cornerRadius)
    }
}

//
//  UIView+Extension.swift
//  Rmpl
//
//  Created by Rajpal singh on 10/08/26.
//

import Foundation
import UIKit

extension UIView {
    
    func configureCornerRadius(_ cornerRadius: CGFloat) {
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
    }
    
    func addBottomBorder(withColor color: UIColor, andWidth borderWidth: CGFloat) {
          let bottomBorder = CALayer()
          bottomBorder.backgroundColor = color.cgColor
          bottomBorder.frame = CGRect(x: 0, y: self.frame.height - borderWidth, width: self.frame.width, height: borderWidth)
          
          self.layer.addSublayer(bottomBorder)
      }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func addTopAndBottomBorders(borderColor: UIColor, borderWidth: CGFloat) {
            let topBorder = CALayer()
            topBorder.backgroundColor = borderColor.cgColor
            topBorder.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: borderWidth)
            let bottomBorder = CALayer()
            bottomBorder.backgroundColor = borderColor.cgColor
            bottomBorder.frame = CGRect(x: 0, y: self.frame.size.height - borderWidth, width: self.frame.size.width, height: borderWidth)
            self.layer.addSublayer(topBorder)
            self.layer.addSublayer(bottomBorder)
        }
    
    //IBInspectable
    @IBInspectable var cornerRadius: Double {
        get {
            return Double(self.layer.cornerRadius)
        }set {
            self.layer.cornerRadius = CGFloat(newValue)
        }
    }
    @IBInspectable var borderWidth: Double {
        get {
            return Double(self.layer.borderWidth)
        }
        set {
            self.layer.borderWidth = CGFloat(newValue)
        }
    }
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: self.layer.borderColor!)
        }
        set {
            self.layer.borderColor = newValue?.cgColor
        }
    }
    @IBInspectable var shadowColor: UIColor?{
        set {
            guard let uiColor = newValue else { return }
            layer.shadowColor = uiColor.cgColor
        }
        get{
            guard let color = layer.shadowColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
    
    @IBInspectable var shadowOpacity: Float{
        set {
            layer.shadowOpacity = newValue
        }
        get{
            return layer.shadowOpacity
        }
    }
    
    @IBInspectable var shadowOffset: CGSize{
        set {
            layer.shadowOffset = newValue
        }
        get{
            return layer.shadowOffset
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat{
        set {
            layer.shadowRadius = newValue
        }
        get{
            return layer.shadowRadius
        }
    }
}





extension CALayer {
  func applySketchShadow(
    color: UIColor = .blue,
    alpha: Float = 0.9,
    x: CGFloat = 0,
    y: CGFloat = 2,
    blur: CGFloat = 4,
    spread: CGFloat = 0)
  {
    masksToBounds = false
    shadowColor = color.cgColor
    shadowOpacity = alpha
    shadowOffset = CGSize(width: x, height: y)
    shadowRadius = blur / 2.0
    if spread == 0 {
      shadowPath = nil
    } else {
      let dx = -spread
      let rect = bounds.insetBy(dx: dx, dy: dx)
      shadowPath = UIBezierPath(rect: rect).cgPath
    }
  }
}

extension UITextField {
    func placeholderColor(_ color: UIColor, text: String){
        var placeholderText = text
        if self.placeholder != nil{
            placeholderText = self.placeholder!
        }
        self.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: [NSAttributedString.Key.foregroundColor : color])
    }
}



extension UIImageView {
    
    /// Changes the tint color of the image.
    /// - Parameter color: The new tint color.
    func changeTintColor(to color: UIColor) {
        guard let image = self.image else {
            print("No image set in UIImageView to change tint color")
            return
        }
        
        self.image = image.withRenderingMode(.alwaysTemplate)
        self.tintColor = color
    }
}


extension UITextField {
    @IBInspectable var placeholderColor: UIColor {
        get {
            return attributedPlaceholder?.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor ?? .clear
        }
        set {
            guard let attributedPlaceholder = attributedPlaceholder else { return }
            let attributes: [NSAttributedString.Key: UIColor] = [.foregroundColor: newValue]
            self.attributedPlaceholder = NSAttributedString(string: attributedPlaceholder.string, attributes: attributes)
        }
    }
}






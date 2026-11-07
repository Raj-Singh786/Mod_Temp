//
//  ConfigureCellShared.swift
//  Rmpl
//
//  Created by Rajpal singh on 12/08/26.
//

import UIKit
import Foundation

class ConfigureCellSharedClass: NSObject {
    static let sharedInstance = ConfigureCellSharedClass()
    
    private override init() {
        
    }
    
func getCircularBorder(_ object: Any) {
        if let imageView = object as? UIImageView {
            imageView.layer.cornerRadius = imageView.frame.height / 2
            imageView.layer.borderWidth = 0.5
            imageView.layer.borderColor = AppColor.mod_red.cgColor
            imageView.clipsToBounds = true
        } else if let view = object as? UIView {
            view.layer.cornerRadius = view.frame.height / 2
            view.layer.borderWidth = 0.5
            view.layer.borderColor = AppColor.text_gray.cgColor
            view.clipsToBounds = true
        } else {
            // Handle other types or unsupported types
            print("Unsupported type")
        }
    }

}

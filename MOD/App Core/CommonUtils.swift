//
//  CommonUtils.swift
//  MOD
//
//  Created by Rajpal singh on 07/11/26.
//

import UIKit
//import SVProgressHUD

let kAlertTitle         = "MOD"
let kButtonTitle        = "Ok"
let kNoInternetMsg      = "Unable to connect to the Internet. Please try again."
let kDefaultErrorMsg    = "Something went wrong. Please try again."
let kSharedAppDelegate  = UIApplication.shared.delegate as? AppDelegate

class CommonUtils: NSObject {
    
    static func showToast(message: String, duration: Double = 2.0) {
         let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
         
       
         if let messageLabel = alert.view.subviews.first?.subviews.first as? UILabel {
             messageLabel.font = messageLabel.font.withSize(8)
         }
         
         if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let sceneDelegate = windowScene.delegate as? SceneDelegate,
            let rootViewController = sceneDelegate.window?.rootViewController {
             rootViewController.present(alert, animated: true, completion: nil)
         }
         
         DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
             alert.dismiss(animated: true)
         }
     }
    
    static func makeRounded(_ view: UIView, cornerRadius: CGFloat? = nil) {
        view.layer.cornerRadius = cornerRadius ?? view.bounds.height / 2
        view.clipsToBounds = true
    }
    
    static func alert(
        message: String,
        title: String? = "",
        buttonTitle: String = "OK",
        _ onView: UIViewController,
        completion: (() -> Void)? = nil
    ) {

        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        alert.view.tintColor = .systemBlue

        let action = UIAlertAction(
            title: buttonTitle,
            style: .default
        ) { _ in
            completion?()
        }

        alert.addAction(action)
        onView.present(alert, animated: true)
    }
    
    
    static func alertCompletion(
        message: String,
        _ onView: UIViewController,
        completion: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(
            title: "",
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(title: "OK", style: .default) { _ in
                completion?()
            }
        )

        onView.present(alert, animated: true)
    }
    
    
    //** function to capatalize first letter  ***
    static func capitalizeFirstLetter(_ string: String) -> String {
        guard let firstLetter = string.first else {
            return string
        }
        let capitalizedFirstLetter = String(firstLetter).capitalized
        let stringWithCapitalizeFirstLetter = capitalizedFirstLetter + string.dropFirst()
        return stringWithCapitalizeFirstLetter
    }
    
    static func showAlertWithTwoButtons(
           title: String,
           message: String,
           onView: UIViewController,
           firstButtonTitle: String,
           secondButtonTitle: String,
           firstButtonHandler: ((UIAlertAction) -> Void)?,
           secondButtonHandler: ((UIAlertAction) -> Void)?
    ) {
        let alertController = UIAlertController(title: title, message:  message, preferredStyle: .alert)
        
        // Create the first button action
        let firstButtonAction = UIAlertAction(title: firstButtonTitle, style: .default, handler: firstButtonHandler)
        alertController.addAction(firstButtonAction)
        
        // Create the second button action
        let secondButtonAction = UIAlertAction(title: secondButtonTitle, style: .default, handler: secondButtonHandler)
        alertController.addAction(secondButtonAction)
        
        // Present the alert dialog
        onView.present(alertController, animated: true)
    }
    
    
//    static func showHudWithNoInteraction(show: Bool) {
//        if show {
//            SVProgressHUD.setDefaultStyle(.custom)
//            SVProgressHUD.setDefaultMaskType(.custom)
//            SVProgressHUD.setForegroundColor(AppColor.primary_dense_blue)           //Ring Color
//            SVProgressHUD.setBackgroundColor(.clear)        //HUD Color
//            SVProgressHUD.setBackgroundLayerColor(UIColor.clear)    //Background Color
//            SVProgressHUD.show()
//            
//        } else {
//            SVProgressHUD.dismiss()
//        }
//    }
//    
//    class func hideProgressHud() {
//        DispatchQueue.main.async {
//            SVProgressHUD.dismiss()
//        }
//    }
}

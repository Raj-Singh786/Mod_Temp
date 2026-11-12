//
//  LoginViewController.swift
//  MOD
//
//  Created by Rajpal singh on 06/11/26.
//

import UIKit
import SwiftUI



// MARK: - LoginViewController

class LoginViewController: UIViewController {

    @IBOutlet weak var loginField: UITextField!

    private let maxInputLength = 17   // e.g. "+91 98765 43210"

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextField()
        //configureSignupLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    // MARK: - Setup

    private func configureTextField() {
        loginField.delegate = self
        loginField.keyboardType = .phonePad
        loginField.textContentType = .telephoneNumber
        loginField.placeholder = "Enter mobile number/Email"
        loginField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        
    }

   

    // MARK: - Actions

    @IBAction func didTapOnLoginBtn(_ sender: UIButton) {

        view.endEditing(true)

        let text = loginField.text?.trimmingCharacters(in: .whitespaces) ?? ""

        // Empty field: Alert only, no red border
        guard !text.isEmpty else {
            showError("Please enter your mobile number.", showBorder: false)
            return
        }

        // Invalid number: Alert + red border
        guard let result = PhoneValidator.validate(text) else {
            showError("Please enter a valid Indian or US mobile number.", showBorder: true)
            return
        }

        setFieldError(false)

        print("Valid \(result.region.rawValue) number:", result.number)

        let otpVC = OTPVerificationViewController(phoneNumber: result.number)
        navigationController?.pushViewController(otpVC, animated: false)
    }

    @IBAction func didTapOnGuestBtn(_ sender: UIButton) {
        kSharedAppDelegate?.moveToTabBar(isGuest: true)
    }

    @objc private func didTapSignupLabel() {
        let signupView = SignupView(onDismiss: { [weak self] in
            if let nav = self?.navigationController {
                nav.popViewController(animated: true)
            } else {
                self?.dismiss(animated: true)
            }
        })
        let hostingController = UIHostingController(rootView: signupView)
        hostingController.modalPresentationStyle = .fullScreen
        if let nav = navigationController {
            nav.pushViewController(hostingController, animated: true)
        } else {
            present(hostingController, animated: true)
        }
    }

    @objc private func textDidChange() {
        setFieldError(false)   // clear the red border while typing
    }

    // MARK: - Navigation

    

    // MARK: - Error UI

    private func showError(_ message: String, showBorder: Bool) {

        setFieldError(showBorder)

        let alert = UIAlertController(
            title: "Invalid Number",
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    
    private func setFieldError(_ hasError: Bool) {
        loginField.layer.borderWidth = hasError ? 1 : 0
        loginField.layer.borderColor = UIColor.systemRed.cgColor
    }
}

// MARK: - UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        // allow only digits and common phone symbols
        let allowed = CharacterSet(charactersIn: "0123456789+-() ")
        guard string.rangeOfCharacter(from: allowed.inverted) == nil else { return false }

        // limit length
        let current = textField.text ?? ""
        guard let r = Range(range, in: current) else { return false }
        let updated = current.replacingCharacters(in: r, with: string)
        return updated.count <= maxInputLength
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - Phone Validator

enum PhoneRegion: String {
    case india = "India"
    case us = "US"
}

struct PhoneValidator {

    /// Returns the matching region and the clean 10-digit number, or nil if invalid.
    static func validate(_ input: String) -> (region: PhoneRegion, number: String)? {
        // keep digits only (removes spaces, dashes, brackets, +)
        var digits = input.filter { $0.isNumber }

        // India: 10 digits, starts with 6-9. Accepts an optional 91 or 0 prefix.
        var indian = digits
        if indian.hasPrefix("91") && indian.count == 12 { indian.removeFirst(2) }
        else if indian.hasPrefix("0") && indian.count == 11 { indian.removeFirst(1) }

        if indian.range(of: #"^[6-9][0-9]{9}$"#, options: .regularExpression) != nil {
            return (.india, indian)
        }

        // US (NANP): 10 digits, area code and exchange both start with 2-9. Optional 1 prefix.
        if digits.hasPrefix("1") && digits.count == 11 { digits.removeFirst(1) }

        if digits.range(of: #"^[2-9][0-9]{2}[2-9][0-9]{6}$"#, options: .regularExpression) != nil {
            return (.us, digits)
        }

        return nil
    }
}

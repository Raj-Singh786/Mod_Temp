//
//  LoginViewController.swift
//  MOD
//
//  Created by Rajpal singh on 06/11/26.
//

import UIKit



// MARK: - LoginViewController

class LoginViewController: UIViewController {

    @IBOutlet weak var loginField: UITextField!
    @IBOutlet weak var signupLbl: UILabel!

    private let maxInputLength = 17   // e.g. "+91 98765 43210"

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextField()
        configureSignupLabel()
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
        loginField.placeholder = "Enter mobile number"
        loginField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        
    }

    private func configureSignupLabel() {
        signupLbl.isUserInteractionEnabled = true   // labels ignore touches by default
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapSignupLabel))
        signupLbl.addGestureRecognizer(tap)
    }

    // MARK: - Actions

    @IBAction func didTapOnLoginBtn(_ sender: UIButton) {
        view.endEditing(true)

        let text = loginField.text?.trimmingCharacters(in: .whitespaces) ?? ""

        guard !text.isEmpty else {
            showError("Please enter your mobile number.")
            return
        }

        guard let result = PhoneValidator.validate(text) else {
            showError("Please enter a valid Indian or US mobile number.")
            return
        }

        setFieldError(false)
        print("Valid \(result.region.rawValue) number:", result.number)
        // TODO: call your login / OTP API with result.number

        let otpVC = OTPVerificationViewController(phoneNumber: result.number)
        navigationController?.pushViewController(otpVC, animated: false)
    }

    @IBAction func didTapOnGuestBtn(_ sender: UIButton) {
        kSharedAppDelegate?.moveToTabBar(isGuest: true)
    }

    @objc private func didTapSignupLabel() {
        openSignupScreen()
    }

    @objc private func textDidChange() {
        setFieldError(false)   // clear the red border while typing
    }

    // MARK: - Navigation

    private func openSignupScreen() {
        // Storyboard ID of your signup screen must be "SignupViewController"
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SignupViewController")

        if let nav = navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }

    // MARK: - Error UI

    private func showError(_ message: String) {
        setFieldError(true)
        let alert = UIAlertController(title: "Invalid Number", message: message, preferredStyle: .alert)
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

import UIKit

// MARK: - OTPTextField (detects backspace on an empty box)

final class OTPTextField: UITextField {
    var onDeleteBackward: (() -> Void)?

    override func deleteBackward() {
        let wasEmpty = text?.isEmpty ?? true
        super.deleteBackward()
        if wasEmpty { onDeleteBackward?() }
    }
}

// MARK: - OTPVerificationViewController

class OTPVerificationViewController: UIViewController {

    // MARK: - Properties
    private let phoneNumber: String
    private let otpLength = 6
    private let resendSeconds = 30

    private var otp: String = "" { didSet { updateLoginButtonState() } }
    private var resendTimer: Timer?
    private var secondsRemaining = 30

    // MARK: - UI
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "OTP Verification"
        label.font = .boldSystemFont(ofSize: 22)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel = UILabel()

    private var otpFields: [OTPTextField] = []
    private let stackView = UIStackView()

    private let autoReadLabel: UILabel = {
        let label = UILabel()
        label.text = "Trying to auto read your OTP"
        label.font = .systemFont(ofSize: 13)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Label instead of UIButton: no implicit title cross-fade, so only the digits change.
    private let resendLabel: UILabel = {
        let label = UILabel()
        label.text = "Resend OTP in 30s"
        label.font = .monospacedDigitSystemFont(ofSize: 15, weight: .regular)
        label.textColor = .systemGray
        label.isUserInteractionEnabled = false
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 17)
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 22.5
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Init
    init(phoneNumber: String) {
        self.phoneNumber = phoneNumber
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    deinit { resendTimer?.invalidate() }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        if navigationController != nil {
            let backButton = UIBarButtonItem(
                image: UIImage(systemName: "chevron.left"),
                style: .plain,
                target: self,
                action: #selector(didTapChange)
            )
            backButton.tintColor = .gray
            navigationItem.leftBarButtonItem = backButton
        }

        setupLayout()
        setupOTPFields()
        wireActions()
        updateLoginButtonState()
        startResendTimer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)

        // Plain white bar with no shadow, so it blends into the screen
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .white
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParent || isBeingDismissed {
            resendTimer?.invalidate()
            resendTimer = nil
        }
    }

    // MARK: - Setup
    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(stackView)
        view.addSubview(autoReadLabel)
        view.addSubview(resendLabel)
        view.addSubview(loginButton)

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = .systemFont(ofSize: 15)
        subtitleLabel.textColor = .darkGray
        subtitleLabel.numberOfLines = 0
        let display = phoneNumber.count > 4 ? "****" + phoneNumber.suffix(6) : phoneNumber
        subtitleLabel.text = "OTP has been sent to \(display)"

        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 18),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            stackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32),
            stackView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 54),
            stackView.widthAnchor.constraint(equalToConstant: 290),

            autoReadLabel.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 22),
            autoReadLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            resendLabel.topAnchor.constraint(equalTo: autoReadLabel.bottomAnchor, constant: 18),
            resendLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            resendLabel.heightAnchor.constraint(equalToConstant: 28),

            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            loginButton.heightAnchor.constraint(equalToConstant: 45)
        ])
    }

    private func setupOTPFields() {
        otpFields = (0..<otpLength).map { index in
            let tf = OTPTextField()
            tf.backgroundColor = UIColor(white: 0.97, alpha: 1)
            tf.textColor = .black
            tf.font = .systemFont(ofSize: 28, weight: .medium)
            tf.textAlignment = .center
            tf.keyboardType = .numberPad
            tf.layer.cornerRadius = 8
            tf.delegate = self
            tf.tintColor = .systemBlue
            tf.autocorrectionType = .no
            tf.autocapitalizationType = .none
            tf.isSecureTextEntry = false
            tf.translatesAutoresizingMaskIntoConstraints = false

            // Enables SMS code suggestion above the keyboard
            if index == 0 { tf.textContentType = .oneTimeCode }

            // Backspace on an empty box: clear and move to the previous box
            tf.onDeleteBackward = { [weak self] in
                guard let self = self, index > 0 else { return }
                self.otpFields[index - 1].text = ""
                self.otpFields[index - 1].becomeFirstResponder()
                self.refreshOTP()
            }
            return tf
        }

        otpFields.forEach { field in
            stackView.addArrangedSubview(field)
            field.widthAnchor.constraint(equalToConstant: 38).isActive = true
            field.heightAnchor.constraint(equalToConstant: 54).isActive = true
        }
        otpFields.first?.becomeFirstResponder()
    }

    private func wireActions() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapResend))
        resendLabel.addGestureRecognizer(tap)
        loginButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
    }

    private func updateLoginButtonState() {
        let ready = otp.count == otpLength
        loginButton.isEnabled = ready
        loginButton.backgroundColor = ready ? AppColor.mod_red : UIColor.systemGray4
    }

    // MARK: - OTP helpers
    private func refreshOTP() {
        otp = otpFields.compactMap { $0.text }.joined()
    }

    /// Writes digits into the boxes starting at `index` (used for typing, paste and autofill).
    private func fill(_ digits: String, startingAt index: Int) {
        var lastFilled = index
        for (offset, ch) in digits.enumerated() {
            let i = index + offset
            guard i < otpLength else { break }
            otpFields[i].text = String(ch)
            lastFilled = i
        }
        refreshOTP()

        if lastFilled < otpLength - 1 {
            otpFields[lastFilled + 1].becomeFirstResponder()
        } else {
            otpFields[otpLength - 1].becomeFirstResponder()
        }
    }

    // MARK: - Resend Timer
    private func startResendTimer() {
        secondsRemaining = resendSeconds
        updateResendLabel()

        resendTimer?.invalidate()
        // Block-based timer with [weak self]: no retain cycle, and .common keeps it ticking during touch tracking
        let timer = Timer(timeInterval: 1, repeats: true) { [weak self] t in
            guard let self = self else { t.invalidate(); return }
            self.secondsRemaining -= 1
            if self.secondsRemaining <= 0 {
                t.invalidate()
                self.resendTimer = nil
            }
            self.updateResendLabel()
        }
        RunLoop.main.add(timer, forMode: .common)
        resendTimer = timer
    }

    private func updateResendLabel() {
        if secondsRemaining > 0 {
            resendLabel.text = "Resend OTP in \(secondsRemaining)s"
            resendLabel.textColor = .systemGray
            resendLabel.isUserInteractionEnabled = false
        } else {
            resendLabel.text = "Resend OTP"
            resendLabel.textColor = .systemBlue
            resendLabel.isUserInteractionEnabled = true
        }
    }

    // MARK: - Actions
    @objc private func didTapChange() {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    @objc private func didTapResend() {
        // TODO: Call resend OTP API here
        otpFields.forEach { $0.text = "" }
        refreshOTP()
        otpFields.first?.becomeFirstResponder()
        startResendTimer()
    }

    @objc private func didTapLogin() {
        view.endEditing(true)
        if otp.count == otpLength && otp.range(of: "^[0-9]{6}$", options: .regularExpression) != nil {
            // TODO: Call verify OTP API
            let alert = UIAlertController(title: "Success", message: "OTP verified!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        } else {
            let alert = UIAlertController(title: "Invalid OTP", message: "Please enter a valid 6-digit OTP.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
}

// MARK: - UITextFieldDelegate

extension OTPVerificationViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        guard let field = textField as? OTPTextField,
              let index = otpFields.firstIndex(of: field) else { return false }

        // Backspace on a filled box
        if string.isEmpty {
            field.text = ""
            refreshOTP()
            return false
        }

        // Digits only
        guard string.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil else { return false }

        // Single digit (overwrites whatever is there), or multiple digits (paste / SMS autofill)
        fill(string, startingAt: string.count > 1 ? 0 : index)
        return false
    }
}

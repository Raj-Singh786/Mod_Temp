//
//  OnboardingViewController.swift
//  MOD
//
//  Created by Rajpal singh on 06/11/26.
//

import UIKit
import SwiftUI

class OnboardingViewController: UIViewController {
    
    // MARK: - Storyboard Outlets (Preserved for IB compatibility)
    @IBOutlet weak var pageControl: UIPageControl?
    @IBOutlet weak var startedBtn: UIButton?
    @IBOutlet weak var skipBtn: UIButton?
    @IBOutlet weak var scrollView: UIScrollView?
    @IBOutlet weak var blackBgView: UIView?
    @IBOutlet weak var badgeLabel: UILabel?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var descLabel: UILabel?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSwiftUIOnboarding()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    // MARK: - SwiftUI Hosting
    private func setupSwiftUIOnboarding() {
        let onboardingView = OnboardingView(
            onSkip: { [weak self] in
                self?.openLoginVC()
            },
            onFinish: { [weak self] in
                self?.openLoginVC()
            }
        )

        let hostingController = UIHostingController(rootView: onboardingView)
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        hostingController.didMove(toParent: self)
    }

    // MARK: - Navigation
    func openLoginVC() {
        let vc = LoginViewController.instantiate(fromAppStoryboard: .Main)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

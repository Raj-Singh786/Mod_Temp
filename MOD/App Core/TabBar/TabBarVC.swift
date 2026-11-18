//
//  TabBarVC.swift
//  MOD
//
//  Created by Rajpal singh on 07/11/26.
//

import UIKit
import SwiftUI

class TabBarVC: UITabBarController {

    var myIndex = 0

    private var indicatorView: UIView!

    private let indicatorWidth: CGFloat = 32
    private let indicatorHeight: CGFloat = 4
    
    private var cartHostingVC: UIHostingController<PersistentFloatingCartBar>?

    let tabItems: [TabItems] = [
        .Home,
        .Menu,
        .Rewards,
        .Orders,
        .Account
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        initialViewLoad()

        DispatchQueue.main.async {
           // self.addTabbarIndicatorView(index: self.selectedIndex)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationItem.setHidesBackButton(true, animated: true)
        navigationController?.isNavigationBarHidden = true
        
        if selectedIndex != myIndex {
            selectedIndex = myIndex
        }
    }

   


    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let hostingView = cartHostingVC?.view {
            view.bringSubviewToFront(hostingView)
        }
    }
}


// MARK: - Setup

extension TabBarVC {

    private func initialViewLoad() {

        navigationController?.isNavigationBarHidden = true

        setUPTabBar()
        setupPersistentFloatingCartBar()
        
        NotificationCenter.default.addObserver(forName: .selectMenuTabWithCategory, object: nil, queue: .main) { [weak self] _ in
            self?.selectedIndex = 1
        }
        
        NotificationCenter.default.addObserver(forName: .presentGlobalAccountNotification, object: nil, queue: .main) { [weak self] _ in
            self?.presentSettingUserInfoSheet()
        }
        
        NotificationCenter.default.addObserver(forName: .presentGlobalLoginNotification, object: nil, queue: .main) { [weak self] _ in
            self?.redirectToOriginalLogin()
        }
        
        NotificationCenter.default.addObserver(forName: .handleStarTapNotification, object: nil, queue: .main) { [weak self] _ in
            let isGuest = (UserDefaults.standard.object(forKey: "isGuestUser") as? Bool) ?? false
            if isGuest {
                self?.redirectToOriginalLogin()
            } else {
                self?.presentSettingUserInfoSheet()
            }
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name("showWalletDirectlyNotification"), object: nil, queue: .main) { [weak self] _ in
            self?.presentWalletSheet()
        }
        
        NotificationCenter.default.addObserver(forName: .userLoggedOutNotification, object: nil, queue: .main) { [weak self] _ in
            self?.dismissTopModal()
            self?.selectedIndex = 0
        }
    }


    private func setUPTabBar() {

        delegate = self

        // MARK: Appearance

        let appearance = UITabBarAppearance()

        appearance.configureWithOpaqueBackground()

        appearance.backgroundColor = .white

        appearance.shadowColor = UIColor.systemGray4

        // Unselected
        appearance.stackedLayoutAppearance.normal.iconColor =
        AppColor.text_gray

        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: AppColor.text_gray,
            .font: AppFonts.barlowMedium.withSize(12)
        ]

        // Selected
        appearance.stackedLayoutAppearance.selected.iconColor =
            AppColor.mod_red

        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: AppColor.mod_red,
            .font: AppFonts.barlowMedium.withSize(12)
        ]

        tabBar.standardAppearance = appearance

        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }

        tabBar.itemPositioning = .fill


        // MARK: Home

        let homeVC = tabItems[0].viewController

        homeVC.tabBarItem = UITabBarItem(
            title: tabItems[0].displayTitle,
            image: tabItems[0].unSelectedIcon,
            selectedImage: tabItems[0].selectedIcon
        )

        let nav1 = BaseNavigationVC(
            rootViewController: homeVC
        )


        // MARK: Menu (2nd tab - direct hosting controller without BaseNavigationVC to prevent double safe-area insets)

        let menuVC = tabItems[1].viewController

        menuVC.tabBarItem = UITabBarItem(
            title: tabItems[1].displayTitle,
            image: tabItems[1].unSelectedIcon,
            selectedImage: tabItems[1].selectedIcon
        )


        // MARK: Rewards (3rd tab - direct hosting controller without BaseNavigationVC to prevent double safe-area insets)

        let serviceVC = tabItems[2].viewController

        serviceVC.tabBarItem = UITabBarItem(
            title: tabItems[2].displayTitle,
            image: tabItems[2].unSelectedIcon,
            selectedImage: tabItems[2].selectedIcon
        )


        // MARK: Track

        let trackVC = tabItems[3].viewController

        trackVC.tabBarItem = UITabBarItem(
            title: tabItems[3].displayTitle,
            image: tabItems[3].unSelectedIcon,
            selectedImage: tabItems[3].selectedIcon
        )

        let nav4 = BaseNavigationVC(
            rootViewController: trackVC
        )
        
        // MARK: Account (5th tab - direct hosting controller without BaseNavigationVC to prevent double safe-area insets)
        
        let ProfileVC = tabItems[4].viewController

        ProfileVC.tabBarItem = UITabBarItem(
            title: tabItems[4].displayTitle,
            image: tabItems[4].unSelectedIcon,
            selectedImage: tabItems[4].selectedIcon
        )

        viewControllers = [
            nav1,
            menuVC,
            serviceVC,
            nav4,
            ProfileVC
        ]

        selectedIndex = myIndex
    }
}


// MARK: - Indicator

extension TabBarVC {

    private func addTabbarIndicatorView(index: Int) {

        indicatorView?.removeFromSuperview()

        guard let items = tabBar.items,
              !items.isEmpty,
              index < items.count else {
            return
        }

        let itemWidth =
            tabBar.bounds.width / CGFloat(items.count)

        let x =
            (CGFloat(index) * itemWidth)
            + ((itemWidth - indicatorWidth) / 2)

        indicatorView = UIView(
            frame: CGRect(
                x: x,
                y: 0,
                width: indicatorWidth,
                height: indicatorHeight
            )
        )

        indicatorView.backgroundColor = .orange

        indicatorView.layer.cornerRadius =
            indicatorHeight / 2

        tabBar.addSubview(indicatorView)
    }
}


// MARK: - UITabBarControllerDelegate

extension TabBarVC: UITabBarControllerDelegate {

    func tabBarController(
        _ tabBarController: UITabBarController,
        didSelect viewController: UIViewController
    ) {
        if let hostingView = cartHostingVC?.view {
            view.bringSubviewToFront(hostingView)
        }
    }
}

// MARK: - Persistent Floating Cart Bar Extension

extension TabBarVC {

    private func setupPersistentFloatingCartBar() {
        let cartBar = PersistentFloatingCartBar(onTap: { [weak self] in
            self?.presentCartSheet()
        })
        
        let hosting = UIHostingController(rootView: cartBar)
        hosting.view.backgroundColor = .clear
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        
        addChild(hosting)
        view.addSubview(hosting.view)
        hosting.didMove(toParent: self)
        
        self.cartHostingVC = hosting
        
        NSLayoutConstraint.activate([
            hosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: tabBar.topAnchor, constant: -10),
            hosting.view.heightAnchor.constraint(equalToConstant: 56)
        ])
        
        view.bringSubviewToFront(hosting.view)
        
        NotificationCenter.default.addObserver(forName: .cartUpdatedNotification, object: nil, queue: .main) { [weak self] _ in
            self?.updateCartBarVisibility(animated: true)
        }
        
        NotificationCenter.default.addObserver(forName: .showCartNotification, object: nil, queue: .main) { [weak self] _ in
            self?.presentCartSheet()
        }
        
        updateCartBarVisibility(animated: false)
    }

    private func updateCartBarVisibility(animated: Bool = true) {
        let hasItems = CartManager.shared.totalItemCount > 0
        
        if let hostingView = cartHostingVC?.view {
            view.bringSubviewToFront(hostingView)
        }
        
        let updates = {
            self.cartHostingVC?.view.alpha = hasItems ? 1.0 : 0.0
            self.cartHostingVC?.view.isUserInteractionEnabled = hasItems
        }
        
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut, .allowUserInteraction], animations: updates)
        } else {
            updates()
        }
    }

    private func presentCartSheet() {
        let cartVC = UIHostingController(rootView: CartView())
        cartVC.modalPresentationStyle = .fullScreen
        
        var topVC: UIViewController = self
        while let presented = topVC.presentedViewController {
            topVC = presented
        }
        topVC.present(cartVC, animated: true)
    }

    private func presentSettingUserInfoSheet() {
        let settingView = SettingUserInfo(
            onDismiss: { [weak self] in
                self?.dismissTopModal()
            },
            onNavigateToRewards: { [weak self] in
                self?.dismissTopModal()
                self?.selectedIndex = 2
            },
            onNavigateToWallet: { [weak self] in
                self?.dismissTopModal()
                self?.presentWalletSheet()
            },
            onNavigateToOrders: { [weak self] in
                self?.dismissTopModal()
                self?.selectedIndex = 3
            },
            onNavigateToAccountSettings: { [weak self] in
                self?.dismissTopModal()
                self?.selectedIndex = 4
            },
            onSignOut: { [weak self] in
                UserDefaults.standard.set(true, forKey: "isGuestUser")
                NotificationCenter.default.post(name: .userLoggedOutNotification, object: nil)
                self?.dismissTopModal()
                self?.selectedIndex = 0
            }
        )
        
        let hostingVC = UIHostingController(rootView: settingView)
        hostingVC.modalPresentationStyle = .overFullScreen
        hostingVC.view.backgroundColor = .clear
        
        var topVC: UIViewController = self
        while let presented = topVC.presentedViewController {
            topVC = presented
        }
        topVC.present(hostingVC, animated: false)
    }

    private func redirectToOriginalLogin() {
        dismissTopModal()
        if let appDelegate = kSharedAppDelegate {
            appDelegate.moveToAuth(initialDestination: .login)
        }
    }
    
    private func presentWalletSheet() {
        let walletVC = UIHostingController(rootView: AddWalletBalanceView(
            showHeader: true,
            onBack: { [weak self] in
                self?.dismissTopModal()
            }
        ))
        walletVC.modalPresentationStyle = .fullScreen
        
        var topVC: UIViewController = self
        while let presented = topVC.presentedViewController {
            topVC = presented
        }
        topVC.present(walletVC, animated: true)
    }

    private func dismissTopModal() {
        var topVC: UIViewController = self
        while let presented = topVC.presentedViewController {
            topVC = presented
        }
        if topVC != self {
            topVC.dismiss(animated: true)
        }
    }
}





class BaseNavigationVC: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.99, alpha: 1.0)
        self.view.layer.cornerRadius = 0
        self.view.layer.masksToBounds = false
       
        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        apperance()
    }
    
    private func apperance() {
        self.navigationBar.backIndicatorImage = UIImage(named: "backArrow")?.withRenderingMode(.alwaysTemplate)
        self.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "backArrow")?.withRenderingMode(.alwaysTemplate)
        self.navigationBar.tintColor = AppColor.text_gray
        
        let tabBarApperance = UITabBarAppearance()
        tabBarApperance.configureWithOpaqueBackground()
        tabBarApperance.backgroundColor = .white
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabBarApperance
        } else {
            // Fallback on earlier versions
        }
        UITabBar.appearance().standardAppearance = tabBarApperance
    }

}


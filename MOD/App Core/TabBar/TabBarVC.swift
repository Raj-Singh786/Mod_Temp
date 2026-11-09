//
//  TabBarVC.swift
//  MOD
//
//  Created by Rajpal singh on 07/11/26.
//

import UIKit

class TabBarVC: UITabBarController {

    var myIndex = 0

    private var indicatorView: UIView!

    private let indicatorWidth: CGFloat = 32
    private let indicatorHeight: CGFloat = 4

    let tabItems: [TabItems] = [
        .Home,
        .Menu,
        .Cart,
        .Orders,
        .Sign
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
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
}


// MARK: - Setup

extension TabBarVC {

    private func initialViewLoad() {

        navigationController?.isNavigationBarHidden = true

        setUPTabBar()
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
            .font: AppFonts.jakartaSemiBold.withSize(12)
        ]

        // Selected
        appearance.stackedLayoutAppearance.selected.iconColor =
            AppColor.mod_red

        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: AppColor.mod_red,
            .font: AppFonts.jakartaSemiBold.withSize(12)
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


        // MARK: Leave

        let leaveVC = tabItems[1].viewController

        leaveVC.tabBarItem = UITabBarItem(
            title: tabItems[1].displayTitle,
            image: tabItems[1].unSelectedIcon,
            selectedImage: tabItems[1].selectedIcon
        )

        let nav2 = BaseNavigationVC(
            rootViewController: leaveVC
        )


        // MARK: Services

        let serviceVC = tabItems[2].viewController

        serviceVC.tabBarItem = UITabBarItem(
            title: tabItems[2].displayTitle,
            image: tabItems[2].unSelectedIcon,
            selectedImage: tabItems[2].selectedIcon
        )

        let nav3 = BaseNavigationVC(
            rootViewController: serviceVC
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
        
        let ProfileVC = tabItems[4].viewController

        ProfileVC.tabBarItem = UITabBarItem(
            title: tabItems[4].displayTitle,
            image: tabItems[4].unSelectedIcon,
            selectedImage: tabItems[4].selectedIcon
        )

        let nav5 = BaseNavigationVC(
            rootViewController: ProfileVC
        )


        viewControllers = [
            nav1,
            nav2,
            nav3,
            nav4,
            nav5
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

//        addTabbarIndicatorView(
//            index: selectedIndex
//        )
    }
}





class BaseNavigationVC: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.view.layer.cornerRadius = 16.0
       
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


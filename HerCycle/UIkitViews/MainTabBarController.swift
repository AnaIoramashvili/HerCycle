//
//  MainTabBarController.swift
//  HerCycle
//
//  Created by Ana on 7/13/24.
//

import UIKit

class MainTabBarController: UITabBarController {
    private let coordinator: AppCoordinator
    
    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    private func setupTabBar() {
        let homeViewController = HomeViewController()
        homeViewController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        
        let profileViewController = ProfileViewController(authViewModel: coordinator.authViewModel, coordinator: coordinator)
        profileViewController.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 1)
        
        viewControllers = [homeViewController, profileViewController]
    }
}

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
        let homeNavController = UINavigationController(rootViewController: homeViewController)
        homeNavController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        
        let calendarViewController = CalendarViewController(authViewModel: coordinator.authViewModel)
        let calendarNavController = UINavigationController(rootViewController: calendarViewController)
        calendarNavController.tabBarItem = UITabBarItem(title: "Calendar", image: UIImage(systemName: "calendar"), tag: 1)
        
        let chatViewController = ChatViewController()
        let chatNavController = UINavigationController(rootViewController: chatViewController)
        chatNavController.tabBarItem = UITabBarItem(title: "Chat", image: UIImage(systemName: "message"), tag: 2)
        
        let profileViewController = ProfileViewController(authViewModel: coordinator.authViewModel, coordinator: coordinator)
        let profileNavController = UINavigationController(rootViewController: profileViewController)
        profileNavController.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 3)
        
        viewControllers = [homeNavController, calendarNavController, chatNavController, profileNavController]
        
        tabBar.tintColor = .systemPink
        tabBar.unselectedItemTintColor = .gray
    }
}

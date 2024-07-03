//
//  NavigationManager.swift
//  HerCycle
//
//  Created by Ana on 7/4/24.
//

import UIKit
import SwiftUI

class NavigationManager {
    static let shared = NavigationManager()
    
    private init() {}
    
    func presentTabBarController(from viewController: UIViewController) {
        let tabBarController = UITabBarController()
        
        // Calendar View (SwiftUI)
        let calendarView = PeriodTrackingCalendarView()
        let calendarViewController = UIHostingController(rootView: calendarView)
        calendarViewController.tabBarItem = UITabBarItem(title: "Calendar", image: UIImage(systemName: "calendar"), tag: 0)
        
        // Chat ViewController
        let chatViewController = UIViewController()
        chatViewController.view.backgroundColor = .white
        chatViewController.tabBarItem = UITabBarItem(title: "Chat", image: UIImage(systemName: "message"), tag: 1)
        
        // Profile ViewController
        let profileViewController = UIViewController()
        profileViewController.view.backgroundColor = .white
        profileViewController.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 2)
        
        tabBarController.viewControllers = [calendarViewController, chatViewController, profileViewController]

        tabBarController.modalPresentationStyle = .fullScreen
        viewController.present(tabBarController, animated: true, completion: nil)
    }
}

//
//  MainTabBarController.swift
//  HerCycle
//
//  Created by Ana on 7/13/24.
//

import UIKit

protocol ThemeUpdateDelegate: AnyObject {
    func didUpdateTheme(_ theme: Theme)
}

class MainTabBarController: UITabBarController, ThemeUpdateDelegate {
    private let coordinator: AppCoordinator
    private let tabbarView = UIView()
    private var buttons: [UIButton] = []
    private let tabbarItemBackgroundView = UIView()
    private var centerConstraint: NSLayoutConstraint?
    
    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        setUpCustomTabBar()
        generateButtons()
        applyPreviouslySelectedTheme()
    }
    
    func setCustomTabBarHidden(_ hidden: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.tabbarView.isHidden = hidden
        }
    }
    
    private func setupViewControllers() {
        let homeViewController = HomeViewController(authViewModel: coordinator.authViewModel)
        let calendarViewController = CalendarViewController(authViewModel: coordinator.authViewModel)
        let chatViewController = ChatViewController()
        let profileViewController = ProfileViewController(authViewModel: coordinator.authViewModel, coordinator: coordinator)
                
        viewControllers = [
            UINavigationController(rootViewController: homeViewController),
            UINavigationController(rootViewController: calendarViewController),
            UINavigationController(rootViewController: chatViewController),
            UINavigationController(rootViewController: profileViewController)
        ]
    }
    
    private func setUpCustomTabBar() {
        tabBar.isHidden = true
        
        view.addSubview(tabbarView)
        tabbarView.backgroundColor = .quaternarySystemFill
        tabbarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tabbarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tabbarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            tabbarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            tabbarView.heightAnchor.constraint(equalToConstant: 60)
        ])
        tabbarView.layer.cornerRadius = 30
        
        tabbarView.addSubview(tabbarItemBackgroundView)
        tabbarItemBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tabbarItemBackgroundView.widthAnchor.constraint(equalTo: tabbarView.widthAnchor, multiplier: 1/4, constant: -10),
            tabbarItemBackgroundView.heightAnchor.constraint(equalTo: tabbarView.heightAnchor, constant: -10),
            tabbarItemBackgroundView.centerYAnchor.constraint(equalTo: tabbarView.centerYAnchor)
        ])
        tabbarItemBackgroundView.layer.cornerRadius = 25
        tabbarItemBackgroundView.backgroundColor = UIColor(named: "tertiaryPink")
    }
    
    private func generateButtons() {
        let buttonConfigurations = [
            ("house", "Home"),
            ("calendar", "Calendar"),
            ("message", "Chat"),
            ("person", "Profile")
        ]
        
        for (index, config) in buttonConfigurations.enumerated() {
            let button = createButton(withImageName: config.0, tag: index)
            tabbarView.addSubview(button)
            buttons.append(button)
            
            NSLayoutConstraint.activate([
                button.centerYAnchor.constraint(equalTo: tabbarView.centerYAnchor),
                button.widthAnchor.constraint(equalTo: tabbarView.widthAnchor, multiplier: 1/4),
                button.heightAnchor.constraint(equalTo: tabbarView.heightAnchor)
            ])
            
            if index == 0 {
                button.leadingAnchor.constraint(equalTo: tabbarView.leadingAnchor).isActive = true
            } else {
                button.leadingAnchor.constraint(equalTo: buttons[index-1].trailingAnchor).isActive = true
            }
        }
        
        centerConstraint = tabbarItemBackgroundView.centerXAnchor.constraint(equalTo: buttons[0].centerXAnchor)
        centerConstraint?.isActive = true
    }
    
    private func createButton(withImageName imageName: String, tag: Int) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .gray
        let image = UIImage(systemName: imageName)?.resize(targetSize: CGSize(width: 28, height: 25)).withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tag = tag
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }
    
    @objc private func buttonTapped(sender: UIButton) {
        selectedIndex = sender.tag
        
        for button in buttons {
            button.tintColor = .gray
        }
        
        UIView.animate(withDuration: 0.3) {
            self.centerConstraint?.isActive = false
            self.centerConstraint = self.tabbarItemBackgroundView.centerXAnchor.constraint(equalTo: self.buttons[sender.tag].centerXAnchor)
            self.centerConstraint?.isActive = true
            self.buttons[sender.tag].tintColor = .white
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Theme Update Methods
    
    func didUpdateTheme(_ theme: Theme) {
        viewControllers?.forEach { viewController in
            if let navController = viewController as? UINavigationController {
                if let homeVC = navController.viewControllers.first as? HomeViewController {
                    homeVC.updateBackground(with: theme)
                } else if let profileVC = navController.viewControllers.first as? ProfileViewController {
                    profileVC.updateBackground(with: theme)
                } else if let chatVC = navController.viewControllers.first as? ChatViewController {
                    chatVC.updateBackground(with: theme)
                } else if let calendarVC = navController.viewControllers.first as? CalendarViewController {
                    calendarVC.updateTheme(theme)
                }
            }
        }
        
        ThemeManager.shared.saveSelectedTheme(theme)
    }

    private func applyPreviouslySelectedTheme() {
        if let savedTheme = ThemeManager.shared.getSelectedTheme() {
            didUpdateTheme(savedTheme)
        }
    }
    
    func presentThemeViewController() {
        let themeVC = ThemeViewController()
        themeVC.delegate = self
        let navController = UINavigationController(rootViewController: themeVC)
        present(navController, animated: true)
    }
}

extension UIImage {
    func resize(targetSize: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size:targetSize).image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}

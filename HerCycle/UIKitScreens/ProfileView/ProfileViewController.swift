//
//  ProfileViewController.swift
//  HerCycle
//
//  Created by Ana on 7/13/24.
//

import UIKit
import SwiftUI

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ThemeUpdateDelegate {

    private let authViewModel: AuthViewModel
    private let coordinator: AppCoordinator
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(ProfileHeaderCell.self, forCellReuseIdentifier: ProfileHeaderCell.identifier)
        tableView.register(InfoCell.self, forCellReuseIdentifier: InfoCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var remindersButton: UIButton = createButton(title: "Reminders", imageName: "bell", iconColor: .systemYellow)
    private lazy var themeButton: UIButton = createButton(title: "Theme", imageName: "paintbrush", iconColor: .systemPink)
    private lazy var feedbackButton: UIButton = createButton(title: "Feedback", imageName: "paperplane", iconColor: .systemBlue)

    private func createColoredImage(systemName: String, color: UIColor) -> UIImage? {
        let configuration = UIImage.SymbolConfiguration(scale: .medium)
        if let image = UIImage(systemName: systemName, withConfiguration: configuration) {
            return image.withTintColor(color, renderingMode: .alwaysOriginal)
        }
        return nil
    }

    
    private lazy var signOutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Out", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = .white
        button.layer.cornerRadius = 22
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(signOutTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(authViewModel: AuthViewModel, coordinator: AppCoordinator) {
        self.authViewModel = authViewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func didUpdateTheme(_ theme: Theme) {
        updateBackground(with: theme)
        
        if let mainTabBarController = self.tabBarController as? MainTabBarController {
            mainTabBarController.didUpdateTheme(theme)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchUserData()
    }
    
    
    private func setupUI() {
        view.backgroundColor = UIColor(named: "mainBackgroundColor")
        
        view.addSubview(tableView)
        view.addSubview(buttonsStackView)
        view.addSubview(signOutButton)
        
        buttonsStackView.addArrangedSubview(remindersButton)
        buttonsStackView.addArrangedSubview(themeButton)
        buttonsStackView.addArrangedSubview(feedbackButton)
        
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6),
            
            buttonsStackView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: -140),
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 80),
            
            signOutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 90),
            signOutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -90),
            signOutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
            signOutButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func avatarTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        Task {
            do {
                try await authViewModel.uploadProfilePicture(image)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print("Could not upload profile picture: \(error.localizedDescription)")
            }
        }
        
        dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    private func createButton(title: String, imageName: String, iconColor: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        
        var config = UIButton.Configuration.plain()
        config.title = title
        config.image = createColoredImage(systemName: imageName, color: iconColor)
        config.imagePlacement = .top
        config.imagePadding = 8
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(scale: .medium)
        config.baseForegroundColor = .darkGray
        config.background.backgroundColor = .white
        config.cornerStyle = .medium
        
        button.configuration = config
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        
        return button
    }


    private func fetchUserData() {
        Task {
            await authViewModel.fetchUserData()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    @objc private func signOutTapped() {
        Task {
            await authViewModel.signOut()
            await coordinator.userDidLogout()
        }
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        switch sender {
        case remindersButton:
            let remindersVC = RemindersViewController()
            navigationController?.pushViewController(remindersVC, animated: true)
        case themeButton:
            let themeVC = ThemeViewController()
            themeVC.delegate = self
            let navController = UINavigationController(rootViewController: themeVC)
            present(navController, animated: true)
        case feedbackButton:
            let ratingVC = RatingViewController()
            let navController = UINavigationController(rootViewController: ratingVC)
            present(navController, animated: true)
        default:
            break
        }
    }
    
     func updateBackground(with theme: Theme) {
        view.backgroundColor = UIColor(patternImage: theme.image)
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 3
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileHeaderCell.identifier, for: indexPath) as! ProfileHeaderCell
            if let user = authViewModel.currentUser {
                cell.configure(with: user, profilePictureURL: authViewModel.userData?.profilePictureURL)
                cell.addAvatarTapGesture(target: self, action: #selector(avatarTapped))
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: InfoCell.identifier, for: indexPath) as! InfoCell
            if let userData = authViewModel.userData {
                switch indexPath.row {
                case 0:
                    cell.configure(title: "Cycle Length", value: "\(userData.cycleLength) days", icon: "calendar")
                case 1:
                    cell.configure(title: "Period Length", value: "\(userData.periodLength) days", icon: "drop")
                case 2:
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .medium
                    cell.configure(title: "Last Period Start", value: dateFormatter.string(from: userData.lastPeriodStartDate), icon: "clock")
                default:
                    break
                }
            }
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


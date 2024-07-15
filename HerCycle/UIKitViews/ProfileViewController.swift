//
//  ProfileViewController.swift
//  HerCycle
//
//  Created by Ana on 7/13/24.
//

import UIKit
import SwiftUI

class ProfileViewController: UIViewController {
    
    private let authViewModel: AuthViewModel
    private let coordinator: AppCoordinator
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(ProfileHeaderCell.self, forCellReuseIdentifier: "ProfileHeaderCell")
        tableView.register(InfoCell.self, forCellReuseIdentifier: "InfoCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchUserData()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(named: "background")
        view.addSubview(tableView)
        view.addSubview(signOutButton)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: signOutButton.topAnchor, constant: -20),
            
            signOutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 80),
            signOutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -80),
            signOutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60),
            signOutButton.heightAnchor.constraint(equalToConstant: 44)
        ])
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileHeaderCell", for: indexPath) as! ProfileHeaderCell
            if let user = authViewModel.currentUser {
                cell.configure(with: user)
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath) as! InfoCell
            if let userData = authViewModel.userData {
                switch indexPath.row {
                case 0:
                    cell.configure(title: "Cycle Length", value: "\(userData.cycleLength) days", icon: "calendar")
                case 1:
                    cell.configure(title: "Period Length", value: "\(userData.periodLength) days", icon: "clock")
                case 2:
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .medium
                    cell.configure(title: "Last Period Start", value: dateFormatter.string(from: userData.lastPeriodStartDate), icon: "calendar.badge.clock")
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
        
        if indexPath.section == 2 {
            Task {
                await authViewModel.signOut()
                await coordinator.userDidLogout()
            }
        }
    }
}

// MARK: - Custom Cells

class ProfileHeaderCell: UITableViewCell {
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemPink
        imageView.layer.cornerRadius = 40
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(emailLabel)
        
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            avatarImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            avatarImageView.widthAnchor.constraint(equalToConstant: 80),
            avatarImageView.heightAnchor.constraint(equalToConstant: 80),
            
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.topAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            emailLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            emailLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor)
        ])
    }
    
    func configure(with user: User) {
        nameLabel.text = user.fullName
        emailLabel.text = user.email
        avatarImageView.backgroundColor = .systemPink
    }
}

class InfoCell: UITableViewCell {
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemPink
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .right
        label.textColor = .black
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)
        
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            valueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            valueLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            valueLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8)
        ])
    }
    
    func configure(title: String, value: String, icon: String) {
        titleLabel.text = title
        valueLabel.text = value
        iconImageView.image = UIImage(systemName: icon)
    }
}

class SignOutCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        textLabel?.text = "Sign Out"
        textLabel?.textColor = .systemRed
        textLabel?.textAlignment = .center
        textLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
    }
}


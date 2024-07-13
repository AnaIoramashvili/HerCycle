//
//  ProfileViewController.swift
//  HerCycle
//
//  Created by Ana on 7/13/24.
//

import UIKit

class ProfileViewController: UIViewController {
    
    private let authViewModel: AuthViewModel
    private let coordinator: AppCoordinator
    
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
        view.backgroundColor = .white
        
        let tableView = UITableView(frame: view.bounds, style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
    }
    
    private func fetchUserData() {
        Task {
            await authViewModel.fetchUserData()
            DispatchQueue.main.async {
                (self.view as? UITableView)?.reloadData()
            }
        }
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 3
        case 2: return 1
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        
        switch indexPath.section {
        case 0:
            if let user = authViewModel.currentUser {
                cell.textLabel?.text = user.fullName
                cell.detailTextLabel?.text = user.email
            }
        case 1:
            if let userData = authViewModel.userData {
                switch indexPath.row {
                case 0:
                    cell.textLabel?.text = "Cycle Length"
                    cell.detailTextLabel?.text = "\(userData.cycleLength) days"
                case 1:
                    cell.textLabel?.text = "Period Length"
                    cell.detailTextLabel?.text = "\(userData.periodLength) days"
                case 2:
                    cell.textLabel?.text = "Last Period Start"
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .medium
                    cell.detailTextLabel?.text = dateFormatter.string(from: userData.lastPeriodStartDate)
                default:
                    break
                }
            }
        case 2:
            cell.textLabel?.text = "Sign Out"
            cell.textLabel?.textColor = .red
        default:
            break
        }
        
        return cell
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

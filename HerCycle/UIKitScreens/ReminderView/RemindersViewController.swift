//
//  RemindersViewController.swift
//  HerCycle
//
//  Created by Ana on 7/21/24.
//

import UIKit

class RemindersViewController: UIViewController {
    
    private let viewModel = ReminderViewModel()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ModernReminderCell.self, forCellReuseIdentifier: ModernReminderCell.identifier)
        tableView.backgroundColor = UIColor(named: "background")
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModel.loadReminders()
        tableView.reloadData()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(named: "background")
        title = "Reminders"
        
        setupNavigationBar()
        setupTableView()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.largeTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.color1
        ]
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = .color6
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addReminderTapped)
        )
        navigationItem.rightBarButtonItem?.tintColor = .color1
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    @objc private func addReminderTapped() {
        let addReminderVC = AddReminderViewController { [weak self] reminder in
            self?.viewModel.addReminder(reminder)
            self?.tableView.reloadData()
        }
        let navController = UINavigationController(rootViewController: addReminderVC)
        present(navController, animated: true)
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension RemindersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.reminders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ModernReminderCell.identifier, for: indexPath) as? ModernReminderCell else {
            return UITableViewCell()
        }
        
        let reminder = viewModel.reminders[indexPath.row]
        let dateTimeString = DateFormatter.reminderDateTimeFormatter.string(from: reminder.date)
        
        cell.configure(with: reminder.title, dateTime: dateTimeString)
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.toggleReminderCompletion(at: indexPath.row)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.deleteReminder(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}


//
//  RemindersViewController.swift
//  HerCycle
//
//  Created by Ana on 7/21/24.
//

import UIKit
import UserNotifications

class RemindersViewController: UIViewController {
    
    private var reminders: [Reminder] = []
    
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
        loadReminders()
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
            self?.handleNewReminder(reminder)
        }
        let navController = UINavigationController(rootViewController: addReminderVC)
        present(navController, animated: true)
    }
    
    private func handleNewReminder(_ reminder: Reminder) {
        reminders.append(reminder)
        saveReminders()
        tableView.reloadData()
        scheduleNotification(for: reminder)
    }
    
    private func loadReminders() {
        if let data = UserDefaults.standard.data(forKey: "reminders") {
            do {
                reminders = try JSONDecoder().decode([Reminder].self, from: data)
                tableView.reloadData()
            } catch {
                print("Error loading reminders: \(error)")
            }
        }
    }

    private func saveReminders() {
        do {
            let data = try JSONEncoder().encode(reminders)
            UserDefaults.standard.set(data, forKey: "reminders")
        } catch {
            print("Error saving reminders: \(error)")
        }
    }
    
    private func scheduleNotification(for reminder: Reminder) {
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = reminder.title
        content.sound = .default
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: reminder.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension RemindersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ModernReminderCell.identifier, for: indexPath) as? ModernReminderCell else {
            return UITableViewCell()
        }
        
        let reminder = reminders[indexPath.row]
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
        reminders[indexPath.row].isCompleted.toggle()
        saveReminders()
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let reminderToRemove = reminders[indexPath.row]
            reminders.remove(at: indexPath.row)
            saveReminders()
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminderToRemove.id.uuidString])
        }
    }
}

extension DateFormatter {
    static let reminderDateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
        return formatter
    }()
}

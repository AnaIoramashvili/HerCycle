//
//  RemindersViewController.swift
//  HerCycle
//
//  Created by Ana on 7/21/24.
//

//import UIKit
//import UserNotifications
//
//class RemindersViewController: UIViewController {
//    private var reminders: [Reminder] = []
//    private let tableView = UITableView()
//    private let addButton = UIButton(type: .system)
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        loadReminders()
//    }
//    
//    private func setupUI() {
//        view.backgroundColor = .systemBackground
//        title = "Reminders"
//        
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ReminderCell")
//        view.addSubview(tableView)
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        
//        addButton.setTitle("Add Reminder", for: .normal)
//        addButton.addTarget(self, action: #selector(addReminderTapped), for: .touchUpInside)
//        view.addSubview(addButton)
//        addButton.translatesAutoresizingMaskIntoConstraints = false
//        
//        NSLayoutConstraint.activate([
//            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            tableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -20),
//            
//            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80),
//            addButton.heightAnchor.constraint(equalToConstant: 50)
//        ])
//    }
//    
//    @objc private func addReminderTapped() {
//        let addReminderVC = AddReminderViewController { [weak self] reminder in
//            self?.reminders.append(reminder)
//            self?.saveReminders()
//            self?.tableView.reloadData()
//            self?.scheduleNotification(for: reminder)
//        }
//        let navController = UINavigationController(rootViewController: addReminderVC)
//        present(navController, animated: true, completion: nil)
//    }
//    
//    private func loadReminders() {
//        if let data = UserDefaults.standard.data(forKey: "reminders") {
//            do {
//                reminders = try JSONDecoder().decode([Reminder].self, from: data)
//            } catch {
//                print("Error loading reminders: \(error)")
//            }
//        }
//        tableView.reloadData()
//    }
//    
//    private func saveReminders() {
//        do {
//            let data = try JSONEncoder().encode(reminders)
//            UserDefaults.standard.set(data, forKey: "reminders")
//        } catch {
//            print("Error saving reminders: \(error)")
//        }
//    }
//    
//    private func scheduleNotification(for reminder: Reminder) {
//        let content = UNMutableNotificationContent()
//        content.title = "Reminder"
//        content.body = reminder.title
//        content.sound = .default
//        
//        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.date)
//        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
//        
//        let request = UNNotificationRequest(identifier: reminder.id.uuidString, content: content, trigger: trigger)
//        
//        UNUserNotificationCenter.current().add(request) { error in
//            if let error = error {
//                print("Error scheduling notification: \(error)")
//            }
//        }
//    }
//}
//
//extension RemindersViewController: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return reminders.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderCell", for: indexPath)
//        let reminder = reminders[indexPath.row]
//        
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "MMM d, yyyy h:mm a"
//        
//        cell.textLabel?.text = reminder.title
//        cell.detailTextLabel?.text = dateFormatter.string(from: reminder.date)
//        cell.accessoryType = reminder.isCompleted ? .checkmark : .none
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        reminders[indexPath.row].isCompleted.toggle()
//        saveReminders()
//        tableView.reloadRows(at: [indexPath], with: .automatic)
//    }
//    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            let reminderToRemove = reminders[indexPath.row]
//            reminders.remove(at: indexPath.row)
//            saveReminders()
//            tableView.deleteRows(at: [indexPath], with: .fade)
//            
//            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminderToRemove.id.uuidString])
//        }
//    }
//}
//
//class AddReminderViewController: UIViewController {
//    private let titleTextField = UITextField()
//    private let datePicker = UIDatePicker()
//    private let addButton = UIButton(type: .system)
//    private let completion: (Reminder) -> Void
//    
//    init(completion: @escaping (Reminder) -> Void) {
//        self.completion = completion
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//    }
//    
//    private func setupUI() {
//        view.backgroundColor = .systemBackground
//        title = "Add Reminder"
//        
//        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
//        
//        titleTextField.placeholder = "Reminder Title"
//        titleTextField.borderStyle = .roundedRect
//        view.addSubview(titleTextField)
//        titleTextField.translatesAutoresizingMaskIntoConstraints = false
//        
//        datePicker.datePickerMode = .dateAndTime
//        datePicker.preferredDatePickerStyle = .wheels
//        datePicker.minimumDate = Date()
//        view.addSubview(datePicker)
//        datePicker.translatesAutoresizingMaskIntoConstraints = false
//        
//        addButton.setTitle("Add", for: .normal)
//        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
//        view.addSubview(addButton)
//        addButton.translatesAutoresizingMaskIntoConstraints = false
//        
//        NSLayoutConstraint.activate([
//            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
//            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            
//            datePicker.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20),
//            datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            
//            addButton.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 20),
//            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            addButton.widthAnchor.constraint(equalToConstant: 100),
//            addButton.heightAnchor.constraint(equalToConstant: 44)
//        ])
//    }
//    
//    @objc private func cancelTapped() {
//        dismiss(animated: true, completion: nil)
//    }
//    
//    @objc private func addTapped() {
//        guard let title = titleTextField.text, !title.isEmpty else {
//            return
//        }
//        
//        let newReminder = Reminder(title: title, date: datePicker.date)
//        completion(newReminder)
//        dismiss(animated: true, completion: nil)
//    }
//}


import UIKit
import UserNotifications

class RemindersViewController: UIViewController {
    private var reminders: [Reminder] = []
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadReminders()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(named: "background")
        title = "Reminders"
        
        navigationController?.navigationBar.tintColor = .color1
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.color1]
        
        navigationItem.rightBarButtonItem?.tintColor = .color1
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addReminderTapped))
        
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ReminderCell.self, forCellReuseIdentifier: "ReminderCell")
        tableView.backgroundColor = UIColor(named: "background")
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
            self?.reminders.append(reminder)
            self?.saveReminders()
            self?.tableView.reloadData()
            self?.scheduleNotification(for: reminder)
        }
        let navController = UINavigationController(rootViewController: addReminderVC)
        present(navController, animated: true, completion: nil)
    }
    
    private func loadReminders() {
        if let data = UserDefaults.standard.data(forKey: "reminders") {
            do {
                reminders = try JSONDecoder().decode([Reminder].self, from: data)
            } catch {
                print("Error loading reminders: \(error)")
            }
        }
        tableView.reloadData()
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
}

extension RemindersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderCell", for: indexPath) as? ReminderCell else {
            return UITableViewCell()
        }
        
        let reminder = reminders[indexPath.row]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy h:mm a"
        
        cell.titleLabel.text = reminder.title
        cell.dateLabel.text = dateFormatter.string(from: reminder.date)
        cell.accessoryType = reminder.isCompleted ? .checkmark : .none
        cell.backgroundColor = .white
        
        return cell
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

class AddReminderViewController: UIViewController {
    private let titleTextField = UITextField()
    private let datePicker = UIDatePicker()
    private let addButton = UIButton(type: .system)
    private let completion: (Reminder) -> Void
    
    init(completion: @escaping (Reminder) -> Void) {
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(named: "background")
        title = "Add Reminder"
        
        navigationController?.navigationBar.tintColor = .color1
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.color1]
        
        navigationItem.leftBarButtonItem?.tintColor = .color1
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(cancelTapped))
        
        titleTextField.placeholder = "Reminder Title"
        titleTextField.borderStyle = .roundedRect
        view.addSubview(titleTextField)
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.minimumDate = Date()
        view.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        addButton.setTitle("Add", for: .normal)
        addButton.layer.cornerRadius = 20
        addButton.backgroundColor = .color1
        addButton.setTitleColor(.white, for: .normal)
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        view.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            datePicker.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20),
            datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            addButton.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 20),
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 100),
            addButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func addTapped() {
        guard let title = titleTextField.text, !title.isEmpty else {
            return
        }
        
        let newReminder = Reminder(title: title, date: datePicker.date)
        completion(newReminder)
        dismiss(animated: true, completion: nil)
    }
}

import UIKit

class ReminderCell: UITableViewCell {
    let titleLabel = UILabel()
    let dateLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Customize titleLabel
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = .black
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Customize dateLabel
        dateLabel.font = UIFont.systemFont(ofSize: 14)
        dateLabel.textColor = .gray
        dateLabel.textAlignment = .right
        contentView.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            dateLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 10)
        ])
    }
}



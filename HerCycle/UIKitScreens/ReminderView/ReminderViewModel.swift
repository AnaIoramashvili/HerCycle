//
//  ReminderViewModel.swift
//  HerCycle
//
//  Created by Ana on 7/26/24.
//

import Foundation
import UserNotifications

class ReminderViewModel {
    private(set) var reminders: [Reminder] = []
    
    func loadReminders() {
        if let data = UserDefaults.standard.data(forKey: "reminders") {
            do {
                reminders = try JSONDecoder().decode([Reminder].self, from: data)
            } catch {
                print("Error loading reminders: \(error)")
            }
        }
    }
    
    func saveReminders() {
        do {
            let data = try JSONEncoder().encode(reminders)
            UserDefaults.standard.set(data, forKey: "reminders")
        } catch {
            print("Error saving reminders: \(error)")
        }
    }
    
    func addReminder(_ reminder: Reminder) {
        reminders.append(reminder)
        saveReminders()
        scheduleNotification(for: reminder)
    }
    
    func toggleReminderCompletion(at index: Int) {
        reminders[index].isCompleted.toggle()
        saveReminders()
    }
    
    func deleteReminder(at index: Int) {
        let reminderToRemove = reminders[index]
        reminders.remove(at: index)
        saveReminders()
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminderToRemove.id.uuidString])
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

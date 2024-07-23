//
//  Reminder.swift
//  HerCycle
//
//  Created by Ana on 7/21/24.
//

import Foundation

struct Reminder: Identifiable, Codable {
    let id: UUID
    var title: String
    var date: Date
    var isCompleted: Bool
    
    init(id: UUID = UUID(), title: String, date: Date, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.date = date
        self.isCompleted = isCompleted
    }
}

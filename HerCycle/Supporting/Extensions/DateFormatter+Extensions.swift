//
//  DateFormatter+Extensions.swift
//  HerCycle
//
//  Created by Ana on 7/26/24.
//

import Foundation

extension DateFormatter {
    static let reminderDateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
        return formatter
    }()
}

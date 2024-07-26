//
//  CalendarViewModel.swift
//  HerCycle
//
//  Created by Ana on 7/26/24.
//

import SwiftUI

final class CalendarViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var isMonthlyView: Bool = true
    @Published var markedDays: [Date: CyclePhase] = [:]
    
    let pmsColor = Color.blue.opacity(0.4)
    let periodColor = Color(UIColor.systemRed).opacity(0.7)
    let ovulationColor = Color.yellow
    
    private let calendar = Calendar.current
    private let authViewModel: AuthViewModel
    
    @MainActor var lastPeriodStartDate: Date {
        authViewModel.userData?.lastPeriodStartDate ?? Date()
    }
    
    init(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
    }
    
    func currentDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: Date())
    }
    
    @MainActor func loadUserData() {
        guard let userData = authViewModel.userData else { return }
        updateMarkedDays(using: userData)
    }
    
    private func updateMarkedDays(using userData: UserData) {
        let cycleLength = userData.cycleLength
        let periodLength = userData.periodLength
        let lastPeriodStartDate = userData.lastPeriodStartDate
        
        markedDays.removeAll()
        
        var currentPeriodStart = lastPeriodStartDate
        let endDate = calendar.date(byAdding: .year, value: 2, to: Date())!
        
        while currentPeriodStart <= endDate {
            for day in 0..<periodLength {
                if let date = calendar.date(byAdding: .day, value: day, to: currentPeriodStart) {
                    let components = calendar.dateComponents([.year, .month, .day], from: date)
                    let normalizedDate = calendar.date(from: components)!
                    markedDays[normalizedDate] = .period
                }
            }
            
            if let ovulationDate = calendar.date(byAdding: .day, value: cycleLength - 14, to: currentPeriodStart) {
                let components = calendar.dateComponents([.year, .month, .day], from: ovulationDate)
                let normalizedDate = calendar.date(from: components)!
                markedDays[normalizedDate] = .ovulation
            }
            
            for day in 1...5 {
                if let pmsDate = calendar.date(byAdding: .day, value: -day, to: currentPeriodStart) {
                    let components = calendar.dateComponents([.year, .month, .day], from: pmsDate)
                    let normalizedDate = calendar.date(from: components)!
                    markedDays[normalizedDate] = .pms
                }
            }
            
            currentPeriodStart = calendar.date(byAdding: .day, value: cycleLength, to: currentPeriodStart)!
        }
    }
    
    func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    func daysInMonth(for date: Date) -> [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: date) else { return [] }
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let leadingSpaces = (firstWeekday - calendar.firstWeekday + 7) % 7
        
        var days: [Date?] = Array(repeating: nil, count: leadingSpaces)
        
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        
        let totalDays = 42
        if days.count < totalDays {
            days += Array(repeating: nil as Date?, count: totalDays - days.count)
        }
        
        return days
    }
    
    func previousMonth() {
        selectedDate = calendar.date(byAdding: .month, value: -1, to: selectedDate)!
    }
    
    func nextMonth() {
        selectedDate = calendar.date(byAdding: .month, value: 1, to: selectedDate)!
    }
    
    func monthString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: date)
    }
}

//
//  CalendarView.swift
//  HerCycle
//
//  Created by Ana on 7/15/24.
//

import SwiftUI

enum PeriodType: String {
    case period = "Period"
    case ovulation = "Ovulation"
}

struct CalendarView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedDate: Date = Date()
    @State private var markedDays: [Date: PeriodType] = [:]
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack {
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                }
                Text(monthYearString(from: selectedDate))
                    .font(.title)
                    .padding()
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding()
            
            // Weekday labels
            HStack {
                ForEach(0..<7, id: \.self) { index in
                    Text(weekdaySymbol(for: (index + calendar.firstWeekday - 1) % 7))
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            
            // Calendar days
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                ForEach(daysInMonth(for: selectedDate), id: \.self) { date in
                    if let date = date {
                        DayView(date: date, periodType: markedDays[date])
                    } else {
                        Color.clear
                    }
                }
            }
            .padding()
            
            // Legend
            HStack(spacing: 20) {
                LegendItem(color: .red, label: "Period")
                LegendItem(color: .purple, label: "Ovulation")
            }
            .padding()
        }
        .onAppear(perform: loadUserData)
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func daysInMonth(for date: Date) -> [Date?] {
        let range = calendar.range(of: .day, in: .month, for: date)!
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        days += range.map { day -> Date? in
            calendar.date(bySetting: .day, value: day, of: date)
        }
        
        return days
    }
    
    private func previousMonth() {
        selectedDate = calendar.date(byAdding: .month, value: -1, to: selectedDate)!
        updateMarkedDays()
    }
    
    private func nextMonth() {
        selectedDate = calendar.date(byAdding: .month, value: 1, to: selectedDate)!
        updateMarkedDays()
    }
    
    private func weekdaySymbol(for index: Int) -> String {
        let weekdays = calendar.shortWeekdaySymbols
        return weekdays[index]
    }
    
    private func loadUserData() {
        guard let userData = authViewModel.userData else { return }
        updateMarkedDays(using: userData)
    }
    
    private func updateMarkedDays() {
        guard let userData = authViewModel.userData else { return }
        updateMarkedDays(using: userData)
    }
    
    private func updateMarkedDays(using userData: UserData) {
        let cycleLength = userData.cycleLength
        let periodLength = userData.periodLength
        let lastPeriodStartDate = userData.lastPeriodStartDate
        
        markedDays.removeAll()
        
        // Mark periods and ovulations for the next 6 months
        var currentPeriodStart = lastPeriodStartDate
        let endDate = calendar.date(byAdding: .month, value: 6, to: Date())!
        
        while currentPeriodStart <= endDate {
            // Mark period days
            for day in 0..<periodLength {
                if let date = calendar.date(byAdding: .day, value: day, to: currentPeriodStart) {
                    markedDays[date] = .period
                }
            }
            
            // Mark ovulation day (14 days before the next period)
            if let ovulationDate = calendar.date(byAdding: .day, value: cycleLength - 14, to: currentPeriodStart) {
                markedDays[ovulationDate] = .ovulation
            }
            
            // Move to next cycle
            currentPeriodStart = calendar.date(byAdding: .day, value: cycleLength, to: currentPeriodStart)!
        }
    }
}

struct DayView: View {
    let date: Date
    let periodType: PeriodType?
    
    private let calendar = Calendar.current
    
    var body: some View {
        Text("\(calendar.component(.day, from: date))")
            .frame(width: 40, height: 40)
            .background(backgroundForPeriodType())
            .clipShape(Circle())
            .foregroundColor(foregroundForPeriodType())
    }
    
    private func backgroundForPeriodType() -> Color {
        switch periodType {
        case .period:
            return .red
        case .ovulation:
            return .purple
        case .none:
            return .clear
        }
    }
    
    private func foregroundForPeriodType() -> Color {
        switch periodType {
        case .period, .ovulation:
            return .white
        case .none:
            return .primary
        }
    }
}

struct LegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 20, height: 20)
            Text(label)
                .font(.caption)
        }
    }
}

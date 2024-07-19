//
//  CalendarView.swift
//  HerCycle
//
//  Created by Ana on 7/15/24.
//

import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedDate: Date = Date()
    @State private var markedDays: [Date: PeriodType] = [:]
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack {
            monthHeader
            weekdayHeader
            calendarGrid
            legend
        }
        .onAppear(perform: loadUserData)
        .onChange(of: selectedDate) { _, _ in
            updateMarkedDays()
        }
    }
    
    private var monthHeader: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.blue)
            }
            Spacer()
            Text(monthYearString(from: selectedDate))
                .font(.title2)
            Spacer()
            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.blue)
            }
        }
        .padding()
    }
    
    private var weekdayHeader: some View {
        HStack {
            ForEach(calendar.shortWeekdaySymbols, id: \.self) { day in
                Text(day)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.gray)
            }
        }
    }
    
    private var calendarGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
            ForEach(daysInMonth(), id: \.self) { date in
                if let date = date {
                    DayView(date: date, periodType: periodTypeForDate(date))
                } else {
                    Color.clear
                }
            }
        }
        .padding()
    }
    
    private var legend: some View {
        HStack(spacing: 20) {
            LegendItem(color: .red, label: "Period")
            LegendItem(color: .purple, label: "Ovulation")
        }
        .padding()
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func daysInMonth() -> [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: selectedDate) else { return [] }
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate))!
        
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let leadingSpaces = (firstWeekday - calendar.firstWeekday + 7) % 7
        
        var days: [Date?] = Array(repeating: nil, count: leadingSpaces)
        
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private func previousMonth() {
        selectedDate = calendar.date(byAdding: .month, value: -1, to: selectedDate)!
    }
    
    private func nextMonth() {
        selectedDate = calendar.date(byAdding: .month, value: 1, to: selectedDate)!
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
        
        var currentPeriodStart = lastPeriodStartDate
        let endDate = calendar.date(byAdding: .month, value: 6, to: Date())!
        
        while currentPeriodStart <= endDate {
            for day in 0..<periodLength {
                if let date = calendar.date(byAdding: .day, value: day, to: currentPeriodStart) {
                    let components = calendar.dateComponents([.year, .month, .day], from: date)
                    let normalizedDate = calendar.date(from: components)!
                    markedDays[normalizedDate] = day == 0 ? .periodStart : .period
                }
            }
            
            if let ovulationDate = calendar.date(byAdding: .day, value: cycleLength - 14, to: currentPeriodStart) {
                let components = calendar.dateComponents([.year, .month, .day], from: ovulationDate)
                let normalizedDate = calendar.date(from: components)!
                markedDays[normalizedDate] = .ovulation
            }
            
            currentPeriodStart = calendar.date(byAdding: .day, value: cycleLength + periodLength, to: currentPeriodStart)!
        }
    }
    
    private func periodTypeForDate(_ date: Date) -> PeriodType? {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let normalizedDate = calendar.date(from: components)!
        return markedDays[normalizedDate]
    }
}

struct DayView: View {
    let date: Date
    let periodType: PeriodType?
    
    private let calendar = Calendar.current
    
    var body: some View {
        Text("\(calendar.component(.day, from: date))")
            .frame(width: 35, height: 35)
            .background(backgroundForPeriodType())
            .clipShape(Circle())
            .foregroundColor(foregroundForPeriodType())
    }
    
    private func backgroundForPeriodType() -> Color {
        switch periodType {
        case .periodStart, .period:
            return .red
        case .ovulation:
            return .purple
        case .none:
            return .clear
        }
    }
    
    private func foregroundForPeriodType() -> Color {
        periodType != nil ? .white : .primary
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

enum PeriodType {
    case periodStart, period, ovulation
}

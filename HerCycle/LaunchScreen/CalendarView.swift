//
//  CalendarView.swift
//  HerCycle
//
//  Created by Ana on 7/15/24.
//

import SwiftUI

enum PeriodType {
    case period, ovulation
}


import SwiftUI

struct CalendarView: View {
    @Binding var selectedDate: Date
    @Binding var markedDays: [Date: PeriodType]
    @Binding var selectedPeriodType: PeriodType?
    
    var onPreviousMonth: () -> Void
    var onNextMonth: () -> Void
    var onDaySelected: (Date) -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack {
            HStack {
                Button(action: onPreviousMonth) {
                    Image(systemName: "chevron.left")
                }
                Text(monthYearString(from: selectedDate))
                    .font(.title)
                    .padding()
                Button(action: onNextMonth) {
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
                        DayView(date: date, periodType: markedDays[date]) {
                            onDaySelected(date)
                        }
                    } else {
                        Color.clear
                    }
                }
            }
            .padding()
            
            // Period type buttons
            HStack(spacing: 20) {
                PeriodButton(color: .red, label: "Period", isSelected: selectedPeriodType == .period) {
                    selectedPeriodType = .period
                }
                PeriodButton(color: .blue, label: "Ovulation", isSelected: selectedPeriodType == .ovulation) {
                    selectedPeriodType = .ovulation
                }
            }
            .padding()
        }
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
    
    private func toggleMarkedDay(_ date: Date) {
        if let selectedType = selectedPeriodType {
            markedDays[date] = selectedType
        }
    }
    
    private func previousMonth() {
        selectedDate = calendar.date(byAdding: .month, value: -1, to: selectedDate)!
    }
    
    private func nextMonth() {
        selectedDate = calendar.date(byAdding: .month, value: 1, to: selectedDate)!
    }
    
    private func weekdaySymbol(for index: Int) -> String {
        let weekdays = calendar.shortWeekdaySymbols
        return weekdays[index]
    }
}

struct DayView: View {
    let date: Date
    let periodType: PeriodType?
    let action: () -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        Button(action: action) {
            Text("\(calendar.component(.day, from: date))")
                .frame(width: 40, height: 40)
                .background(getColorForPeriodType())
                .clipShape(Circle())
                .foregroundColor(.primary)
        }
    }
    
    private func getColorForPeriodType() -> Color {
        switch periodType {
        case .period:
            return .red
        case .ovulation:
            return .blue
        case .none:
            return .clear
        }
    }
}

struct PeriodButton: View {
    let color: Color
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Text(label)
            .foregroundColor(isSelected ? .white : color)
            .padding()
            .background(RoundedRectangle(cornerRadius: 15).stroke(color, lineWidth: 1))
            .background(isSelected ? color : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .onTapGesture {
                action()
            }
    }
}


//#Preview {
//    CalendarView()
//}

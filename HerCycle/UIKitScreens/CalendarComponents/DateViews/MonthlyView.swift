//
//  MonthlyView.swift
//  HerCycle
//
//  Created by Ana on 7/24/24.
//

import SwiftUI

struct MonthlyView: View {
    @Binding var selectedDate: Date
    let markedDays: [Date: CyclePhase]
    let pmsColor: Color
    let periodColor: Color
    let ovulationColor: Color
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 8)
                
                Text(monthYearString(from: selectedDate))
                    .font(.title3)
                    .fontWeight(.medium)
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding(.leading, 8)
            }
            
            HStack {
                ForEach(Array(calendar.veryShortWeekdaySymbols.enumerated()), id: \.offset) { index, day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.gray)
                }
            }
            .padding(.top, 8)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(Array(daysInMonth().enumerated()), id: \.offset) { index, date in
                    if let date = date {
                        DayView(date: date, cyclePhase: markedDays[date], pmsColor: pmsColor, periodColor: periodColor, ovulationColor: ovulationColor)
                    } else {
                        Text("")
                            .frame(height: 40)
                    }
                }
            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
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
        
        let totalDays = 42
        if days.count < totalDays {
            days += Array(repeating: nil as Date?, count: totalDays - days.count)
        }
        
        return days
    }
    
    private func previousMonth() {
        selectedDate = calendar.date(byAdding: .month, value: -1, to: selectedDate)!
    }
    
    private func nextMonth() {
        selectedDate = calendar.date(byAdding: .month, value: 1, to: selectedDate)!
    }
}

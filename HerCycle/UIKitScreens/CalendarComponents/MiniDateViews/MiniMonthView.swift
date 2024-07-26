//
//  MiniMonthView.swift
//  HerCycle
//
//  Created by Ana on 7/24/24.
//

import SwiftUI

struct MiniMonthView: View {
    let date: Date
    let markedDays: [Date: CyclePhase]
    let pmsColor: Color
    let periodColor: Color
    let ovulationColor: Color
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(monthString(from: date))
                .font(.caption)
                .fontWeight(.medium)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 2) {
                ForEach(Array(daysInMonth().enumerated()), id: \.offset) { index, date in
                    if let date = date {
                        MiniDayView(date: date, cyclePhase: markedDays[date], pmsColor: pmsColor, periodColor: periodColor, ovulationColor: ovulationColor)
                    } else {
                        Text("")
                            .frame(width: 12, height: 12)
                    }
                }
            }
        }
        .padding(8)
        .background(Color.white)
        .cornerRadius(10)
    }
    
    private func monthString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: date)
    }
    
    private func daysInMonth() -> [Date?] {
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
}

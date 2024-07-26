//
//  MonthlyView.swift
//  HerCycle
//
//  Created by Ana on 7/24/24.
//

import SwiftUI

struct MonthlyView: View {
    @ObservedObject var viewModel: CalendarViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: viewModel.previousMonth) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 8)
                
                Text(viewModel.monthYearString(from: viewModel.selectedDate))
                    .font(.title3)
                    .fontWeight(.medium)
                
                Button(action: viewModel.nextMonth) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding(.leading, 8)
            }
            
            HStack {
                ForEach(Array(Calendar.current.veryShortWeekdaySymbols.enumerated()), id: \.offset) { index, day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.gray)
                }
            }
            .padding(.top, 8)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(Array(viewModel.daysInMonth(for: viewModel.selectedDate).enumerated()), id: \.offset) { index, date in
                    if let date = date {
                        DayView(date: date, cyclePhase: viewModel.markedDays[date], pmsColor: viewModel.pmsColor, periodColor: viewModel.periodColor, ovulationColor: viewModel.ovulationColor)
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
}

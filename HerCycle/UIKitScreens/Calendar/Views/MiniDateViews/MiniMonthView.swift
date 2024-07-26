//
//  MiniMonthView.swift
//  HerCycle
//
//  Created by Ana on 7/24/24.
//

import SwiftUI

struct MiniMonthView: View {
    @ObservedObject var viewModel: CalendarViewModel
    let date: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(viewModel.monthString(from: date))
                .font(.caption)
                .fontWeight(.medium)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 2) {
                ForEach(Array(viewModel.daysInMonth(for: date).enumerated()), id: \.offset) { index, date in
                    if let date = date {
                        MiniDayView(date: date, cyclePhase: viewModel.markedDays[date], pmsColor: viewModel.pmsColor, periodColor: viewModel.periodColor, ovulationColor: viewModel.ovulationColor)
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
}

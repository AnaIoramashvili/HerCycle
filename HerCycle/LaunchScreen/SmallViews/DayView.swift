//
//  DayView.swift
//  HerCycle
//
//  Created by Ana on 7/24/24.
//

import SwiftUI

struct DayView: View {
    let date: Date
    let cyclePhase: CyclePhase?
    let pmsColor: Color
    let periodColor: Color
    let ovulationColor: Color
    
    private let calendar = Calendar.current
    
    var body: some View {
        ZStack {
            Group {
                switch cyclePhase {
                case .pms:
                    DashedCircle()
                        .stroke(pmsColor, lineWidth: 2)
                        .frame(width: 38, height: 38)
                case .period:
                    Circle()
                        .fill(periodColor)
                case .ovulation:
                    Circle()
                        .fill(ovulationColor)
                case .none:
                    Circle()
                        .fill(Color.clear)
                }
            }
            .frame(width: 40, height: 40)
            
            Text("\(calendar.component(.day, from: date))")
                .foregroundColor(.black)
                .font(.system(size: 14, weight: .medium))
        }
    }
}

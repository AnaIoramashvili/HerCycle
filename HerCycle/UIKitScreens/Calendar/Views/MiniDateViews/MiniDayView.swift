//
//  MiniDayView.swift
//  HerCycle
//
//  Created by Ana on 7/24/24.
//

import SwiftUI

struct MiniDayView: View {
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
                        .stroke(pmsColor, lineWidth: 1.5)
                        .frame(width: 10, height: 10)
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
            .frame(width: 12, height: 12)
            
            Text("\(calendar.component(.day, from: date))")
                .foregroundColor(.black)
                .font(.system(size: 8))
        }
    }
}

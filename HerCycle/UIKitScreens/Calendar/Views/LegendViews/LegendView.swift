//
//  LegendView.swift
//  HerCycle
//
//  Created by Ana on 7/24/24.
//

import SwiftUI

struct LegendView: View {
    let pmsColor: Color
    let periodColor: Color
    let ovulationColor: Color
    
    var body: some View {
        HStack(spacing: 20) {
            LegendItem(color: pmsColor, label: "PMS")
            LegendItem(color: periodColor, label: "Period")
            LegendItem(color: ovulationColor, label: "Ovulation")
        }
        .font(.caption)
        .padding(.top, 8)
    }
}

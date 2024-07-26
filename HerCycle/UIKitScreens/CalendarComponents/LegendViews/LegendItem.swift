//
//  LegendItem.swift
//  HerCycle
//
//  Created by Ana on 7/24/24.
//

import SwiftUI

struct LegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 20, height: 20)
            Text(label)
        }
    }
}

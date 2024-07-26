//
//  DashedCircle.swift
//  HerCycle
//
//  Created by Ana on 7/24/24.
//

import SwiftUI

struct DashedCircle: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let numberOfDashes: CGFloat = 16
        
        var path = Path()
        
        for i in 0..<Int(numberOfDashes) {
            let angle = (CGFloat(i) / numberOfDashes) * 2 * .pi
            _ = 2 * .pi * radius / (2 * numberOfDashes)
            
            let startPoint = CGPoint(
                x: center.x + radius * cos(angle),
                y: center.y + radius * sin(angle)
            )
            let endPoint = CGPoint(
                x: center.x + radius * cos(angle + (.pi / numberOfDashes)),
                y: center.y + radius * sin(angle + (.pi / numberOfDashes))
            )
            
            path.move(to: startPoint)
            path.addLine(to: endPoint)
        }
        
        return path
    }
}

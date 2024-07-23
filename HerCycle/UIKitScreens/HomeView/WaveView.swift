//
//  WaveView.swift
//  HerCycle
//
//  Created by Ana on 7/23/24.
//

import UIKit

class WaveView: UIView {
    private var waveLayer: CAShapeLayer!
    private var displayLink: CADisplayLink?
    private var startTime: CFTimeInterval?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        waveLayer = CAShapeLayer()
        waveLayer.fillColor = UIColor.red.withAlphaComponent(0.3).cgColor
        layer.addSublayer(waveLayer)
        
        displayLink = CADisplayLink(target: self, selector: #selector(updateWave))
        displayLink?.add(to: .current, forMode: .common)
    }
    
    @objc private func updateWave() {
        if startTime == nil {
            startTime = CACurrentMediaTime()
        }
        
        let elapsed = CACurrentMediaTime() - startTime!
        let phase = CGFloat(elapsed) * 2
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: bounds.height))
        
        for x in stride(from: 0, to: bounds.width, by: 1) {
            let relativeX = x / bounds.width
            let sine = sin(relativeX * 4 * .pi + phase)
            let y = bounds.height * 0.5 + sine * 10
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
        path.close()
        
        waveLayer.path = path.cgPath
    }
}


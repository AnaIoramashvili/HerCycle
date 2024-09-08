//
//  HomeViewModel.swift
//  HerCycle
//
//  Created by Ana on 7/26/24.
//

import UIKit

final class HomeViewModel {
    
    private let calendar = Calendar.current
    
    func generateDates() -> [Date] {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        let currentYear = calendar.component(.year, from: Date())
        
        var dates: [Date] = []
        
        guard let startOfMonth = calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: 1)) else { return [] }
        guard let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else { return [] }
        
        var date = startOfMonth
        while date <= endOfMonth {
            dates.append(date)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: date) else { break }
            date = nextDate
        }
        
        return dates
    }
    
    func getUpdatedMarkedDays(userData: UserData?) -> [Date: CyclePhase] {
        
        guard let userData else { return [:] }
        
        let cycleLength = userData.cycleLength
        let periodLength = userData.periodLength
        let lastPeriodStartDate = userData.lastPeriodStartDate
        
        var markedDays: [Date: CyclePhase] = [:]
        
        let nextPeriodStartDate = calendar.date(byAdding: .day, value: cycleLength, to: lastPeriodStartDate)!
        
        for day in 0..<periodLength {
            if let date = calendar.date(byAdding: .day, value: day, to: lastPeriodStartDate) {
                let components = calendar.dateComponents([.year, .month, .day], from: date)
                let normalizedDate = calendar.date(from: components)!
                markedDays[normalizedDate] = .period
            }
        }
        
        for day in 1...5 {
            if let pmsDate = calendar.date(byAdding: .day, value: -day, to: lastPeriodStartDate) {
                let components = calendar.dateComponents([.year, .month, .day], from: pmsDate)
                let normalizedDate = calendar.date(from: components)!
                markedDays[normalizedDate] = .pms
            }
        }
        
        for day in 1...5 {
            if let pmsDate = calendar.date(byAdding: .day, value: -day, to: nextPeriodStartDate) {
                let components = calendar.dateComponents([.year, .month, .day], from: pmsDate)
                let normalizedDate = calendar.date(from: components)!
                markedDays[normalizedDate] = .pms
            }
        }
        
        if let ovulationDate = calendar.date(byAdding: .day, value: -14, to: nextPeriodStartDate) {
            let components = calendar.dateComponents([.year, .month, .day], from: ovulationDate)
            let normalizedDate = calendar.date(from: components)!
            markedDays[normalizedDate] = .ovulation
        }
        
        return markedDays
    }
    
    func getCalculatedCycleInfo(userData: UserData?) -> (Int, CGFloat) {
        guard let userData else { return (0, 0) }
        
        let cycleLength = userData.cycleLength
        let lastPeriodStartDate = userData.lastPeriodStartDate
        
        let nextPeriodStartDate = calendar.date(byAdding: .day, value: cycleLength, to: lastPeriodStartDate)!
        
        let today = Date()
        
        let daysUntilNextPeriod = max(0, calendar.dateComponents([.day], from: today, to: nextPeriodStartDate).day ?? 0)
        
        let daysSinceLastPeriod = calendar.dateComponents([.day], from: lastPeriodStartDate, to: today).day ?? 0
        let cycleProgress = min(1, max(0, CGFloat(daysSinceLastPeriod) / CGFloat(cycleLength)))
        
        return (daysUntilNextPeriod, cycleProgress)
    }
    
    func getUpdatedColors(userData: UserData?, days: Int) -> (CGColor, CGColor) {
        guard let userData else { return (UIColor.clear.cgColor, UIColor.clear.cgColor) }
        
        let cycleLength = userData.cycleLength
        let percentageOfCycle = Double(cycleLength - days) / Double(cycleLength)
        let startColor: UIColor
        let endColor: UIColor
        
        switch percentageOfCycle {
        case 0.9...1.0:  // Last 10% of cycle
            startColor = UIColor(named: "gradLightRed")!
            endColor = .tertiaryPink
        case 0.75..<0.9:  // 75-90% of cycle
            startColor = .tertiaryPink
            endColor = UIColor(named: "gradLightPurple")!
        case 0.5..<0.75:
            startColor = UIColor(named: "primaryPink")!
            endColor = UIColor(named: "primaryPink")!
        default:  // First half of cycle
            startColor = .circleDefaultGrad
            endColor = .primaryPink
        }
        
        return (startColor.cgColor, endColor.cgColor)
    }
    
    func createPulsatingAnimation() -> CABasicAnimation {
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.duration = 1.0
        pulseAnimation.fromValue = 0.98
        pulseAnimation.toValue = 1.02
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        return pulseAnimation
    }
}

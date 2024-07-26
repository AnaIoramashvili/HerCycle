//
//  CalendarView.swift
//  HerCycle
//
//  Created by Ana on 7/15/24.
//

import SwiftUI

enum CyclePhase {
    case pms, period, ovulation
}

struct CalendarView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var themeManager = ThemeManager.shared
    @State private var selectedDate: Date = Date()
    @State private var isMonthlyView: Bool = true
    @State private var markedDays: [Date: CyclePhase] = [:]
    @State private var transitionId = UUID()

    
    private let calendar = Calendar.current
    
    private let pmsColor = Color.blue.opacity(0.4)
    private let periodColor = Color(UIColor.systemRed).opacity(0.7)
    private let ovulationColor = Color.yellow
    
    var body: some View {
        NavigationStack {
            ZStack {
                if let theme = themeManager.currentTheme {
                    Image(theme.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .edgesIgnoringSafeArea(.all)
                } else {
                    Color("background")
                        .ignoresSafeArea(.all)
                }
                
                VStack(spacing: 16) {
                    HStack {
                        Text(currentDateString())
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    Text("Calendar")
                        .font(.headline)
                    
                    Picker("View", selection: $isMonthlyView) {
                        Text("Monthly").tag(true)
                        Text("Yearly").tag(false)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 200)
                    
                    if isMonthlyView {
                        MonthlyView(selectedDate: $selectedDate, markedDays: markedDays, pmsColor: pmsColor, periodColor: periodColor, ovulationColor: ovulationColor)
                        
                        LegendView(pmsColor: pmsColor, periodColor: periodColor, ovulationColor: ovulationColor)
                    } else {
                        YearlyView(selectedDate: $selectedDate, markedDays: markedDays, pmsColor: pmsColor, periodColor: periodColor, ovulationColor: ovulationColor, lastPeriodStartDate: authViewModel.userData?.lastPeriodStartDate ?? Date())
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
        .onAppear(perform: loadUserData)

    }
    
    private func currentDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: Date())
    }
    
    private func loadUserData() {
        guard let userData = authViewModel.userData else { return }
        updateMarkedDays(using: userData)
    }
    
    private func updateMarkedDays(using userData: UserData) {
        let cycleLength = userData.cycleLength
        let periodLength = userData.periodLength
        let lastPeriodStartDate = userData.lastPeriodStartDate
        
        markedDays.removeAll()
        
        var currentPeriodStart = lastPeriodStartDate
        let endDate = calendar.date(byAdding: .year, value: 2, to: Date())!
        
        while currentPeriodStart <= endDate {
            for day in 0..<periodLength {
                if let date = calendar.date(byAdding: .day, value: day, to: currentPeriodStart) {
                    let components = calendar.dateComponents([.year, .month, .day], from: date)
                    let normalizedDate = calendar.date(from: components)!
                    markedDays[normalizedDate] = .period
                }
            }
            
            if let ovulationDate = calendar.date(byAdding: .day, value: cycleLength - 14, to: currentPeriodStart) {
                let components = calendar.dateComponents([.year, .month, .day], from: ovulationDate)
                let normalizedDate = calendar.date(from: components)!
                markedDays[normalizedDate] = .ovulation
            }
            
            for day in 1...5 {
                if let pmsDate = calendar.date(byAdding: .day, value: -day, to: currentPeriodStart) {
                    let components = calendar.dateComponents([.year, .month, .day], from: pmsDate)
                    let normalizedDate = calendar.date(from: components)!
                    markedDays[normalizedDate] = .pms
                }
            }
            
            currentPeriodStart = calendar.date(byAdding: .day, value: cycleLength, to: currentPeriodStart)!
        }
    }
}

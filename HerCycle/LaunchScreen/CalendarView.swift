//
//  CalendarView.swift
//  HerCycle
//
//  Created by Ana on 7/15/24.
//

import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
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
                Color("background")
                    .ignoresSafeArea(.all)
                
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

struct MonthlyView: View {
    @Binding var selectedDate: Date
    let markedDays: [Date: CyclePhase]
    let pmsColor: Color
    let periodColor: Color
    let ovulationColor: Color
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 8)
                
                Text(monthYearString(from: selectedDate))
                    .font(.title3)
                    .fontWeight(.medium)
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding(.leading, 8)
            }
            
            HStack {
                ForEach(calendar.veryShortWeekdaySymbols, id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.gray)
                }
            }
            .padding(.top, 8)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(daysInMonth(), id: \.self) { date in
                    if let date = date {
                        DayView(date: date, cyclePhase: markedDays[date], pmsColor: pmsColor, periodColor: periodColor, ovulationColor: ovulationColor)
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
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func daysInMonth() -> [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: selectedDate) else { return [] }
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate))!
        
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let leadingSpaces = (firstWeekday - calendar.firstWeekday + 7) % 7
        
        var days: [Date?] = Array(repeating: nil, count: leadingSpaces)
        
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        
        let totalDays = 42 
        if days.count < totalDays {
            days += Array(repeating: nil as Date?, count: totalDays - days.count)
        }
        
        return days
    }
    
    private func previousMonth() {
        selectedDate = calendar.date(byAdding: .month, value: -1, to: selectedDate)!
    }
    
    private func nextMonth() {
        selectedDate = calendar.date(byAdding: .month, value: 1, to: selectedDate)!
    }
}

struct YearlyView: View {
    @Binding var selectedDate: Date
    let markedDays: [Date: CyclePhase]
    let pmsColor: Color
    let periodColor: Color
    let ovulationColor: Color
    let lastPeriodStartDate: Date
    
    private let calendar = Calendar.current
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(0..<2, id: \.self) { yearOffset in
                    let yearDate = calendar.date(byAdding: .year, value: yearOffset, to: lastPeriodStartDate)!
                    VStack(alignment: .leading, spacing: 10) {
                        Text(String(calendar.component(.year, from: yearDate)))
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            ForEach(0..<12, id: \.self) { monthOffset in
                                let date = calendar.date(byAdding: .month, value: monthOffset, to: calendar.date(from: DateComponents(year: calendar.component(.year, from: yearDate), month: 1, day: 1))!)!
                                if calendar.compare(date, to: lastPeriodStartDate, toGranularity: .month) != .orderedAscending &&
                                   calendar.compare(date, to: calendar.date(byAdding: .year, value: 2, to: lastPeriodStartDate)!, toGranularity: .month) == .orderedAscending {
                                    MiniMonthView(date: date, markedDays: markedDays, pmsColor: pmsColor, periodColor: periodColor, ovulationColor: ovulationColor)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .adjustScrollContentInsetForTabBar()
        .background(Color("background"))
    }
}

struct AdjustScrollContentInsetModifier: ViewModifier {
    @State private var tabBarHeight: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                tabBarHeight = getTabBarHeight()
            }
            .padding(.bottom, tabBarHeight)
    }
    
    private func getTabBarHeight() -> CGFloat {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        
        let bottomPadding = window?.safeAreaInsets.bottom ?? 0
        return bottomPadding + 35
    }
}

extension ScrollView {
    func adjustScrollContentInsetForTabBar() -> some View {
        self.modifier(AdjustScrollContentInsetModifier())
    }
}

struct MiniMonthView: View {
    let date: Date
    let markedDays: [Date: CyclePhase]
    let pmsColor: Color
    let periodColor: Color
    let ovulationColor: Color
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(monthString(from: date))
                .font(.caption)
                .fontWeight(.medium)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 2) {
                ForEach(daysInMonth(), id: \.self) { date in
                    if let date = date {
                        MiniDayView(date: date, cyclePhase: markedDays[date], pmsColor: pmsColor, periodColor: periodColor, ovulationColor: ovulationColor)
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
    
    private func monthString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: date)
    }
    
    private func daysInMonth() -> [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: date) else { return [] }
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let leadingSpaces = (firstWeekday - calendar.firstWeekday + 7) % 7
        
        var days: [Date?] = Array(repeating: nil, count: leadingSpaces)
        
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        
        let totalDays = 42 
        if days.count < totalDays {
            days += Array(repeating: nil as Date?, count: totalDays - days.count)
        }
        
        return days
    }
}

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

enum CyclePhase {
    case pms, period, ovulation
}

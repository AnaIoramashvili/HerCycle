//
//  YearlyView.swift
//  HerCycle
//
//  Created by Ana on 7/24/24.
//

import SwiftUI

struct YearlyView: View {
    @ObservedObject var viewModel: CalendarViewModel
    
    private let calendar = Calendar.current
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(0..<2, id: \.self) { yearOffset in
                    let yearDate = calendar.date(byAdding: .year, value: yearOffset, to: viewModel.lastPeriodStartDate)!
                    VStack(alignment: .leading, spacing: 10) {
                        Text(String(calendar.component(.year, from: yearDate)))
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            ForEach(0..<12, id: \.self) { monthOffset in
                                let date = calendar.date(byAdding: .month, value: monthOffset, to: calendar.date(from: DateComponents(year: calendar.component(.year, from: yearDate), month: 1, day: 1))!)!
                                if calendar.compare(date, to: viewModel.lastPeriodStartDate, toGranularity: .month) != .orderedAscending &&
                                   calendar.compare(date, to: calendar.date(byAdding: .year, value: 2, to: viewModel.lastPeriodStartDate)!, toGranularity: .month) == .orderedAscending {
                                    MiniMonthView(viewModel: viewModel, date: date)
                                        .id("\(yearOffset)-\(monthOffset)")
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .adjustScrollContentInsetForTabBar()
        .background(Color("mainBackgroundColor"))
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

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
    @StateObject private var viewModel: CalendarViewModel
    @StateObject private var themeManager = ThemeManager.shared
    
    init(authViewModel: AuthViewModel) {
        _viewModel = StateObject(wrappedValue: CalendarViewModel(authViewModel: authViewModel))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if let theme = themeManager.currentTheme {
                    Image(theme.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .edgesIgnoringSafeArea(.all)
                } else {
                    Color("mainBackgroundColor")
                        .ignoresSafeArea(.all)
                }
                
                VStack(spacing: 16) {
                    HStack {
                        Text(viewModel.currentDateString())
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    Text("Calendar")
                        .font(.headline)
                    
                    Picker("View", selection: $viewModel.isMonthlyView) {
                        Text("Monthly").tag(true)
                        Text("Yearly").tag(false)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 200)
                    
                    if viewModel.isMonthlyView {
                        MonthlyView(viewModel: viewModel)
                        
                        LegendView(pmsColor: viewModel.pmsColor, periodColor: viewModel.periodColor, ovulationColor: viewModel.ovulationColor)
                    } else {
                        YearlyView(viewModel: viewModel)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
        .onAppear(perform: viewModel.loadUserData)
    }
}

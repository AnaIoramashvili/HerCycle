//
//  QuestionPage3.swift
//  HerCycle
//
//  Created by Ana on 7/12/24.
//

import SwiftUI

struct QuestionPage3: View {
    @State private var lastPeriodStartDate: Date = Date()
    @State private var navigateToMainTabBar = false
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var coordinator: AppCoordinator

    var body: some View {
        ZStack {
            Color.background
                .edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                
                Image("Calendar")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .padding(.top, 20)
                
                Text("When did your previous menses begin?")
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding()
                
                DatePicker(
                    "",
                    selection: $lastPeriodStartDate,
                    displayedComponents: .date
                )
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .padding(.horizontal)
                
                Spacer()
                
                Button(action: {
                    saveLastPeriodStartDate(lastPeriodStartDate)
                    navigateToMainTabBar = true
                }) {
                    Text("Continue")
                        .bold()
                        .frame(width: 200, height: 50)
                        .background(Color.color1)
                        .foregroundColor(.white)
                        .cornerRadius(25)
                        .padding(.horizontal, 40)
                }
                .padding(.bottom, 30)
            }
            .padding()
        }
        .onChange(of: navigateToMainTabBar) { _, newValue in
            if newValue {
                Task {
                    await coordinator.userDidCompleteQuestions()
                }
            }
        }
    }

    func saveLastPeriodStartDate(_ date: Date) {
        Task {
            var userData = viewModel.userData ?? UserData(cycleLength: 0, periodLength: 0, lastPeriodStartDate: Date())
            userData.lastPeriodStartDate = date
            try? await viewModel.saveUserData(userData)
            await viewModel.fetchUserData()
        }
    }
}

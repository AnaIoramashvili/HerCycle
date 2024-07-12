//
//  QuestionPage3.swift
//  HerCycle
//
//  Created by Ana on 7/12/24.
//

import SwiftUI

struct QuestionPage3: View {
    @State private var lastPeriodStartDate: Date = Date()
    @State private var navigateToCalendar = false
    @EnvironmentObject var viewModel: AuthViewModel


    var body: some View {
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
                // Save data and navigate to calendar
                saveLastPeriodStartDate(lastPeriodStartDate)
                navigateToCalendar = true
            }) {
                Text("Continue")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.pink)
                    .foregroundColor(.white)
                    .cornerRadius(25)
                    .padding(.horizontal, 40)
            }
            .padding(.bottom, 30)

            .navigationDestination(isPresented: $navigateToCalendar) {
                ContentView()
            }
        }
        .padding()
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

struct QuestionPage3_Previews: PreviewProvider {
    static var previews: some View {
        QuestionPage3()
    }
}


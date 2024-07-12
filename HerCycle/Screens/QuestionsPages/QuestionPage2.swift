//
//  QuestionPage2.swift
//  HerCycle
//
//  Created by Ana on 7/12/24.
//

import SwiftUI

struct QuestionPage2: View {
    @State private var periodLength: Int? = nil
    @State private var navigateToNextPage = false
    @EnvironmentObject var viewModel: AuthViewModel


    var body: some View {
        VStack {
            Image("Woman2")
                .resizable()
                .scaledToFit()
                .frame(height: 250)

            Text("How long does your period last on average?")
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding()

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(1...10, id: \.self) { day in
                        Circle()
                            .fill(day == periodLength ? Color.pink : Color.color3)
                            .frame(width: 60, height: 60)
                            .overlay(Text("\(day)").foregroundColor(.white).font(.headline))
                            .onTapGesture {
                                periodLength = day
                            }
                    }
                }
                .padding()
            }
            
            HStack {
                Text("days")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
            }

            Button(action: {
                // Save data and navigate to next question page
                if let periodLength = periodLength {
                    savePeriodLength(periodLength)
                    navigateToNextPage = true
                }
            }) {
                Text("Continue")
                    .bold()
                    .frame(width: 200, height: 50)
                    .background(Color.pink)
                    .foregroundColor(.white)
                    .cornerRadius(25)
            }
            .padding()
            .disabled(periodLength == nil)

            .navigationDestination(isPresented: $navigateToNextPage) {
                QuestionPage3()
            }
        }
        .padding()
    }

    func savePeriodLength(_ length: Int) {
        Task {
            var userData = viewModel.userData ?? UserData(cycleLength: 0, periodLength: 0, lastPeriodStartDate: Date())
            userData.periodLength = length
            try? await viewModel.saveUserData(userData)
            await viewModel.fetchUserData()
        }
    }
}


#Preview {
    QuestionPage2()
}


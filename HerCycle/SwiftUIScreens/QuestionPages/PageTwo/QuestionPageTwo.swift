//
//  QuestionPage2.swift
//  HerCycle
//
//  Created by Ana on 7/12/24.
//

import SwiftUI

struct QuestionPageTwo: View {
    @Binding var path: NavigationPath
    @State private var periodLength: Int? = nil
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var coordinator: AppCoordinator

    var body: some View {
        ZStack {
            Color.mainBackground.edgesIgnoringSafeArea(.all)
            VStack {
                Image("woman2")
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
                                .fill(day == periodLength ? Color.pink : Color("primaryPurple"))
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
                    if let periodLength = periodLength {
                        savePeriodLength(periodLength)
                        path.append("QuestionPage3")
                    }
                }) {
                    Text("Continue")
                        .bold()
                        .frame(width: 200, height: 50)
                        .background(Color("primaryPink"))
                        .foregroundColor(.white)
                        .cornerRadius(25)
                }
                .padding()
                .disabled(periodLength == nil)
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
    }

    private var backButton: some View {
        Button(action: {
            path.removeLast()
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(.white)
                .imageScale(.large)
        }
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

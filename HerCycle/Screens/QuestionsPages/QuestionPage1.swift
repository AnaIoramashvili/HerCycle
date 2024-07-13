//
//  QuestionPage1.swift
//  HerCycle
//
//  Created by Ana on 7/12/24.
//

import SwiftUI

struct QuestionPage1: View {
    @State private var cycleLength: Int? = nil
    @State private var navigateToNextPage = false
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var coordinator: AppCoordinator

    var body: some View {
        NavigationStack {
            ZStack {
                Color.background
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    Image("Woman1")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 250)
                    
                    Text("How many days does your cycle last on average?")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(1...35, id: \.self) { day in
                                Circle()
                                    .fill(day == cycleLength ? Color.pink : Color.color3)
                                    .frame(width: 60, height: 60)
                                    .overlay(Text("\(day)").foregroundColor(.white).font(.headline))
                                    .onTapGesture {
                                        cycleLength = day
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
                        if let cycleLength = cycleLength {
                            saveCycleLength(cycleLength)
                            navigateToNextPage = true
                        }
                    }) {
                        Text("Continue")
                            .bold()
                            .frame(width: 200, height: 50)
                            .background(Color.color1)
                            .foregroundColor(.white)
                            .cornerRadius(25)
                    }
                    .padding()
                    .disabled(cycleLength == nil)
                }
                .padding()
                .navigationDestination(isPresented: $navigateToNextPage) {
                    QuestionPage2().environmentObject(viewModel).environmentObject(coordinator)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    func saveCycleLength(_ length: Int) {
        Task {
            var userData = viewModel.userData ?? UserData(cycleLength: 0, periodLength: 0, lastPeriodStartDate: Date())
            userData.cycleLength = length
            try? await viewModel.saveUserData(userData)
            await viewModel.fetchUserData()
        }
    }
}

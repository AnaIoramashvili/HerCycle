//
//  QuestionPage1.swift
//  HerCycle
//
//  Created by Ana on 7/12/24.
//

import SwiftUI

struct QuestionPage1: View {
    @State private var cycleLength: Int? = nil
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Color.mainBackground.edgesIgnoringSafeArea(.all)
                VStack {
                    Image("woman1")
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
                                    .fill(day == cycleLength ? Color.pink : Color("primaryPurple"))
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
                            path.append("QuestionPage2")
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
                    .disabled(cycleLength == nil)
                }
                .padding()
            }
            .navigationDestination(for: String.self) { page in
                switch page {
                case "QuestionPage2":
                    QuestionPage2(path: $path)
                        .environmentObject(viewModel)
                        .environmentObject(coordinator)
                case "QuestionPage3":
                    QuestionPage3(path: $path)
                        .environmentObject(viewModel)
                        .environmentObject(coordinator)
                default:
                    EmptyView()
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

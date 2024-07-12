//
//  ContentView.swift
//  HerCycle
//
//  Created by Ana on 7/11/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    @State private var hasCompletedQuestions: Bool = false

    var body: some View {
        NavigationStack {
            Group {
                if !hasSeenOnboarding {
                    OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
                } else if viewModel.userSession != nil {
                    if hasCompletedQuestions {
                        TabView {
                            HomeView()
                                .tabItem {
                                    Label("Home", systemImage: "house")
                                }
                            
                            ProfileView()
                                .tabItem {
                                    Label("Profile", systemImage: "person")
                                }
                        }
                        .accentColor(Color.black)
                    } else {
                        QuestionPage1()
                    }
                } else {
                    LoginView()
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchUserData()
                hasCompletedQuestions = viewModel.userData != nil 
            }
        }
    }
}

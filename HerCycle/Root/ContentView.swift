//
//  ContentView.swift
//  HerCycle
//
//  Created by Ana on 7/11/24.
//

//import SwiftUI
//
//struct ContentView: View {
//    @EnvironmentObject var viewModel: AuthViewModel
//    @AppStorage("currentPage") var currentPage = 1
//    
//    var body: some View {
//            if viewModel.userSession != nil {
//                TabView {
//                    HomeView()
//                        .tabItem {
//                            Label("Home", systemImage: "house")
//                        }
//                    
//                    ProfileView()
//                        .tabItem {
//                            Label("Profile", systemImage: "person")
//                        }
//                }
//                .accentColor(Color.black)
//            } else {
//                LoginView()
//        }
//    }
//         
//}


import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false

    var body: some View {
        Group {
            if !hasSeenOnboarding {
                OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
            } else if viewModel.userSession != nil {
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
                LoginView()
            }
        }
    }
}

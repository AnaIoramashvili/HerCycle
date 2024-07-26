//
//  OnboardingView.swift
//  HerCycle
//
//  Created by Ana on 7/11/24.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @Binding var hasSeenOnboarding: Bool
    
    var body: some View {
        ZStack {
            GradientBackground()
            
            VStack {
                NavigationControls(currentPage: $viewModel.currentPage)
                
                TabView(selection: $viewModel.currentPage) {
                    ForEach(0..<viewModel.pages.count, id: \.self) { index in
                        PageView(page: viewModel.pages[index])
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                NavigationButtons(viewModel: viewModel, hasSeenOnboarding: $hasSeenOnboarding)
                    .padding(.bottom, 50)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .fullScreenCover(isPresented: $viewModel.showLoginView) {
            LoginView()
        }
    }
}

struct NavigationControls: View {
    @Binding var currentPage: Int
    
    var body: some View {
        HStack {
            if currentPage > 0 {
                BackButton(currentPage: $currentPage)
            }
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 50)
    }
}

struct BackButton: View {
    @Binding var currentPage: Int
    
    var body: some View {
        Button(action: {
            if currentPage > 0 {
                currentPage -= 1
            }
        }) {
            Text("Back")
                .foregroundColor(.white)
        }
    }
}

struct NavigationButtons: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var hasSeenOnboarding: Bool
    
    var body: some View {
        VStack {
            PageControl(currentPage: $viewModel.currentPage, pageCount: viewModel.pages.count)
            
            if viewModel.isLastPage {
                GetStartedButton(viewModel: viewModel, hasSeenOnboarding: $hasSeenOnboarding)
            } else {
                ContinueButton(currentPage: $viewModel.currentPage)
            }
        }
    }
}

struct PageControl: View {
    @Binding var currentPage: Int
    let pageCount: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<pageCount, id: \.self) { index in
                Circle()
                    .fill(currentPage == index ? Color.white : Color.white.opacity(0.5))
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.bottom)
    }
}

struct ContinueButton: View {
    @Binding var currentPage: Int
    
    var body: some View {
        Button(action: {
            currentPage += 1
        }) {
            Text("Continue")
                .foregroundColor(.pink)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .cornerRadius(25)
        }
        .padding(.horizontal)
    }
}

struct GetStartedButton: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var hasSeenOnboarding: Bool
    
    var body: some View {
        Button(action: { viewModel.getStarted(hasSeenOnboarding: $hasSeenOnboarding) }) {
            Text("Get started")
                .foregroundColor(.pink)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .cornerRadius(25)
        }
        .padding(.horizontal)
    }
}

struct PageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack {
            if !page.imageName.isEmpty {
                VStack(spacing: 20) {
                    Image(page.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                    
                    Text(page.title)
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                    
                    Text(page.subtitle)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                }
                .padding()
            } else {
                VStack(alignment: .leading, spacing: 20) {
                    Spacer()
                    Spacer()
                    
                    Text(page.title)
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                    
                    Text(page.subtitle)
                        .font(.title3)
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

struct GradientBackground: View {
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [.white, Color("primaryPink"), Color("secondaryPink"), Color("primaryPurple")]),
                       startPoint: .top,
                       endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)
    }
}



#Preview {
    OnboardingView(hasSeenOnboarding: .constant(false))
}

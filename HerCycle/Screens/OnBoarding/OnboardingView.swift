//
//  OnboardingView.swift
//  HerCycle
//
//  Created by Ana on 7/11/24.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var showLoginView = false
    @Binding var hasSeenOnboarding: Bool
    
    let pages = [
        OnboardingPage(title: "Accurate Predictions", subtitle: "Our expert-backed algorithms bring you accurate menstrual cycle predictions.", imageName: "Period1"),
        OnboardingPage(title: "Cycle Harmony", subtitle: "Based on your inputs and data, you'll have guidance and knowledge relevant to your unique patterns.", imageName: "Period2"),
        OnboardingPage(title: "Keep track of your period", subtitle: "Easily and accurately track each phase of your menstrual cycle.", imageName: "")
    ]
    
    var body: some View {
        ZStack {
            gradientBackground
            
            VStack {
                HStack {
                    if currentPage > 0 {
                        backButton
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 50)
                
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        pageView(for: pages[index])
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                VStack {
                    pageControl
                    
                    if currentPage == pages.count - 1 {
                        getStartedButton
                    } else {
                        continueButton
                    }
                }
                .padding(.bottom, 50)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .fullScreenCover(isPresented: $showLoginView) {
            LoginView()
        }
    }
    
    var gradientBackground: some View {
        LinearGradient(gradient: Gradient(colors: [.white, Color("Color1"), Color("Color2"), Color("Color3")]),
                       startPoint: .top,
                       endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)
    }
    
    func pageView(for page: OnboardingPage) -> some View {
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
    
    var backButton: some View {
        Button(action: {
            if currentPage > 0 {
                currentPage -= 1
            }
        }) {
            Text("Back")
                .foregroundColor(.white)
        }
    }
    
    var pageControl: some View {
        HStack(spacing: 8) {
            ForEach(0..<pages.count, id: \.self) { index in
                Circle()
                    .fill(currentPage == index ? Color.white : Color.white.opacity(0.5))
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.bottom)
    }
    
    var continueButton: some View {
        Button(action: {
            if currentPage < pages.count - 1 {
                currentPage += 1
            }
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
    
    var getStartedButton: some View {
        Button(action: {
            hasSeenOnboarding = true
            showLoginView = true
        }) {
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

struct OnboardingPage {
    let title: String
    let subtitle: String
    let imageName: String
}

#Preview {
    OnboardingView(hasSeenOnboarding: .constant(false))
}

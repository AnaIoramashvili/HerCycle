//
//  OnboardingViewModel.swift
//  HerCycle
//
//  Created by Ana on 7/26/24.
//

import SwiftUI

class OnboardingViewModel: ObservableObject {
    @Published var currentPage = 0
    @Published var showLoginView = false
    
    private let model = OnboardingModel()
    
    var pages: [OnboardingPage] {
        model.pages
    }
    
    var isLastPage: Bool {
        currentPage == pages.count - 1
    }
    
    func nextPage() {
        if currentPage < pages.count - 1 {
            currentPage += 1
        }
    }
    
    func previousPage() {
        if currentPage > 0 {
            currentPage -= 1
        }
    }
    
    func getStarted(hasSeenOnboarding: Binding<Bool>) {
        hasSeenOnboarding.wrappedValue = true
        showLoginView = true
    }
}

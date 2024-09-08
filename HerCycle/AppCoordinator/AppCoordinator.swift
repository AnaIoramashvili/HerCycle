//
//  AppCoordinator.swift
//  HerCycle
//
//  Created by Ana on 7/13/24.
//

import UIKit
import SwiftUI

@MainActor
class AppCoordinator: ObservableObject {
    private let window: UIWindow
    let authViewModel: AuthViewModel
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    
    init(window: UIWindow) {
        self.window = window
        self.authViewModel = AuthViewModel()
    }
    
    func start() async {
        if !hasSeenOnboarding {
            await showOnboarding()
        } else if await authViewModel.checkSession() {
            if await hasCompletedQuestions() {
                await showMainTabBar()
            } else {
                await showQuestions()
            }
        } else {
            await showLogin()
        }
    }
    
    private func showOnboarding() async {
        let onboardingViewController = UIHostingController(rootView: OnboardingView(hasSeenOnboarding: $hasSeenOnboarding).environmentObject(authViewModel).environmentObject(self))
        await MainActor.run {
            window.rootViewController = onboardingViewController
        }
    }
    
    private func showLogin() async {
        let loginViewController = UIHostingController(rootView: LoginView().environmentObject(authViewModel).environmentObject(self))
        await MainActor.run {
            window.rootViewController = loginViewController
        }
    }
    
    private func showQuestions() async {
        let questionsView = QuestionPageOne().environmentObject(authViewModel).environmentObject(self)
        let questionsViewController = UIHostingController(rootView: questionsView)
        await MainActor.run {
            window.rootViewController = questionsViewController
        }
    }
    
    private func showMainTabBar() async {
        let tabBarController = MainTabBarController(coordinator: self)
        await MainActor.run {
            window.rootViewController = tabBarController
        }
    }
    
    private func userDidCompleteOnboarding() async {
        hasSeenOnboarding = true
        await showLogin()
    }
    
    private func hasCompletedQuestions() async -> Bool {
        await authViewModel.fetchUserData()
        return authViewModel.userData != nil
    }
    
    func userDidLogin() async {
        if await hasCompletedQuestions() {
            await showMainTabBar()
        } else {
            await showQuestions()
        }
    }
    
    func userDidCompleteQuestions() async {
        await showMainTabBar()
    }
    
    func userDidLogout() async {
        await showLogin()
    }
}

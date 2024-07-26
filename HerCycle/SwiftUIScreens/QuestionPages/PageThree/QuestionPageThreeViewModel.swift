//
//  QuestionPage3ViewModel.swift
//  HerCycle
//
//  Created by Ana on 7/26/24.
//

import SwiftUI

final class QuestionPage3ViewModel: ObservableObject {
    @Published var lastPeriodStartDate = Date()
    @Published var navigateToMainTabBar = false
    @Binding var path: NavigationPath
    
    private let authViewModel: AuthViewModel
    private let coordinator: AppCoordinator
    
    init(path: Binding<NavigationPath>, authViewModel: AuthViewModel, coordinator: AppCoordinator) {
        self._path = path
        self.authViewModel = authViewModel
        self.coordinator = coordinator
    }
    
    func saveLastPeriodStartDate() async {
        do {
            var userData = await authViewModel.userData ?? UserData(cycleLength: 0, periodLength: 0, lastPeriodStartDate: Date())
            userData.lastPeriodStartDate = lastPeriodStartDate
            try await authViewModel.saveUserData(userData)
            await authViewModel.fetchUserData()
            navigateToMainTabBar = true
        } catch {
            print("Error saving last period start date: \(error.localizedDescription)")
        }
    }
    
    func goBack() {
        path.removeLast()
    }
    
    func userDidCompleteQuestions() async {
        await coordinator.userDidCompleteQuestions()
    }
}

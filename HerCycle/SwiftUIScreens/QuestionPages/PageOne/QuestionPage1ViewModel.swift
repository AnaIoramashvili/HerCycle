//
//  QuestionPage1ViewModel.swift
//  HerCycle
//
//  Created by Ana on 7/26/24.
//

import SwiftUI

class QuestionPage1ViewModel: ObservableObject {
    @Published var cycleLength: Int?
    @Published var path = NavigationPath()
    
    private let authViewModel: AuthViewModel
    let coordinator: AppCoordinator
    
    init(authViewModel: AuthViewModel, coordinator: AppCoordinator) {
        self.authViewModel = authViewModel
        self.coordinator = coordinator
    }
    
    var isContinueButtonEnabled: Bool {
        cycleLength != nil
    }
    
    func saveCycleLength() async {
        guard let cycleLength = cycleLength else { return }
        
        do {
            var userData = await authViewModel.userData ?? UserData(cycleLength: 0, periodLength: 0, lastPeriodStartDate: Date())
            userData.cycleLength = cycleLength
            try await authViewModel.saveUserData(userData)
            await authViewModel.fetchUserData()
            path.append("QuestionPage2")
        } catch {
            print("Error saving cycle length: \(error.localizedDescription)")
        }
    }
}

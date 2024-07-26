//
//  QuestionPageTwoViewModel.swift
//  HerCycle
//
//  Created by Ana on 7/26/24.
//

import SwiftUI

final class QuestionPageTwoViewModel: ObservableObject {
    @Published var periodLength: Int?
    @Binding var path: NavigationPath
    
    private let authViewModel: AuthViewModel
    private let coordinator: AppCoordinator
    
    var isContinueButtonEnabled: Bool {
        periodLength != nil
    }
    
    init(path: Binding<NavigationPath>, authViewModel: AuthViewModel, coordinator: AppCoordinator) {
        self._path = path
        self.authViewModel = authViewModel
        self.coordinator = coordinator
    }
    
    func savePeriodLength() async {
        guard let periodLength = periodLength else { return }
        
        do {
            var userData = await authViewModel.userData ?? UserData(cycleLength: 0, periodLength: 0, lastPeriodStartDate: Date())
            userData.periodLength = periodLength
            try await authViewModel.saveUserData(userData)
            await authViewModel.fetchUserData()
            path.append("QuestionPage3")
        } catch {
            print("Error saving period length: \(error.localizedDescription)")
        }
    }
    
    func goBack() {
        path.removeLast()
    }
}

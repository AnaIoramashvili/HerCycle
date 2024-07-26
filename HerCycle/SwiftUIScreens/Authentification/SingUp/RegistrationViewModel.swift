//
//  RegistrationViewModel.swift
//  HerCycle
//
//  Created by Ana on 7/26/24.
//

import SwiftUI

final class RegistrationViewModel: ObservableObject {
    @Published var email = ""
    @Published var fullName = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var isRotating = false
    @Published var showAlert = false
    @Published var errorMessage = ""
    
    var authViewModel: AuthViewModel
    var coordinator: AppCoordinator
    
    var formIsValid: Bool {
        isValidEmail(email) &&
        isValidPassword(password) &&
        password == confirmPassword &&
        isValidFullName(fullName)
    }
    
    init(authViewModel: AuthViewModel, coordinator: AppCoordinator) {
        self.authViewModel = authViewModel
        self.coordinator = coordinator
    }
    
    func createUser() async {
        do {
            try await authViewModel.createUser(withEmail: email,
                                               password: password,
                                               fullName: fullName)
            await coordinator.userDidLogin()
        } catch {
            errorMessage = error.localizedDescription
            showAlert = true
        }
    }
    
    func startRotation() {
        withAnimation(Animation.linear(duration: 10).repeatForever(autoreverses: false)) {
            isRotating = true
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = #"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$"#
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = #"^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$"#
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: password)
    }
    
    private func isValidFullName(_ name: String) -> Bool {
        let nameRegex = #"^[a-zA-Z]+(([',. -][a-zA-Z ])?[a-zA-Z]*)*$"#
        let namePredicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        return namePredicate.evaluate(with: name) && name.count >= 2
    }
}

//
//  LoginViewModel.swift
//  HerCycle
//
//  Created by Ana on 7/24/24.
//

import Foundation
import SwiftUI

final class LoginViewModel: ObservableObject, AuthenticationFormProtocol {
    @Published var email = ""
    @Published var password = ""
    @Published var isRotating = false
    @Published var showAlert = false
    @Published var errorMessage = ""
    
    var formIsValid: Bool {
        return isValidEmail(email) && isValidPassword(password)
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
}

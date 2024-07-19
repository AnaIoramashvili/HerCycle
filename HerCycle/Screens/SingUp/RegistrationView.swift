//
//  RegistrationView.swift
//  HerCycle
//
//  Created by Ana on 7/11/24.
//

import SwiftUI

struct RegistrationView: View {
    @State private var email = ""
    @State private var fullName = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var coordinator: AppCoordinator
    
    @State private var isRotating = false
    @State private var showAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.background.edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                    
                    VStack {
                        Image("logo")
                            .resizable()
                            .foregroundColor(.gray)
                            .scaledToFill()
                            .frame(width: 100, height: 150)
                            .rotationEffect(.degrees(isRotating ? 360 : 0))
                            .onAppear {
                                withAnimation(Animation.linear(duration: 10).repeatForever(autoreverses: false)) {
                                    isRotating = true
                                }
                            }
                            .padding(.top, 40)
                        
                        VStack(spacing: 24) {
                            InputView(text: $email,
                                      tittle: "Email Address",
                                      plaseholder: "Enter your email")
                            .autocapitalization(.none)
                            
                            InputView(text: $fullName,
                                      tittle: "Full Name",
                                      plaseholder: "Enter your full name")
                            
                            InputView(text: $password,
                                      tittle: "Password",
                                      plaseholder: "Enter your password",
                                      isSecureField: true)
                            
                            ZStack(alignment: .trailing) {
                                InputView(text: $confirmPassword,
                                          tittle: "Confirm Password",
                                          plaseholder: "Confirm password",
                                          isSecureField: true)
                            }
                        }
                        .padding(.horizontal, 32)
                        .padding(.top, 32)
                        
                        Button(action: {
                            Task {
                                do {
                                    try await viewModel.createUser(withEmail: email,
                                                                   password: password,
                                                                   fullName: fullName)
                                    await coordinator.userDidLogin()
                                } catch {
                                    errorMessage = error.localizedDescription
                                    showAlert = true
                                }
                            }
                        }, label: {
                            Text("SIGN UP")
                                .bold()
                                .frame(width: UIScreen.main.bounds.width - 100, height: 50)
                                .background(Color.pink)
                                .foregroundColor(.white)
                                .cornerRadius(25)
                        })
                        .disabled(!formIsValid)
                        .opacity(formIsValid ? 1.0 : 0.5)
                        .padding(.top, 20)
                        
                        Spacer()
                        
                        Button {
                            dismiss()
                        } label: {
                            HStack(spacing: 3) {
                                Text("Already have an account?")
                                    .foregroundColor(.black)
                                Text("Sign In")
                                    .bold()
                            }
                            .font(.system(size: 15))
                        }
                        .padding(.bottom, 20)
                    }
                    .background(Color.white)
                    .cornerRadius(20)
                    .padding(.horizontal, 16)
                    
                    Spacer()
                }
                .padding()
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }
}

// MARK: - AuthenticationFormProtocol
extension RegistrationView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return isValidEmail(email) &&
               isValidPassword(password) &&
               password == confirmPassword &&
               isValidFullName(fullName)
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

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
            .environmentObject(AuthViewModel())
            .environmentObject(AppCoordinator(window: UIWindow()))
    }
}

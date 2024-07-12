//
//  LoginView.swift
//  HerCycle
//
//  Created by Ana on 7/11/24.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var viewModel: AuthViewModel
    
    @State private var isRotating = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.background.edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                    
                    VStack {
                        Image(.logo)
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
                            
                            InputView(text: $password,
                                      tittle: "Password",
                                      plaseholder: "Enter your password",
                                      isSecureField: true)
                        }
                        .padding(.horizontal, 32)
                        .padding(.top, 32)
                        
                        Button(action: {
                            Task {
                                try await viewModel.signIn(withEmail: email, password: password)
                            }
                        }, label: {
                            Text("LOG IN")
                                .bold()
                                .frame(width: UIScreen.main.bounds.width - 100, height: 50)
                                .background(Color.pink)
                                .foregroundColor(.white)
                                .cornerRadius(25)
                        })
                        .disabled(!formIsValid)
                        .opacity(formIsValid ? 1.0 : 0.5)
                        .padding(.top, 60)
                        
                        Spacer()
                        
                        NavigationLink {
                            RegistrationView()
                                .navigationBarBackButtonHidden()
                        } label: {
                            HStack(spacing: 3) {
                                Text("Don’t have an account?")
                                    .foregroundColor(.black)
                                Text("Sign Up")
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
    }
}

// MARK: - AuthenticationFormProtocol

extension LoginView: AuthenticationFromProtocol {
    var formIsValid: Bool {
        return !email.isEmpty && email.contains("@") && !password.isEmpty && password.count > 5
    }
}

#Preview {
    LoginView()
}

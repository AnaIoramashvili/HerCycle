//
//  RegistrationView.swift
//  HerCycle
//
//  Created by Ana on 7/11/24.
//

import SwiftUI

struct RegistrationView: View {
    @StateObject private var viewModel: RegistrationViewModel
    @Environment(\.dismiss) var dismiss
    
    init(authViewModel: AuthViewModel, coordinator: AppCoordinator) {
        _viewModel = StateObject(wrappedValue: RegistrationViewModel(authViewModel: authViewModel, coordinator: coordinator))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.background.edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                    
                    VStack {
                        logoView
                        inputFieldsView
                        signUpButton
                        Spacer()
                        signInButton
                    }
                    .background(Color.white)
                    .cornerRadius(20)
                    .padding(.horizontal, 16)
                    
                    Spacer()
                }
                .padding()
            }
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("Error"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private var logoView: some View {
        Image("logo")
            .resizable()
            .foregroundColor(.gray)
            .scaledToFill()
            .frame(width: 100, height: 150)
            .rotationEffect(.degrees(viewModel.isRotating ? 360 : 0))
            .onAppear { viewModel.startRotation() }
            .padding(.top, 40)
    }
    
    private var inputFieldsView: some View {
        VStack(spacing: 24) {
            InputView(text: $viewModel.email,
                      tittle: "Email Address",
                      plaseholder: "Enter your email")
                .autocapitalization(.none)
            
            InputView(text: $viewModel.fullName,
                      tittle: "Full Name",
                      plaseholder: "Enter your full name")
            
            InputView(text: $viewModel.password,
                      tittle: "Password",
                      plaseholder: "Enter your password",
                      isSecureField: true)
            
            InputView(text: $viewModel.confirmPassword,
                      tittle: "Confirm Password",
                      plaseholder: "Confirm password",
                      isSecureField: true)
        }
        .padding(.horizontal, 32)
        .padding(.top, 32)
    }
    
    private var signUpButton: some View {
        Button(action: {
            Task { await viewModel.createUser() }
        }, label: {
            Text("SIGN UP")
                .bold()
                .frame(width: UIScreen.main.bounds.width - 100, height: 50)
                .background(Color.pink)
                .foregroundColor(.white)
                .cornerRadius(25)
        })
        .disabled(!viewModel.formIsValid)
        .opacity(viewModel.formIsValid ? 1.0 : 0.5)
        .padding(.top, 20)
    }
    
    private var signInButton: some View {
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
}

#Preview {
    RegistrationView(authViewModel: AuthViewModel(), coordinator: AppCoordinator(window: UIWindow()))
}

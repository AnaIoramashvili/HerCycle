//
//  LoginView.swift
//  HerCycle
//
//  Created by Ana on 7/11/24.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("mainBackground").edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                    
                    VStack {
                        Image("logo")
                            .resizable()
                            .foregroundColor(.gray)
                            .scaledToFill()
                            .frame(width: 100, height: 150)
                            .rotationEffect(.degrees(viewModel.isRotating ? 360 : 0))
                            .onAppear {
                                withAnimation(Animation.linear(duration: 10).repeatForever(autoreverses: false)) {
                                    viewModel.isRotating = true
                                }
                            }
                            .padding(.top, 40)
                        
                        VStack(spacing: 24) {
                            InputView(text: $viewModel.email,
                                      tittle: "Email Address",
                                      plaseholder: "Enter your email")
                            .autocapitalization(.none)
                            
                            InputView(text: $viewModel.password,
                                      tittle: "Password",
                                      plaseholder: "Enter your password",
                                      isSecureField: true)
                        }
                        .padding(.horizontal, 32)
                        .padding(.top, 32)
                        
                        Button(action: {
                            Task {
                                do {
                                    try await authViewModel.signIn(withEmail: viewModel.email, password: viewModel.password)
                                    await coordinator.userDidLogin()
                                } catch {
                                    viewModel.errorMessage = error.localizedDescription
                                    viewModel.showAlert = true
                                }
                            }
                        }, label: {
                            Text("LOG IN")
                                .bold()
                                .frame(width: UIScreen.main.bounds.width - 100, height: 50)
                                .background(Color.pink)
                                .foregroundColor(.white)
                                .cornerRadius(25)
                        })
                        .disabled(!viewModel.formIsValid)
                        .opacity(viewModel.formIsValid ? 1.0 : 0.5)
                        .padding(.top, 60)
                        
                        Spacer()
                        
                        NavigationLink {
                            RegistrationView(authViewModel: authViewModel, coordinator: coordinator)
                                .navigationBarBackButtonHidden()
                        } label: {
                            HStack(spacing: 3) {
                                Text("Don't have an account?")
                                    .foregroundColor(.black)
                                Text("Sign Up")
                                    .bold()
                            }
                            .font(.system(size: 16))
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
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("Error"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
        .environmentObject(AppCoordinator(window: UIWindow()))
}

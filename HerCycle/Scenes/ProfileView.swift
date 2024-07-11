//
//  ProfileView.swift
//  HerCycle
//
//  Created by Ana on 7/11/24.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var currentPassword = ""
    
    var body: some View {
        if let user = viewModel.currentUser {
            List {
                Section {
                    HStack {
                        Text(user.initials)
                            .font(.title)
                            .bold()
                            .foregroundStyle(.white)
                            .frame(width: 70, height: 70)
                            .background(Color(.systemGray3))
                            .clipShape(Circle())
                        VStack(alignment: .leading) {
                            Text(user.fullName)
                                .font(.subheadline)
                                .bold()
                            Text(user.email)
                                .font(.footnote)
                                .foregroundStyle(.gray)
                        }
                    }
                }
                
                Section("General") {
                    HStack {
                        SettingRowView(imageName: "gear",
                                       title: "Version",
                                       tintColor: Color(.systemGray))
                        Spacer()
                        
                        Text("1.0.0")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                    }
                }
                
                Section("Acclount") {
                    Button(action: {
                        viewModel.signOut()
                    }, label: {
                        SettingRowView(imageName: "arrow.left.circle.fill",
                                       title: "Sign Out",
                                       tintColor: .red)
                    })
                    
                    Button(action: {
//                        Task {
//                            do {
//                                try await viewModel.deleteAccount(currentPassword: currentPassword)
//                            } catch {
//                                print("Failed to delete account: \(error.localizedDescription)")
//                            }
//                        }
                        print("sss")
                    }, label: {
                        SettingRowView(imageName: "xmark.circle.fill",
                                       title: "Delite Account",
                                       tintColor: .red)
                    })
                }
            }
        }
    }
}

#Preview {
    ProfileView()
}

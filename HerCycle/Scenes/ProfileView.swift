//
//  ProfileView.swift
//  HerCycle
//
//  Created by Ana on 7/11/24.
//

import SwiftUI
import Firebase

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        if let user = viewModel.currentUser {
            List {
                Section {
                    HStack {
                        Text(user.initials)
                            .font(.title)
                            .bold()
                            .foregroundColor(.white)
                            .frame(width: 70, height: 70)
                            .background(Color(.systemGray3))
                            .clipShape(Circle())
                        VStack(alignment: .leading) {
                            Text(user.fullName)
                                .font(.subheadline)
                                .bold()
                            Text(user.email)
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section("Cycle Information") {
                    if let userData = viewModel.userData {
                        HStack {
                            Text("Cycle Length")
                            Spacer()
                            Text("\(userData.cycleLength) days")
                        }
                        HStack {
                            Text("Period Length")
                            Spacer()
                            Text("\(userData.periodLength) days")
                        }
                        HStack {
                            Text("Last Period Start")
                            Spacer()
                            Text(userData.lastPeriodStartDate, style: .date)
                        }
                    }
                }
                
                Section("Account") {
                    Button(action: {
                        viewModel.signOut()
                    }) {
                        SettingRowView(imageName: "arrow.left.circle.fill",
                                       title: "Sign Out",
                                       tintColor: .red)
                    }
                }
            }
            .onAppear {
                Task {
                    await viewModel.fetchUserData()
                }
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthViewModel())
    }
}


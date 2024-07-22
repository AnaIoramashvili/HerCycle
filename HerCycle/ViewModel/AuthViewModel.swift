//
//  AuthViewModel.swift
//  HerCycle
//
//  Created by Ana on 7/11/24.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

protocol AuthenticationFormProtocol {
    var formIsValid: Bool { get }
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var userData: UserData?

    init() {
        self.userSession = Auth.auth().currentUser
        
        Task {
            await fetchUser()
        }
    }
    
    func checkSession() async -> Bool {
        if userSession == nil {
            self.userSession = Auth.auth().currentUser
        }
        return userSession != nil
    }
    
    func updateUserData(_ newData: UserData) {
        DispatchQueue.main.async {
            self.userData = newData
            self.objectWillChange.send()
        }
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
        } catch {
            print("Failed to sign in user \(error.localizedDescription)")
            throw error
        }
    }
    
    func createUser(withEmail email: String, password: String, fullName: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            let user = User(id: result.user.uid, fullName: fullName, email: email)
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("user").document(user.id).setData(encodedUser)
            await fetchUser()
        } catch {
            print("Failed to create user \(error.localizedDescription)")
            throw error
        }
    }
    
    func signOut() async {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
            self.userData = nil
        } catch {
            print("Failed to sign out: \(error.localizedDescription)")
        }
    }
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let snapshot = try? await Firestore.firestore().collection("user").document(uid).getDocument() else { return }
        self.currentUser = try? snapshot.data(as: User.self)
        
        await fetchUserData()
    }
    
    func saveUserData(_ data: UserData) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { throw NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No authenticated user"]) }
        let encodedData = try Firestore.Encoder().encode(data)
        try await Firestore.firestore().collection("userData").document(uid).setData(encodedData)
        self.userData = data
    }

    func fetchUserData() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let snapshot = try? await Firestore.firestore().collection("userData").document(uid).getDocument() else { return }
        self.userData = try? snapshot.data(as: UserData.self)
    }
}


import FirebaseStorage

extension AuthViewModel {
    
    func uploadProfilePicture(_ image: UIImage) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "ავტორიზებული მომხმარებელი არ არის"])
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            throw NSError(domain: "ImageError", code: 0, userInfo: [NSLocalizedDescriptionKey: "სურათის მონაცემებად გარდაქმნა ვერ მოხერხდა"])
        }
        
        let storageRef = Storage.storage().reference().child("profile_pictures/\(uid).jpg")
        let _ = try await storageRef.putDataAsync(imageData)
        let downloadURL = try await storageRef.downloadURL()
        
        var updatedUserData = self.userData ?? UserData(cycleLength: 0, periodLength: 0, lastPeriodStartDate: Date())
        updatedUserData.profilePictureURL = downloadURL.absoluteString
        
        try await saveUserData(updatedUserData)
        updateUserData(updatedUserData)
        
        
    }
}

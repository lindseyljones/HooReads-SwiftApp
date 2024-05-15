//
//  AuthenticationViewModel.swift
//  HooReads
//
//  Created by Lindsey Jones on 4/8/24.
//

import Foundation
import Firebase
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
final class AuthenticationViewModel: ObservableObject {
    
    var newUser = false 
    
    func signInGoogle() async throws {
        guard let topVC = Utilities.shared.topViewController() else {
            throw URLError(.cannotFindHost)
        }
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
        
        // gidSignInResult.user
        guard let idToken: String = gidSignInResult.user.idToken?.tokenString else {
            throw URLError(.badServerResponse)
        }
        let accessToken: String = gidSignInResult.user.accessToken.tokenString
        
        
        let tokens = GoogleSignInResultModel(idToken: idToken, accessToken: accessToken)
        let authDataResult = try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
        

        let docRef = Firestore.firestore().collection("users").document(authDataResult.uid)
        
        //check if user already has an account before creating a new one
        do {
            let documentSnapshot = try await docRef.getDocument()
            print("here")
            if !documentSnapshot.exists {
                print("user doesn't exist")
                self.newUser = true
                try await UserManager.shared.createNewUser(auth: authDataResult)
            }
        } catch {
            print("Error getting document: \(error)")
        }
           
        print("hii")
        
    }
    
}

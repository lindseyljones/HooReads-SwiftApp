//
//  ContentView.swift
//  HooReads
//
//  Created by Maraki Fanuil on 4/6/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import UIKit
import GoogleSignInSwift
import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift



struct ContentView: View {
    
    @StateObject private var viewModel = AuthenticationViewModel()
    @Binding var showSignInView: Bool
    @Binding var newUser: Bool
    
    
    var body: some View {
        
        VStack {
            Text("Hoo Reads").font(.title)
            
           
            
            GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .light, style: .wide, state: .normal)) {
                Task {
                   
                        do{
                            //try await viewModel.signInGoogle()
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
                                } else {
                                    self.newUser = false
                                }
                            } catch {
                                print("Error getting document: \(error)")
                            }
                        }
                        showSignInView = false
                    
                    }
                }
            }
        }
    }
    
    






//#Preview {
    //ContentView(showSignInView: $showSignInView)
//}

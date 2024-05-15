//
//  SignedInView.swift
//  HooReads
//
//  Created by Lindsey Jones on 4/9/24.
//

import SwiftUI

struct SignedInView: View {
    @State private var showSignInView: Bool = false
    @State private var newUser: Bool = false
    let userManager = UserManager.shared
    @StateObject private var viewModel = AuthenticationViewModel()
    //@State private var showSignInView: Bool = false

    
    var body: some View {
        ZStack{
            if !showSignInView && newUser{
 
                NavigationStack{
                    RegisterView(showSignInView: $showSignInView)
                }
            } else if !showSignInView {
                NavigationStack{
                    LoggedInContentView(showSignInView: $showSignInView)
                }
            }
        }
        .onAppear {
            print("newUser: \(self.showSignInView)")
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            self.showSignInView = authUser == nil
           
            print("newUser: \(viewModel.newUser)")
        }
        .fullScreenCover(isPresented: $showSignInView) {
            NavigationStack {
                ContentView(showSignInView: $showSignInView, newUser: $newUser)
            }
        }
        
    }
    
    private func isFirstTimeLaunch() -> Bool {
        //UserDefaults is used to store small amounts of data persistently across app launches
        //UserDefaults.standard.removeObject(forKey: "isFirstTimeLaunch")
        if UserDefaults.standard.object(forKey: "isFirstTimeLaunch") == nil {
                UserDefaults.standard.set(false, forKey: "isFirstTimeLaunch")
                return true
        } else {
                return false
        }
        
    }
}

struct SignedInView_Previews: PreviewProvider {
    static var previews: some View {
        SignedInView()
    }
}

//
//  HooReadsApp.swift
//  HooReads
//
//  Created by Maraki Fanuil on 4/6/24.
//

import SwiftUI
import Firebase
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

@main
struct HooReadsApp: App {
    @StateObject var viewModel = AuthenticationViewModel()
    // initialize appDelegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    // init() {
        // setupAuthentication()
    // }
    
    
    var body: some Scene {
        WindowGroup {
            SignedInView()
        }
    }
}

// Used to host root of the app
// contains functions that run when app is launched and closed; functions are accessed through appDelegate
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        //print("hi")
        return true
    }
    
}

extension HooReadsApp {
    private func setupAuthentication() {
        FirebaseApp.configure()
    }
}


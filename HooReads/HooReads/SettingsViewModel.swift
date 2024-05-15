//
//  SettingsViewModel.swift
//  HooReads
//
//  Created by Maraki Fanuil on 4/11/24.
//

import Foundation

import SwiftUI

@MainActor
final class SettingsViewModel : ObservableObject {
    func signOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    
    @Published private(set) var user: DBUser? = nil
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
        
        
    }
    
}

//
//  FriendsManager.swift
//  HooReads
//
//  Created by Maraki Fanuil on 4/17/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift


final class FriendsManager: ObservableObject{
    static let shared = FriendsManager()
    init(){}
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        //self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
        
    }
    
    func sendFriendRequest(senderUserId: String, recieverUserId: String)async throws {
        let usersCollection = Firestore.firestore().collection("users")
        
        let doc = try await usersCollection.document(recieverUserId).getDocument().data()
        if let friendRequests = doc!["friend_requests"] as? [String] {
            // check if sender already has a pending request
            if !friendRequests.contains(senderUserId) {
                try await usersCollection.document(recieverUserId).updateData(["friend_requests": FieldValue.arrayUnion([senderUserId])])
                try await usersCollection.document(senderUserId).updateData(["sent_friend_requests": FieldValue.arrayUnion([recieverUserId])])
            }
        }
        
        
    }
    
    func acceptFriendRequest(senderUserId: String, recieverUserId: String)async throws {
        let usersCollection = Firestore.firestore().collection("users")
        

        try await usersCollection.document(recieverUserId).updateData(["friend_requests": FieldValue.arrayRemove([senderUserId])])
        try await usersCollection.document(senderUserId).updateData(["sent_friend_requests": FieldValue.arrayRemove([recieverUserId])])
       
        try await usersCollection.document(senderUserId).updateData(["friends": FieldValue.arrayUnion([recieverUserId])])
        try await usersCollection.document(recieverUserId).updateData(["friends": FieldValue.arrayUnion([senderUserId])])
        
    }
    
    func declineFriendRequest(senderUserId: String, recieverUserId: String)async throws {
        let usersCollection = Firestore.firestore().collection("users")
        
        
        try await usersCollection.document(recieverUserId).updateData(["friend_requests": FieldValue.arrayRemove([senderUserId])])
        try await usersCollection.document(senderUserId).updateData(["sent_friend_requests": FieldValue.arrayRemove([recieverUserId])])
       
    }
    
    func removeFriend(userId1: String, userId2: String) async throws {
        let usersCollection = Firestore.firestore().collection("users")
        
        try await usersCollection.document(userId1).updateData(["friends": FieldValue.arrayRemove([userId2])])
        try await usersCollection.document(userId2).updateData(["friends": FieldValue.arrayRemove([userId1])])
    }
        
}
    

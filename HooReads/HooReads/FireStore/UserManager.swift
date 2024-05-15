//
//  UserManager.swift
//  HooReads
//
//  Created by Maraki Fanuil on 4/11/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct DBUser {
    let userId: String
    let email: String
    let username: String
    let photoUrl: String?
    let path_to_photo: String?
    let data_created: Date?
    var first_name: String
    var last_name: String
    var friends: [String]?
    var friend_requests: [String]?
    var sent_friend_requests: [String]?
    var bio: String?
    var favorite_genres: [String]?
    let bookshelfId: String
    let favoriteId: String
    
}


final class UserManager{
    static let shared = UserManager()

    private init(){}
    
    func createNewUser(auth: AuthDataResultModel) async throws {
        print("creating new user")
        let index = auth.email!.firstIndex(of: "@") ?? String.Index(encodedOffset: 5)
        let username = String(auth.email![..<index] ?? "")
        
        var userData: [String:Any] = [
            "user_id" : auth.uid,
            "data_created" : Timestamp(),
            "email": auth.email,
            "username": username,
            "photo_url": auth.photoUrl,
            "path_to_photo": "",
            "first_name": "",
            "last_name": "",
            "friends": [],
            "friend_requests": [],
            "sent_friend_requests": [],
            "bio": "",
            "favorite_genres": [],
            "bookshelfId": UUID().uuidString,
            "favoriteId": UUID().uuidString,
        ]
       
        try await Firestore.firestore().collection("users").document(auth.uid).setData(userData, merge: false)
        
        do {
            print("create shelves")
            try await BookshelfManager.shared.createNewShelf(name: "Want to Read", user: auth.uid)
            try await BookshelfManager.shared.createNewShelf(name: "Read", user: auth.uid)
            try await BookshelfManager.shared.createNewShelf(name: "Currently Reading", user: auth.uid)
            try await FavoriteManager.shared.createFavs(userId: auth.uid)
            try await CreatorFavoriteManager.shared.createCreatorFavs()
            try await NewReleasesManager.shared.createNewReleases()
            try await AuthorSpotlightManager.shared.createSpotlight()
        } catch {
            print(error)
        }
        
    }
    
    func getUser(userId: String) async throws -> DBUser{
        let snapshot = try await Firestore.firestore().collection("users").document(userId).getDocument()
        
        guard let data = snapshot.data() else {
            throw URLError(.badServerResponse)
        }
        
        let userId = data["user_id"] as? String
        let email = data["email"] as? String
        let username = data["username"] as? String
        let photoUrl = data["photo_url"] as? String
        let path_to_photo = data["path_to_photo"] as? String
        let data_created = data["date_created"] as? Date
        let first_name = data["first_name"] as? String
        let last_name = data["last_name"] as? String
        let friends = data["friends"] as? [String]
        let friend_requests = data["friend_requests"] as? [String]
        let sent_friend_requests = data["sent_friend_requests"] as? [String]
        let bio = data["bio"] as? String
        let favorite_genres = data["favorite_genres"] as? [String]
        let bookshelfId = data["bookshelfId"]
        let favId = data["favoriteId"]

        
        
        
        return DBUser(userId: userId!, email: email!, username: username!, photoUrl: photoUrl, path_to_photo: path_to_photo, data_created: data_created, first_name: first_name!, last_name: last_name!, friends: friends, friend_requests: friend_requests, sent_friend_requests: sent_friend_requests, bio:bio, favorite_genres: favorite_genres, bookshelfId: bookshelfId as! String, favoriteId: favId as! String)
    }
    
    func updateUserInfo(userId: String, first_name: String, last_name: String, bio: String) async throws {
        var userData: [String:Any] = [
            "first_name" : first_name,
            "last_name" : last_name,
            "bio" : bio
        ]
        try await Firestore.firestore().collection("users").document(userId).updateData(userData)
        
    }
    
    func updateFavGenres(userId: String, genres: [String]) async throws {
        var userData: [String:Any] = [
            "favorite_genres" : genres
        ]
        try await Firestore.firestore().collection("users").document(userId).updateData(userData)
        
    }
    
    
}

// FavoriteManager.swift
//  HooReads
//
//  Created by Lindsey Jones on 5/1/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI
import UIKit

struct Favorite {
    let uid: String?
    let favList: [String: String]?
    let date_created: Date?
    let id: String
}

final class FavoriteManager {
    static let shared = FavoriteManager()
    private init() {}
    
    func createFavs(userId: String) async throws {
        let userObj = try await UserManager.shared.getUser(userId: userId)
        print("runs createFavs")
        
        let favorite: [String:Any] = [
            "uid": userId,
            "favList": [:],
            "date_created": Timestamp(),
            "id": userObj.favoriteId
        ]
        
        try await Firestore.firestore().collection("favorites").document(userObj.favoriteId).setData(favorite, merge: false)
    }
    
    func addFav(favId: String, bookId: String, url: String) async throws {
        let snapshot = try await Firestore.firestore().collection("favorites").document(favId).getDocument()
        print("got favorite data")
        guard let data = snapshot.data() else {
            throw URLError(.badServerResponse)
        }
        
        let uid = data["uid"] as? String
        let favList = data["favList"] as? [String:String]
        let date_created = data["date_created"] as? Date
        let id = data["id"] as? String
        
        
        var current_favs = favList
        current_favs![bookId] = url
        print(current_favs)
        
        let favorite: [String:Any] = [
            "uid": uid,
            "favList": current_favs,
            "date_created": date_created,
            "id": id
        ]
        
        try await Firestore.firestore().collection("favorites").document(favId).updateData(favorite)
    }
    
    func deleteFav(favId: String) async throws {
        try await Firestore.firestore().collection("favorites").document(favId).delete()
    }
    
    func getFavs(favId: String) async throws -> Favorite {
        let snapshot = try await Firestore.firestore().collection("favorites").document(favId).getDocument()
        
        guard let data = snapshot.data() else {
            throw URLError(.badServerResponse)
        }
        
        let uid = data["uid"] as? String
        let date_created = data["date_created"] as? Date
        let favList = (data["favList"] as? [String: String])!
        let id = (data["id"] as? String)!
        
        return Favorite(uid: uid, favList: favList, date_created: date_created, id: id)
    }
    
}

//  BookshelfManager.swift
//  HooReads
//
//  Created by Lindsey Jones on 4/16/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI

struct DBbookshelf: Hashable {
    let name: String?
    let data_created: Date?
    let items: [String: String]?
    let id: String?
}

final class BookshelfManager {
    static let shared = BookshelfManager()
    private init(){}

    func createNewShelf(name: String, user: String) async throws {
        let id = UUID().uuidString
        
        var shelfData: [String:Any] = [
            "name" : name,
            "data_created" : Timestamp(),
            "items": [:],
            "id": id
        ]

        let userObj = try await UserManager.shared.getUser(userId: user)
        
        // print("userId: \(userObj.bookshelfId)")
        try await Firestore.firestore().collection("bookshelves").document("\(userObj.bookshelfId)/shelves/\(id)").setData(shelfData, merge: false)

    }

    func getShelf(usershelfId: String, shelfId: String) async throws -> DBbookshelf{
            let snapshot = try await Firestore.firestore().collection("bookshelves/\(usershelfId)/shelves").document(shelfId).getDocument()

        guard let data = snapshot.data() else {
            throw URLError(.badServerResponse)
        }

        let name = data["name"] as? String
        let date_created = data["date_created"] as? Date
        let items = data["items"] as? [String:String]
        let id = data["id"] as? String

        return DBbookshelf(name: name, data_created: date_created, items: items, id: id)
    }
    
    func getShelves(usershelfId: String) async throws -> [DBbookshelf] {
         
            let snapshot = try await Firestore.firestore().collection("bookshelves/\(usershelfId)/shelves").getDocuments()

            var shelves: [DBbookshelf] = []
         
            for document in snapshot.documents {
                let data = try document.data()

                let name = data["name"] as? String
                let date_created = data["date_created"] as? Date
                let items = data["items"] as? [String:String]
                let id = data["id"] as? String

                let dbBKs = DBbookshelf(name: name, data_created: date_created, items: items, id: id)
                shelves.append(dbBKs)
            }
      
            return shelves
        }

    func updateShelf(usershelfId: String, shelfId: String, name: String, items: [String:String] = ["":""]) async throws {
                let shelfData: [String:Any] = [
                    "name" : name,
                    "items": items
                ]
            try await Firestore.firestore().collection("bookshelves/\(usershelfId)/shelves").document(shelfId).updateData(shelfData)
        }

    func deleteShelf(usershelfId: String, shelfId: String) async throws {
            try await Firestore.firestore().collection("bookshelves/\(usershelfId)/shelves").document(shelfId).delete()
        }



}

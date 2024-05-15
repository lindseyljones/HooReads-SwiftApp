//
//  BookActivityManaget.swift
//  HooReads
//
//  Created by Maraki Fanuil on 5/1/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI

struct DBBookReview: Hashable {
    let id: String?
    let title: String?
    let total_rating_sum: Double?
    let avg_rating: Double?
    let num_of_ratings: Int?
    let data_created: Date?
    let reviews: [String:String]?
    let ratings: [String:Double]?
    
}

final class BookReviewManager {
    static let shared = BookReviewManager()
    private init(){}
    
    func createNewBookReview(bookid: String, title: String) async throws {
        let id = UUID().uuidString
        
        var BookReviewData: [String:Any] = [
            "id": bookid,
            "title": title,
            "total_rating_sum" : 0.0,
            "num_of_ratings": 0,
            "avg_rating": 0.0,
            "data_created" : Timestamp(),
            "reviews": [:],
            "ratings": [:],
            
        ]
        
        try await Firestore.firestore().collection("BookReviews").document("\(bookid)").setData(BookReviewData, merge: false)
        
    }
    
    func getBookReview(bookId: String) async throws ->  DBBookReview{
            let snapshot = try await Firestore.firestore().collection("BookReviews").document(bookId).getDocument()

        guard let data = snapshot.data() else {
            throw URLError(.badServerResponse)
        }
       
        let id = data["id"] as? String
        let title = data["title"] as? String
        let avg_rating = data["avg_rating"] as? Double
        let total_rating_sum = data["total_rating_sum"] as? Double
        let num_of_ratings = data["num_of_ratings"] as? Int
        let date_created = data["date_created"] as? Date
        let reviews = data["reviews"] as? [String:String]
        let ratings = data["ratings"] as? [String:Double]
        

        return DBBookReview(id: id, title: title, total_rating_sum: total_rating_sum, avg_rating: avg_rating, num_of_ratings: num_of_ratings, data_created: date_created, reviews: reviews, ratings:ratings)
    }
    
    func addBookReview(id: String){
        
    }
    func updateBookReview(bookId: String, total_rating_sum: Double, num_of_ratings: Int, avg_rating: Double) async throws {
        var bookData: [String:Any] = [
            "avg_rating": avg_rating,
            "total_rating_sum" : total_rating_sum,
            "num_of_ratings": num_of_ratings
        ]
        try await Firestore.firestore().collection("users").document(bookId).updateData(bookData)
    }
    
    func updateBookRating() async throws {
       
    }

    func deleteBookReview() async throws {
       
    }
    
    func deleteBookRating() async throws {
       
    }
    
}

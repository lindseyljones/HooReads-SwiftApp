//
//  AuthorSpotlightManager.swift
//  HooReads
//
//  Created by Lindsey Jones on 5/3/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI
import UIKit


final class AuthorSpotlightManager {
    static let shared = AuthorSpotlightManager()
    private init() {}
    
    func createSpotlight() async throws {
        var book = try await BookAPIManager.shared.getBook(name: "Malibu Rising")
        var BookData: [String:Any] = [
            "id": book.bookId,
            "title" : book.title,
            "authors": book.authors,
            "description" : book.description,
            "pageCount": book.pageCount,
            "averageRating": book.averageRating,
            "ratingsCount": book.ratingsCount,
            "publishedDate": book.publishedDate,
            "imageLinks": book.imageLinks,
        ]
        try await Firestore.firestore().collection("author_spotlight").document(book.bookId).setData(BookData, merge: false)
        var book2 = try await BookAPIManager.shared.getBook(name: "Daisy Jones & The Six")
        var Book2Data: [String:Any] = [
            "id": book2.bookId,
            "title" : book2.title,
            "authors": book2.authors,
            "description" : book2.description,
            "pageCount": book2.pageCount,
            "averageRating": book2.averageRating,
            "ratingsCount": book2.ratingsCount,
            "publishedDate": book2.publishedDate,
            "imageLinks": book2.imageLinks,
        ]
        try await Firestore.firestore().collection("author_spotlight").document(book2.bookId).setData(Book2Data, merge: false)
        var book3 = try await BookAPIManager.shared.getBook(name: "Carrie Soto Is Back")
        var Book3Data: [String:Any] = [
            "id": book3.bookId,
            "title" : book3.title,
            "authors": book3.authors,
            "description" : book3.description,
            "pageCount": book3.pageCount,
            "averageRating": book3.averageRating,
            "ratingsCount": book3.ratingsCount,
            "publishedDate": book3.publishedDate,
            "imageLinks": book3.imageLinks,
        ]
        try await Firestore.firestore().collection("author_spotlight").document(book3.bookId).setData(Book3Data, merge: false)
        var book4 = try await BookAPIManager.shared.getBook(name: "The Seven Husbands of Evelyn Hugo")
        var Book4Data: [String:Any] = [
            "id": book4.bookId,
            "title" : book4.title,
            "authors": book4.authors,
            "description" : book4.description,
            "pageCount": book4.pageCount,
            "averageRating": book4.averageRating,
            "ratingsCount": book4.ratingsCount,
            "publishedDate": book4.publishedDate,
            "imageLinks": book4.imageLinks,
        ]
        try await Firestore.firestore().collection("author_spotlight").document(book4.bookId).setData(Book4Data, merge: false)
        var book5 = try await BookAPIManager.shared.getBook(name: "Maybe in Another Life")
        var Book5Data: [String:Any] = [
            "id": book5.bookId,
            "title" : book5.title,
            "authors": book5.authors,
            "description" : book5.description,
            "pageCount": book5.pageCount,
            "averageRating": book5.averageRating,
            "ratingsCount": book5.ratingsCount,
            "publishedDate": book5.publishedDate,
            "imageLinks": book5.imageLinks,
        ]
        try await Firestore.firestore().collection("author_spotlight").document(book5.bookId).setData(Book5Data, merge: false)
        
        var book6 = try await BookAPIManager.shared.getBook(name: "Forever, Interrupted")
        var Book6Data: [String:Any] = [
            "id": book6.bookId,
            "title" : book6.title,
            "authors": book6.authors,
            "description" : book6.description,
            "pageCount": book6.pageCount,
            "averageRating": book6.averageRating,
            "ratingsCount": book6.ratingsCount,
            "publishedDate": book6.publishedDate,
            "imageLinks": book6.imageLinks,
        ]
        try await Firestore.firestore().collection("author_spotlight").document(book6.bookId).setData(Book6Data, merge: false)
        
    
    }
    
    func getSpotlight() async throws -> [BookAPIManager.Book] {
        print("get creator FAVs")
        let snapshot = try await Firestore.firestore().collection("author_spotlight").getDocuments()
        
        var favorites: [BookAPIManager.Book] = []
     
        for document in snapshot.documents {
            let data = try document.data()

            let bookId = (data["id"] as? String)!
            let title = (data["title"] as? String)!
            let authors = (data["authors"] as? [String])!
            let description = (data["description"] as? String)!
            let pageCount = (data["pageCount"] as? Int)!
            let averageRating = (data["averageRating"] as? Double)!
            let ratingsCount = (data["ratingsCount"] as? Int)!
            let publishedDate = (data["publishedDate"] as? String)!
            let date_created = data["date_created"] as? Date
            let imageLinks = data["imageLinks"] as? [String:String]
            
            print("TITLE: \(title)")
            let little_book = BookAPIManager.Book(bookId: bookId, title: title, authors: authors, description: description, pageCount: pageCount, averageRating: averageRating, ratingsCount: ratingsCount, publishedDate: publishedDate, imageLinks: imageLinks!)

            favorites.append(little_book)
        }
        print("FAVSSSSS: \(favorites)")
        return favorites
    }
    
}

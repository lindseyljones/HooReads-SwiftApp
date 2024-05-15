//
//  BooksAPIManager.swift
//  HooReads
//
//  Created by Maraki Fanuil on 4/9/24.
//

import Foundation
import Alamofire
import FirebaseFirestore
import FirebaseFirestoreSwift

class BookAPIManager {
    
    static let shared = BookAPIManager()
    
    private var apiKey: String?
    private var searchQuery: String
    @Published var books: [Book] = []
    
    
    init(){
        self.apiKey = Bundle.main.object(forInfoDictionaryKey: "GoogleBooksAPIKey") as? String
        self.searchQuery = "harry potter"
        
    }
    
//    private var url: String {
//        guard let apiKey = apiKey else {
//            fatalError("GoogleBooksAPIKey not found in Info.plist")
//        }
//        return "https://www.googleapis.com/books/v1/volumes?q=\(searchQuery)&key=\(apiKey)"
//    }
    
    struct Book: Identifiable, Hashable {
        let id = UUID()
        
        let bookId: String
        var title: String
        var authors: [String]
        var description: String
        var pageCount: Int
        let averageRating: Double
        let ratingsCount: Int
        let publishedDate: String
        let imageLinks: [String:String]
        
    }
    
    func getBook(name: String) async throws -> Book {

        let snapshot = try await Firestore.firestore().collection("Books").whereField("title", isEqualTo: name).getDocuments()

        for document in snapshot.documents {
            let data = try document.data()

            let bookId = (data["bookId"] as? String)!
            let title = (data["title"] as? String)!
            let authors = (data["authors"] as? [String])!
            let description = (data["description"] as? String)!
            let pageCount = (data["pageCount"] as? Int)!
            let averageRating = (data["averageRating"] as? Double)!
            let ratingsCount = (data["ratingsCount"] as? Int)!
            let publishedDate = (data["publishedDate"] as? String)!
            let date_created = data["date_created"] as? Date
            let imageLinks = data["imageLinks"] as? [String:String]


            let little_book = Book(bookId: bookId, title: title, authors: authors, description: description, pageCount: pageCount, averageRating: averageRating, ratingsCount: ratingsCount, publishedDate: publishedDate, imageLinks: imageLinks!)
            return little_book
        }
        return Book(bookId: "", title: "", authors: [], description: "", pageCount: 0, averageRating: 0.0, ratingsCount: 0, publishedDate: "", imageLinks: [:])
    }

    func createBook(bookId: String, title: String, authors: [String], description: String, pageCount: Int, averageRating: Double, ratingsCount: Int, publishedDate: String, imageLinks: [String:String]) async {
        
        var BookData: [String:Any] = [
            "bookId": bookId,
            "title" : title,
            "authors": authors,
            "description" : description,
            "pageCount": pageCount,
            "averageRating": averageRating,
            "ratingsCount": ratingsCount,
            "publishedDate": publishedDate,
            "imageLinks": imageLinks,
        ]

        do {
            try await Firestore.firestore().collection("Books").document("\(bookId)").setData(BookData, merge: false)
        }  catch {
            print("Error trying to create Book: \(error)")
        }
        
    }
    
    func displayBooks(searchQuery: String) {
                let maxResults = 20
                let apikey = "YOUR-API-KEY-HERE"
                var this_url = "https://www.googleapis.com/books/v1/volumes?q=\(searchQuery)&maxResults=\(maxResults)&key=\(apikey)"
                AF.request(this_url).responseJSON { response in
                switch response.result {
                case .success(let value):
                    if let data = response.data {
                        do {
                            guard let parsedResult = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                                print("Could not parse the data as JSON: '\(data)'")
                                return
                            }
                            //print(parsedResult)
                            var book_temp_list : [Book] = []
                            if let items = parsedResult["items"] as? [[String: Any]] {
                                for item in items {
                                    let temp_vol = item["volumeInfo"] as? [String: Any]
                                    
                                    if let volumeInfo = item["volumeInfo"] as? [String: Any],
                                       let title = volumeInfo["title"] as? String,
                                       let bookId = item["id"] as? String,
                                       let authors = volumeInfo["authors"] as? [String],
                                       let description = volumeInfo["description"] as? String,
                                       let averageRating = volumeInfo["averageRating"] as? Double,
                                       let ratingsCount = volumeInfo["ratingsCount"] as? Int,
                                       let publishedDate = volumeInfo["publishedDate"] as? String,
                                       let imageLinks = volumeInfo["imageLinks"] as? [String: String],
                                       let pageCount = volumeInfo["pageCount"] as? Int {
                                        
                                        Task {
                                            await self.createBook(bookId: bookId, title: title, authors: authors, description: description, pageCount: pageCount, averageRating: averageRating, ratingsCount: ratingsCount, publishedDate: publishedDate, imageLinks: imageLinks)
                                        }
                                        DispatchQueue.main.async {
                                            let book = Book(bookId: bookId, title: title, authors: authors, description: description, pageCount: pageCount, averageRating: averageRating, ratingsCount: ratingsCount, publishedDate: publishedDate, imageLinks: imageLinks)
                                            //print("BOOK: \(book)")
                                            
                                            book_temp_list.append(book)
                                            self.books = book_temp_list
                                        }
                                    }
                                }
                                
                            } else {
                                print("No items found in the response.")
                           
                            }
                        } catch {
                            print("Error decoding JSON: \(error)")
                        }
                        
                    }
                case .failure(let error):
                    print("Request failed with error: \(error)")
                    
                }
            }.resume()
            
        }
        
    
    func getBookInfo(searchQuery: String) -> [String] {
            let maxResults = 10
            let apikey = "YOUR-API-KEY-HERE"
            var this_url = "https://www.googleapis.com/books/v1/volumes?q=\(searchQuery)&maxResults=\(maxResults)&key=\(apikey)"
            var bookInfo: [String] = []
            AF.request(this_url).responseJSON { response in
            switch response.result {
            case .success(let value):
                
                if let data = response.data {
                    do {
                        guard let parsedResult = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                            print("Could not parse the data as JSON: '\(data)'")
                            return
                        }
                        print(parsedResult)
                        if let items = parsedResult["items"] as? [[String: Any]] {
                            var bookInfoCopy: [String] = []
                            for item in items {
                                let temp_vol = item["volumeInfo"] as? [String: Any]
                                
                                if let volumeInfo = item["volumeInfo"] as? [String: Any],
                                   let title = volumeInfo["title"] as? String,
                                   let bookId = item["id"] as? String,
                                   let authors = volumeInfo["authors"] as? [String],
                                   let description = volumeInfo["description"] as? String,
                                   let averageRating = volumeInfo["averageRating"] as? Double,
                                   let ratingsCount = volumeInfo["ratingsCount"] as? Int,
                                   let publishedDate = volumeInfo["publishedDate"] as? String,
                                   let imageLinks = volumeInfo["imageLinks"] as? [String: String],
                                   let pageCount = volumeInfo["pageCount"] as? Int {
                                    
//                                    Task {
//                                        await self.createBook(bookId: bookId, title: title, authors: authors, description: description, pageCount: pageCount, averageRating: averageRating, ratingsCount: ratingsCount, publishedDate: publishedDate, imageLinks: imageLinks)
//                                    }
//                                    let book = Book(bookId: bookId, title: title, authors: authors, description: description, pageCount: pageCount, averageRating: averageRating, ratingsCount: ratingsCount, publishedDate: publishedDate, imageLinks: imageLinks)
                                    //print("BOOK: \(book)")
                                    bookInfo.append(bookId)
                                }
                            }
                            bookInfo = bookInfoCopy
                            
                        } else {
                            print("No items found in the response.")
                       
                        }
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                    
                }
                
            case .failure(let error):
                print("Request failed with error: \(error)")
                
            }
        }
        return bookInfo
    }
    
   


}
    

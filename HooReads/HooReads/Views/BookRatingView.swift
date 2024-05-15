//
//  BookRatingView.swift
//  HooReads
//
//  Created by Maraki Fanuil on 5/2/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import UIKit
import SDWebImageSwiftUI

@MainActor
final class BookRatingViewModel: ObservableObject{

    @Published private(set) var user: DBUser? = nil
    @Published private(set) var BookReviews: [DBBookReview]? = nil

    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    func checkBookExsistence(bookId: String) async throws -> Bool {
        let doc = Firestore.firestore().collection("BookReviews").document(bookId)
       
        
        do {
            let documentSnapshot = try await doc.getDocument()
            if documentSnapshot.exists {
                return true
            }
            
        }
        return false
    }
    
    
        

}

struct BookRatingView: View {
    @Binding var showSignInView: Bool
    @StateObject private var viewModel = BookRatingViewModel()
    @State var currBook: BookAPIManager.Book
    let bookReviewManager = BookReviewManager.shared
    let timelineManager = TimelineManager.shared
    
    @State private var rating: Double = 0
    @State private var returnToBooksPage = false
    @State private var showSuccessPopup = false
    
    
    
    
    var body: some View {
        VStack {
            VStack {
                WebImage(url: URL(string: currBook.imageLinks["thumbnail"]!))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 250)
                    .padding(.all, 5)
                
                Text(currBook.title)
                
            }
            Spacer()
            VStack(spacing: 20) {
                Text("Rate this book")
                    .font(.headline)
                
                VStack {
                    Slider(value: $rating, in: 0...5, step: 0.1)
                        .accentColor(Color(hex: 0xF8EC99))
                        .padding(.horizontal, 20)
                    
                    Text(String(format: "%.1f", rating))
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 20)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 10)
            
            
            Spacer()
            Button("Submit Rating") {
                addRating()
                showSuccessPopup = true
                
            }.frame(maxWidth: .infinity, maxHeight: 60)
                .foregroundColor(Color.black)
                .background(Color(hex: 0xCCC3A8))
                .cornerRadius(10)
                .padding(.leading, 5)
                .padding(.trailing, 5)
                .alert("Successfully Rated Book!",
                       isPresented: $showSuccessPopup) {
                    Button("Ok") {}
                    
                }
            
            
        
        }
        
    }
    func addRating(){
        
        Task{
            try? await viewModel.loadCurrentUser()
            let curUserId = viewModel.user?.userId
            
            print("curr book id: \(currBook.bookId)")
            if ((try? await viewModel.checkBookExsistence(bookId: currBook.bookId)) == false){
                try? await bookReviewManager.createNewBookReview(bookid: currBook.bookId , title: currBook.title)
                
                
            }
            
         
            let bookDoc = Firestore.firestore().collection("BookReviews").document(currBook.bookId)
            
            bookDoc.getDocument { document, error in
                if let error = error {
                    print("Error fetching document: \(error)")
                    return
                }

                guard var ratings = document?.data()?["ratings"] as? [String: Double] else {
                    print("Error with ratings Field")
                    return
                }
                guard var total_rating_sum = document?.data()?["total_rating_sum"] as? Double else {
                    print("Error with total_rating_sum Field")
                    return
                }
                
                guard var new_num_of_ratings = document?.data()?["num_of_ratings"] as? Int else {
                    print("Error with num_of_ratings Field")
                    return
                }
                
                total_rating_sum += rating
                
                ratings[curUserId!] = rating
                
                new_num_of_ratings += 1
            
                var recalculatedRating = calculateAvgRating(hooReadsRatingsSum: total_rating_sum, hooReadsNumOfRatings: new_num_of_ratings)
                
                bookDoc.updateData([
                    "ratings": ratings,
                    "total_rating_sum": total_rating_sum,
                    "num_of_ratings": new_num_of_ratings,
                    "avg_rating": recalculatedRating
                ])
            }
            
            //add rating activity to friends' timeline
            let friends = try await fetchFriends(curUserId: curUserId!)
            
            
            if !friends.isEmpty {
                print("friend copy: \(friends)")
                for friend in friends {
                    print("friend for loop: \(friend)")
                    await addToFriendsTimeline(userId: friend, friendId: curUserId!, activityType: "rated", bookId: currBook.bookId )
                }
            }
            
        }
    }
    func fetchFriends(curUserId: String) async throws -> [String] {
        let userDoc = Firestore.firestore().collection("users").document(curUserId)
        let document = try await userDoc.getDocument()
        
        guard let friends = document.data()?["friends"] as? [String] else {
            throw NSError()
        }
        
        return friends
    }
    
    func addToFriendsTimeline(userId: String, friendId: String, activityType: String, bookId: String ) async{
        try? await timelineManager.createTimeLine(userId: userId, friendId:friendId, activityType: activityType, bookId: bookId)
    }

    func calculateAvgRating(hooReadsRatingsSum: Double, hooReadsNumOfRatings: Int) -> Double{
        let recalculatedRating = hooReadsRatingsSum / Double(hooReadsNumOfRatings)
        return recalculatedRating
        
    }
}

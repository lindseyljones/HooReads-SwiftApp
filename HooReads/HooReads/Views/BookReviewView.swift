//
//  BookReviewView.swift
//  HooReads
//
//  Created by Maraki Fanuil on 5/1/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import UIKit
import SDWebImageSwiftUI

@MainActor
final class BookReviewViewModel: ObservableObject{

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

struct BookReviewView: View {
    @Binding var showSignInView: Bool
    @StateObject private var viewModel = BookReviewViewModel()
    @State var currBook: BookAPIManager.Book
    @State var review: String = ""
    let bookReviewManager = BookReviewManager.shared
    let timelineManager = TimelineManager.shared
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
            
            ZStack{
                TextEditor(text: $review)
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)
                    .background(Color(hex: 0xE7C099))
                    .border(Color(hex: 0xF0EBE7), width: 1)
                    .cornerRadius(10)
                    .padding(.bottom, 20)
                    .padding(.leading, 8)
                    .padding(.trailing, 8)
                
                if review.isEmpty {
                    Text("Add Review Here...")
                        .foregroundColor(.gray)
                        .padding(8)
                        .offset(x: 8, y: 8)
                }
            }
            Spacer()
            Button("Submit Review") {
                addReview()
                showSuccessPopup = true
                
            }.frame(maxWidth: .infinity, maxHeight: 60)
                .foregroundColor(Color.black)
                .background(Color(hex: 0xCCC3A8))
                .cornerRadius(10)
                .padding(.leading, 5)
                .padding(.trailing, 5)
                .alert("Successfully Reviewed Book!",
                       isPresented: $showSuccessPopup) {
                    Button("Ok") {}
                    
                }
        }
        
    }
    func addReview(){
        
        Task{
            try? await viewModel.loadCurrentUser()
            let curUserId = viewModel.user?.userId
            
            print("curr book id: \(currBook.bookId)")
            if ((try? await viewModel.checkBookExsistence(bookId: currBook.bookId)) == false){
                try? await bookReviewManager.createNewBookReview(bookid: currBook.bookId, title: currBook.title)
                
                
            }

            let bookDoc = Firestore.firestore().collection("BookReviews").document(currBook.bookId)
            
            bookDoc.getDocument { document, error in
                if let error = error {
                    print("Error fetching document: \(error)")
                    return
                }

                guard var reviews = document?.data()?["reviews"] as? [String: String] else {
                    print("Error with Reviews Field")
                    return
                }
                
                reviews[curUserId!] = review
            
                bookDoc.updateData([
                    "reviews": reviews
                ])
            }
            
            
            //add review activity to friends' timeline
            let friends = try await fetchFriends(curUserId: curUserId!)
            
            
            if !friends.isEmpty {
                print("friend copy: \(friends)")
                for friend in friends {
                    print("friend for loop: \(friend)")
                    await addToFriendsTimeline(userId: friend, friendId: curUserId!, activityType: "reviewed", bookId: currBook.bookId )
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
        print("friendId: \(friendId)")
        print("activityType: \(activityType)")
        try? await timelineManager.createTimeLine(userId: userId, friendId:friendId, activityType: activityType, bookId: bookId)
    }
}

//#Preview {
//    BookReviewView()
//}

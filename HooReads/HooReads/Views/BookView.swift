//
//  BookView.swift
//  HooReads
//
//  Created by Lindsey Jones on 5/1/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import UIKit
import SDWebImageSwiftUI

@MainActor
final class BookViewModel: ObservableObject{
    
    @Published private(set) var user: DBUser? = nil
    @Published private(set) var shelves: [DBbookshelf]? = nil
    @Published private(set) var review: DBBookReview? = nil
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    func loadCurrentShelves() async {
        do {
            self.shelves = try await BookshelfManager.shared.getShelves(usershelfId: user!.bookshelfId)
        } catch {
            print(error)
        }
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
    
    func loadReviews(for bookId: String) async {
        do {
            self.review = try await BookReviewManager.shared.getBookReview(bookId: bookId)
        } catch {
            print(error)
        }
    }
    
    
}
    struct BookView: View {
        @State var thisBook: BookAPIManager.Book
        @Binding var showSignInView: Bool
        @StateObject private var viewModel = BookViewModel()
        @State private var willMoveToNextScreen = false
        @State private var isExpanded = false
        @State var avgRating = 0.0
        @State var numOfRatings = 0
        @State var bookReviews: [String: String] = [:]
        @State private var showAlert = false
        
        
        var body: some View {
            VStack (alignment: .center){
                HStack {
                    WebImage(url: URL(string: thisBook.imageLinks["thumbnail"]!))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 250)
                        .padding(.all, 5)
                    VStack {
                        Text(thisBook.title).font(Font.headline.weight(.bold))
                        HStack {
                            Text(thisBook.authors[0])
                            if (thisBook.authors.count > 1) {
                                Text(thisBook.authors[1]).padding(.trailing, 5)
                            }
                            if (thisBook.authors.count > 2) {
                                Text(thisBook.authors[2]).padding(.trailing, 5)
                            }
                            if (thisBook.authors.count > 3) {
                                Image(systemName: "ellipsis").padding(.trailing, 5)
                            }
                        }
                        Text(thisBook.publishedDate)
                        HStack {
                            Image(systemName: "star.fill").padding(.trailing, 5)
                            Text(String(format: "%.2f", avgRating)).padding(.trailing, 5)
                            Image(systemName: "circle.fill").resizable().frame(width: 5, height: 5).padding(.trailing, 5)
                            Text("\(numOfRatings) Ratings").padding(.trailing, 5)
                        }
                        if let user = viewModel.user {
                            NavigationLink(destination: ShelfView(showSignInView: $showSignInView, thisBook: thisBook)) {
                                Text("Add to Shelf").foregroundColor(Color(hex: 0x6D9567))
                            }
                            
                            Button("Add to Favorites", systemImage: "heart.fill") { showAlert = true }
                                .alert("Add to Favorites",
                                       isPresented: $showAlert) {
                                    Button("Add Favorite", role: .destructive) {
                                        Task {
                                            try await FavoriteManager.shared.addFav(favId: user.favoriteId, bookId: thisBook.bookId, url: thisBook.imageLinks["thumbnail"]!)
                                        }
                                    }
                                } message: {
                                    Text("Are you sure you want to add this book to favorites?")
                                }
                            
                        
                            NavigationLink(destination: BookReviewView(showSignInView: $showSignInView, currBook: thisBook )){
                                Text("Add Review").foregroundColor(Color(hex: 0x6D9567))
                            }
                            NavigationLink(destination: BookRatingView(showSignInView: $showSignInView, currBook: thisBook)){
                                Text("Add Rating").foregroundColor(Color(hex: 0x6D9567))
                            }
                        }
                        
                    }
                }
                VStack {
                    let description = thisBook.description
                    Text(description)
                        .lineLimit(isExpanded ? nil : 2) 
                        .padding(.horizontal)
                    
                    Button(action: {
                        withAnimation {
                            isExpanded.toggle()
                        }
                    }) {
                        Text(isExpanded ? "Show Less" : "Show More")
                    }
                    .padding(.top, 4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider()
                
                VStack{
                    
                    Text("Reviews")
                        .font(.headline)
                        .padding(.top)
                    
                    if self.bookReviews.isEmpty{
                        Text("No Reviews Yet").padding()
                    } else {
                      
                            ForEach(self.bookReviews.sorted(by: { $0.key < $1.key }), id: \.key) { displayName, reviewContent in
                                VStack(alignment: .center, spacing: 4) {
                                    Text("\(displayName):")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .padding(.bottom, 10)
                                    
                                    Text(reviewContent)
                                        .font(.body)
                                }
                                .frame(width: 400)
                                .padding(.top, 15)
                                .padding(.bottom, 15)
                                .background(Color(hex: 0xF8F7F5))
                                .cornerRadius(10)
                                .shadow(radius: 2)
                                
                            }
                        }
                    
                    
                    
                }
            Spacer()
            }.task{
                try? await viewModel.loadCurrentUser()
                try? await viewModel.loadCurrentShelves()
                
                
                if ((try? await viewModel.checkBookExsistence(bookId: thisBook.bookId)) == true) {
                    await viewModel.loadReviews(for: thisBook.bookId)
                    avgRating = (viewModel.review?.avg_rating)!
                    numOfRatings = (viewModel.review?.num_of_ratings)!
                    await getBookReviews()
                }
            }
            
        }
        
        func getBookReviews() async{
            
            if let reviews = viewModel.review?.reviews {
                for (reviewerId, reviewContent) in reviews {
                    if let userDoc = try? await Firestore.firestore().collection("users").document(reviewerId).getDocument().data() {
                        let first_name = userDoc["first_name"] as? String ?? ""
                        let last_name = userDoc["last_name"] as? String ?? ""
                        let username = userDoc["username"] as? String ?? ""
                        
                        var displayName = ""
                        if !first_name.isEmpty && !last_name.isEmpty {
                            displayName = "\(first_name) \(last_name)"
                        } else if !first_name.isEmpty {
                            displayName = first_name
                        } else {
                            displayName = username
                        }
                        
                        self.bookReviews[displayName] = reviewContent
                    }
                }
            } else {
                print("Error loading reviews")
            }
            
        }
        
        
    
}

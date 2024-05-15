//
//  HomeView.swift
//  HooReads
//
//  Created by Lindsey Jones on 4/9/24.
//

import SwiftUI
import Alamofire
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage
import SDWebImageSwiftUI


@MainActor
final class HomeViewModel: ObservableObject{
    
    @Published private(set) var user: DBUser? = nil
    @Published private(set) var timeline: [DBTimeline]? = nil
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    
    func loadTimeline(userId: String) async {
        do {
            self.timeline = try await TimelineManager.shared.getActivities(userId: user!.userId)
        } catch {
            print(error)
        }
    }
}

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @Binding var showSignInView: Bool
    
    @State private var timeline: [TimelineManager] = []
    let timelineManager = TimelineManager.shared
    
    
    //@State private var book: BookAPIManager.Book
    let bookAPIManager = BookAPIManager.shared
    
    @State private var book: BookAPIManager.Book?
    @State private var isShowingBookDetails = false
    @State private var newReleases: [BookAPIManager.Book] = []
    
    
    @State var feedActivity: [String: [[String: [String]]]] = [:]
    
    
    var body: some View {
        VStack{
            
            Text("Feed")
                .font(.title)
                .padding(.top)
            
//            List(self.newReleases, id: \.self) { book in
//                VStack(alignment: .leading) {
//                    NavigationLink(destination: BookView(thisBook: book, showSignInView: $showSignInView)) {
//                        WebImage(url: URL(string: book.imageLinks["thumbnail"]!))
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(width: 50, height: 75)
//                    }
//                }
//            }
            
            if self.feedActivity.isEmpty{
                Text("Add Friends to See Feed Activity").padding()
            } else {
                ScrollView{
                    ForEach(self.feedActivity.sorted(by: { $0.key < $1.key }), id: \.key) { activityId, activityContent in
                        ForEach(activityContent, id: \.self) { activity in
                            VStack(alignment: .center, spacing: 4) {
                                if let activityMsgArray = activity["activityMessage"] as? [String], let activityMsg = activityMsgArray.first {
                                    Text(activityMsg)
                                        .font(.body)
                                }
                                
                                HStack{
                                    Button(action: {
                                        if let bookIdArray = activity["bookId"] as? [String], let bookId = bookIdArray.first {
                                            loadBookDetails(bookId: bookId)
                                        }
                                    }) {
                                        if let bookIdArray = activity["bookId"] as? [String],
                                           let thumbnailURLString = bookIdArray.last,
                                           let thumbnailURL = URL(string: thumbnailURLString) ,
                                           let title = bookIdArray[1] as? String{
                                            
                                            WebImage(url: thumbnailURL)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 75, height: 100)
                                            VStack{
                                                Text(title).foregroundColor(Color.black)
                                                if let authors = activity["authors"] as? [String]{
                                                    Text("by").foregroundColor(Color.gray)
                                                    Text("\(authors.joined(separator: ", "))").foregroundColor(Color.black)
                                                    
                                                }
                                                
                                            }
                                            
                                        } else {
                                            Color.gray
                                                .frame(width: 50, height: 75)
                                        }
                                    }
                                    
                                    .sheet(item: $book) { book in
                                        NavigationView {
                                            BookView(thisBook: book, showSignInView: $showSignInView)
                                            
                                        }
                                    }.padding(.leading, 20)
                                    Spacer()
                                }
                            }
                            .frame(width: 400)
                            .padding(.top, 15)
                            .padding(.bottom, 15)
                            .background(Color(hex: 0xF8F7F5))
                            .cornerRadius(10)
                            .shadow(radius: 2)
                        }
                        Spacer()
                    }
                    
                    
                }
            }
            
        }.task{
            try? await viewModel.loadCurrentUser()
            try? await viewModel.loadTimeline(userId: viewModel.user!.userId)
            await getActivities()
            //getNewReleases()
        }
        
        
        
    }
    
    func loadBookDetails(bookId: String) {
        let docRef = Firestore.firestore().collection("Books").document(bookId)
        
        docRef.getDocument { document, error in
            if let error = error {
                print("Error fetching document: \(error)")
                return
            }
            
            guard let document = document, document.exists else {
                print("Document does not exist")
                return
            }
            
            do {
                if let bookData = document.data() {
                    var book = BookAPIManager.Book(
                        bookId: bookId,
                        title: bookData["title"] as? String ?? "",
                        authors: bookData["authors"] as? [String] ?? [],
                        description: bookData["description"] as? String ?? "",
                        pageCount: bookData["pageCount"] as? Int ?? 0,
                        averageRating: bookData["averageRating"] as? Double ?? 0.0,
                        ratingsCount: bookData["ratingsCount"] as? Int ?? 0,
                        publishedDate: bookData["publishedDate"] as? String ?? "",
                        imageLinks: bookData["imageLinks"] as? [String: String] ?? [:]
                    )
                    self.book = book
                } else {
                    print("Document data was empty.")
                }
            } catch {
                print("Error decoding book data: \(error)")
            }
        }
    }
    
    func getNewReleases(){
        Task {
            newReleases.removeAll()
            bookAPIManager.books.removeAll()
            await bookAPIManager.displayBooks(searchQuery: "new releases")
            self.newReleases = bookAPIManager.books
        }
    }
  
    func getActivities() async{
        
        if let timeline = viewModel.timeline  {
            print("timeline: \(timeline)")
            for activity in timeline {
                print("activity: \(activity)")
                let activityId = activity.id
                
                if let activityDoc = try? await Firestore.firestore().collection("users/\(viewModel.user!.userId)/timeline").document(activityId!).getDocument().data() {
                    let activityDetails = activityDoc["activityDetails"] as? [String: String] ?? [:]
                    let activityType = activityDetails.keys.first ?? ""
                    print("activityType: \(activityType)")
                    let bookId = activityDetails.values.first ?? ""
                    print("bookId: \(bookId)")
                    let friendId = activityDoc["friendId"] as? String ?? ""
                    let timestamp = activityDoc["timestamp"] as? Timestamp
                    
                    if let friendDoc = try? await Firestore.firestore().collection("users").document(friendId).getDocument().data() {
                        let first_name = friendDoc["first_name"] as? String ?? ""
                        let last_name = friendDoc["last_name"] as? String ?? ""
                        let username = friendDoc["username"] as? String ?? ""
                        
                        var displayName = ""
                        if !first_name.isEmpty && !last_name.isEmpty {
                            displayName = "\(first_name) \(last_name)"
                        } else if !first_name.isEmpty {
                            displayName = first_name
                        } else {
                            displayName = username
                        }
                        if let bookReviewDoc = try? await Firestore.firestore().collection("BookReviews").document("\(bookId)").getDocument().data() {
                            let title = bookReviewDoc["title"] as? String ?? "No title available"
                            
                            //let timestamp = data["timestamp"] as? Date
                            
                            if let timestamp = timestamp {
                                let date = timestamp.dateValue()
                                let now = Date()
                                
                                let elapsedTime = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date, to: now)
                                
                                var timestampString = ""
                                if let years = elapsedTime.year, years > 0 {
                                    timestampString = "\(years) year\(years > 1 ? "s" : "") ago"
                                } else if let months = elapsedTime.month, months > 0 {
                                    timestampString = "\(months) month\(months > 1 ? "s" : "") ago"
                                } else if let days = elapsedTime.day, days > 0 {
                                    timestampString = "\(days) day\(days > 1 ? "s" : "") ago"
                                } else if let hours = elapsedTime.hour, hours > 0 {
                                    timestampString = "\(hours) hour\(hours > 1 ? "s" : "") ago"
                                } else if let minutes = elapsedTime.minute, minutes > 0 {
                                    timestampString = "\(minutes) minute\(minutes > 1 ? "s" : "") ago"
                                } else if let seconds = elapsedTime.second, seconds > 0 {
                                    timestampString = "\(seconds) second\(seconds > 1 ? "s" : "") ago"
                                } else {
                                    timestampString = "Just now"
                                }
                                
                                
                                
                                let activityMessage = "\(displayName) \(activityType) \(title) on \(timestampString)"
                                
                                if let bookDoc = try? await Firestore.firestore().collection("Books").document(bookId).getDocument().data(){
                                    if let imageLinks = bookDoc["imageLinks"] as? [String: String], let thumbnail = imageLinks["thumbnail"] as? String,
                                    let authors = bookDoc["authors"] as? [String]{
                                        //print("self.feedActivity[activityId!] \(self.feedActivity[activityId!])")
                                        self.feedActivity[activityId!] = [["activityMessage": [activityMessage], "bookId": [bookId, title, thumbnail], "authors": authors]]
                                        
                                        
                                    }
                                }
                                
                                //self.feedActivity[activityId!] = activityMessage
                                
                            }
                            
                            
                            
                        }
                        
                    }
                }
            }
        } else {
            print("Error loading timeline")
        }
    }
    
    

    
}


//struct HomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationStack {
//            HomeView(showSignInView: .constant(false))
//        }
//    }
//}


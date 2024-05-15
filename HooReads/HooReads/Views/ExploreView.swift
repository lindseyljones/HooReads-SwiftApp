
import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import UIKit
import SDWebImageSwiftUI
import Alamofire


@MainActor
final class ExploreViewModel: ObservableObject{
    
    @Published private(set) var user: DBUser? = nil
    @Published private(set) var shelves: [DBbookshelf]? = nil
    @Published private(set) var creator_favorites: [BookAPIManager.Book]? = nil
    @Published private(set) var author_spotlight: [BookAPIManager.Book]? = nil
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    
    func loadCreatorFavorites() async throws {
        do {
            print("running here pls")
            self.creator_favorites = try await CreatorFavoriteManager.shared.getCreatorFavs()
            // print("CFs:\(self.creator_favorites)")
        }
        catch {
            print(error)
        }
    }
    
    func loadAuthorSpotlight() async throws {
        do {
            
            self.author_spotlight = try await AuthorSpotlightManager.shared.getSpotlight()
            
        }
        catch {
            print(error)
        }
    }
    
    
}

class getData: ObservableObject {
    @Published var data = [BookAPIManager.Book]()
    init() {
        print("initializing now")
        BookAPIManager.shared.displayBooks(searchQuery: "yellowface")
        self.data = BookAPIManager.shared.books
        print("DATA: \(self.data)")
    }
}


struct ExploreView: View {
    @Binding var showSignInView: Bool
    @StateObject private var viewModel = ExploreViewModel()
    @State private var books: [BookAPIManager.Book] = []
    let bookAPIManager = BookAPIManager.shared
    @State private var searchText = ""
    @State private var searchResults: [BookAPIManager.Book] = []
    @State var searching: Bool = false
    @ObservedObject var Books = getData()
    
    
    var body: some View {
        VStack {
            Text("Discover").font(.title)
            HStack {
                
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .frame(width: 15, height: 15)
                    .padding(.leading, 20)
                
                TextField("Search for a book", text: $searchText)
                    .padding(.horizontal, 20)
                    .frame(width: 350, height: 25)
                //.padding(.trailing, 30)
                //.padding(.leading, 30)
                
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        searchResults.removeAll()
                        searching = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing, 8)
                }
            }
            .frame(height: 40)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
            Button("Search") {
                Task {
                    searching = true
                    await searchBooks()
                }
            }
            .frame(maxWidth: 100, maxHeight: 30)
            .foregroundColor(Color.black)
            .background(Color(hex: 0xCCC3A8))
            .cornerRadius(10)
            .padding(.top, 7)
            .padding(.leading, 5)
            .padding(.trailing, 5)
            
            
            VStack {
                if !self.searchResults.isEmpty  {
                    List(self.searchResults, id: \.self) { book in
                        HStack {
                            NavigationLink(destination: BookView(thisBook: book, showSignInView: $showSignInView)) {
                                WebImage(url: URL(string: book.imageLinks["thumbnail"]!))
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 50, height: 75)
                                VStack(alignment: .leading){
                                    Text(book.title)
                                    Text("by").foregroundColor(Color.gray)
                                    Text("\(book.authors.joined(separator: ", "))")
                                }
                            }
                            
                            
                        }
                    }
                } else if self.searchResults.isEmpty && searching {
                    Text("No Results Found. Try Searching for another item.")
                }
                
                
                
            }
            Spacer()
            
            if !searching {
                VStack {
                    if let c_favs = viewModel.creator_favorites {
                        
                        VStack {
                            Text("Creator Favorites").padding(.leading, 10).padding(.top, 100).font(Font.headline.weight(.bold))
                            LazyHStack {
                                
                                NavigationLink(destination: BookView(thisBook: c_favs[0], showSignInView: $showSignInView)) {
                                    WebImage(url: URL(string: c_favs[0].imageLinks["thumbnail"]!))
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50, height: 75)
                                }
                                Spacer()
                                NavigationLink(destination: BookView(thisBook: c_favs[1], showSignInView: $showSignInView)) {
                                    WebImage(url: URL(string: c_favs[1].imageLinks["thumbnail"]!))
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50, height: 75)
                                }
                                Spacer()
                                NavigationLink(destination: BookView(thisBook: c_favs[2], showSignInView: $showSignInView)) {
                                    WebImage(url: URL(string: c_favs[2].imageLinks["thumbnail"]!))
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50, height: 75)
                                }
                                Spacer()
                                NavigationLink(destination: BookView(thisBook: c_favs[3], showSignInView: $showSignInView)) {
                                    WebImage(url: URL(string: c_favs[3].imageLinks["thumbnail"]!))
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50, height: 75)
                                }
                                Spacer()
                                NavigationLink(destination: BookView(thisBook: c_favs[4], showSignInView: $showSignInView)) {
                                    WebImage(url: URL(string: c_favs[4].imageLinks["thumbnail"]!))
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50, height: 75)
                                }
                                Spacer()
                                NavigationLink(destination: BookView(thisBook: c_favs[5], showSignInView: $showSignInView)) {
                                    WebImage(url: URL(string: c_favs[5].imageLinks["thumbnail"]!))
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50, height: 75)
                                }
                            }
                        }
                    }
                
                    if let author_spot = viewModel.author_spotlight {
                        VStack {
                            Text("Author Spotlight: Taylor Jenkins Reid").padding(.leading, 10).padding(.top, 50).font(Font.headline.weight(.bold))
                            LazyHStack {
                                
                                NavigationLink(destination: BookView(thisBook: author_spot[0], showSignInView: $showSignInView)) {
                                    WebImage(url: URL(string: author_spot[0].imageLinks["thumbnail"]!))
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50, height: 75)
                                }
                                Spacer()
                                NavigationLink(destination: BookView(thisBook: author_spot[1], showSignInView: $showSignInView)) {
                                    WebImage(url: URL(string: author_spot[1].imageLinks["thumbnail"]!))
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50, height: 75)
                                }
                                Spacer()
                                NavigationLink(destination: BookView(thisBook: author_spot[2], showSignInView: $showSignInView)) {
                                    WebImage(url: URL(string: author_spot[2].imageLinks["thumbnail"]!))
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50, height: 75)
                                }
                                Spacer()
                                NavigationLink(destination: BookView(thisBook: author_spot[3], showSignInView: $showSignInView)) {
                                    WebImage(url: URL(string: author_spot[3].imageLinks["thumbnail"]!))
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50, height: 75)
                                }
                                Spacer()
                                NavigationLink(destination: BookView(thisBook: author_spot[4], showSignInView: $showSignInView)) {
                                    WebImage(url: URL(string: author_spot[4].imageLinks["thumbnail"]!))
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50, height: 75)
                                }
                                Spacer()
                                NavigationLink(destination: BookView(thisBook: author_spot[5], showSignInView: $showSignInView)) {
                                    WebImage(url: URL(string: author_spot[5].imageLinks["thumbnail"]!))
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50, height: 75)
                                }
                            }
                        }
                    }
                }.task{
                    try? await viewModel.loadCreatorFavorites()
                    try? await viewModel.loadAuthorSpotlight()
                }.onAppear(){
                    searchResults.removeAll()
                    searching = false
                }
            }
        }
    }
        func searchBooks() {
            searchResults.removeAll()
            let maxResults = 10
            let apikey = "YOUR-API-KEY-HERE"
            var this_url = "https://www.googleapis.com/books/v1/volumes?q=\(searchText)&maxResults=\(maxResults)&key=\(apikey)"
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
                                                                            await bookAPIManager.createBook(bookId: bookId, title: title, authors: authors, description: description, pageCount: pageCount, averageRating: averageRating, ratingsCount: ratingsCount, publishedDate: publishedDate, imageLinks: imageLinks)
                                                                        }
                                        let book = BookAPIManager.Book(bookId: bookId, title: title, authors: authors, description: description, pageCount: pageCount, averageRating: averageRating, ratingsCount: ratingsCount, publishedDate: publishedDate, imageLinks: imageLinks)
                                        
                                        searchResults.append(book)
                                    }
                                }
                                print(searchResults)
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
        }
        
        
    }
    
    
    
    //
    //#Preview {
    //    ExploreView()
    //}
    

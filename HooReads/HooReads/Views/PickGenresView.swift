//
//  PickGenresView.swift
//  HooReads
//
//  Created by Maraki Fanuil on 4/28/24.
//

import SwiftUI

struct PickGenresView: View {
    @StateObject private var viewModel = RegisterViewModel()
    @Binding var showSignInView: Bool
    @State private var selectedGenres = [String]()
    @State var favorite_genres = [String]()
    @State private var showNextPage = false
    
    
    let genres = [
        "Action",
        "Adventure",
        "Architecture",
        "Art",
        "Biography",
        "Business & Money",
        "Children's Books",
        "Classics",
        "Comedy",
        "Comics & Graphic Novels",
        "Computers & Technology",
        "Cookbooks, Food & Wine",
        "Crafts, Hobbies & Home",
        "Crime",
        "Drama",
        "Economics",
        "Education & Teaching",
        "Engineering & Transportation",
        "Fantasy",
        "Gardening",
        "Health, Fitness & Dieting",
        "History",
        "Horror",
        "Humor & Entertainment",
        "Law",
        "LGBTQ+ Books",
        "Life & History",
        "Literature & Fiction",
        "Literature & Music",
        "Math",
        "Medical Books",
        "Memoirs",
        "Music",
        "Mystery",
        "Parenting & Relationships",
        "Philosophy",
        "Photography",
        "Poetry",
        "Politics & Social Sciences",
        "Psychology",
        "Reference",
        "Religion & Society",
        "Religion & Spirituality",
        "Romance",
        "Science",
        "Science & Fiction",
        "Self-Help",
        "Sociology",
        "Sports & Outdoors",
        "Teen & Young Adult",
        "Technology",
        "Test Preparation",
        "Thriller",
        "Travel",
        "True Crime"
    ]


    var body: some View {
        ZStack{
            //Color(Color(hex:0xF7F2E4))
                //.ignoresSafeArea()
                //.overlay(
                    VStack{
                        Spacer()
                        List(genres, id: \.self) { genre in
                            Text(genre)
                                .foregroundColor(selectedGenres.contains(genre) ? Color(hex: 0x6D9567) : .black)
                                .onTapGesture {
                                    if let index = selectedGenres.firstIndex(of: genre) {
                                        selectedGenres.remove(at: index)
                                    } else {
                                        selectedGenres.append(genre)
                                    }
                                }
                        }
                        Button("Submit") {
                            updateUserInfo()
                        }.frame(maxWidth: .infinity, maxHeight: 60)
                            .foregroundColor(Color.black)
                            .background(Color(hex: 0xCCC3A8))
                            .cornerRadius(10)
                            .padding(.leading, 5)
                            .padding(.trailing, 5)
                }
            }.navigationBarTitle("Select Favorite Genres")
            .fullScreenCover(isPresented: $showNextPage)  {
                NavigationStack {
                    LoggedInContentView(showSignInView: $showSignInView)
                }
            }
        
    }
    func updateUserInfo() {
            Task {
                self.favorite_genres = self.selectedGenres
                try await viewModel.updateFavGenres(genres: self.favorite_genres)
                showNextPage = true
            }
    }
    
    
}

struct PickGenresView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PickGenresView(showSignInView: .constant(false))
        }
    }
}

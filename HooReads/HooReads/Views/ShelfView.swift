//
//  ShelfView.swift
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
final class ShelfViewModel: ObservableObject{

    @Published private(set) var user: DBUser? = nil
    @Published private(set) var shelves: [DBbookshelf]? = nil

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
}

struct ShelfView: View {
    @Binding var showSignInView: Bool
    @State var thisBook: BookAPIManager.Book
    @StateObject private var viewModel = ShelfViewModel()
    @State private var showAlert = false

    var body: some View {
        VStack {
            if let user = viewModel.user{
                if let shelves = viewModel.shelves{
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
                    }

                    List(shelves, id: \.self) { shelf in
                            Button(shelf.name!) {
                                Task {
                                    do {
                                        var shelf_books = shelf.items
                                        shelf_books![thisBook.bookId] = thisBook.imageLinks["thumbnail"]
                                        try await BookshelfManager.shared.updateShelf(usershelfId: user.bookshelfId, shelfId: shelf.id!, name: shelf.name!, items: shelf_books!)
                                        print("book confirmed and added")
                                    } catch {
                                        print(error)
                                    }
                                }
                                showAlert = true
                            }.alert("Book was added to your shelf.",
                                    isPresented: $showAlert) {
                                    Button("Ok") {}
                             } message: {
                                    Text("Visit your profile to see the book on your shelf.")
                             }
                            .frame(maxWidth: .infinity)
                                .foregroundColor(Color.black)
                        }
                }
            }

        }.task{
            try? await viewModel.loadCurrentUser()
            await viewModel.loadCurrentShelves()
        }
    }
}

//#Preview {
//    ShelfView()
//}

//
//  ProfileView.swift
//  HooReads
//
//  Created by Maraki Fanuil on 4/11/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import UIKit
import SDWebImageSwiftUI

@MainActor
final class ProfileViewModel: ObservableObject{
    
    @Published private(set) var user: DBUser? = nil
    @Published private(set) var shelves: [DBbookshelf]? = nil
    @Published private(set) var favs: Favorite? = nil
    
    
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
    
    func loadCurrentFavs() async {
        do {
            self.favs = try await FavoriteManager.shared.getFavs(favId: user!.favoriteId)
        } catch {
            print(error)
        }
    }
    
}

struct ProfileView: View {
    
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
    @State private var showAlert = false
    @State private var books: [BookAPIManager.Book] = []
    @State private var tooManyShelves = false
    // @State private var currRead = false
    
    
   
    var body: some View {
        ScrollView {
            VStack{
                if let user = viewModel.user{
                    if let shelves = viewModel.shelves {
                        HStack{
                            if let photoUrl = user.photoUrl{
                                AsyncImage(url: URL(string: photoUrl)) { phase in
                                    if let image = phase.image {
                                        image.resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .scaledToFit()
                                            .clipShape(Circle())
                                    }
                                }
                            }
                            VStack{
                                
                                Text(user.username)
                                    .font(Font.headline.weight(.semibold))
                                    .scaledToFill()
                                    .padding(.bottom, 10)
                                
                                if let bio = user.bio  {
                                    Text("\(bio)").scaledToFill()
                                        .font(.system(size: 12))
                                }
                            }
                            VStack {
                                Text("Currently Reading")
                                    .font(.system(size: 14))
                                    .padding(.leading, 10)
                                ForEach(shelves, id:\.self) { shelf in
                                    if (shelf.name == "Currently Reading") {
                                        if (shelf.items!.keys.count > 0) {
                                            let curr_read = Array(shelf.items!.keys)
                                            let curr = curr_read[curr_read.endIndex - 1]
                                            
                                            WebImage(url: URL(string: shelf.items![curr]!))
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 50, height: 75)
                                        }
                                        //currRead = true
                                    }
                                }
                                //                            if (currRead != true) {
                                //                                Text("No 'Currently Reading' Shelf.").frame(width: 50, height: 75).background(Color(hex: 0x786935, opacity: 0.34))
                                //                            }
                                
                            }
                            Spacer()
                            VStack {
                                Text("Last Read").font(.system(size: 14))
                                    .padding(.trailing, 10)
                                ForEach(shelves, id:\.self) { shelf in
                                    if (shelf.name == "Read") {
                                        if (shelf.items!.keys.count > 0) {
                                            let curr_read = Array(shelf.items!.keys)
                                            let curr = curr_read[curr_read.endIndex - 1]
                                            
                                            WebImage(url: URL(string: shelf.items![curr]!))
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 50, height: 75)
                                            
                                        }
                                    }
                                    
                                }
                            }
                        }
                        .frame(alignment: .top)
                        
                        HStack {
                            Text("My Shelves").padding(.leading, 10).font(Font.headline.weight(.bold))
                            Spacer()
                            Button("Add Shelf", systemImage: "plus") {
                                addShelfPop(title: "Add Shelf", message: "Type the name of your new shelf", hintText: "Shelf Name", primaryTitle: "Save", secondaryTitle: "Cancel") { text in
                                    Task {
                                        var tempBool = true
                                        if (shelves.count >= 5) {
                                            tooManyShelves = true
                                        }
                                        for bookshelf in shelves {
                                            if (bookshelf.name == text) {
                                                tempBool = false
                                                addShelfPop(title: "Try Again - Add Shelf", message: "This bookshelf name already exists.", hintText: "Shelf Name", primaryTitle: "Save", secondaryTitle: "Cancel") { text in
                                                    Task {
                                                        for bookshelf in shelves {
                                                            if (bookshelf.name == text) {
                                                                tempBool = false
                                                                addShelfPop(title: "Try Again - Add Shelf", message: "This bookshelf name already exists.", hintText: "Shelf Name", primaryTitle: "Save", secondaryTitle: "Cancel") { text in
                                                                    Task {
                                                                        for bookshelf in shelves {
                                                                            if (bookshelf.name == text) {
                                                                                tempBool = false
                                                                                print("This bookshelf already exists and user is dumb.")
                                                                            }
                                                                        }
                                                                        if (tempBool) {
                                                                            await createShelf(shelfName: text, userId: user.userId)
                                                                        }
                                                                    }
                                                                } secondaryAction: {
                                                                    print("Cancelled")
                                                                }
                                                            }
                                                        }
                                                        if (tempBool) {
                                                            await createShelf(shelfName: text, userId: user.userId)
                                                        }
                                                    }
                                                } secondaryAction: {
                                                    print("Cancelled")
                                                }
                                            }
                                        }
                                        if (tempBool) {
                                            await createShelf(shelfName: text, userId: user.userId)
                                        }
                                    }
                                } secondaryAction: {
                                    print("Cancelled")
                                }
                            }.padding(.trailing, 10).alert(isPresented: $tooManyShelves) {
                                Alert(title: Text("You have reached the shelf limit."),
                                      message: Text("Delete one shelf and try again."),
                                      dismissButton: .default(Text("Ok")))
                            }
                        }
                        ForEach(shelves, id:\.self) { shelf in
                            HStack {
                                VStack {
                                    Text(shelf.name!).frame(alignment: .topLeading)
                                    Spacer()
                                }
                                Spacer()
                                VStack {
                                    Button("", systemImage: "trash") { showAlert = true }
                                        .alert("Delete Shelf",
                                               isPresented: $showAlert) {
                                            Button("Delete Shelf", role: .destructive) {
                                                Task {
                                                    await deleteDBShelf(uid: user.bookshelfId, shelfId: shelf.id!)
                                                }
                                            }
                                        } message: {
                                            Text("This action cannot be undone.")
                                        }
                                    Spacer()
                                }
                                VStack {
                                    Button("", systemImage: "pencil") {
                                        editShelf(title: "Edit Shelf", message: "Modify an existing bookshelf.", hintText: shelf.name!, primaryTitle: "Save", secondaryTitle: "Cancel") { text in
                                            Task {
                                                do {
                                                    try await BookshelfManager.shared.updateShelf(usershelfId: user.bookshelfId, shelfId: shelf.id!, name: text, items: shelf.items!)
                                                } catch {
                                                    print(error)
                                                }
                                            }
                                        } secondaryAction: {
                                            print("Cancelled")
                                        }
                                    }
                                    Spacer()
                                }
                            }.frame(maxWidth: .infinity, maxHeight: 15)
                            LazyHStack {
                                if (shelf.items!.keys.count > 0) {
                                    let items = shelf.items!
                                    ForEach(Array(items.keys), id:\.self) { key in
                                        if let value = items[key] {
                                            Button(action: {
                                                print("was clicked")
                                                showAlert = true
                                            })
                                            { WebImage(url: URL(string: value))
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 50, height: 75)
                                            }
                                        
                                        }
                                    }
                                }
                            }.frame(maxWidth: .infinity, maxHeight: 75).background(Color(hex: 0x786935, opacity: 0.34))
                        }
                            
                        Text("My Favorites").padding(.leading, 10).font(Font.headline.weight(.bold))
                        if let favorites = viewModel.favs {
                            LazyHStack {
                                if (favorites.favList!.keys.count > 0) {
                                    let items = favorites.favList!
                                    ForEach(Array(items.keys), id:\.self) { key in
                                        if let value = items[key] {
                                            WebImage(url: URL(string: value))
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 50, height: 75)
                                        }
                                    }
                                }
                            }.frame(maxWidth: .infinity)
                        }
                    }
                }
            }
        }
        .task{
            try? await viewModel.loadCurrentUser()
            try? await viewModel.loadCurrentShelves()
            try? await viewModel.loadCurrentFavs()
        }
        // .navigationBarHidden(true)
        .navigationTitle("Profile")
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing){
                NavigationLink{
                    SettingsView(showSignInView: $showSignInView)
                } label: {
                    Image(systemName: "gear")
                        .font(.headline)
                }
                
            }
            
        }
    }
}
extension View {
    func addShelfPop(title: String, message: String, hintText: String, primaryTitle: String, secondaryTitle: String, primaryAction: @escaping (String)->(), secondaryAction: @escaping ()->()) {

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField { field in
            field.placeholder = hintText
        }

        alert.addAction(.init(title: secondaryTitle, style: .cancel, handler: { _ in
            secondaryAction()
        }))

        alert.addAction(.init(title: primaryTitle, style: .default, handler: { _ in
            if let text = alert.textFields?[0].text {
                primaryAction(text)
            } else {
                primaryAction("")
            }
        }))

        rootController().present(alert, animated: true, completion: nil)
    }
    func editShelf(title: String, message: String, hintText: String, primaryTitle: String, secondaryTitle: String, primaryAction: @escaping (String)->(), secondaryAction: @escaping ()->()) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField { field in
            field.placeholder = hintText
        }

        alert.addAction(.init(title: secondaryTitle, style: .cancel, handler: { _ in
            secondaryAction()
        }))

        alert.addAction(.init(title: primaryTitle, style: .default, handler: { _ in
            if let text = alert.textFields?[0].text {
                primaryAction(text)
            } else {
                primaryAction("")
            }
        }))

        rootController().present(alert, animated: true, completion: nil)
    }
    
    func deleteShelf(title: String, message: String, primaryTitle: String, secondaryTitle: String, primaryAction: @escaping ()->(), secondaryAction: @escaping ()->()) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addAction(.init(title: secondaryTitle, style: .cancel, handler: { _ in
            secondaryAction()
        }))

        alert.addAction(.init(title: primaryTitle, style: .default, handler: { _ in
            primaryAction()
        }))

        rootController().present(alert, animated: true, completion: nil)
    }
 
    func rootController()->UIViewController {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .init()
        }

        guard let root = screen.windows.first?.rootViewController else {
            return .init()
        }

        return root
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProfileView(showSignInView: .constant(false))
        }
    }
}

func createShelf(shelfName: String, userId: String) async {
    do {
        try await BookshelfManager.shared.createNewShelf(name: shelfName, user: userId)
    } catch {
        print(error)
    }
}



func deleteDBShelf(uid: String, shelfId: String) async {
    do {
        try await BookshelfManager.shared.deleteShelf(usershelfId: uid, shelfId: shelfId)
    } catch {
        print(error)
    }
}

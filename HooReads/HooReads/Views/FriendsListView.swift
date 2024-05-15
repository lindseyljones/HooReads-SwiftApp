//
//  FriendsView.swift
//  HooReads
//
//  Created by Maraki Fanuil on 5/1/24.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

struct FriendsListView: View {
    @StateObject private var profileViewModel = ProfileViewModel()
    @StateObject private var friendViewModel = FriendsManager()
    @State var friends: [String: String] = [:]
    @State var isRemoved = false
    
    var body: some View {
        VStack {
            Text("Friends")
                .font(.title)
                .padding()
            
            if friends.isEmpty{
                Text("No Friends to Display").foregroundColor(.gray)
                Spacer()
            } else {
                ForEach(friends.sorted(by: { $0.key < $1.key }), id: \.key) { userId, displayName in
                    NavigationLink(destination: FriendProfileView(userId: userId)) {
                        HStack {
                            Text(displayName)
                                .foregroundColor(.black)
                            
                            Spacer()
                            if isRemoved {
                                Text("Removed").foregroundColor(.red)
                            } else {
                                Button(action: {
                                    removeFriend(userId: userId)
                                    isRemoved = true
                                }) {
                                    Text("Remove")
                                        .foregroundColor(.red)
                                }
                            }
                        }.frame(width: 370)
                            .padding(.top, 15)
                            .padding(.bottom, 15)
                            .padding(.leading, 15)
                            .padding(.trailing, 15)
                            .background(Color(hex: 0xFAF9F9))
                            .cornerRadius(10)
                            .shadow(radius: 2)
                    }
                    
                }.disabled(isRemoved)
                Spacer()
        }
        }
        .onAppear {
            getFriends()
        }
        
    }
    
    func getFriends(){
        Task{
            try? await profileViewModel.loadCurrentUser()
            let curUserId = profileViewModel.user?.userId
            
            if let doc = try? await Firestore.firestore().collection("users").document(curUserId!).getDocument().data(),
               let friendsList = doc["friends"] as? [String] {
                for userId in friendsList {
                    if let friend_doc = try? await Firestore.firestore().collection("users").document(userId).getDocument().data() {
                        let first_name = friend_doc["first_name"] as? String ?? ""
                        let last_name = friend_doc["last_name"] as? String ?? ""
                        let username = friend_doc["username"] as? String ?? ""
                        
                        var displayName = ""
                        if !first_name.isEmpty && !last_name.isEmpty {
                            displayName = "\(first_name) \(last_name)"
                        } else if !first_name.isEmpty {
                            displayName = first_name
                        } else {
                            displayName = username
                        }
                        
                        self.friends[userId] = displayName
                    }
                }
            }
        }
    }
    
    func removeFriend(userId: String){
        Task{
            try? await profileViewModel.loadCurrentUser()
            let userId2 = profileViewModel.user?.userId
            try? await friendViewModel.removeFriend(userId1: userId, userId2: userId2!)
        }
    }
}

#Preview {
    FriendsListView()
}

//
//  FriendSearchView.swift
//  HooReads
//
//  Created by Maraki Fanuil on 4/18/24.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

struct FriendView: View {
    @ObservedObject var data = getUsers()
    @State var selectedTab = Tabs.FirstTab
    var body: some View {
        
        VStack {
            HStack {
                Spacer()
        
                VStack {
                    Image(systemName: "person.3.fill")
                        .foregroundColor(selectedTab == .FirstTab ? Color(hex: 0x6D9567) : Color.black)
                    Text("Friends")
                }.padding(.top, 17)
                .onTapGesture {
                    self.selectedTab = .FirstTab
                }
                Spacer()
                VStack {
                    Image(systemName: "person.crop.circle.fill.badge.plus")
                        .foregroundColor(selectedTab == .SecondTab ? Color(hex: 0x6D9567) : Color.black)
                    Text("Find Friends")
                }.padding(.top, 17)
                .onTapGesture {
                    self.selectedTab = .SecondTab
                }
                Spacer()
                VStack {
                    Image(systemName: "person.fill.questionmark")
                        .foregroundColor(selectedTab == .ThirdTab ? Color(hex: 0x6D9567) : Color.black)
                    Text("Requests")
                }.padding(.top, 17)
                .onTapGesture {
                    self.selectedTab = .ThirdTab
                }
                Spacer()
                
            }.padding(.bottom)
                .background(Color(hex: 0xEAE7E4).edgesIgnoringSafeArea(.all))
            Spacer()
            
            if selectedTab == .FirstTab {
                FriendsListView()
            } else if selectedTab == .SecondTab {
                FriendSearchView(data:self.$data.users)
            } else if selectedTab == .ThirdTab {
                FriendRequestsView()
            }
            
        }
        
        
        
    }
    
}

enum Tabs {
    case FirstTab
    case SecondTab
    case ThirdTab
}

class getUsers : ObservableObject{
    
    @Published var users = [dataType]()
    
    init() {
        let snapshot = Firestore.firestore().collection("users").getDocuments() { snapshot, error in
            
            if let error = error {
                print("Error fetching users: \(error.localizedDescription)")
                return
            }
                    
            guard let snapshot = snapshot else {
                print("Snapshot is nil")
                return
            }
            
            for user in snapshot.documents{
                
                let id = user.documentID
                let first_name = user.get("first_name") as? String ?? ""
                let last_name = user.get("last_name") as? String ?? ""
                let email = user.get("email") as? String ?? ""
                let username = user.get("username") as? String ?? ""
                
                self.users.append(dataType(id: id, first_name: first_name, last_name: last_name, email: email, username: username))
            }
            
            
        }
    }
}




#Preview {
    FriendView()
}

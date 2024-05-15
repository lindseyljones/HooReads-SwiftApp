//
//  FriendSearchView.swift
//  HooReads
//
//  Created by Maraki Fanuil on 5/1/24.
//

import SwiftUI

struct dataType : Identifiable {
    var id : String?
    var first_name : String?
    var last_name : String?
    var email: String?
    var username: String?
    
}

struct FriendSearchView : View {
    @State var txt = ""
    @Binding var data : [dataType]
    @StateObject private var profileViewModel = ProfileViewModel()
    @StateObject private var friendViewModel = FriendsManager()
    @State var isRequestSent = false
    @State var currUserId = ""
    @State var isFriend = false
    @State var isPending = false
    
    var body: some View {
        VStack{
            Text("Find Friends") .font(.title)
            HStack{
                TextField("Search", text: self.$txt)
                
                if self.txt != ""{
                    Button(action: {
                        self.txt = ""
                    }){
                        Text("Cancel")
                    }
                    .foregroundColor(.black)
                }
            }.padding()
            
            if self.txt != "" {
        
                let searchText = txt.lowercased()
                let filteredData = data.filter { user in
                    let firstNameMatches = user.first_name?.lowercased().contains(searchText) ?? false
                    let lastNameMatches = user.last_name?.lowercased().contains(searchText) ?? false
                    let usernameMatches = user.username?.lowercased().contains(searchText) ?? false
                    
                    
                    return firstNameMatches || lastNameMatches || usernameMatches
                }
                
                if filteredData.isEmpty {
                    Text("No Results Found")
                        .foregroundStyle(Color.black.opacity(0.5))
                } else {
                    List(filteredData) { user in
                        if user.first_name != "" && user.last_name != "" && user.id != getCurrUser(){
                            HStack {
                                Text("\(user.first_name ?? "") \(user.last_name ?? "")")
                                Spacer()
                                if isPending(friendId: user.id!) {
                                    Text("Pending")
                                } else if !isFriend(friendId: user.id!){
                                    Button("Request"){
                                        Task{
                                            await sendRequest(recieverUserId: user.id!)
                                            isRequestSent = true
                                        }
                                    }
                                    .disabled(isRequestSent)
                                } else {
                                    Text("Friends")
                                }
                            }
                        } else if user.first_name != "" && user.id != getCurrUser(){
                            HStack {
                                Text("\(user.first_name ?? "")")
                                Spacer()
                                if isPending(friendId: user.id!) {
                                    Text("Pending")
                                } else if !isFriend(friendId: user.id!){
                                    Button("Request"){
                                        print("Button clicked")
                                        Task{
                                            await sendRequest(recieverUserId: user.id!)
                                            isRequestSent = true
                                        }
                                    }
                                    .disabled(isRequestSent)
                                } else {
                                    Text("Friends")
                                }
                            }
                        } else if user.username != "" && user.id != getCurrUser(){
                            HStack {
                                Text("\(user.username ?? "")")
                                Spacer()
                                if isPending(friendId: user.id!) {
                                    Text("Pending")
                                } else if !isFriend(friendId: user.id!){
                                    Button("Request"){
                                        Task{
                                            await sendRequest(recieverUserId: user.id!)
                                            isRequestSent = true
                                        }
                                    }
                                    .disabled(isRequestSent)
                                } else {
                                    Text("Friends")
                                }
                            }
                        }
                        
                    }
                    .frame(height: UIScreen.main.bounds.height / 5 )
                }
            }
            Spacer()
        }.background(Color.white).padding()
        
    }
    
    func getCurrUser() -> String{
        
        Task{
            try? await profileViewModel.loadCurrentUser()
            self.currUserId = (profileViewModel.user?.userId)!
            
        }
        return self.currUserId
    }
    func isFriend(friendId: String) -> Bool{
        
        Task{
            try? await profileViewModel.loadCurrentUser()
            let user = profileViewModel.user
            if ((user!.friends!.contains(friendId))){
                self.isFriend = true
            } else {
                self.isFriend = false
            }
            
        }
        return self.isFriend
    }
    func isPending(friendId: String) -> Bool{
        
        Task{
            try? await profileViewModel.loadCurrentUser()
            let user = profileViewModel.user
            if ((user!.sent_friend_requests!.contains(friendId)) ){
                self.isPending = true
            } else {
                self.isPending = false
            }
            
        }
        return self.isPending
    }
    
    func sendRequest(recieverUserId: String){
        Task{
            try? await profileViewModel.loadCurrentUser()
            let curUserId = profileViewModel.user?.userId
            try? await friendViewModel.sendFriendRequest(senderUserId: curUserId!, recieverUserId: recieverUserId)
            
        }
    }
    
}



//
//  RequestsView.swift
//  HooReads
//
//  Created by Maraki Fanuil on 5/1/24.
//


import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

struct FriendRequestsView: View {
    @State var friend_requests: [String: String] = [:]
    @StateObject private var profileViewModel = ProfileViewModel()
    @StateObject private var friendViewModel = FriendsManager()
    
    @State var acceptedRequests: Set<String> = []
    @State var declinedRequests: Set<String> = []
    
    var body: some View {
        VStack {
            Text("Requests") .font(.title).padding()
            if (friend_requests != nil) {
                
                    ForEach(friend_requests.sorted(by: { $0.key < $1.key }), id: \.key) { userID, displayName in
                        if !acceptedRequests.contains(userID) && !declinedRequests.contains(userID) {
                            HStack {
                                Text(displayName)
                                Spacer()
                                
                                HStack(spacing: 20) {
                                    Button(action: {
                                        acceptFriendRequest(requestorUserId: userID)
                                        acceptedRequests.insert(userID)
                                    }) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.green)
                                    }
                                    
                                    Button(action: {
                                        declineFriendRequest(requestorUserId: userID)
                                        declinedRequests.insert(userID)
                                    }) {
                                        Image(systemName: "xmark")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                            .frame(width: 370)
                            .padding(.top, 15)
                            .padding(.bottom, 15)
                            .padding(.leading, 15)
                            .padding(.trailing, 20)
                            .background(Color(hex: 0xFAF9F9))
                            .cornerRadius(10)
                            .shadow(radius: 2)


                        } else if acceptedRequests.contains(userID) {
                            HStack {
                                Text(displayName)
                                Spacer()
                                Text("Friends").foregroundColor(.green)
                            }
                            .frame(width: 370)
                            .padding(.top, 15)
                            .padding(.bottom, 15)
                            .padding(.leading, 15)
                            .padding(.trailing, 15)
                            .background(Color(hex: 0xFAF9F9))
                            .cornerRadius(10)
                            .shadow(radius: 2)
                                
                        } else if declinedRequests.contains(userID) {
                            HStack {
                                Text(displayName)
                                Spacer()
                                Text("Declined").foregroundColor(.red)
                            }
                            .frame(width: 370)
                            .padding(.top, 15)
                            .padding(.bottom, 15)
                            .padding(.leading, 15)
                            .padding(.trailing, 15)
                            .background(Color(hex: 0xFAF9F9))
                            .cornerRadius(10)
                            .shadow(radius: 2)
                        }
                    
                }
                Spacer()
            } else {
                Text("No Friend Requests")
            }
            
        }.task {
            getRequests()
        }
        Spacer()
    }
    func acceptFriendRequest(requestorUserId: String){
        Task{
            try? await profileViewModel.loadCurrentUser()
            let curUserId = profileViewModel.user?.userId
            try? await friendViewModel.acceptFriendRequest(senderUserId: requestorUserId, recieverUserId: curUserId!)
            
        }
        
    }
    func declineFriendRequest(requestorUserId: String){
        Task{
            try? await profileViewModel.loadCurrentUser()
            let curUserId = profileViewModel.user?.userId
            try? await friendViewModel.declineFriendRequest(senderUserId: requestorUserId, recieverUserId: curUserId!)
            
        }
        
    }
    func getRequests(){
        Task{
            try? await profileViewModel.loadCurrentUser()
            let curUserId = profileViewModel.user?.userId
            
            if let doc = try? await Firestore.firestore().collection("users").document(curUserId!).getDocument().data(),
               let friendRequests = doc["friend_requests"] as? [String] {
                for userId in friendRequests {
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
                        
                        self.friend_requests[userId] = displayName
                    }
                }
            }
        }
    }
}



#Preview {
    FriendRequestsView()
}

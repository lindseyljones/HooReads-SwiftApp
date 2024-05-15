//
//  EditInfoView.swift
//  HooReads
//
//  Created by Maraki Fanuil on 5/3/24.
//

import SwiftUI

@MainActor
final class EditInfoViewModel: ObservableObject{
    
    @Published private(set) var user: DBUser? = nil
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
        
        
    }
    
    func updateUserInfo(first_name: String, last_name: String, bio: String) async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        try await UserManager.shared.updateUserInfo(userId: authDataResult.uid, first_name: first_name, last_name: last_name, bio:bio)
        
        
    }
    
   
}
struct EditInfoView: View {
    
    @StateObject private var viewModel = RegisterViewModel()
    @Binding var showSignInView: Bool
    @State var first_name: String = ""
    @State var last_name: String = ""
    @State var bio: String = ""
    @State private var showNextPage = false
    
    var body: some View {
        //NavigationView {
        ZStack(alignment: .center){
            Color(Color(hex:0xF7F2E4))
                .ignoresSafeArea()
                .overlay(
                VStack{
                    HStack{
                        Text("First Name")
                            .padding(.top, 20)
                            .padding(.leading, 5)
                            .font(.headline)
                        Spacer()
                        
                    }
                    
                    TextField("First Name", text: $first_name)
                        .disableAutocorrection(true)
                        .textFieldStyle(.roundedBorder)
                        .padding(.bottom, 20)
                        .padding(.leading, 8)
                        .padding(.trailing, 8)
                    
                    HStack{
                        Text("Last Name")
                            .padding(.leading, 5)
                            .font(.headline)
                        Spacer()
                        
                    }
                    
                    TextField("Last Name", text: $last_name)
                        .disableAutocorrection(true)
                        .textFieldStyle(.roundedBorder)
                        .padding(.bottom, 20)
                        .padding(.leading, 8)
                        .padding(.trailing, 8)
                        //.background(Color(hex: 0xF1E9D2))
                    
                    HStack{
                        Text("Bio")
                            .padding(.leading, 5)
                            .font(.headline)
                        Spacer()
                        
                    }
                    TextEditor(text: $bio)
                        .disableAutocorrection(true)
                        .textFieldStyle(.roundedBorder)
                        .padding(.bottom, 20)
                        .padding(.leading, 8)
                        .padding(.trailing, 8)
                    
                    Spacer()
                    Button("Submit") {
                        updateUserInfo()
                    }.frame(maxWidth: .infinity, maxHeight: 60)
                        .foregroundColor(Color.black)
                        .background(Color(hex: 0xCCC3A8))
                        .cornerRadius(10)
                        .padding(.leading, 5)
                        .padding(.trailing, 5)
                }
            )}
            
        Spacer()
            
        //}
        .navigationBarTitle("Edit Information!")
        .fullScreenCover(isPresented: $showNextPage)  {
            NavigationStack {
                LoggedInContentView(showSignInView: $showSignInView)
            }
        }

    }

        
    
    func updateUserInfo() {
            Task {
                try await viewModel.updateUserInfo(first_name: first_name, last_name: last_name, bio: bio)
                showNextPage = true
            }
    }
}


//#Preview {
//    EditInfoView()
//}

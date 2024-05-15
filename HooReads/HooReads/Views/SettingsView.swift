//
//  SettingsView.swift
//  HooReads
//
//  Created by Lindsey Jones on 4/9/24.


import SwiftUI
import Alamofire
import PhotosUI
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

struct SettingsView: View {
    @StateObject private var settingsViewModel = SettingsViewModel()
    @StateObject private var profileViewModel = ProfileViewModel()
    
    @State var showPhotoSheet = false
    @State var showPhotoLibrary = false
    @State var selectedPhoto: UIImage?
    @State var profileImage = Image("")
    @State var photoURL = ""
    @State private var photoUrlTrigger = false
    
    @Binding var showSignInView: Bool
    let bookAPIManager = BookAPIManager.shared
    
    @State private var showEditGenrePage = false
    @State var showCamera = false
    @State private var simulatorAlertPresented = false
    
    var body: some View {
        ZStack {
            Color(Color(hex:0xF7F2E4))
                .ignoresSafeArea()
                .overlay(
                    VStack {
                        HStack {
                            if let user = profileViewModel.user {
                                if let photoUrl = user.photoUrl {
                                    AsyncImage(url: URL(string: photoUrl)) { image in
                                        image.resizable()
                                            .clipped()
                                            .aspectRatio(contentMode: .fill)
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipShape(Circle())
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .onTapGesture {
                                        showPhotoSheet.toggle()
                                    }
                                    .confirmationDialog("Select A Profile Photo", isPresented: $showPhotoSheet) {
                                        Button {
                                            showPhotoLibrary.toggle()
                                        } label: {
                                            Text("Upload From Photo Library")
                                        }
                                        Button {
                                            #if targetEnvironment(simulator)
                                            simulatorAlertPresented.toggle()
                                            #else
                                            showCamera.toggle()
                                            #endif
                                        } label: {
                                            Text("Take Photo")
                                        }
                                    }
                                    .sheet(isPresented: $showPhotoLibrary, onDismiss: nil) {
                                        ImagePicker(selectedPhoto: $selectedPhoto, showPhotoLibrary: $showPhotoLibrary, showCamera: $showCamera)
                                    }
                                    .sheet(isPresented: $showCamera, onDismiss: nil) {
                                        ImagePicker(selectedPhoto: $selectedPhoto, showPhotoLibrary: $showPhotoLibrary, showCamera: $showCamera)
                                    }
                                    .onChange(of: selectedPhoto) {
                                        uploadPhoto()
                                        retrievePhotos()
                                    }
                                }
                                VStack {
                                    HStack {
                                        Text("\(user.first_name)")
                                        Text("\(user.last_name)")
                                    }
                                    if let bio = user.bio {
                                        Text("\(bio)")
                                    }
                                }
                            }
                            Spacer()
                        }
                        Button("Edit Profile Picture") {
                            showPhotoSheet.toggle()
                        }
                        .frame(maxWidth: .infinity, maxHeight: 60)
                        .foregroundColor(Color.black)
                        .background(Color(hex: 0xCCC3A8))
                        .cornerRadius(10)
                        .padding(.top, 7)
                        .padding(.leading, 5)
                        .padding(.trailing, 5)
                        .onTapGesture {
                            showPhotoSheet.toggle()
                        }
                        .confirmationDialog("Select A Profile Photo", isPresented: $showPhotoSheet) {
                            Button {
                                showPhotoLibrary.toggle()
                            } label: {
                                Text("Upload From Photo Library")
                            }
                            Button {
                                #if targetEnvironment(simulator)
                                simulatorAlertPresented.toggle()
                                #else
                                showCamera.toggle()
                                #endif
                            } label: {
                                Text("Take Photo")
                            }
                        }
                        .sheet(isPresented: $showPhotoLibrary, onDismiss: nil) {
                            ImagePicker(selectedPhoto: $selectedPhoto, showPhotoLibrary: $showPhotoLibrary, showCamera: $showCamera)
                        }
                        .sheet(isPresented: $showCamera, onDismiss: nil) {
                            ImagePicker(selectedPhoto: $selectedPhoto, showPhotoLibrary: $showPhotoLibrary, showCamera: $showCamera)
                        }
                        .onChange(of: selectedPhoto) {
                            uploadPhoto()
                            retrievePhotos()
                        }

                       
                        NavigationLink(destination: PickGenresView(showSignInView: $showSignInView)) {
                            Text("Edit Favorite Genres")
                                .frame(maxWidth: .infinity, maxHeight: 60)
                                .foregroundColor(Color.black)
                                .background(Color(hex: 0xCCC3A8))
                                .cornerRadius(10)
                                .padding(.top, 7)
                                .padding(.leading, 5)
                                .padding(.trailing, 5)
                        }
                        NavigationLink(destination: EditInfoView(showSignInView: $showSignInView)) {
                            Text("Edit Information")
                                .frame(maxWidth: .infinity, maxHeight: 60)
                                .foregroundColor(Color.black)
                                .background(Color(hex: 0xCCC3A8))
                                .cornerRadius(10)
                                .padding(.top, 7)
                                .padding(.leading, 5)
                                .padding(.trailing, 5)
                        }
                        Button("Log Out") {
                            Task {
                                do {
                                    try settingsViewModel.signOut()
                                    showSignInView = true
                                } catch {
                                    print(error)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: 60)
                        .foregroundColor(Color.black)
                        .background(Color(hex: 0xCCC3A8))
                        .cornerRadius(10)
                        .padding(.top, 7)
                        .padding(.leading, 5)
                        .padding(.trailing, 5)
                    }
                )
                .task {
                    try? await profileViewModel.loadCurrentUser()
                }
                .navigationBarTitle("Settings")
                
        }
        .alert(isPresented: $simulatorAlertPresented) {
            Alert(title: Text("Unavailable on Simulator"), message: Text("Camera functionality is not available on the simulator. Use real device to use this feature"), dismissButton: .default(Text("OK")))
        }.onReceive(profileViewModel.$user) { user in
            photoURL = user?.photoUrl ?? ""
        }
    }
    
    func uploadPhoto() {
        guard selectedPhoto != nil else {
                return
            }
        
        //create reference to storage
        let storageRef = Storage.storage().reference()
        
        //turn our image into data
        let photoData =  selectedPhoto!.jpegData(compressionQuality: 0.8)
        
        guard photoData != nil else {
                return
            }
        //specify path where to upload image in firebase storage
        let path = "images/\(UUID().uuidString).jpg"
        let profilePicRef = storageRef.child(path)
        
        let uploadTask = profilePicRef.putData(photoData!, metadata: nil) { (metadata, error) in
            if error == nil && metadata != nil {
                let db = Firestore.firestore()
                db.collection("users").document((profileViewModel.user?.userId)!).updateData(["path_to_photo": path])
            }
        }
    }
    
    func retrievePhotos(){
        Firestore.firestore().collection("users").document((profileViewModel.user?.userId)!).getDocument {
            snapshot, error in
            if error == nil && snapshot != nil {
                
                let storageRef = Storage.storage().reference()
                let doc = snapshot?.data()
                let path = doc!["path_to_photo"] as! String
                let profilePicRef = storageRef.child(path)
                
                profilePicRef.getData(maxSize: 5 * 1024 * 1024){ data, error in
                    if error == nil {
                        profilePicRef.downloadURL { url, error in
                            
                            guard let downloadURL = url else {
                                print("Download URL is nil")
                                return
                            }
                            
                            DispatchQueue.main.async {
                                Firestore.firestore().collection("users").document((profileViewModel.user?.userId)!).updateData(["photo_url": downloadURL.absoluteString])
                            }
                            
                            photoURL = (profileViewModel.user?.photoUrl)!
                        }
                        
                    }
                }
            }
        }
    }
        
   
}

extension UIImageView {

   func setRounded() {
      let radius = CGRectGetWidth(self.frame) / 2
      self.layer.cornerRadius = radius
      self.layer.masksToBounds = true
   }
}


//
//import SwiftUI
//import Alamofire
//import PhotosUI
//import Firebase
//import FirebaseFirestore
//import FirebaseFirestoreSwift
//import FirebaseStorage
//
//
//struct SettingsView: View {
//    @StateObject private var settingsViewModel = SettingsViewModel()
//    @StateObject private var profileViewModel = ProfileViewModel()
//    
//    @State var showPhotoSheet = false
//    @State var showPhotoLibrary = false
//    @State var selectedPhoto: UIImage?
//    @State var profileImage = Image("")
//    @State var photoURL = ""
//    @State private var photoUrlTrigger = UUID()
//    
//    @Binding var showSignInView: Bool
//    let bookAPIManager = BookAPIManager.shared
//    
//    @State private var showEditGenrePage = false
//    @State var showCamera = false
//    
//    var body: some View {
//        ZStack{
//            Color(Color(hex:0xF7F2E4))
//                .ignoresSafeArea()
//                .overlay(
//                    
//                    VStack{
//                        HStack{
//                            if let user = profileViewModel.user{
//                                
//                                if let photoUrl = user.photoUrl {
//                                    AsyncImage(url: URL(string: photoUrl)) { image in
//                                        image.resizable()
//                                            .clipped()
//                                            .aspectRatio(contentMode: .fill)
//                                            .scaledToFill()
//                                            .frame(width: 100, height: 100)
//                                            .clipShape(Circle())
//                                            
//                                    } placeholder: {
//                                        ProgressView()
//                                    }
//                                    
//                                    //.clipShape(Circle())
//                                    .onTapGesture {
//                                        showPhotoSheet.toggle()
//                                    }
//                                    .confirmationDialog("Select A Profile Photo", isPresented: $showPhotoSheet){
//                                        Button {
//                                            showPhotoLibrary.toggle()
//                                        } label: {
//                                            Text("Photo Library")
//                                        }
//                                    }
//                                    .sheet(isPresented: $showPhotoLibrary, onDismiss: nil) {
//                                        ImagePicker(selectedPhoto: $selectedPhoto, showPhotoLibrary: $showPhotoLibrary, showCamera: $showCamera)
//                                        
//                                    }
//                                    .onChange(of: selectedPhoto){
//                                        uploadPhoto()
//                                        retrievePhotos()
//                                    }
//                                    
//                                    
//                                }
//                                
//                                VStack {
//                                    
//                                    HStack{
//                                        Text("\(user.first_name)")
//                                        
//                                        
//                                        Text("\(user.last_name)")
//                                    }
//                                    
//                                    if let bio = user.bio  {
//                                        Text("\(bio)")
//                                    }
//                                    
//                                }
//                            }
//                            Spacer()
//                            
//                        }
//                        Button("Select from Camera") {
//                            showCamera.toggle()
//                            showPhotoLibrary = true // Always reset showPhotoLibrary when switching to camera
//
//                        }
//                        .frame(maxWidth: .infinity, maxHeight: 60)
//                        .foregroundColor(Color.black)
//                        .background(Color(hex: 0xCCC3A8))
//                        .cornerRadius(10)
//                        .padding(.top, 7)
//                        .padding(.leading, 5)
//                        .padding(.trailing, 5)
//                        .sheet(isPresented: $showPhotoLibrary, onDismiss: nil) {
//                            ImagePicker(selectedPhoto: $selectedPhoto, showPhotoLibrary: $showPhotoLibrary, showCamera: $showCamera)
//                        }
//                        .onChange(of: selectedPhoto) {
//                            uploadPhoto()
//                            retrievePhotos()
//                        }
//                        Button("Edit Profile Picture") {
//                            //showPhotoSheet.toggle()
//                        }.frame(maxWidth: .infinity, maxHeight: 60)
//                            .foregroundColor(Color.black)
//                            .background(Color(hex: 0xCCC3A8))
//                            .cornerRadius(10)
//                            .padding(.top, 7)
//                            .padding(.leading, 5)
//                            .padding(.trailing, 5)
//                            .sheet(isPresented: $showPhotoLibrary, onDismiss: nil) {
//                                ImagePicker(selectedPhoto: $selectedPhoto, showPhotoLibrary: $showPhotoLibrary)
//                            }
//                            .onChange(of: selectedPhoto) {
//                                uploadPhoto()
//                                retrievePhotos()
//                            }
//                  
//                    NavigationLink(destination: PickGenresView(showSignInView: $showSignInView)) {
//                        Text("Edit Favorite Genres")
//                            .frame(maxWidth: .infinity, maxHeight: 60)
//                            .foregroundColor(Color.black)
//                            .background(Color(hex: 0xCCC3A8))
//                            .cornerRadius(10)
//                            .padding(.top, 7)
//                            .padding(.leading, 5)
//                            .padding(.trailing, 5)
//                    }
//                    
//                        NavigationLink(destination: EditInfoView(showSignInView: $showSignInView)) {
//                            Text("Edit Information")
//                                .frame(maxWidth: .infinity, maxHeight: 60)
//                                .foregroundColor(Color.black)
//                                .background(Color(hex: 0xCCC3A8))
//                                .cornerRadius(10)
//                                .padding(.top, 7)
//                                .padding(.leading, 5)
//                                .padding(.trailing, 5)
//                                 }
//                    
//                    
//                    Button("Log Out") {
//                        Task {
//                            do {
//                                try settingsViewModel.signOut()
//                                showSignInView = true
//                            } catch {
//                                print(error)
//                            }
//                        }
//                    }.frame(maxWidth: .infinity, maxHeight: 60)
//                        .foregroundColor(Color.black)
//                        .background(Color(hex: 0xCCC3A8))
//                        .cornerRadius(10)
//                        .padding(.top, 7)
//                        .padding(.leading, 5)
//                        .padding(.trailing, 5)
//                    
//            })
//            .task {
//                try? await profileViewModel.loadCurrentUser()
//            }
//            .navigationBarTitle("Settings")
//            .onAppear {
//                            // Check if camera is available
//                            #if targetEnvironment(simulator)
//                            showCameraOption = false
//                            #else
//                            showCameraOption = UIImagePickerController.isSourceTypeAvailable(.camera)
//                            #endif
//                        }
//        }
//        
//        
//    
//    }
//    

//
//struct SettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationStack {
//            SettingsView(showSignInView: .constant(false))
//        }
//    }
//}

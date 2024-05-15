//
//  ImagePicker.swift
//  HooReads
//
//  Created by Maraki Fanuil on 4/24/24.
//

import Foundation
import UIKit
import SwiftUI

struct ImagePicker: UIViewControllerRepresentable{
    @Binding var selectedPhoto: UIImage?
    @Binding var showPhotoLibrary: Bool
    @Binding var showCamera: Bool
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = context.coordinator
        
        if showCamera {
            imagePicker.sourceType = .camera
        } else {
            imagePicker.sourceType = .photoLibrary
        }
        
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
}

class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    var parent: ImagePicker
    
    init(_ picker: ImagePicker) {
        self.parent = picker
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //run when user has selected an image
        print("image selected")
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            DispatchQueue.main.async{
                self.parent.selectedPhoto = image
            }
        }
        //dismiss the picker
        parent.showPhotoLibrary = false
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //Run code when user has cancelled picker UI
        print("cancelled")
        parent.showPhotoLibrary = false
    }
}

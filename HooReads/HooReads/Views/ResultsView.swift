//
//  ResultsView.swift
//  HooReads
//
//  Created by Maraki Fanuil on 5/3/24.
//

import SwiftUI
import SDWebImageSwiftUI

struct ResultsView: View {
    @Binding var showSignInView: Bool
    var bookInfoSet: [String] // Changed to a regular variable
    
    var body: some View {
        VStack {
            ForEach(bookInfoSet, id: \.self) { bookTitle in
                Text(bookTitle)
            }
        }
    }
}


//
//#Preview {
//    ResultsView()
//}

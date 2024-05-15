//
//  LoggedInContentView.swift
//  HooReads
//
//  Created by Lindsey Jones on 4/15/24.
//

import SwiftUI

struct LoggedInContentView: View {
    @Binding var showSignInView: Bool
    @StateObject private var viewModel = AuthenticationViewModel()
    
    var body: some View {
        HStack {
            Text("HooReads")
                .font(.title)
                .padding()
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
        }
        .background(Color(hex: 0x6D9567))
        TabView {
            NavigationView {
                HomeView(showSignInView: $showSignInView)
            }
            .tabItem {
                Image(systemName: "house")
                Text("Home")
            }

            NavigationView {
                ExploreView(showSignInView: $showSignInView)
            }
            .tabItem {
                Image(systemName: "magnifyingglass")
                Text("Explore")
            }

            NavigationView {
                ProfileView(showSignInView: $showSignInView)
            }
            .tabItem {
                Image(systemName: "person")
                Text("Profile")
            }

            NavigationView {
                SettingsView(showSignInView: $showSignInView)
            }
            .tabItem {
                Image(systemName: "gear")
                Text("Settings")
            }

            NavigationView {
                FriendView()
            }
            .tabItem {
                Image(systemName: "person")
                Text("Friends")
            }
        }

        .accentColor(Color(hex: 0x6D9567))
        .background(Color(hex: 0x6D9567))
        .navigationBarBackButtonHidden(true)
        .onAppear {
            print("newUser: \(self.viewModel.newUser)")
        }
    }
}

extension Color {
    init(hex: Int, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08 ) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: opacity
        )
    }
}
#Preview {
    LoggedInContentView(showSignInView: .constant(false))
}

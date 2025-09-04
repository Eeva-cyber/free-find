//
//  ContentView.swift
//  free_find
//
//  Created by jack ren on 8/30/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var donationStore: DonationStore
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        TabView {
            HomeView()
                .environmentObject(donationStore)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            DonateView()
                .environmentObject(donationStore)
                .tabItem {
                    Image(systemName: "plus.square")
                    Text("Donate")
                }
            
            DiscoverView()
                .environmentObject(donationStore)
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Discover")
                }
            
            MyDonationsView()
                .environmentObject(donationStore)
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("My Items")
                }
            
            AccountView()
                .environmentObject(authManager)
                .environmentObject(donationStore)
                .tabItem {
                    Image(systemName: "person.crop.circle.fill")
                    Text("Account")
                }
        }
        .accentColor(Color(red: 0.18, green: 0.49, blue: 0.20)) // #2E7D32 - primary green
    }
}

#Preview {
    ContentView()
        .environmentObject(DonationStore())
        .environmentObject(AuthenticationManager())
}

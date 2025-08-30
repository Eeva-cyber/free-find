//
//  ContentView.swift
//  free_find
//
//  Created by jack ren on 8/30/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var donationStore = DonationStore()
    
    var body: some View {
        TabView {
            DonateView()
                .tabItem {
                    Image(systemName: "plus.circle")
                    Text("Donate")
                }
            
            DiscoverView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Discover")
                }
            
            MyDonationsView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("My Items")
                }
            
            BackendTestView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Test")
                }
        }
        .environmentObject(donationStore)
    }
}

#Preview {
    ContentView()
}

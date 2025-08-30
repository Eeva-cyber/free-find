//
//  ContentView.swift
//  free_find
//
//  Created by jack ren on 8/30/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            DonateView()
                .tabItem {
                    Image(systemName: "plus.square")
                    Text("Donate")
                }
            
            DiscoverView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Discover")
                }
            
            NotificationsView()
                .tabItem {
                    Image(systemName: "bell.fill")
                    Text("Notifications")
                }
            
            BackendTestView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .accentColor(Color(red: 0.18, green: 0.49, blue: 0.20)) // #2E7D32 - primary green
    }
}

#Preview {
    ContentView()
}

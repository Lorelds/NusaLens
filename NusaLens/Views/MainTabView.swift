//
//  MainTabView.swift
//  NusaLens
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @StateObject private var cultureService = CultureService()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            CultureExplorerView()
                .tabItem {
                    Label("Jelajah", systemImage: "square.grid.2x2.fill")
                }
                .tag(0)
            
            InteractiveMapView()
                .tabItem {
                    Label("Peta", systemImage: "map.fill")
                }
                .tag(1)
            
            DailyTriviaView()
                .tabItem {
                    Label("Trivia", systemImage: "lightbulb.fill")
                }
                .tag(2)
        }
        .environmentObject(cultureService)
    }
}

#Preview {
    MainTabView()
}

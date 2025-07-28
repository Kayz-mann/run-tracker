//
//  AppTabView.swift
//  run-tracker
//
//  Created by Balogun Kayode on 18/03/2025.
//

import SwiftUI

struct AppTabView: View {
    @State var selectedTab = 0
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tag(0)
                .tabItem {
                    Image(systemName: "figure.run")
                    Text("Run")
                }
        ActivityView()
                .tag(1)
                .tabItem{
                    Image(systemName: "chart.bar.fill")
                    
                    Text("Activity")
                }
        }
    }
}

#Preview {
    AppTabView()
}

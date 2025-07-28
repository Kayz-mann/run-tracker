//
//  ContentView.swift
//  run-tracker
//
//  Created by Balogun Kayode on 18/03/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authService: AuthService
    var body: some View {
        if authService.isAuthenticated {
            AppTabView()
        } else {
            LoginView()
        }
    }
}
 
#Preview {
    ContentView()
}

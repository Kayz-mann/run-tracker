//
//  running_club_latestApp.swift
//  running-club-latest
//
//  Created by Balogun Kayode on 25/04/2025.
//

import SwiftUI
import GoogleSignIn

@main
struct running_club_latestApp: App {
    @StateObject private var authService = AuthService.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
//                .onOpenURL { url in
//                    GIDSignIn.sharedInstance.handle(url)
//                }
        }
    }
}

//
//  File.swift
//  run-tracker
//
//  Created by Balogun Kayode on 09/04/2025.
//

import Foundation
import Supabase
import GoogleSignIn
import _AuthenticationServices_SwiftUI

class AuthService: ObservableObject {
    static let shared = AuthService()
    private var supabase = SupabaseClient(supabaseURL: Secrets.supabaseURL, supabaseKey: Secrets.supabaseKEY)
    
    @Published var currentSession: Session?
    @Published var isAuthenticated = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    
    
    private init() { }
    
    func magicLinkLogin(email: String) async throws {
        try await supabase.auth.signInWithOTP(
            email: email,
            redirectTo: URL(string: "https://pzckaxubrkzgaelxnern.supabase.co/auth/v1/callback")
        )
    }
    
    func handleOpenURL(url: URL) async throws {
        currentSession = try await supabase.auth.session(from: url)
        if currentSession != nil {
            DispatchQueue.main.async {
                self.isAuthenticated = true
            }
        }
    }
    
    func signInWithGoogle() async throws -> AppUser {
        guard let topVC = UIApplication.shared.windows.first?.rootViewController else {
            throw AuthError.noRootViewController
        }
        
        // Create a continuation to bridge the callback-based GIDSignIn API with async/await
        return try await withCheckedThrowingContinuation { continuation in
            GIDSignIn.sharedInstance.signIn(withPresenting: topVC) { signInResult, error in
                // Handle any errors from Google Sign-In
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                // Ensure we have a valid user and ID token
                guard let user = signInResult?.user else {
                    continuation.resume(throwing: AuthError.noSignInResult)
                    return
                }
                
                guard let idToken = user.idToken?.tokenString else {
                    continuation.resume(throwing: AuthError.noIdToken)
                    return
                }
                let nonce = UUID().uuidString
                
                // Use Task to handle the async Supabase call within the callback
                Task {
                    do {
                        // Sign in to Supabase with the Google ID token
                        let session = try await self.supabase.auth.signInWithIdToken(
                            credentials: .init(provider: .google, idToken: idToken, nonce: nonce)
                        )
                        
                        // Update authentication state
                        DispatchQueue.main.async {
                            self.currentSession = session
                            self.isAuthenticated = true
                        }
                        
                        // Create and return the AppUser
                        let appUser = AppUser(
                            uid: session.user.id,
                            session: session.user.id.uuidString,
                            email: session.user.email ?? ""
                        )
                        
                        continuation.resume(returning: appUser)
                    } catch {
                      print("ER",error)
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
    
    func signOut() async throws {
        try await supabase.auth.signOut()
        DispatchQueue.main.async {
            self.currentSession = nil
            self.isAuthenticated = false
        }
    }
}


// Custom errors
enum AuthError: Error {
    case noRootViewController
    case noSignInResult
    case noIdToken
}

struct AppUser {
    var uid: UUID
    var session: String
    var email: String
}

struct Secrets {
    static let supabaseURL = URL(string: "https://pzckaxubrkzgaelxnern.supabase.co")!
    static let supabaseKEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB6Y2theHVicmt6Z2FlbHhuZXJuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc2NjA4NzcsImV4cCI6MjA2MzIzNjg3N30.X9v8Lq8ZQLZJBtbiyRgkUFd8OdLzpKftlz9_wxWwHVc"
}

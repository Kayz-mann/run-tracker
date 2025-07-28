//
//  LoginView.swift
//  running-club-latest
//
//  Created by Balogun Kayode on 25/04/2025.
//

// LoginView.swift
import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var isLoading = false
    @EnvironmentObject private var authService: AuthService
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.6)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Content
            VStack(spacing: 30) {
                // Logo and Header
                VStack(spacing: 15) {
                    Image(systemName: "figure.run.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.white)
                    
                    Text("Running Club")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Track your runs. Join the community.")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.bottom, 30)
                
                // Login Form
                VStack(spacing: 20) {
                    // Email field
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.gray)
                            .padding(.leading, 8)
                        
                        TextField("Email address", text: $email)
                            .padding()
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
                    
                    // Google Sign-In Button
                    Button {
                        handleGoogleSignIn()
                    } label: {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                    .padding(.trailing, 5)
                            } else {
                                Image(systemName: "g.circle.fill")
                                    .resizable()
                                    .frame(width: 22, height: 22)
                                    .padding(.trailing, 5)
                            }
                            
                            Text(isLoading ? "Signing in..." : "Sign in with Google")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .disabled(isLoading)
                    
                    // Magic Link Button
                    Button {
                        handleMagicLink()
                    } label: {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.trailing, 5)
                            } else {
                                Image(systemName: "link.circle.fill")
                                    .resizable()
                                    .frame(width: 22, height: 22)
                                    .padding(.trailing, 5)
                            }
                            
                            Text(isLoading ? "Sending link..." : "Send Magic Link")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            email.isEmpty ? Color.blue.opacity(0.5) : Color.blue
                        )
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
                    }
                    .disabled(email.isEmpty || isLoading)
                    
                    // Guest Mode Button
                    Button {
                        // Handle guest login
                    } label: {
                        Text("Continue as Guest")
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.top, 8)
                    }
                }
                .padding(.horizontal, 24)
            }
            .padding(.vertical, 30)
        }
        .alert(isPresented: $authService.showError) {
            Alert(
                title: Text("Login Error"),
                message: Text(authService.errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func handleGoogleSignIn() {
        isLoading = true
        
        Task {
            do {
                try await authService.signInWithGoogle()
                isLoading = false
            } catch {
                await MainActor.run {
                    authService.errorMessage = error.localizedDescription
                    authService.showError = true
                    isLoading = false
                }
            }
        }
    }
    
    private func handleMagicLink() {
        isLoading = true
        
        Task {
            do {
                try await authService.magicLinkLogin(email: email)
                await MainActor.run {
                    isLoading = false
                    // Show success message or notification
                }
            } catch {
                await MainActor.run {
                    authService.errorMessage = error.localizedDescription
                    authService.showError = true
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthService.shared)
}

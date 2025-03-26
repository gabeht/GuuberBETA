//
//  ContentView.swift
//  GuuberBETA
//
//  Created by Gabe Holte on 2/24/25.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var buttonColor: Color = .green
    @State private var shakeUsernameField: Bool = false
    @State private var highlightUsernameField: Bool = false
    @FocusState private var focusedField: Field?
    @State private var showCreateAccount = false
    @StateObject private var firebaseService = FirebaseService()
    @StateObject private var googleSignInService = GoogleSignInService()
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                    .frame(height: 120) // Reduced from 150
                
                // Logo
                HStack {
                    Image(systemName: "car.fill")
                        .imageScale(.large)
                        .foregroundColor(Color.green)
                    Text("GÜHBER")
                        .font(.title) // Changed from .largeTitle
                        .fontWeight(.bold)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .multilineTextAlignment(.center)
                    Text("BETA")
                        .foregroundColor(Color.green)
                }
                
                Spacer()
                    .frame(height: 40) // Reduced from 50
                
                // Login or Create Account Text
                Text("Log in or Create Account")
                    .font(.system(size: 26, weight: .bold)) // Increased from 24 to 26
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .lineLimit(1)
                
                Spacer()
                    .frame(height: 25) // Reduced from 30
                
                // Username Field
                TextField("Username", text: $username, onCommit: {
                    if isValidUsername(username) {
                        // Handle valid username
                    } else {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.5)) {
                            shakeUsernameField = true
                            highlightUsernameField = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            withAnimation {
                                shakeUsernameField = false
                                highlightUsernameField = false
                            }
                        }
                    }
                })
                .textFieldStyle(SoftRoundedTextFieldStyle(highlight: highlightUsernameField))
                .modifier(ShakeEffect(animatableData: shakeUsernameField ? 1 : 0))
                .frame(width: 340, height: 55)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .font(.system(size: 18, weight: .bold, design: .default))
                .focused($focusedField, equals: .username)
                
                // Password Field (appears after username is entered)
                if !username.isEmpty {
                    SecureField("Password", text: $password)
                        .textFieldStyle(SoftRoundedTextFieldStyle(highlight: false))
                        .frame(width: 340, height: 55)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .font(.system(size: 18, weight: .bold, design: .default))
                        .focused($focusedField, equals: .password)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
                
                // Continue Button
                Button(action: {
                    // Handle continue action
                }) {
                    Text("Continue")
                        .font(.system(size: 18, weight: .bold, design: .default))
                        .foregroundColor(.white)
                        .frame(width: 340, height: 55)
                        .background(buttonColor)
                        .cornerRadius(15)
                }
                
                // Or text
                Text("or")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.green)
                    .padding(.vertical, 8)
                
                // Create Account Button
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        showCreateAccount = true
                    }
                }) {
                    HStack {
                        Text("GÜ")
                            .font(.system(size: 18, weight: .bold, design: .default))
                            .foregroundColor(.green)
                        Text("Create an Account")
                            .font(.system(size: 18, weight: .bold, design: .default))
                    }
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .frame(width: 340, height: 55)
                    .background(colorScheme == .dark ? Color(.systemGray6) : .white)
                    .cornerRadius(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(colorScheme == .dark ? Color.clear : Color.black.opacity(0.2), lineWidth: 1)
                    )
                }
                .navigationDestination(isPresented: $showCreateAccount) {
                    CreateAccountScreen()
                }
                
                // Continue with Google Button
                Button(action: {
                    Task {
                        do {
                            try await googleSignInService.signIn()
                            // Handle successful sign in
                        } catch {
                            showError = true
                            errorMessage = error.localizedDescription
                        }
                    }
                }) {
                    HStack {
                        Image("google_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                        Text("Continue with Google")
                            .font(.system(size: 18, weight: .bold, design: .default))
                    }
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .frame(width: 340, height: 55)
                    .background(colorScheme == .dark ? Color(.systemGray6) : .white)
                    .cornerRadius(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(colorScheme == .dark ? Color.clear : Color.black.opacity(0.2), lineWidth: 1)
                    )
                }
                
                // Continue with Apple Button
                Button(action: {
                    // Handle Apple sign in
                }) {
                    HStack {
                        Image(systemName: "apple.logo")
                            .imageScale(.large)
                        Text("Continue with Apple")
                            .font(.system(size: 18, weight: .bold, design: .default))
                    }
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .frame(width: 340, height: 55)
                    .background(colorScheme == .dark ? Color(.systemGray6) : .white)
                    .cornerRadius(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(colorScheme == .dark ? Color.clear : Color.black.opacity(0.2), lineWidth: 1)
                    )
                }
                
                // Legal Text
                Text("By signing up, you are creating a GÜHBER account and agree to our Terms of Service and Privacy Policy")
                    .font(.system(size: 13))
                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.6) : Color.black.opacity(0.4))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.top, 15)
                    .padding(.bottom, 20)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: username)
            .sheet(isPresented: $showCreateAccount) {
                CreateAccountScreen()
            }
            .sheet(isPresented: $googleSignInService.showCompleteRegistration) {
                CompleteRegistration(googleSignInService: googleSignInService)
            }
        }
    }
    
    private func isValidUsername(_ username: String) -> Bool {
        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_"))
        return !username.isEmpty && username.unicodeScalars.allSatisfy { allowedCharacters.contains($0) }
    }
    
    private enum Field: Hashable {
        case username
        case password
    }
}

#Preview {
    MainView()
        .modelContainer(for: Item.self, inMemory: true)
}


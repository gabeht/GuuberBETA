//
//  LoginScreen.swift
//  GuuberBETA
//
//  Created by Gabe Holte on 3/5/25.


import SwiftUI

struct SecondaryLoginScreen: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var reenterPassword: String = ""
    @State private var isPasswordFieldVisible: Bool = false
    @State private var isReenterPasswordFieldVisible: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                Spacer(minLength: 50) // Adjusted to move fields higher
                
                // Username Field (Centered)
                TextField("Username", text: $username, onCommit: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.5)) {
                        isPasswordFieldVisible = true
                    }
                })
                .textFieldStyle(SoftRoundedTextFieldStyle())
                .frame(width: 280, height: 50)
                .autocapitalization(.words)
                .disableAutocorrection(true)
                .font(.system(size: 18, weight: .bold, design: .default))
                .onChange(of: username) { oldValue, newValue in
                    password = ""
                    reenterPassword = ""
                    if isPasswordFieldVisible {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.5)) {
                            isPasswordFieldVisible = false
                            isReenterPasswordFieldVisible = false
                        }
                    }
                }

                // Password Field (Centered and animated)
                if isPasswordFieldVisible {
                    SecureField("Password", text: $password, onCommit: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.5)) {
                            isReenterPasswordFieldVisible = true
                        }
                    })
                    .textFieldStyle(SoftRoundedTextFieldStyle())
                    .frame(width: 280, height: 50)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity.combined(with: .move(edge: .top))
                    ))
                    .font(.system(size: 18, weight: .bold, design: .default))
                    .onChange(of: password) { oldValue, newValue in
                        reenterPassword = ""
                        if isReenterPasswordFieldVisible {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.5)) {
                                isReenterPasswordFieldVisible = false
                            }
                        }
                    }
                }

                // Re-Enter Password Field (Centered and animated)
                if isReenterPasswordFieldVisible {
                    SecureField("Re-Enter Password", text: $reenterPassword)
                        .textFieldStyle(SoftRoundedTextFieldStyle())
                        .frame(width: 280, height: 50)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .top)),
                            removal: .opacity.combined(with: .move(edge: .top))
                        ))
                        .font(.system(size: 18, weight: .bold, design: .default))
                }

                Spacer() // Push content up
            }
            .padding()
            .navigationTitle("Login")
        }
    }
}

// Custom TextField Style for Soft Rounded Corners
struct SoftRoundedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
    }
}


#Preview {
    SecondaryLoginScreen()
        .modelContainer(for: Item.self, inMemory: true)
}


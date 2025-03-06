//
//  LoginScreen.swift
//  GuuberBETA
//
//  Created by Gabe Holte on 3/5/25.


import SwiftUI

struct CreateAccountScreen: View {
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var reenterPassword: String = ""
    @State private var isUsernameFieldVisible: Bool = false
    @State private var isPasswordFieldVisible: Bool = false
    @State private var isReenterPasswordFieldVisible: Bool = false
    @State private var navigateToPhoneNumberVer: Bool = false // State to control navigation

    var body: some View {
        NavigationStack {
            VStack {
                Spacer(minLength: 20) // Reduced spacer to bring content closer to the top

                // First Name and Last Name Fields
                HStack(spacing: 10) {
                    TextField("First Name", text: $firstName, onCommit: {
                        // Triggered when the user hits "Enter" on the First Name field
                        if !firstName.isEmpty && !lastName.isEmpty {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.5)) {
                                isUsernameFieldVisible = true
                            }
                        }
                    })
                    .textFieldStyle(SoftRoundedTextFieldStyle())
                    .frame(width: 180, height: 50) // Increased width
                    .autocapitalization(.words)
                    .disableAutocorrection(true)
                    .font(.system(size: 20, weight: .bold, design: .default))

                    TextField("Last Name", text: $lastName, onCommit: {
                        // Triggered when the user hits "Enter" on the Last Name field
                        if !firstName.isEmpty && !lastName.isEmpty {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.5)) {
                                isUsernameFieldVisible = true
                            }
                        }
                    })
                    .textFieldStyle(SoftRoundedTextFieldStyle())
                    .frame(width: 180, height: 50) // Increased width
                    .autocapitalization(.words)
                    .disableAutocorrection(true)
                    .font(.system(size: 20, weight: .bold, design: .default))
                }

                // Username Field (Centered and animated)
                if isUsernameFieldVisible {
                    TextField("Username", text: $username, onCommit: {
                        // Triggered when the user hits "Enter" on the Username field
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.5)) {
                            isPasswordFieldVisible = true
                        }
                    })
                    .textFieldStyle(SoftRoundedTextFieldStyle())
                    .frame(width: 370, height: 50) // Increased width
                    .autocapitalization(.words)
                    .disableAutocorrection(true)
                    .font(.system(size: 20, weight: .bold, design: .default))
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity.combined(with: .move(edge: .top))
                    ))
                    .onChange(of: username) { newValue in
                        // Clear password and re-enter password fields if username changes
                        password = ""
                        reenterPassword = ""
                        if isPasswordFieldVisible {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.5)) {
                                isPasswordFieldVisible = false
                                isReenterPasswordFieldVisible = false
                            }
                        }
                    }
                }

                // Password Field (Centered and animated)
                if isPasswordFieldVisible {
                    SecureField("Password", text: $password, onCommit: {
                        // Triggered when the user hits "Enter" on the Password field
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.5)) {
                            isReenterPasswordFieldVisible = true
                        }
                    })
                    .textFieldStyle(SoftRoundedTextFieldStyle())
                    .frame(width: 370, height: 50) // Increased width
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity.combined(with: .move(edge: .top))
                    ))
                    .font(.system(size: 20, weight: .bold, design: .default))
                    .onChange(of: password) { newValue in
                        // Clear re-enter password field if password changes
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
                    SecureField("Re-Enter Password", text: $reenterPassword, onCommit: {
                        // Triggered when the user hits "Enter" on the Re-Enter Password field
                        if password == reenterPassword {
                            navigateToPhoneNumberVer = true // Navigate if passwords match
                        } else {
                            // Show an error or handle mismatched passwords
                            print("Passwords do not match!")
                        }
                    })
                    .textFieldStyle(SoftRoundedTextFieldStyle())
                    .frame(width: 370, height: 50) // Increased width
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity.combined(with: .move(edge: .top))
                    ))
                    .font(.system(size: 20, weight: .bold, design: .default))
                }
            }
            .padding(.horizontal) // Add horizontal padding only
            .navigationTitle("Create Account")
            .background(
                NavigationLink(destination: PhoneNumberVer(), isActive: $navigateToPhoneNumberVer) {
                    EmptyView()
                }
            )
        }
    }
}

// Custom TextField Style for Soft Rounded Corners
struct SoftRoundedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(10)
            .background(Color(.systemGray6)) // Soft background color
            .cornerRadius(15) // Rounded corners
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color(.systemGray4), lineWidth: 1) // Soft border
            )
    }
}
#Preview {
    CreateAccountScreen()
        .modelContainer(for: Item.self, inMemory: true)
}


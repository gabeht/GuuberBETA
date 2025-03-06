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
    @State private var showContinueButton: Bool = false // State to control button visibility

    // Customizable button color
    @State private var buttonColor: Color = .green // You can change this to any color

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
                                showContinueButton = false // Hide button if username changes
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
                                showContinueButton = false // Hide button if password changes
                            }
                        }
                    }
                }

                // Re-Enter Password Field (Centered and animated)
                if isReenterPasswordFieldVisible {
                    SecureField("Re-Enter Password", text: $reenterPassword, onCommit: {
                        // Triggered when the user hits "Enter" on the Re-Enter Password field
                        if password == reenterPassword {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.5)) {
                                showContinueButton = true // Show button if passwords match
                            }
                        } else {
                            showContinueButton = false // Hide button if passwords don't match
                        }
                    })
                    .textFieldStyle(SoftRoundedTextFieldStyle())
                    .frame(width: 370, height: 50) // Increased width
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity.combined(with: .move(edge: .top))
                    ))
                    .font(.system(size: 20, weight: .bold, design: .default))
                    .onChange(of: reenterPassword) { newValue in
                        // Check if passwords match and show/hide button accordingly
                        if password == reenterPassword {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.5)) {
                                showContinueButton = true
                            }
                        } else {
                            showContinueButton = false
                        }
                    }
                }

                // Continue Button (Animated)
                if showContinueButton {
                    Button(action: {
                        navigateToPhoneNumberVer = true // Navigate to the next screen
                    }) {
                        Text("Continue")
                            .font(.system(size: 20, weight: .bold, design: .default))
                            .foregroundColor(.white) // Text color changes based on colorScheme
                            .frame(width: 370, height: 60) // Slightly taller than text fields
                            .background(buttonColor) // Use the customizable button color
                            .cornerRadius(15)
                            .padding(.top, 10) // Add some spacing between the button and the re-enter password field
                    }
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity.combined(with: .move(edge: .top))
                    ))
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


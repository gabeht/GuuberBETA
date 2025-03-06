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
    @State private var buttonColor: Color = .blue // You can change this to any color

    // Shake animation state
    @State private var shakeReenterPasswordField: Bool = false

    // Highlight state
    @State private var highlightReenterPasswordField: Bool = false

    // Focus state for each field
    @FocusState private var focusedField: Field?

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
                                focusedField = .lastName // Move focus to Last Name
                            }
                        }
                    })
                    .textFieldStyle(SoftRoundedTextFieldStyle())
                    .frame(width: 180, height: 50) // Increased width
                    .autocapitalization(.words)
                    .disableAutocorrection(true)
                    .font(.system(size: 20, weight: .bold, design: .default))
                    .focused($focusedField, equals: .firstName) // Bind focus state
                    .onChange(of: firstName) { newValue in
                        // Remove spaces from the First Name field
                        firstName = newValue.replacingOccurrences(of: " ", with: "")
                        // If First Name changes, reset everything below it
                        resetFieldsBelow(.firstName)
                    }

                    TextField("Last Name", text: $lastName, onCommit: {
                        // Triggered when the user hits "Enter" on the Last Name field
                        if !firstName.isEmpty && !lastName.isEmpty {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.5)) {
                                isUsernameFieldVisible = true
                                focusedField = .username // Move focus to Username
                            }
                        }
                    })
                    .textFieldStyle(SoftRoundedTextFieldStyle())
                    .frame(width: 180, height: 50) // Increased width
                    .autocapitalization(.words)
                    .disableAutocorrection(true)
                    .font(.system(size: 20, weight: .bold, design: .default))
                    .focused($focusedField, equals: .lastName) // Bind focus state
                    .onChange(of: lastName) { newValue in
                        // Remove spaces from the Last Name field
                        lastName = newValue.replacingOccurrences(of: " ", with: "")
                        // If Last Name changes, reset everything below it
                        resetFieldsBelow(.lastName)
                    }
                }

                // Username Field (Centered and animated)
                if isUsernameFieldVisible {
                    TextField("Username", text: $username, onCommit: {
                        // Triggered when the user hits "Enter" on the Username field
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.5)) {
                            isPasswordFieldVisible = true
                            focusedField = .password // Move focus to Password
                        }
                    })
                    .textFieldStyle(SoftRoundedTextFieldStyle())
                    .frame(width: 370, height: 50) // Increased width
                    .autocapitalization(.words)
                    .disableAutocorrection(true)
                    .font(.system(size: 20, weight: .bold, design: .default))
                    .focused($focusedField, equals: .username) // Bind focus state
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity.combined(with: .move(edge: .top))
                    ))
                    .onChange(of: username) { newValue in
                        // Remove spaces from the Username field
                        username = newValue.replacingOccurrences(of: " ", with: "")
                        // If Username changes, reset everything below it
                        resetFieldsBelow(.username)
                    }
                }

                // Password Field (Centered and animated)
                if isPasswordFieldVisible {
                    SecureField("Password", text: $password, onCommit: {
                        // Triggered when the user hits "Enter" on the Password field
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.5)) {
                            isReenterPasswordFieldVisible = true
                            focusedField = .reenterPassword // Move focus to Re-Enter Password
                        }
                    })
                    .textFieldStyle(SoftRoundedTextFieldStyle())
                    .frame(width: 370, height: 50) // Increased width
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity.combined(with: .move(edge: .top))
                    ))
                    .font(.system(size: 20, weight: .bold, design: .default))
                    .focused($focusedField, equals: .password) // Bind focus state
                    .onChange(of: password) { newValue in
                        // Remove spaces from the Password field
                        password = newValue.replacingOccurrences(of: " ", with: "")
                        // If Password changes, reset everything below it
                        resetFieldsBelow(.password)
                    }
                }

                // Re-Enter Password Field (Centered and animated)
                if isReenterPasswordFieldVisible {
                    SecureField("Re-Enter Password", text: $reenterPassword, onCommit: {
                        // Triggered when the user hits "Enter" on the Re-Enter Password field
                        if password == reenterPassword {
                            navigateToPhoneNumberVer = true // Navigate to the next screen
                        } else {
                            // Shake and highlight the Re-Enter Password field
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.5)) {
                                shakeReenterPasswordField = true
                                highlightReenterPasswordField = true
                            }
                            // Reset the shake and highlight after a short delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                withAnimation {
                                    shakeReenterPasswordField = false
                                    highlightReenterPasswordField = false
                                }
                            }
                        }
                    })
                    .textFieldStyle(SoftRoundedTextFieldStyle(highlight: highlightReenterPasswordField))
                    .frame(width: 370, height: 50) // Increased width
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity.combined(with: .move(edge: .top))
                    ))
                    .font(.system(size: 20, weight: .bold, design: .default))
                    .focused($focusedField, equals: .reenterPassword) // Bind focus state
                    .modifier(ShakeEffect(animatableData: shakeReenterPasswordField ? 1 : 0)) // Shake effect
                    .onChange(of: reenterPassword) { newValue in
                        // Remove spaces from the Re-Enter Password field
                        reenterPassword = newValue.replacingOccurrences(of: " ", with: "")
                        // Check if passwords match in real-time
                        if password == reenterPassword {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.5)) {
                                showContinueButton = true
                            }
                        } else {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.5)) {
                                showContinueButton = false
                            }
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
            .onAppear {
                // Set initial focus to the First Name field
                focusedField = .firstName
            }
        }
    }

    // Helper function to reset fields below a certain hierarchy level
    private func resetFieldsBelow(_ field: Field) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.5)) {
            switch field {
            case .firstName:
                lastName = ""
                fallthrough
            case .lastName:
                username = ""
                isUsernameFieldVisible = false
                fallthrough
            case .username:
                password = ""
                isPasswordFieldVisible = false
                fallthrough
            case .password:
                reenterPassword = ""
                isReenterPasswordFieldVisible = false
                fallthrough
            case .reenterPassword:
                showContinueButton = false
            }
        }
    }

    // Enum to represent the hierarchy of fields
    private enum Field: Hashable {
        case firstName, lastName, username, password, reenterPassword
    }
}

// Custom TextField Style for Soft Rounded Corners with Highlight
struct SoftRoundedTextFieldStyle: TextFieldStyle {
    var highlight: Bool = false

    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(10)
            .background(Color(.systemGray6)) // Soft background color
            .cornerRadius(15) // Rounded corners
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(highlight ? .red : Color(.systemGray4), lineWidth: 1) // Highlight border if true
            )
    }
}

// Shake Effect Modifier
struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit: CGFloat = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * shakesPerUnit),
            y: 0))
    }
}
#Preview {
    CreateAccountScreen()
        .modelContainer(for: Item.self, inMemory: true)
}


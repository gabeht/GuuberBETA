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
    @State private var navigateToPhoneNumberVer: Bool = false
    @State private var showContinueButton: Bool = false
    @State private var buttonColor: Color = .green
    @State private var shakeReenterPasswordField: Bool = false
    @State private var highlightReenterPasswordField: Bool = false
    @FocusState private var focusedField: Field?

    var body: some View {
        ZStack {
            // Video Background
            VideoBackgroundView(darkModeVideoName: "dark_background", lightModeVideoName: "light_background")
                .blur(radius: 3) // Add slight blur for better text visibility
            
            // Content
            NavigationStack {
                VStack(alignment: .leading, spacing: 10) { // Reduced spacing and aligned to leading edge
                    // First Name and Last Name Fields
                    HStack(spacing: 10) {
                        TextField("First Name", text: $firstName, onCommit: {
                            if !firstName.isEmpty {
                                focusedField = .lastName
                            }
                        })
                        .textFieldStyle(SoftRoundedTextFieldStyle())
                        .frame(width: 180, height: 50)
                        .autocapitalization(.words)
                        .disableAutocorrection(true)
                        .font(.system(size: 20, weight: .bold, design: .default))
                        .focused($focusedField, equals: .firstName)
                        .onChange(of: firstName) { newValue in
                            firstName = newValue.replacingOccurrences(of: " ", with: "")
                            resetFieldsBelow(.firstName)
                        }

                        TextField("Last Name", text: $lastName, onCommit: {
                            if !firstName.isEmpty && !lastName.isEmpty {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.5)) {
                                    isUsernameFieldVisible = true
                                    focusedField = .username
                                }
                            }
                        })
                        .textFieldStyle(SoftRoundedTextFieldStyle())
                        .frame(width: 180, height: 50)
                        .autocapitalization(.words)
                        .disableAutocorrection(true)
                        .font(.system(size: 20, weight: .bold, design: .default))
                        .focused($focusedField, equals: .lastName)
                        .onChange(of: lastName) { newValue in
                            lastName = newValue.replacingOccurrences(of: " ", with: "")
                            resetFieldsBelow(.lastName)
                        }
                    }

                    // Username Field
                    if isUsernameFieldVisible {
                        TextField("Username", text: $username, onCommit: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.5)) {
                                isPasswordFieldVisible = true
                                focusedField = .password
                            }
                        })
                        .textFieldStyle(SoftRoundedTextFieldStyle())
                        .frame(width: 370, height: 50)
                        .autocapitalization(.words)
                        .disableAutocorrection(true)
                        .font(.system(size: 20, weight: .bold, design: .default))
                        .focused($focusedField, equals: .username)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .top)),
                            removal: .opacity.combined(with: .move(edge: .top))
                        ))
                        .onChange(of: username) { newValue in
                            username = newValue.replacingOccurrences(of: " ", with: "")
                            resetFieldsBelow(.username)
                        }
                    }

                    // Password Field
                    if isPasswordFieldVisible {
                        SecureField("Password", text: $password, onCommit: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.5)) {
                                isReenterPasswordFieldVisible = true
                                focusedField = .reenterPassword
                            }
                        })
                        .textFieldStyle(SoftRoundedTextFieldStyle())
                        .frame(width: 370, height: 50)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .top)),
                            removal: .opacity.combined(with: .move(edge: .top))
                        ))
                        .font(.system(size: 20, weight: .bold, design: .default))
                        .focused($focusedField, equals: .password)
                        .onChange(of: password) { newValue in
                            password = newValue.replacingOccurrences(of: " ", with: "")
                            resetFieldsBelow(.password)
                        }
                    }

                    // Re-Enter Password Field
                    if isReenterPasswordFieldVisible {
                        SecureField("Re-Enter Password", text: $reenterPassword, onCommit: {
                            if password == reenterPassword {
                                navigateToPhoneNumberVer = true
                            } else {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.5)) {
                                    shakeReenterPasswordField = true
                                    highlightReenterPasswordField = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                    withAnimation {
                                        shakeReenterPasswordField = false
                                        highlightReenterPasswordField = false
                                    }
                                }
                            }
                        })
                        .textFieldStyle(SoftRoundedTextFieldStyle(highlight: highlightReenterPasswordField))
                        .frame(width: 370, height: 50)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .top)),
                            removal: .opacity.combined(with: .move(edge: .top))
                        ))
                        .font(.system(size: 20, weight: .bold, design: .default))
                        .focused($focusedField, equals: .reenterPassword)
                        .modifier(ShakeEffect(animatableData: shakeReenterPasswordField ? 1 : 0))
                        .onChange(of: reenterPassword) { newValue in
                            reenterPassword = newValue.replacingOccurrences(of: " ", with: "")
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

                    // Continue Button
                    if showContinueButton {
                        Button(action: {
                            navigateToPhoneNumberVer = true
                        }) {
                            Text("Continue")
                                .font(.system(size: 20, weight: .bold, design: .default))
                                .foregroundColor(.white)
                                .frame(width: 370, height: 60)
                                .background(buttonColor)
                                .cornerRadius(15)
                                .padding(.top, 10)
                        }
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .top)),
                            removal: .opacity.combined(with: .move(edge: .top))
                        ))
                    }
                }
                .padding(.horizontal, 20) // Reduced horizontal padding
                .padding(.top, -20) // Negative top padding to pull content up
                .navigationTitle("Create Account")
                .background(
                    NavigationLink(destination: PhoneNumberVer(), isActive: $navigateToPhoneNumberVer) {
                        EmptyView()
                    }
                )
                .onAppear {
                    focusedField = .firstName
                }
            }
            .background(Color(.systemBackground).opacity(0.7)) // Add semi-transparent background for better readability
        }
    }

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

    private enum Field: Hashable {
        case firstName, lastName, username, password, reenterPassword
    }
}

struct SoftRoundedTextFieldStyle: TextFieldStyle {
    var highlight: Bool = false

    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(highlight ? .red : Color(.systemGray4), lineWidth: 1)
            )
    }
}

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


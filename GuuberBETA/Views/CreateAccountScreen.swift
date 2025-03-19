//
//  LoginScreen.swift
//  GuuberBETA
//
//  Created by Gabe Holte on 3/5/25.


import SwiftUI

struct PasswordRequirementsView: View {
    let password: String
    @Environment(\.colorScheme) var colorScheme
    
    private var requirements: [(String, Bool)] {
        [
            ("At least 8 characters", password.count >= 8),
            ("Contains a letter", password.contains { $0.isLetter }),
            ("Contains a number", password.contains { $0.isNumber }),
            ("Contains special character", password.contains { "!@#$%^&*()_+-=[]{}|;:,.<>?".contains($0) })
        ]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(requirements, id: \.0) { requirement in
                HStack(spacing: 8) {
                    Image(systemName: requirement.1 ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(requirement.1 ? .green : .gray)
                        .font(.system(size: 12))
                    
                    Text(requirement.0)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal, 4)
        .padding(.top, 4)
    }
}

struct CreateAccountScreen: View {
    @StateObject private var firebaseService = FirebaseService()
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var reenterPassword: String = ""
    @State private var isUsernameFieldVisible: Bool = false
    @State private var isEmailFieldVisible: Bool = false
    @State private var isPasswordFieldVisible: Bool = false
    @State private var isReenterPasswordFieldVisible: Bool = false
    @State private var navigateToPhoneNumberVer: Bool = false
    @State private var showContinueButton: Bool = false
    @State private var buttonColor: Color = .green
    @State private var shakeReenterPasswordField: Bool = false
    @State private var highlightReenterPasswordField: Bool = false
    @FocusState private var focusedField: Field?
    @State private var shakeFirstNameField: Bool = false
    @State private var shakeLastNameField: Bool = false
    @State private var shakeUsernameField: Bool = false
    @State private var shakeEmailField: Bool = false
    @State private var shakePasswordField: Bool = false
    @State private var highlightFirstNameField: Bool = false
    @State private var highlightLastNameField: Bool = false
    @State private var highlightUsernameField: Bool = false
    @State private var highlightEmailField: Bool = false
    @State private var highlightPasswordField: Bool = false
    @State private var showPasswordRequirements: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 10) { // Reduced spacing and aligned to leading edge
                // First Name and Last Name Fields
                HStack(spacing: 10) {
                    TextField("First Name", text: $firstName, onCommit: {
                        if isValidFirstName(firstName) {
                            focusedField = .lastName
                        } else {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.5)) {
                                shakeFirstNameField = true
                                highlightFirstNameField = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                withAnimation {
                                    shakeFirstNameField = false
                                    highlightFirstNameField = false
                                }
                            }
                        }
                    })
                    .textFieldStyle(SoftRoundedTextFieldStyle(highlight: highlightFirstNameField))
                    .modifier(ShakeEffect(animatableData: shakeFirstNameField ? 1 : 0))
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
                        if isValidLastName(lastName) && isValidFirstName(firstName) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.5)) {
                                isUsernameFieldVisible = true
                                focusedField = .username
                            }
                        } else {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.5)) {
                                shakeLastNameField = true
                                highlightLastNameField = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                withAnimation {
                                    shakeLastNameField = false
                                    highlightLastNameField = false
                                }
                            }
                        }
                    })
                    .textFieldStyle(SoftRoundedTextFieldStyle(highlight: highlightLastNameField))
                    .modifier(ShakeEffect(animatableData: shakeLastNameField ? 1 : 0))
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
                        if isValidUsername(username) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.5)) {
                                isEmailFieldVisible = true
                                focusedField = .email
                            }
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

                // Email Field
                if isEmailFieldVisible {
                    TextField("Email", text: $email, onCommit: {
                        if isValidEmail(email) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.5)) {
                                isPasswordFieldVisible = true
                                focusedField = .password
                            }
                        } else {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.5)) {
                                shakeEmailField = true
                                highlightEmailField = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                withAnimation {
                                    shakeEmailField = false
                                    highlightEmailField = false
                                }
                            }
                        }
                    })
                    .textFieldStyle(SoftRoundedTextFieldStyle(highlight: highlightEmailField))
                    .modifier(ShakeEffect(animatableData: shakeEmailField ? 1 : 0))
                    .frame(width: 370, height: 50)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .disableAutocorrection(true)
                    .font(.system(size: 20, weight: .bold, design: .default))
                    .focused($focusedField, equals: .email)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity.combined(with: .move(edge: .top))
                    ))
                    .onChange(of: email) { newValue in
                        email = newValue.replacingOccurrences(of: " ", with: "")
                        resetFieldsBelow(.email)
                    }
                }

                // Password Field
                if isPasswordFieldVisible {
                    VStack(alignment: .leading, spacing: 0) {
                        SecureField("Password", text: $password, onCommit: {
                            if isValidPassword(password) {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.5)) {
                                    isReenterPasswordFieldVisible = true
                                    focusedField = .reenterPassword
                                }
                            } else {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.5)) {
                                    shakePasswordField = true
                                    highlightPasswordField = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                    withAnimation {
                                        shakePasswordField = false
                                        highlightPasswordField = false
                                    }
                                }
                            }
                        })
                        .textFieldStyle(SoftRoundedTextFieldStyle(highlight: highlightPasswordField))
                        .modifier(ShakeEffect(animatableData: shakePasswordField ? 1 : 0))
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
                            withAnimation {
                                showPasswordRequirements = !newValue.isEmpty
                            }
                        }
                        
                        if showPasswordRequirements {
                            PasswordRequirementsView(password: password)
                                .transition(.opacity)
                        }
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
                        Task {
                            do {
                                // Check username availability
                                let isAvailable = try await firebaseService.checkUsernameAvailability(username)
                                if !isAvailable {
                                    showError = true
                                    errorMessage = "Username is already taken"
                                    return
                                }
                                
                                // Create user in Firebase
                                let user = try await firebaseService.createUser(
                                    firstName: firstName,
                                    lastName: lastName,
                                    username: username,
                                    email: email,
                                    password: password
                                )
                                
                                // Navigate to phone verification
                                navigateToPhoneNumberVer = true
                            } catch {
                                showError = true
                                errorMessage = error.localizedDescription
                            }
                        }
                    }) {
                        Text("Continue")
                            .font(.system(size: 20, weight: .bold, design: .default))
                            .foregroundColor(.white)
                            .frame(width: 370, height: 60)
                            .background(buttonColor)
                            .cornerRadius(15)
                            .padding(.top, 10)
                    }
                    .alert("Error", isPresented: $showError) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        Text(errorMessage)
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
                email = ""
                isEmailFieldVisible = false
                fallthrough
            case .email:
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

    private func isValidFirstName(_ name: String) -> Bool {
        let lettersOnly = CharacterSet.letters
        return !name.isEmpty && name.unicodeScalars.allSatisfy { lettersOnly.contains($0) }
    }

    private func isValidLastName(_ name: String) -> Bool {
        let lettersOnly = CharacterSet.letters
        return !name.isEmpty && name.unicodeScalars.allSatisfy { lettersOnly.contains($0) }
    }

    private func isValidUsername(_ username: String) -> Bool {
        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_"))
        return !username.isEmpty && username.unicodeScalars.allSatisfy { allowedCharacters.contains($0) }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    private func isValidPassword(_ password: String) -> Bool {
        // Password must be at least 8 characters and contain at least one letter and one number
        let hasLetter = password.contains { $0.isLetter }
        let hasNumber = password.contains { $0.isNumber }
        let hasMinLength = password.count >= 8
        
        // Allow letters, numbers, and common special characters
        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;:,.<>?"))
        let hasValidCharacters = password.unicodeScalars.allSatisfy { allowedCharacters.contains($0) }
        
        return hasLetter && hasNumber && hasMinLength && hasValidCharacters
    }

    private enum Field: Hashable {
        case firstName, lastName, username, email, password, reenterPassword
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


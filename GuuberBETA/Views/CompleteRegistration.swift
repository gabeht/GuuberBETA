import SwiftUI

struct CompleteRegistration: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var firebaseService = FirebaseService()
    @ObservedObject var googleSignInService: GoogleSignInService
    @State private var username = ""
    @State private var password = ""
    @State private var reenterPassword = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var showPasswordField = false
    @State private var showReenterPasswordField = false
    @State private var shakeUsernameField = false
    @State private var shakePasswordField = false
    @State private var shakeReenterPasswordField = false
    @State private var highlightUsernameField = false
    @State private var highlightPasswordField = false
    @State private var highlightReenterPasswordField = false
    @State private var passwordStrength: PasswordStrength = .none
    @FocusState private var focusedField: Field?
    
    enum Field {
        case username, password, reenterPassword
    }
    
    init(googleSignInService: GoogleSignInService) {
        self.googleSignInService = googleSignInService
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Dismiss Button
            HStack {
                Spacer()
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.system(size: 24))
                }
                .padding(.trailing, 10)
                .padding(.top, 10)
            }
            
            Text("Complete Registration")
                .font(.system(size: 32, weight: .bold, design: .default))
                .padding(.top, 20)
            
            Text("Choose a username and password")
                .font(.system(size: 18, weight: .medium, design: .default))
                .foregroundColor(.gray)
                .padding(.bottom, 30)
            
            // Username Field
            TextField("Username", text: $username)
                .textFieldStyle(SoftRoundedTextFieldStyle(highlight: highlightUsernameField))
                .modifier(ShakeEffect(animatableData: shakeUsernameField ? 1 : 0))
                .frame(width: 340, height: 55)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .font(.system(size: 20, weight: .bold, design: .default))
                .focused($focusedField, equals: .username)
                .onChange(of: username) { newValue in
                    username = newValue.replacingOccurrences(of: " ", with: "")
                }
                .onSubmit {
                    if isValidUsername(username) {
                        Task {
                            await handleContinue()
                        }
                    }
                }
            
            // Password Field
            if showPasswordField {
                VStack(spacing: 4) {
                    SecureField("Password", text: $password)
                        .textFieldStyle(SoftRoundedTextFieldStyle(highlight: highlightPasswordField))
                        .modifier(ShakeEffect(animatableData: shakePasswordField ? 1 : 0))
                        .frame(width: 340, height: 55)
                        .font(.system(size: 20, weight: .bold, design: .default))
                        .focused($focusedField, equals: .password)
                        .onChange(of: password) { newValue in
                            if showReenterPasswordField {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.5)) {
                                    showReenterPasswordField = false
                                }
                            }
                        }
                        .onSubmit {
                            if isValidPassword(password) {
                                Task {
                                    await handleContinue()
                                }
                            }
                        }
                    
                    // Password Requirements
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Circle()
                                .fill(password.count >= 8 ? Color.green : Color.gray)
                                .frame(width: 8, height: 8)
                            Text("At least 8 characters")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        HStack {
                            Circle()
                                .fill(password.contains(where: { $0.isLetter }) ? Color.green : Color.gray)
                                .frame(width: 8, height: 8)
                            Text("At least one letter")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        HStack {
                            Circle()
                                .fill(password.contains(where: { $0.isNumber }) ? Color.green : Color.gray)
                                .frame(width: 8, height: 8)
                            Text("At least one number")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        HStack {
                            Circle()
                                .fill(password.contains(where: { "!@#$%^&*()_+-=[]{}|;:,.<>?".contains($0) }) ? Color.green : Color.gray)
                                .frame(width: 8, height: 8)
                            Text("At least one special character")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.leading, 0)
                }
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)),
                    removal: .opacity.combined(with: .move(edge: .top))
                ))
            }
            
            // Re-Enter Password Field
            if showReenterPasswordField {
                SecureField("Re-Enter Password", text: $reenterPassword)
                    .textFieldStyle(SoftRoundedTextFieldStyle(highlight: highlightReenterPasswordField))
                    .modifier(ShakeEffect(animatableData: shakeReenterPasswordField ? 1 : 0))
                    .frame(width: 340, height: 55)
                    .font(.system(size: 20, weight: .bold, design: .default))
                    .focused($focusedField, equals: .reenterPassword)
                    .onSubmit {
                        if password == reenterPassword {
                            Task {
                                await handleContinue()
                            }
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity.combined(with: .move(edge: .top))
                    ))
            }
            
            // Continue Button
            Button(action: {
                Task {
                    await handleContinue()
                }
            }) {
                Text("Complete Registration")
                    .font(.system(size: 20, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .frame(width: 340, height: 55)
                    .background(Color(red: 0.2, green: 0.8, blue: 0.4))
                    .cornerRadius(15)
                    .padding(.top, 20)
            }
            .disabled(isLoading)
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .padding(.top, 10)
            }
        }
        .padding()
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func handleContinue() async {
        isLoading = true
        
        // Validate username
        if !isValidUsername(username) {
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
            showError = true
            errorMessage = "Username must be 3-20 characters and can only contain letters, numbers, and underscores"
            isLoading = false
            return
        }
        
        // Check username availability
        do {
            let isAvailable = try await firebaseService.checkUsernameAvailability(username)
            if !isAvailable {
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
                showError = true
                errorMessage = "Username is already taken"
                isLoading = false
                return
            }
        } catch {
            showError = true
            errorMessage = "Error checking username availability"
            isLoading = false
            return
        }
        
        // Show password field if not shown
        if !showPasswordField {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.5)) {
                showPasswordField = true
                focusedField = .password
            }
            isLoading = false
            return
        }
        
        // Validate password
        if !isValidPassword(password) {
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
            showError = true
            errorMessage = "Password must be at least 8 characters long and contain at least one letter, one number, and one special character"
            isLoading = false
            return
        }
        
        // Show re-enter password field if not shown
        if !showReenterPasswordField {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.5)) {
                showReenterPasswordField = true
                focusedField = .reenterPassword
            }
            isLoading = false
            return
        }
        
        // Validate passwords match
        if password != reenterPassword {
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
            showError = true
            errorMessage = "Passwords do not match"
            isLoading = false
            return
        }
        
        // Update user profile with Google user's first and last name
        do {
            try await firebaseService.updateUserProfile(
                username: username,
                password: password,
                firstName: googleSignInService.googleUserFirstName,
                lastName: googleSignInService.googleUserLastName
            )
            dismiss()
        } catch {
            showError = true
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func isValidUsername(_ username: String) -> Bool {
        let usernameRegex = "^[a-zA-Z0-9_]{3,20}$"
        let usernamePredicate = NSPredicate(format: "SELF MATCHES %@", usernameRegex)
        return usernamePredicate.evaluate(with: username)
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        // Password must be at least 8 characters and contain at least one letter and one number
        let hasLetter = password.contains { $0.isLetter }
        let hasNumber = password.contains { $0.isNumber }
        let hasMinLength = password.count >= 8
        let hasSpecialChar = password.contains(where: { "!@#$%^&*()_+-=[]{}|;:,.<>?".contains($0) })
        
        // Allow letters, numbers, and common special characters
        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;:,.<>?"))
        let hasValidCharacters = password.unicodeScalars.allSatisfy { allowedCharacters.contains($0) }
        
        return hasLetter && hasNumber && hasMinLength && hasSpecialChar && hasValidCharacters
    }
    
    private enum PasswordStrength {
        case none, weak, medium, strong
    }
    
    private func checkPasswordStrength(_ password: String) -> PasswordStrength {
        let hasLowercase = password.contains(where: { $0.isLowercase })
        let hasUppercase = password.contains(where: { $0.isUppercase })
        let hasNumber = password.contains(where: { $0.isNumber })
        let hasMinLength = password.count >= 8
        
        let strength = [hasLowercase, hasUppercase, hasNumber, hasMinLength].filter { $0 }.count
        
        switch strength {
        case 0: return .none
        case 1: return .weak
        case 2: return .medium
        default: return .strong
        }
    }
    
    private func getStrengthColor(for index: Int) -> Color {
        let strength = checkPasswordStrength(password)
        let requiredStrength = index + 1
        
        switch strength {
        case .none:
            return .gray
        case .weak:
            return requiredStrength <= 1 ? .red : .gray
        case .medium:
            return requiredStrength <= 2 ? .yellow : .gray
        case .strong:
            return requiredStrength <= 4 ? .green : .gray
        }
    }
}

#Preview {
    CompleteRegistration(googleSignInService: GoogleSignInService())
} 
import Foundation
import FirebaseFirestore
import FirebaseAuth

class FirebaseService: ObservableObject {
    private let db = Firestore.firestore()
    
    func createUser(firstName: String, lastName: String, username: String, email: String, password: String) async throws -> User {
        // Convert username to lowercase for storage
        let lowercaseUsername = username.lowercased()
        
        // Check if username is available (case-insensitive)
        let isAvailable = try await checkUsernameAvailability(lowercaseUsername)
        guard isAvailable else {
            throw NSError(domain: "FirebaseService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Username is already taken"])
        }
        
        // Create authentication user
        let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
        
        // Create user document
        let user = User(
            firstName: firstName,
            lastName: lastName,
            username: lowercaseUsername,
            email: email,
            uid: authResult.user.uid,
            createdAt: Date()
        )
        
        try db.collection("users").document(authResult.user.uid).setData(from: user)
        
        return user
    }
    
    func checkUsernameAvailability(_ username: String) async throws -> Bool {
        let lowercaseUsername = username.lowercased()
        let snapshot = try await db.collection("users")
            .whereField("username", isEqualTo: lowercaseUsername)
            .getDocuments()
        
        return snapshot.documents.isEmpty
    }
    
    func checkEmailAvailability(_ email: String) async throws -> Bool {
        let snapshot = try await db.collection("users")
            .whereField("email", isEqualTo: email)
            .getDocuments()
        
        return snapshot.documents.isEmpty
    }
    
    func signIn(email: String, password: String) async throws -> User {
        let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
        
        let document = try await db.collection("users").document(authResult.user.uid).getDocument()
        
        guard let data = document.data() else {
            throw NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User data not found"])
        }
        
        return User(
            firstName: data["firstName"] as? String ?? "",
            lastName: data["lastName"] as? String ?? "",
            username: data["username"] as? String ?? "",
            email: data["email"] as? String ?? "",
            uid: data["uid"] as? String ?? "",
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        )
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func updateUserProfile(username: String, password: String, firstName: String, lastName: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])
        }
        
        // Update password
        try await user.updatePassword(to: password)
        
        // Create or update user document
        let userData: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "username": username,
            "email": user.email ?? "",
            "uid": user.uid,
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        try await db.collection("users").document(user.uid).setData(userData, merge: true)
    }
} 
import Foundation
import FirebaseFirestore
import FirebaseAuth

class FirebaseService: ObservableObject {
    private let db = Firestore.firestore()
    
    func createUser(firstName: String, lastName: String, username: String, email: String, password: String) async throws -> User {
        // Create user in Firebase Auth
        let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
        
        // Create user document in Firestore
        let user = User(
            firstName: firstName,
            lastName: lastName,
            username: username,
            email: email,
            uid: authResult.user.uid,
            createdAt: Date()
        )
        
        try await db.collection("users").document(authResult.user.uid).setData([
            "firstName": user.firstName,
            "lastName": user.lastName,
            "username": user.username,
            "email": user.email,
            "uid": user.uid,
            "createdAt": user.createdAt
        ])
        
        return user
    }
    
    func checkUsernameAvailability(_ username: String) async throws -> Bool {
        let snapshot = try await db.collection("users")
            .whereField("username", isEqualTo: username)
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
} 
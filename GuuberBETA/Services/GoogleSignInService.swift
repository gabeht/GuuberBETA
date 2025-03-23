import Foundation
import GoogleSignIn
import FirebaseAuth
import FirebaseFirestore

@MainActor
class GoogleSignInService: ObservableObject {
    @Published var isSignedIn = false
    @Published var error: Error?
    
    func signIn() async throws {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            throw NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "No root view controller found"])
        }
        
        do {
            // Start the sign in flow
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            guard let idToken = result.user.idToken?.tokenString else {
                throw NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "No ID token found"])
            }
            
            // Create Firebase credential
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )
            
            // Sign in to Firebase
            let authResult = try await Auth.auth().signIn(with: credential)
            
            // Check if user exists in Firestore
            let db = Firestore.firestore()
            let userDoc = try await db.collection("users").document(authResult.user.uid).getDocument()
            
            if !userDoc.exists {
                // Create new user document
                let user = User(
                    firstName: result.user.profile?.givenName ?? "",
                    lastName: result.user.profile?.familyName ?? "",
                    username: result.user.profile?.email.components(separatedBy: "@").first ?? "",
                    email: result.user.profile?.email ?? "",
                    uid: authResult.user.uid,
                    createdAt: Date()
                )
                
                try db.collection("users").document(authResult.user.uid).setData(from: user)
            }
            
            self.isSignedIn = true
        } catch {
            self.error = error
            throw error
        }
    }
    
    func signOut() throws {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            self.isSignedIn = false
        } catch {
            self.error = error
            throw error
        }
    }
} 

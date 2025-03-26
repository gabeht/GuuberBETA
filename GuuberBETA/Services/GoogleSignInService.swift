import Foundation
import GoogleSignIn
import FirebaseAuth
import FirebaseFirestore

@MainActor
class GoogleSignInService: ObservableObject {
    @Published var isSignedIn = false
    @Published var showCompleteRegistration = false
    @Published var error: Error?
    @Published var googleUserFirstName: String = ""
    @Published var googleUserLastName: String = ""
    
    private let clientID = "335607760955-u80hlnei00el4f5r6eq2a8qpkdpvcuma.apps.googleusercontent.com"
    private let db = Firestore.firestore()
    
    func signIn() async {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No root view controller found"])
            return
        }
        
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            guard let idToken = result.user.idToken?.tokenString else {
                error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No ID token found"])
                return
            }
            
            // Store Google user's first and last name
            googleUserFirstName = result.user.profile?.givenName ?? ""
            googleUserLastName = result.user.profile?.familyName ?? ""
            
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )
            
            let authResult = try await Auth.auth().signIn(with: credential)
            
            // Check if user document exists
            let userDoc = try await db.collection("users").document(authResult.user.uid).getDocument()
            
            if !userDoc.exists {
                // User is new, show complete registration
                showCompleteRegistration = true
            } else {
                // User exists, sign them in
                isSignedIn = true
            }
            
        } catch {
            self.error = error
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            isSignedIn = false
            showCompleteRegistration = false
            googleUserFirstName = ""
            googleUserLastName = ""
        } catch {
            self.error = error
        }
    }
} 

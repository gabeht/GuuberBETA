import Foundation
import FirebaseFirestore

struct User: Codable {
    let firstName: String
    let lastName: String
    let username: String
    let email: String
    let uid: String
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case firstName
        case lastName
        case username
        case email
        case uid
        case createdAt
    }
} 
import Foundation
import FirebaseFirestore

struct Tweet {
    let id: String
    let content: String
    let username: String?
    let imageURL: String?
    let userDisplayName: String?
    let profileImageURL: String? // Agregado
    let timestamp: Timestamp?
}



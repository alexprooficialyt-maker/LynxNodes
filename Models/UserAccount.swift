import Foundation

struct UserAccount: Codable {
    let id: Int
    let admin: Bool
    let username: String
    let email: String
    let firstName: String
    let lastName: String
    let language: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case admin
        case username
        case email
        case firstName = "first_name"
        case lastName = "last_name"
        case language
    }
}

struct AccountAttributesResponse: Codable {
    let object: String
    let attributes: UserAccount
}

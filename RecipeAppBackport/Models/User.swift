import Foundation
import RealmSwift

class User: Object, Decodable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var username: String
    @Persisted var passwordHash: String

    enum CodingKeys: String, CodingKey {
        case id
        case username
        case passwordHash
    }
}

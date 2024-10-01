import Foundation
import RealmSwift

class Recipe: Object, Decodable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var typeID: String
    @Persisted var title: String
    @Persisted var imageData: Data?
    @Persisted var ingredients: List<String>
    @Persisted var steps: List<String>
    @Persisted var createdAt: Date = Date()
    @Persisted var userID: String

    enum CodingKeys: String, CodingKey {
        case id
        case typeID
        case title
        case imageData
        case ingredients
        case steps
        case createdAt
        case userID
    }
}

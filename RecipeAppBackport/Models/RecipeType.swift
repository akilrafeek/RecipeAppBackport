import Foundation
import RealmSwift

class RecipeType: Object, Decodable {
    @Persisted(primaryKey: true) var id: String
    @Persisted var name: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
}

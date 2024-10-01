import Foundation
import RealmSwift

struct Constants {
    static let realmConfig = Realm.Configuration(
        schemaVersion: 3, // Incremented due to new User model
        migrationBlock: { migration, oldSchemaVersion in
            if (oldSchemaVersion < 3) {
                // Perform migrations if needed
            }
        }
    )
}

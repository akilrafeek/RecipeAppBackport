import Foundation
import RealmSwift
import RxSwift
import CryptoSwift

class UserService {
    static let shared = UserService()
    let realm: Realm

    private init() {
        do {
            realm = try Realm()
        } catch {
            fatalError("Failed to initialize Realm: \(error)")
        }
    }

    // Register a new user
    func registerUser(username: String, password: String) -> Observable<Bool> {
        return Observable.create { observer in
            // Check if username already exists
            if self.realm.objects(User.self).filter("username == %@", username).count > 0 {
                observer.onNext(false) // Username already taken
                observer.onCompleted()
                return Disposables.create()
            }

            // Hash the password
            guard let passwordData = password.data(using: .utf8) else {
                observer.onNext(false)
                observer.onCompleted()
                return Disposables.create()
            }

            let passwordHash = passwordData.sha256().toHexString()

            let newUser = User()
            newUser.username = username
            newUser.passwordHash = passwordHash

            do {
                try self.realm.write {
                    self.realm.add(newUser)
                }
                observer.onNext(true) // Registration successful
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }

            return Disposables.create()
        }
    }

    // Fetch user by username
    func fetchUser(username: String) -> Observable<User?> {
        return Observable.create { observer in
            let user = self.realm.objects(User.self).filter("username == %@", username).first
            observer.onNext(user)
            observer.onCompleted()
            return Disposables.create()
        }
    }
}

import Foundation
import RxSwift
import RealmSwift

class AuthenticationService {
    static let shared = AuthenticationService()
    let userService = UserService.shared
    let userDefaults = UserDefaults.standard

    private init() {}

    // Login method
    func login(username: String, password: String) -> Observable<Bool> {
        return userService.fetchUser(username: username)
            .flatMap { user -> Observable<Bool> in
                guard let user = user else {
                    return Observable.just(false) // User not found
                }

                // Hash the input password
                guard let passwordData = password.data(using: .utf8) else {
                    return Observable.just(false)
                }

                let passwordHash = passwordData.sha256().toHexString()

                if user.passwordHash == passwordHash {
                    // Save current user ID in UserDefaults
                    self.userDefaults.set(user.id, forKey: "currentUserID")
                    return Observable.just(true)
                } else {
                    return Observable.just(false) // Incorrect password
                }
            }
    }

    // Logout method
    func logout() {
        userDefaults.removeObject(forKey: "currentUserID")
    }

    // Check if a user is logged in
    func isLoggedIn() -> Bool {
        return userDefaults.string(forKey: "currentUserID") != nil
    }

    // Get current logged-in user
    func getCurrentUser() -> User? {
        guard let userID = userDefaults.string(forKey: "currentUserID") else { return nil }
        return userService.realm.object(ofType: User.self, forPrimaryKey: userID)
    }
}

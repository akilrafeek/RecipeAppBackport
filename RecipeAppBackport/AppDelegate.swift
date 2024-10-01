import UIKit
import RxSwift
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let disposeBag = DisposeBag()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Initialize Realm with updated configuration
        Realm.Configuration.defaultConfiguration = Constants.realmConfig

        do {
            _ = try Realm()
        } catch {
            fatalError("Error initializing Realm: \(error)")
        }
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // Check Authentication
        if AuthenticationService.shared.isLoggedIn() {
            let recipeListVC = RecipeListViewController()
            let navController = UINavigationController(rootViewController: recipeListVC)
            window?.rootViewController = navController
        } else {
            let authVC = AuthenticationViewController()
            let navController = UINavigationController(rootViewController: authVC)
            window?.rootViewController = navController
        }
        
        window?.makeKeyAndVisible()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

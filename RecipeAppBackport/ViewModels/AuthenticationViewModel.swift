import Foundation
import RxSwift
import RxCocoa

class AuthenticationViewModel {
    // Inputs
    let username = BehaviorRelay<String>(value: "")
    let password = BehaviorRelay<String>(value: "")

    // Outputs
    let isLoggedIn: BehaviorRelay<Bool> = BehaviorRelay(value: AuthenticationService.shared.isLoggedIn())
    let loginError: PublishRelay<String> = PublishRelay()
    let isLoading: BehaviorRelay<Bool> = BehaviorRelay(value: false)

    private let disposeBag = DisposeBag()

    func login() {
        let username = self.username.value.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = self.password.value

        // Basic Validation
        guard !username.isEmpty, !password.isEmpty else {
            loginError.accept("Username and password are required.")
            return
        }
        
        isLoading.accept(true)

        AuthenticationService.shared.login(username: username, password: password)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] success in
                self?.isLoading.accept(false)
                if success {
                    self?.isLoggedIn.accept(true)
                } else {
                    self?.loginError.accept("Invalid username or password.")
                }
            }, onError: { [weak self] error in
                self?.isLoading.accept(false)
                self?.loginError.accept("Login failed. Please try again.")
                print("Login Error: \(error)")
            })
            .disposed(by: disposeBag)
    }

    func logout() {
        AuthenticationService.shared.logout()
        isLoggedIn.accept(false)
    }

    func getCurrentUser() -> User? {
        return AuthenticationService.shared.getCurrentUser()
    }
}

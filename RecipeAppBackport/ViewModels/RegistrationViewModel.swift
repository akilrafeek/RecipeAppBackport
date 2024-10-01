import Foundation
import RxSwift
import RxCocoa

class RegistrationViewModel {
    // Inputs
    let username = BehaviorRelay<String>(value: "")
    let password = BehaviorRelay<String>(value: "")
    let confirmPassword = BehaviorRelay<String>(value: "")

    // Outputs
    let isRegistrationSuccessful: PublishRelay<Bool> = PublishRelay()
    let registrationError: PublishRelay<String> = PublishRelay()

    private let disposeBag = DisposeBag()
    let userService = UserService.shared

    func register() {
        let username = self.username.value.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = self.password.value
        let confirmPassword = self.confirmPassword.value

        // Basic Validation
        guard !username.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            registrationError.accept("All fields are required.")
            return
        }
        
        guard password.count >= 8 else {
            registrationError.accept("Password must be at least 8 characters long.")
            return
        }

        guard password == confirmPassword else {
            registrationError.accept("Passwords do not match.")
            return
        }

        // Additional validations can be added here (e.g., password strength)

        // Proceed with registration
        userService.registerUser(username: username, password: password)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] success in
                if success {
                    self?.isRegistrationSuccessful.accept(true)
                } else {
                    self?.registrationError.accept("Username is already taken.")
                }
            }, onError: { [weak self] error in
                self?.registrationError.accept("Registration failed. Please try again.")
                print("Registration Error: \(error)")
            })
            .disposed(by: disposeBag)
    }
}

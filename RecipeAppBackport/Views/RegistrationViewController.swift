import UIKit
import RxSwift
import RxCocoa
import SnapKit

class RegistrationViewController: UIViewController {
    // UI Elements
    let scrollView = UIScrollView()
    let contentView = UIView()
    let usernameTextField = UITextField()
    let passwordTextField = UITextField()
    let confirmPasswordTextField = UITextField()
    let registerButton = UIButton(type: .system)
    let errorLabel = UILabel()

    // ViewModel
    let viewModel = RegistrationViewModel()
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }

    private func setupUI() {
        title = "Sign Up"
        view.backgroundColor = .systemBackground
        
        // Configure ContentView
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        // Configure Username TextField
        usernameTextField.placeholder = "Username"
        usernameTextField.borderStyle = .roundedRect
        contentView.addSubview(usernameTextField)
        usernameTextField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.left.right.equalToSuperview().inset(32)
            make.height.equalTo(44)
        }
        
        // Configure Password TextField
        passwordTextField.placeholder = "Password"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        contentView.addSubview(passwordTextField)
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(usernameTextField.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(32)
            make.height.equalTo(44)
        }
        
        // Configure Confirm Password TextField
        confirmPasswordTextField.placeholder = "Confirm Password"
        confirmPasswordTextField.borderStyle = .roundedRect
        confirmPasswordTextField.isSecureTextEntry = true
        contentView.addSubview(confirmPasswordTextField)
        confirmPasswordTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(32)
            make.height.equalTo(44)
        }
        
        // Configure Register Button
        registerButton.setTitle("Register", for: .normal)
        registerButton.backgroundColor = .systemGreen
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.layer.cornerRadius = 8
        contentView.addSubview(registerButton)
        registerButton.snp.makeConstraints { make in
            make.top.equalTo(confirmPasswordTextField.snp.bottom).offset(32)
            make.left.right.equalToSuperview().inset(32)
            make.height.equalTo(50)
        }
        
        // Configure Error Label
        errorLabel.textColor = .systemRed
        errorLabel.numberOfLines = 0
        errorLabel.textAlignment = .center
        contentView.addSubview(errorLabel)
        errorLabel.snp.makeConstraints { make in
            make.top.equalTo(registerButton.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(32)
        }
    }

    private func bindViewModel() {
        // Bind TextFields to ViewModel
        usernameTextField.rx.text.orEmpty
            .bind(to: viewModel.username)
            .disposed(by: disposeBag)

        passwordTextField.rx.text.orEmpty
            .bind(to: viewModel.password)
            .disposed(by: disposeBag)

        confirmPasswordTextField.rx.text.orEmpty
            .bind(to: viewModel.confirmPassword)
            .disposed(by: disposeBag)

        // Handle Register Button
        registerButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.register()
            })
            .disposed(by: disposeBag)

        // Observe Registration Success
        viewModel.isRegistrationSuccessful
            .subscribe(onNext: { [weak self] success in
                if success {
                    let alert = UIAlertController(title: "Success", message: "Registration successful. You can now log in.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                        self?.navigationController?.popViewController(animated: true)
                    }))
                    self?.present(alert, animated: true, completion: nil)
                }
            })
            .disposed(by: disposeBag)

        // Observe Registration Errors
        viewModel.registrationError
            .subscribe(onNext: { [weak self] errorMessage in
                self?.errorLabel.text = errorMessage
            })
            .disposed(by: disposeBag)
    }
}

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class AuthenticationViewController: UIViewController {
    // UI Elements
    let scrollView = UIScrollView()
    let contentView = UIView()
    let usernameTextField = UITextField()
    let passwordTextField = UITextField()
    let loginButton = UIButton(type: .roundedRect)
    let registerButton = UIButton(type: .system)
    let errorLabel = UILabel()
    let activityIndicator = UIActivityIndicatorView(style: .large)

    // ViewModel
    let viewModel = AuthenticationViewModel()
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    private func setupUI() {
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
        
        loginButton.setTitle("Login", for: .normal)
        loginButton.backgroundColor = .systemBlue
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.layer.cornerRadius = 8
        loginButton.isUserInteractionEnabled = true
        contentView.addSubview(loginButton)
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(32)
            make.left.right.equalToSuperview().inset(32)
            make.height.equalTo(50)
        }
        
        // Configure Register Button
        registerButton.setTitle("Don't have an account? Register", for: .normal)
        registerButton.setTitleColor(.systemBlue, for: .normal)
        contentView.addSubview(registerButton)
        registerButton.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(32)
            make.height.equalTo(44)
        }
        
        // Configure Activity Indicator
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
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

        // Handle Login Button
        loginButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.login()
            })
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .subscribe(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.activityIndicator.startAnimating()
                    self?.view.isUserInteractionEnabled = false
                } else {
                    self?.activityIndicator.stopAnimating()
                    self?.view.isUserInteractionEnabled = true
                }
            })
            .disposed(by: disposeBag)

        // Observe Login Success
        viewModel.isLoggedIn
            .subscribe(onNext: { [weak self] isLoggedIn in
                if isLoggedIn {
                    // Navigate to Recipe List
                    let recipeListVC = RecipeListViewController()
                    let navController = UINavigationController(rootViewController: recipeListVC)
                    navController.modalPresentationStyle = .fullScreen
                    self?.present(navController, animated: true, completion: nil)
                }
            })
            .disposed(by: disposeBag)

        // Observe Login Errors
        viewModel.loginError
            .subscribe(onNext: { [weak self] errorMessage in
                self?.errorLabel.text = errorMessage
            })
            .disposed(by: disposeBag)

        // Handle Register Button
        registerButton.rx.tap
            .subscribe(onNext: { [weak self] in
                let registrationVC = RegistrationViewController()
                self?.navigationController?.pushViewController(registrationVC, animated: true)
            })
            .disposed(by: disposeBag)
    }
}

import UIKit
import RxSwift
import RxCocoa
import Kingfisher
import SnapKit

class RecipeDetailViewController: UIViewController {
    // UI Elements
    let scrollView = UIScrollView()
    let contentView = UIView()
    let imageView = UIImageView()
    let ingredientsLabel = UILabel()
    let ingredientsTextView = UITextView()
    let stepsLabel = UILabel()
    let stepsTextView = UITextView()
    let saveButton = UIButton(type: .system)
    let deleteButton = UIButton(type: .system)

    // ViewModel
    let viewModel: RecipeDetailViewModel
    let disposeBag = DisposeBag()

    init(recipe: Recipe) {
        self.viewModel = RecipeDetailViewModel(recipe: recipe)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        bindViewModel()
    }

    private func setupUI() {
        title = "Recipe Detail"
        view.backgroundColor = .systemBackground

        // Configure ScrollView
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        // Configure ContentView
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        // Configure ImageView
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(200)
        }

        // Ingredients Label
        ingredientsLabel.text = "Ingredients"
        ingredientsLabel.font = UIFont.boldSystemFont(ofSize: 18)
        contentView.addSubview(ingredientsLabel)
        ingredientsLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
        }

        // Ingredients TextView
        ingredientsTextView.layer.borderColor = UIColor.gray.cgColor
        ingredientsTextView.layer.borderWidth = 1
        ingredientsTextView.layer.cornerRadius = 8
        ingredientsTextView.isEditable = true
        contentView.addSubview(ingredientsTextView)
        ingredientsTextView.snp.makeConstraints { make in
            make.top.equalTo(ingredientsLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(100)
        }

        // Steps Label
        stepsLabel.text = "Steps"
        stepsLabel.font = UIFont.boldSystemFont(ofSize: 18)
        contentView.addSubview(stepsLabel)
        stepsLabel.snp.makeConstraints { make in
            make.top.equalTo(ingredientsTextView.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
        }

        // Steps TextView
        stepsTextView.layer.borderColor = UIColor.gray.cgColor
        stepsTextView.layer.borderWidth = 1
        stepsTextView.layer.cornerRadius = 8
        stepsTextView.isEditable = true
        contentView.addSubview(stepsTextView)
        stepsTextView.snp.makeConstraints { make in
            make.top.equalTo(stepsLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(100)
        }

        // Save Button
        saveButton.setTitle("Save Changes", for: .normal)
        contentView.addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(stepsTextView.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }

        // Delete Button
        deleteButton.setTitle("Delete Recipe", for: .normal)
        deleteButton.setTitleColor(.systemRed, for: .normal)
        contentView.addSubview(deleteButton)
        deleteButton.snp.makeConstraints { make in
            make.top.equalTo(saveButton.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-16)
        }
    }

    private func bindViewModel() {
        // Bind Image
        viewModel.image
            .subscribe(onNext: { [weak self] data in
                if let data = data, let image = UIImage(data: data) {
                    self?.imageView.image = image
                }
            })
            .disposed(by: disposeBag)

        // Bind Ingredients
        viewModel.ingredients
            .map { $0.joined(separator: "\n") }
            .bind(to: ingredientsTextView.rx.text)
            .disposed(by: disposeBag)

        // Bind Steps
        viewModel.steps
            .map { $0.joined(separator: "\n") }
            .bind(to: stepsTextView.rx.text)
            .disposed(by: disposeBag)

        // Handle Save Button
        saveButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let updatedIngredients = self.ingredientsTextView.text.components(separatedBy: "\n")
                let updatedSteps = self.stepsTextView.text.components(separatedBy: "\n")
                self.viewModel.updateRecipe(
                    newTitle: self.viewModel.title.value,
                    newIngredients: updatedIngredients,
                    newSteps: updatedSteps,
                    newImageData: self.viewModel.image.value
                )
                .subscribe(onNext: {
                    self.navigationController?.popViewController(animated: true)
                }, onError: { error in
                    print("Error updating recipe: \(error)")
                    self.showErrorAlert(message: "Failed to save changes.")
                })
                .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)

        // Handle Delete Button
        deleteButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.presentDeleteConfirmation()
            })
            .disposed(by: disposeBag)
    }

    private func presentDeleteConfirmation() {
        let alert = UIAlertController(title: "Delete Recipe", message: "Are you sure you want to delete this recipe?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.viewModel.deleteRecipe()
                .subscribe(onNext: {
                    self.navigationController?.popViewController(animated: true)
                }, onError: { error in
                    print("Error deleting recipe: \(error)")
                    self.showErrorAlert(message: "Failed to delete recipe.")
                })
                .disposed(by: self.disposeBag)
        }))
        present(alert, animated: true, completion: nil)
    }

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Operation Failed", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

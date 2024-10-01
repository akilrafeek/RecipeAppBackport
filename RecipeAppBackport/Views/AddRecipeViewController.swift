import UIKit
import RxSwift
import RxCocoa
import Kingfisher
import SnapKit

class AddRecipeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // UI Elements
    let scrollView = UIScrollView()
    let contentView = UIView()
    let pickerView = UIPickerView()
    let titleTextField = UITextField()
    let ingredientsLabel = UILabel()
    let ingredientsTextView = UITextView()
    let stepsLabel = UILabel()
    let stepsTextView = UITextView()
    let imageView = UIImageView()
    let addImageButton = UIButton(type: .system)
    let saveButton = UIButton(type: .system)

    // ViewModel
    let viewModel = AddRecipeViewModel()
    let disposeBag = DisposeBag()

    // Retain data source
    var recipeTypePickerDataSource: PickerViewDataSource<RecipeType>?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        setupKeyboardDismissRecognizer()
        addDoneButtonOnKeyboard()
    }

    private func setupUI() {
        title = "Add Recipe"
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

        // Configure PickerView
        contentView.addSubview(pickerView)
        pickerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(150)
        }

        // Configure Title TextField
        titleTextField.placeholder = "Recipe Title"
        titleTextField.borderStyle = .roundedRect
        contentView.addSubview(titleTextField)
        titleTextField.snp.makeConstraints { make in
            make.top.equalTo(pickerView.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }

        // Ingredients Label
        ingredientsLabel.text = "Ingredients"
        ingredientsLabel.font = UIFont.boldSystemFont(ofSize: 18)
        contentView.addSubview(ingredientsLabel)
        ingredientsLabel.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(16)
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

        // Configure ImageView
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.layer.borderWidth = 1.0
        imageView.layer.cornerRadius = 8
        
        if imageView.image == nil {
            imageView.image = UIImage(systemName: "photo")
        }
        
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalTo(stepsTextView.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(200)
        }

        // Add Image Button
        addImageButton.setTitle("Add Image", for: .normal)
        contentView.addSubview(addImageButton)
        addImageButton.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.height.equalTo(44)
        }

        // Save Button
        saveButton.setTitle("Save Recipe", for: .normal)
        contentView.addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(addImageButton.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-16)
        }
    }

    private func bindViewModel() {
        // Bind Recipe Types to PickerView
        viewModel.recipeTypes
            .subscribe(onNext: { [weak self] types in
                guard let self = self else { return }
                self.recipeTypePickerDataSource = PickerViewDataSource(items: types, titleForRow: { _, type in
                    type.name
                })
                self.pickerView.delegate = self.recipeTypePickerDataSource
                self.pickerView.dataSource = self.recipeTypePickerDataSource
                
                // Optionally, select the first row by default
                if !types.isEmpty {
                    self.pickerView.selectRow(0, inComponent: 0, animated: false)
                    self.viewModel.selectedRecipeTypeID.accept(types[0].id)
                }
            })
            .disposed(by: disposeBag)

        // Handle Picker Selection
        pickerView.rx.itemSelected
            .subscribe(onNext: { [weak self] row, component in
                guard let self = self,
                      let type = self.recipeTypePickerDataSource?.items[row] else { return }
                self.viewModel.selectedRecipeTypeID.accept(type.id)
            })
            .disposed(by: disposeBag)

        // Handle Add Image Button
        addImageButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.presentImagePicker()
            })
            .disposed(by: disposeBag)

        // Handle Save Button
        saveButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.viewModel.title.accept(self.titleTextField.text ?? "")
                let ingredients = self.ingredientsTextView.text.components(separatedBy: "\n").filter { !$0.isEmpty }
                let steps = self.stepsTextView.text.components(separatedBy: "\n").filter { !$0.isEmpty }
                self.viewModel.ingredients.accept(ingredients)
                self.viewModel.steps.accept(steps)
                self.viewModel.imageData.accept(self.imageView.image?.pngData())
                
                if let image = self.imageView.image {
                    // Resize image to a maximum dimension to limit size
                    let resizedImage = image.resized(toMaxDimension: 1024)
                    // Use JPEG compression to reduce image size
                    self.viewModel.imageData.accept(resizedImage.jpegData(compressionQuality: 0.7))
                } else {
                    self.viewModel.imageData.accept(nil)
                }

                self.viewModel.addRecipe()
                    .subscribe(onNext: {
                        self.navigationController?.popViewController(animated: true)
                    }, onError: { error in
                        print("Error adding recipe: \(error)")
                        self.showErrorAlert(message: "Failed to add recipe.")
                    })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
    }

    private func presentImagePicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }

    // UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            imageView.image = selectedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Operation Failed", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func setupKeyboardDismissRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar()
        doneToolbar.barStyle = .default
        doneToolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(handleTapGesture))
        ]
        doneToolbar.sizeToFit()
        ingredientsTextView.inputAccessoryView = doneToolbar
        stepsTextView.inputAccessoryView = doneToolbar
    }

    @objc private func handleTapGesture() {
        view.endEditing(true)
    }
}

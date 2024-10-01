import UIKit
import RxSwift
import RxCocoa
import SnapKit

class RecipeListViewController: UIViewController {
    // UI Elements
    let tableView = UITableView()
    let pickerView = UIPickerView()
    let addButton = UIBarButtonItem(title: "Add Recipe", style: .plain, target: nil, action: nil)
    let logoutButton = UIBarButtonItem(title: "Logout", style: .plain, target: nil, action: nil)

    // ViewModel
    let viewModel = RecipeListViewModel()
    let disposeBag = DisposeBag()

    // Retain data source
    var recipeTypePickerDataSource: PickerViewDataSource<RecipeType>?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }

    private func setupUI() {
        title = "Recipes"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = addButton
        navigationItem.leftBarButtonItem = logoutButton

        // Add PickerView
        view.addSubview(pickerView)
        pickerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(150)
        }

        // Add TableView
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(pickerView.snp.bottom).offset(8)
            make.left.right.bottom.equalToSuperview()
        }

        // Register Cell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "RecipeCell")
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
                    self.viewModel.selectedRecipeType.accept(types[0].id)
                }
            })
            .disposed(by: disposeBag)

        // Handle Picker Selection
        pickerView.rx.itemSelected
            .subscribe(onNext: { [weak self] row, component in
                guard let self = self,
                      let type = self.recipeTypePickerDataSource?.items[row] else { return }
                self.viewModel.selectedRecipeType.accept(type.id)
            })
            .disposed(by: disposeBag)

        // Bind Recipes to TableView
        viewModel.recipes
            .bind(to: tableView.rx.items(cellIdentifier: "RecipeCell")) { index, recipe, cell in
                cell.textLabel?.text = recipe.title
            }
            .disposed(by: disposeBag)

        // Handle Recipe Selection
        tableView.rx.modelSelected(Recipe.self)
            .subscribe(onNext: { [weak self] recipe in
                let detailVC = RecipeDetailViewController(recipe: recipe)
                self?.navigationController?.pushViewController(detailVC, animated: true)
            })
            .disposed(by: disposeBag)

        // Handle Add Button
        addButton.rx.tap
            .subscribe(onNext: { [weak self] in
                let addVC = AddRecipeViewController()
                self?.navigationController?.pushViewController(addVC, animated: true)
            })
            .disposed(by: disposeBag)
        
        // Handle Logout Button
        logoutButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.handleLogout()
            })
            .disposed(by: disposeBag)
    }
    
    private func handleLogout() {
        AuthenticationService.shared.logout()
        let loginVC = AuthenticationViewController()
        // Reset the navigation stack to prevent going back
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            window.rootViewController = UINavigationController(rootViewController: loginVC)
            UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromLeft, animations: nil, completion: nil)
        }
    }
}

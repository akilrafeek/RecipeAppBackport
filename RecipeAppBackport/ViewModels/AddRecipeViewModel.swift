import Foundation
import RxSwift
import RxCocoa

class AddRecipeViewModel {
    // Inputs
    let selectedRecipeTypeID = BehaviorRelay<String?>(value: nil)
    let title = BehaviorRelay<String>(value: "")
    let ingredients = BehaviorRelay<[String]>(value: [])
    let steps = BehaviorRelay<[String]>(value: [])
    let imageData = BehaviorRelay<Data?>(value: nil)
    let userDefaults = UserDefaults.standard

    // Outputs
    let recipeTypes: BehaviorRelay<[RecipeType]> = BehaviorRelay(value: [])

    private let disposeBag = DisposeBag()
    private let recipeService = RecipeService.shared

    init() {
        fetchRecipeTypes()
    }

    private func fetchRecipeTypes() {
        recipeService.fetchRecipeTypes()
            .subscribe(onNext: { [weak self] types in
                self?.recipeTypes.accept(types)
            }, onError: { error in
                print("Error fetching recipe types: \(error)")
            })
            .disposed(by: disposeBag)
    }

    func addRecipe() -> Observable<Void> {
        return Observable<Void>.create { observer in
            guard let typeID = self.selectedRecipeTypeID.value,
                  !self.title.value.isEmpty else {
                observer.onError(NSError(domain: "Invalid Input", code: 400, userInfo: [NSLocalizedDescriptionKey: "Missing required fields"]))
                return Disposables.create()
            }

            let newRecipe = Recipe()
            newRecipe.typeID = typeID
            newRecipe.title = self.title.value
            newRecipe.imageData = self.imageData.value
            newRecipe.ingredients.append(objectsIn: self.ingredients.value)
            newRecipe.steps.append(objectsIn: self.steps.value)
            newRecipe.userID = self.userDefaults.string(forKey: "currentUserID")!

            self.recipeService.saveRecipe(newRecipe)
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: {
                    observer.onNext(())
                    observer.onCompleted()
                }, onError: { error in
                    observer.onError(error)
                })
                .disposed(by: self.disposeBag)

            return Disposables.create()
        }
    }
}

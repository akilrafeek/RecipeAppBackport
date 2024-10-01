import Foundation
import RealmSwift
import RxSwift
import RxCocoa

class RecipeListViewModel {
    // Inputs
    let selectedRecipeType = BehaviorRelay<String?>(value: "1")

    // Outputs
    let recipeTypes: BehaviorRelay<[RecipeType]> = BehaviorRelay(value: [])
    let recipes: BehaviorRelay<[Recipe]> = BehaviorRelay(value: [])

    private let disposeBag = DisposeBag()
    private let recipeService = RecipeService.shared
    private var notificationToken: NotificationToken?

    init() {
        fetchRecipeTypes()
        fetchRecipe()
        observeRecipes()
        bindRecipes()
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
    
    private func fetchRecipe() {
        recipeService.importRecipes()
            .subscribe(onNext: { [weak self] recipes in
                self?.recipes.accept(recipes)
            }, onError: { error in
                print("Error fetching recipe types: \(error)")
            })
            .disposed(by: disposeBag)
    }
    
    private func observeRecipes() {
        let realm = try! Realm()
        let recipesResult = realm.objects(Recipe.self)
        
        // Convert Realm Results to Array
        recipes.accept(Array(recipesResult))
        
        // Observe changes
        notificationToken = recipesResult.observe { [weak self] changes in
            switch changes {
            case .initial(_):
                self?.bindRecipes()
            case .update(_,_,_,_):
                self?.bindRecipes()
            case .error(let error):
                print("Error observing recipes: \(error)")
            }
        }
    }

    private func bindRecipes() {
        selectedRecipeType
            .distinctUntilChanged()
            .flatMapLatest { typeID -> Observable<[Recipe]> in
                return self.recipeService.fetchRecipes(ofType: typeID)
            }
            .subscribe(onNext: { [weak self] recipes in
                self?.recipes.accept(recipes)
            }, onError: { error in
                print("Error fetching recipes: \(error)")
            })
            .disposed(by: disposeBag)
    }
    
    deinit {
        notificationToken?.invalidate()
    }
}

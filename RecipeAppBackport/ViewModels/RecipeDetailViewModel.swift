import Foundation
import RxCocoa
import RxSwift

class RecipeDetailViewModel {
    // Inputs
    let recipe: Recipe

    // Outputs
    let title: BehaviorRelay<String>
    let ingredients: BehaviorRelay<[String]>
    let steps: BehaviorRelay<[String]>
    let image: BehaviorRelay<Data?>

    private let disposeBag = DisposeBag()
    private let recipeService = RecipeService.shared

    init(recipe: Recipe) {
        self.recipe = recipe
        self.title = BehaviorRelay(value: recipe.title)
        self.ingredients = BehaviorRelay(value: Array(recipe.ingredients))
        self.steps = BehaviorRelay(value: Array(recipe.steps))
        self.image = BehaviorRelay(value: recipe.imageData)
    }

    func updateRecipe(newTitle: String, newIngredients: [String], newSteps: [String], newImageData: Data?) -> Observable<Void> {
        return Observable<Void>.create { observer in
            do {
                try self.recipeService.realm.write {
                    self.recipe.title = newTitle
                    self.recipe.ingredients.removeAll()
                    self.recipe.ingredients.append(objectsIn: newIngredients)
                    self.recipe.steps.removeAll()
                    self.recipe.steps.append(objectsIn: newSteps)
                    self.recipe.imageData = newImageData
                }
                observer.onNext(())
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }
            return Disposables.create()
        }
    }

    func deleteRecipe() -> Observable<Void> {
        return recipeService.deleteRecipe(recipe)
    }
}

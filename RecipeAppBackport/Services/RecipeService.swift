import Foundation
import RealmSwift
import RxSwift
import CryptoSwift

class RecipeService {
    static let shared = RecipeService()
    let realm: Realm
    let authenticationService = AuthenticationService.shared

    private init() {
        do {
            realm = try Realm()
        } catch {
            fatalError("Failed to initialize Realm: \(error)")
        }
    }

    // Fetch Recipe Types from JSON
    func fetchRecipeTypes() -> Observable<[RecipeType]> {
        return Observable.create { observer in
            if let url = Bundle.main.url(forResource: "recipetypes", withExtension: "json") {
                do {
                    let data = try Data(contentsOf: url)
                    let types = try JSONDecoder().decode([RecipeType].self, from: data)
                    
                    // Save to Realm
                    try self.realm.write {
                        self.realm.add(types, update: .modified)
                    }
                    
                    observer.onNext(types)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
            } else {
                observer.onError(NSError(domain: "File not found", code: 404, userInfo: nil))
            }
            return Disposables.create()
        }
    }
    
    // Function to import Recipes
    func importRecipes() -> Observable<[Recipe]> {
        return Observable.create { observer in
            guard let path = Bundle.main.path(forResource: "sampleRecipes", ofType: "json"),
                  let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
                observer.onError(NSError(domain: "DataImportError", code: 1002, userInfo: [NSLocalizedDescriptionKey: "SampleRecipes.json not found"]))
                return Disposables.create()
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            do {
                let recipesData = try decoder.decode([Recipe].self, from: data)
                
                // Verify that RecipeTypes are already imported
                let existingTypeIDs = Set(self.realm.objects(RecipeType.self).map { $0.id })
                let invalidRecipes = recipesData.filter { !existingTypeIDs.contains($0.typeID) }
                
                if !invalidRecipes.isEmpty {
                    let errorMsg = "Some recipes have invalid typeID: \(invalidRecipes.map { $0.id })"
                    print(errorMsg)
                    observer.onError(NSError(domain: "DataImportError", code: 1003, userInfo: [NSLocalizedDescriptionKey: errorMsg]))
                    return Disposables.create()
                }
                
                // Convert to Realm Objects
                let recipes = recipesData.map { data -> Recipe in
                    let recipe = Recipe()
                    recipe.id = data.id
                    recipe.typeID = data.typeID
                    recipe.title = data.title
                    if let imageDataString = data.imageData,
                       let data = Data(base64Encoded: imageDataString) {
                        recipe.imageData = data
                    }
                    recipe.ingredients.append(objectsIn: data.ingredients)
                    recipe.steps.append(objectsIn: data.steps)
                    
                    recipe.userID = data.userID
                    return recipe
                }
                
                try self.realm.write {
                    self.realm.add(recipes, update: .modified)
                }
                
                print("Successfully imported Recipes.")
                observer.onNext(recipesData)
                observer.onCompleted()
            } catch {
                print("Failed to import Recipes: \(error)")
                observer.onError(error)
            }
            
            return Disposables.create()
        }
    }

    // Fetch Recipes for the current user
    func fetchRecipes(ofType typeID: String? = nil) -> Observable<[Recipe]> {
        return Observable.create { observer in
            guard let currentUser = self.authenticationService.getCurrentUser() else {
                observer.onError(NSError(domain: "User not logged in", code: 401, userInfo: nil))
                return Disposables.create()
            }

            let recipes: Results<Recipe>
            if let typeID = typeID {
                recipes = self.realm.objects(Recipe.self)
                    .filter("typeID == %@ AND (userID == %@ OR userID == 'user-123')", typeID, currentUser.id)
                    .sorted(byKeyPath: "createdAt", ascending: false)
            } else {
                recipes = self.realm.objects(Recipe.self)
                    .filter("userID == %@", currentUser.id)
                    .sorted(byKeyPath: "createdAt", ascending: false)
            }
            observer.onNext(Array(recipes))
            observer.onCompleted()
            return Disposables.create()
        }
    }

    // Add or Update Recipe
    func saveRecipe(_ recipe: Recipe) -> Observable<Void> {
        return Observable<Void>.create { observer in
//            DispatchQueue.global(qos: .background).async {
                do {
                    try self.realm.write {
                        self.realm.add(recipe, update: .modified)
                        print("Recipe saved: \(recipe.title)")
                    }
                    observer.onNext(())
                    observer.onCompleted()
                } catch {
                    print("Error saving recipe: \(error)")
                    observer.onError(error)
                }
//            }
            return Disposables.create()
        }
    }

    // Delete Recipe
    func deleteRecipe(_ recipe: Recipe) -> Observable<Void> {
        return Observable<Void>.create { observer in
//            DispatchQueue(label: "realm").async {
                do {
                    try self.realm.write {
                        self.realm.delete(recipe)
                    }
                    observer.onNext(())
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
//            }
            return Disposables.create()
        }
    }
}

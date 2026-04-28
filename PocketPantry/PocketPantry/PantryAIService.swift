//
//  PantryAIService.swift
//  PocketPantry
//
//  Advanced AI logic for pantry management
//

import Foundation

//////////////////////////////////////////////////////////
// MARK: Pantry AI Service
//////////////////////////////////////////////////////////

@MainActor
class PantryAIService {
    
    //////////////////////////////////////////////////////////
    // Category Prediction
    //////////////////////////////////////////////////////////
    
    func predictCategory(for foodName: String) -> FoodCategory {
        let lowercased = foodName.lowercased()
        
        // Vegetables
        let vegetables = ["lettuce", "spinach", "kale", "carrot", "broccoli", "cauliflower", 
                         "tomato", "cucumber", "pepper", "onion", "garlic", "celery", 
                         "zucchini", "potato", "sweet potato", "cabbage", "eggplant"]
        if vegetables.contains(where: { lowercased.contains($0) }) {
            return .vegetables
        }
        
        // Fruits
        let fruits = ["apple", "banana", "orange", "grape", "berry", "strawberry", 
                     "blueberry", "peach", "pear", "plum", "mango", "pineapple",
                     "watermelon", "melon", "cherry", "lemon", "lime", "avocado"]
        if fruits.contains(where: { lowercased.contains($0) }) {
            return .fruits
        }
        
        // Dairy
        let dairy = ["milk", "cheese", "yogurt", "butter", "cream", "cottage cheese", 
                    "sour cream", "cheddar", "mozzarella", "parmesan"]
        if dairy.contains(where: { lowercased.contains($0) }) {
            return .dairy
        }
        
        // Meat
        let meat = ["chicken", "beef", "pork", "turkey", "fish", "salmon", "tuna", 
                   "shrimp", "bacon", "sausage", "ham", "steak", "ground beef"]
        if meat.contains(where: { lowercased.contains($0) }) {
            return .meat
        }
        
        // Grains
        let grains = ["rice", "pasta", "bread", "flour", "oats", "cereal", "quinoa", 
                     "barley", "couscous", "tortilla", "noodle", "wheat"]
        if grains.contains(where: { lowercased.contains($0) }) {
            return .grains
        }
        
        // Spices
        let spices = ["salt", "pepper", "cinnamon", "cumin", "paprika", "oregano", 
                     "basil", "thyme", "rosemary", "ginger", "turmeric", "curry"]
        if spices.contains(where: { lowercased.contains($0) }) {
            return .spices
        }
        
        // Canned
        if lowercased.contains("canned") || lowercased.contains("can of") {
            return .canned
        }
        
        // Frozen
        if lowercased.contains("frozen") {
            return .frozen
        }
        
        // Beverages
        let beverages = ["juice", "soda", "water", "tea", "coffee", "beer", "wine", "drink"]
        if beverages.contains(where: { lowercased.contains($0) }) {
            return .beverages
        }
        
        // Condiments
        let condiments = ["ketchup", "mustard", "mayo", "sauce", "dressing", "oil", 
                         "vinegar", "honey", "jam", "jelly", "syrup"]
        if condiments.contains(where: { lowercased.contains($0) }) {
            return .condiments
        }
        
        // Snacks
        let snacks = ["chips", "crackers", "cookies", "candy", "chocolate", "nuts", 
                     "popcorn", "pretzels", "granola"]
        if snacks.contains(where: { lowercased.contains($0) }) {
            return .snacks
        }
        
        return .other
    }
    
    //////////////////////////////////////////////////////////
    // Expiration Date Estimation
    //////////////////////////////////////////////////////////
    
    func estimateExpirationDate(for foodName: String, category: FoodCategory) -> Date? {
        let calendar = Calendar.current
        let today = Date()
        
        // Days until expiration based on category
        let daysToAdd: Int = {
            switch category {
            case .vegetables: return 7
            case .fruits: return 5
            case .dairy: return 7
            case .meat: return 3
            case .grains: return 180
            case .spices: return 730 // 2 years
            case .canned: return 730 // 2 years
            case .frozen: return 180
            case .beverages: return 30
            case .condiments: return 180
            case .snacks: return 90
            case .other: return 30
            }
        }()
        
        return calendar.date(byAdding: .day, value: daysToAdd, to: today)
    }
    
    //////////////////////////////////////////////////////////
    // Fetch Nutrition Info (Mock Implementation)
    //////////////////////////////////////////////////////////
    
    func fetchNutritionInfo(for foodName: String) async -> NutritionInfo? {
        // In a real app, this would call a nutrition API like USDA FoodData Central
        // For now, we'll return estimated values based on common foods
        
        try? await Task.sleep(nanoseconds: 500_000_000) // Simulate network delay
        
        let lowercased = foodName.lowercased()
        
        // Sample nutrition data
        if lowercased.contains("chicken") {
            return NutritionInfo(
                calories: 165,
                protein: 31,
                carbohydrates: 0,
                fat: 3.6,
                fiber: 0,
                sugar: 0,
                sodium: 74,
                servingSize: "100g"
            )
        } else if lowercased.contains("rice") {
            return NutritionInfo(
                calories: 130,
                protein: 2.7,
                carbohydrates: 28,
                fat: 0.3,
                fiber: 0.4,
                sugar: 0,
                sodium: 1,
                servingSize: "100g cooked"
            )
        } else if lowercased.contains("broccoli") {
            return NutritionInfo(
                calories: 34,
                protein: 2.8,
                carbohydrates: 7,
                fat: 0.4,
                fiber: 2.6,
                sugar: 1.7,
                sodium: 33,
                servingSize: "100g"
            )
        } else if lowercased.contains("egg") {
            return NutritionInfo(
                calories: 155,
                protein: 13,
                carbohydrates: 1.1,
                fat: 11,
                fiber: 0,
                sugar: 1.1,
                sodium: 124,
                servingSize: "100g"
            )
        } else if lowercased.contains("pasta") {
            return NutritionInfo(
                calories: 131,
                protein: 5,
                carbohydrates: 25,
                fat: 1.1,
                fiber: 1.8,
                sugar: 0.8,
                sodium: 1,
                servingSize: "100g cooked"
            )
        } else if lowercased.contains("apple") {
            return NutritionInfo(
                calories: 52,
                protein: 0.3,
                carbohydrates: 14,
                fat: 0.2,
                fiber: 2.4,
                sugar: 10,
                sodium: 1,
                servingSize: "100g"
            )
        } else if lowercased.contains("salmon") {
            return NutritionInfo(
                calories: 206,
                protein: 22,
                carbohydrates: 0,
                fat: 13,
                fiber: 0,
                sugar: 0,
                sodium: 59,
                servingSize: "100g"
            )
        } else if lowercased.contains("milk") {
            return NutritionInfo(
                calories: 61,
                protein: 3.2,
                carbohydrates: 4.8,
                fat: 3.3,
                fiber: 0,
                sugar: 5.1,
                sodium: 43,
                servingSize: "100ml"
            )
        }
        
        // Default nutrition for unknown foods
        return NutritionInfo(
            calories: 100,
            protein: 2,
            carbohydrates: 15,
            fat: 2,
            fiber: 1,
            sugar: 3,
            sodium: 50,
            servingSize: "100g"
        )
    }
    
    //////////////////////////////////////////////////////////
    // Smart Recipe Suggestions
    //////////////////////////////////////////////////////////
    
    func suggestRecipesBasedOnPreferences(
        availableIngredients: [String],
        preferences: DietaryPreferences
    ) -> [String] {
        var suggestions: [String] = []
        
        let ingredients = availableIngredients.map { $0.lowercased() }
        
        // Filter based on dietary restrictions
        if preferences.restrictions.contains(.vegetarian) || preferences.restrictions.contains(.vegan) {
            if ingredients.contains(where: { $0.contains("vegetable") || $0.contains("tomato") }) {
                suggestions.append("Vegetable Stir-Fry")
                suggestions.append("Veggie Buddha Bowl")
            }
        } else {
            if ingredients.contains(where: { $0.contains("chicken") }) {
                suggestions.append("Chicken Stir-Fry")
                suggestions.append("Grilled Chicken Salad")
            }
        }
        
        if preferences.restrictions.contains(.ketogenic) || preferences.restrictions.contains(.lowCarb) {
            if ingredients.contains(where: { $0.contains("egg") }) {
                suggestions.append("Keto Egg Breakfast")
            }
        }
        
        return suggestions
    }
    
    //////////////////////////////////////////////////////////
    // Generate Shopping List
    //////////////////////////////////////////////////////////
    
    func generateShoppingList(
        currentPantry: [PantryItem],
        plannedRecipes: [Recipe]
    ) -> [String] {
        var neededIngredients: Set<String> = []
        let currentIngredients = Set(currentPantry.map { $0.name.lowercased() })
        
        for recipe in plannedRecipes {
            for ingredient in recipe.ingredients {
                let lowercased = ingredient.lowercased()
                if !currentIngredients.contains(lowercased) {
                    neededIngredients.insert(ingredient)
                }
            }
        }
        
        return Array(neededIngredients).sorted()
    }
    
    //////////////////////////////////////////////////////////
    // Meal Planning
    //////////////////////////////////////////////////////////
    
    func generateMealPlan(
        for days: Int,
        with ingredients: [String],
        preferences: DietaryPreferences
    ) -> [MealPlan] {
        var mealPlans: [MealPlan] = []
        let calendar = Calendar.current
        
        for day in 0..<days {
            if let date = calendar.date(byAdding: .day, value: day, to: Date()) {
                let meals = generateMealsForDay(ingredients: ingredients, preferences: preferences)
                mealPlans.append(MealPlan(date: date, meals: meals))
            }
        }
        
        return mealPlans
    }
    
    private func generateMealsForDay(ingredients: [String], preferences: DietaryPreferences) -> [String] {
        var meals: [String] = []
        
        // Breakfast
        if preferences.restrictions.contains(.vegetarian) {
            meals.append("Vegetable Omelette")
        } else {
            meals.append("Scrambled Eggs with Toast")
        }
        
        // Lunch
        if ingredients.contains(where: { $0.lowercased().contains("chicken") }) {
            meals.append("Grilled Chicken Salad")
        } else {
            meals.append("Vegetable Soup")
        }
        
        // Dinner
        if preferences.restrictions.contains(.ketogenic) {
            meals.append("Keto Salmon with Vegetables")
        } else if ingredients.contains(where: { $0.lowercased().contains("pasta") }) {
            meals.append("Pasta Primavera")
        } else {
            meals.append("Stir-Fry with Available Ingredients")
        }
        
        return meals
    }
}

//////////////////////////////////////////////////////////
// MARK: Meal Plan Model
//////////////////////////////////////////////////////////

struct MealPlan: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var meals: [String]
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

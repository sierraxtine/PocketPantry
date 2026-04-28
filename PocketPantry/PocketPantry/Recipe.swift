//
//  Recipe.swift
//  PocketPantry
//
//  Created by Sierra Christine on 3/8/26.
//


import Foundation

//////////////////////////////////////////////////////////
// MARK: Recipe Model
//////////////////////////////////////////////////////////

struct Recipe: Identifiable, Codable, Equatable {
    var id = UUID()
    let title: String
    let ingredients: [String]
    let instructions: [String]
    let timeMinutes: Int
    let difficulty: RecipeDifficulty
    let servings: Int
    let cuisineType: String
    let nutrition: NutritionInfo?
    let tags: [String]
    let imageURL: String?
    
    init(
        id: UUID = UUID(),
        title: String,
        ingredients: [String],
        instructions: [String],
        timeMinutes: Int,
        difficulty: RecipeDifficulty = .medium,
        servings: Int = 4,
        cuisineType: String = "General",
        nutrition: NutritionInfo? = nil,
        tags: [String] = [],
        imageURL: String? = nil
    ) {
        self.id = id
        self.title = title
        self.ingredients = ingredients
        self.instructions = instructions
        self.timeMinutes = timeMinutes
        self.difficulty = difficulty
        self.servings = servings
        self.cuisineType = cuisineType
        self.nutrition = nutrition
        self.tags = tags
        self.imageURL = imageURL
    }
}

enum RecipeDifficulty: String, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var icon: String {
        switch self {
        case .easy: return "1.circle.fill"
        case .medium: return "2.circle.fill"
        case .hard: return "3.circle.fill"
        }
    }
}

//////////////////////////////////////////////////////////
// MARK: Recipe Engine
//////////////////////////////////////////////////////////

@MainActor
class RecipeEngine {
    
    //////////////////////////////////////////////////////////
    // Generate Recipes with Enhanced AI
    //////////////////////////////////////////////////////////

    nonisolated static func generateRecipes(
        from ingredients: [String],
        preferences: DietaryPreferences? = nil,
        maxResults: Int = 5
    ) async -> [Recipe] {
        
        let preferences = preferences ?? DietaryPreferences()

        let apiKey = UserDefaults.standard.string(forKey: "chatGPTKey") ?? ""
        let aiEnabled = UserDefaults.standard.bool(forKey: "aiRecipesEnabled")

        guard aiEnabled && !apiKey.isEmpty else {
            return await generateLocalRecipes(from: ingredients, preferences: preferences, maxResults: maxResults)
        }

        do {
            return try await generateAIRecipes(
                ingredients: ingredients,
                apiKey: apiKey,
                preferences: preferences,
                maxResults: maxResults
            )
        } catch {
            print("AI generation failed: \(error.localizedDescription)")
            return await generateLocalRecipes(from: ingredients, preferences: preferences, maxResults: maxResults)
        }
    }

    //////////////////////////////////////////////////////////
    // Local Recipe Generator (Enhanced)
    //////////////////////////////////////////////////////////

    private static func generateLocalRecipes(
        from ingredients: [String],
        preferences: DietaryPreferences,
        maxResults: Int
    ) -> [Recipe] {

        let lower = ingredients.map { $0.lowercased() }
        var recipes: [Recipe] = []
        
        // Check dietary restrictions
        let isVegetarian = preferences.restrictions.contains(.vegetarian)
        let isVegan = preferences.restrictions.contains(.vegan)
        let isGlutenFree = preferences.restrictions.contains(.glutenFree)
        let isDairyFree = preferences.restrictions.contains(.dairyFree)
        let isKeto = preferences.restrictions.contains(.ketogenic)

        // Breakfast Recipes
        if lower.contains("eggs") && !isVegan {
            
            if lower.contains("spinach") {
                recipes.append(
                    Recipe(
                        title: "Spinach & Feta Omelette",
                        ingredients: ["3 Eggs", "1 cup Spinach", "1/4 cup Feta cheese", "Salt", "Pepper", "Olive oil"],
                        instructions: [
                            "Heat olive oil in a non-stick pan over medium heat.",
                            "Whisk eggs in a bowl with salt and pepper.",
                            "Sauté spinach until wilted, then remove from pan.",
                            "Pour eggs into the pan and cook until edges set.",
                            "Add spinach and feta to one half of the omelette.",
                            "Fold the omelette in half and cook for another minute.",
                            "Slide onto a plate and serve hot."
                        ],
                        timeMinutes: 12,
                        difficulty: .easy,
                        servings: 1,
                        cuisineType: "Mediterranean",
                        nutrition: NutritionInfo(
                            calories: 285,
                            protein: 24,
                            carbohydrates: 4,
                            fat: 19,
                            fiber: 1.2,
                            sugar: 1,
                            sodium: 420,
                            servingSize: "1 omelette"
                        ),
                        tags: ["breakfast", "high-protein", "low-carb", "quick"]
                    )
                )
            }
            
            if lower.contains("tomato") || lower.contains("tomatoes") {
                recipes.append(
                    Recipe(
                        title: "Mediterranean Scrambled Eggs",
                        ingredients: ["3 Eggs", "1 Tomato diced", "Fresh basil", "Olive oil", "Salt", "Pepper"],
                        instructions: [
                            "Heat olive oil in a pan over medium heat.",
                            "Add diced tomatoes and cook for 2-3 minutes.",
                            "Whisk eggs with salt and pepper.",
                            "Pour eggs into the pan with tomatoes.",
                            "Stir gently until eggs are cooked to your liking.",
                            "Garnish with fresh basil and serve."
                        ],
                        timeMinutes: 10,
                        difficulty: .easy,
                        servings: 1,
                        cuisineType: "Mediterranean",
                        nutrition: NutritionInfo(
                            calories: 245,
                            protein: 18,
                            carbohydrates: 5,
                            fat: 17,
                            fiber: 1,
                            sugar: 3,
                            sodium: 180,
                            servingSize: "1 serving"
                        ),
                        tags: ["breakfast", "quick", "healthy"]
                    )
                )
            }
        }

        // Pasta Recipes
        if lower.contains("pasta") && !isKeto && !isGlutenFree {
            
            if lower.contains("tomato sauce") || lower.contains("tomatoes") {
                recipes.append(
                    Recipe(
                        title: "Classic Marinara Pasta",
                        ingredients: ["12 oz Pasta", "2 cups Tomato sauce", "3 cloves Garlic minced", "2 tbsp Olive oil", "Fresh basil", "Salt", "Red pepper flakes"],
                        instructions: [
                            "Bring a large pot of salted water to boil.",
                            "Cook pasta according to package directions until al dente.",
                            "While pasta cooks, heat olive oil in a large pan over medium heat.",
                            "Add minced garlic and cook until fragrant, about 1 minute.",
                            "Pour in tomato sauce and add red pepper flakes.",
                            "Simmer sauce for 10 minutes, stirring occasionally.",
                            "Drain pasta and add to the sauce, tossing to coat.",
                            "Garnish with fresh basil leaves and serve."
                        ],
                        timeMinutes: 25,
                        difficulty: .easy,
                        servings: 4,
                        cuisineType: "Italian",
                        nutrition: NutritionInfo(
                            calories: 380,
                            protein: 12,
                            carbohydrates: 68,
                            fat: 8,
                            fiber: 4,
                            sugar: 8,
                            sodium: 350,
                            servingSize: "1/4 recipe"
                        ),
                        tags: ["dinner", "italian", "vegetarian", "comfort-food"]
                    )
                )
            }
            
            if lower.contains("chicken") && !isVegetarian && !isVegan {
                recipes.append(
                    Recipe(
                        title: "Creamy Chicken Alfredo Pasta",
                        ingredients: ["12 oz Fettuccine", "2 Chicken breasts", "1 cup Heavy cream", "1/2 cup Parmesan cheese", "3 cloves Garlic", "2 tbsp Butter", "Salt", "Pepper", "Parsley"],
                        instructions: [
                            "Cook fettuccine according to package directions.",
                            "Season chicken with salt and pepper, then cook in a pan until golden and cooked through.",
                            "Remove chicken and let rest, then slice.",
                            "In the same pan, melt butter and sauté garlic for 1 minute.",
                            "Add heavy cream and bring to a gentle simmer.",
                            "Stir in Parmesan cheese until melted and sauce is smooth.",
                            "Drain pasta and add to the sauce along with sliced chicken.",
                            "Toss everything together and garnish with parsley."
                        ],
                        timeMinutes: 30,
                        difficulty: .medium,
                        servings: 4,
                        cuisineType: "Italian",
                        nutrition: NutritionInfo(
                            calories: 680,
                            protein: 38,
                            carbohydrates: 64,
                            fat: 28,
                            fiber: 3,
                            sugar: 3,
                            sodium: 420,
                            servingSize: "1/4 recipe"
                        ),
                        tags: ["dinner", "comfort-food", "italian", "creamy"]
                    )
                )
            }
        }

        // Rice Recipes
        if lower.contains("rice") {
            
            if lower.contains("chicken") && !isVegetarian && !isVegan {
                recipes.append(
                    Recipe(
                        title: "Asian Chicken Fried Rice",
                        ingredients: ["3 cups Cooked rice (day-old)", "2 Chicken breasts diced", "2 Eggs", "1 cup Mixed vegetables", "3 tbsp Soy sauce", "2 cloves Garlic", "1 tbsp Ginger", "Green onions", "Sesame oil"],
                        instructions: [
                            "Heat sesame oil in a large wok or skillet over high heat.",
                            "Add diced chicken and cook until golden, about 5-6 minutes.",
                            "Push chicken to the side and scramble eggs in the empty space.",
                            "Add garlic and ginger, stirring for 30 seconds.",
                            "Add vegetables and stir-fry for 2-3 minutes.",
                            "Add rice, breaking up any clumps, and stir-fry for 3-4 minutes.",
                            "Pour soy sauce over everything and toss to combine.",
                            "Garnish with sliced green onions and serve hot."
                        ],
                        timeMinutes: 25,
                        difficulty: .medium,
                        servings: 4,
                        cuisineType: "Asian",
                        nutrition: NutritionInfo(
                            calories: 420,
                            protein: 28,
                            carbohydrates: 52,
                            fat: 10,
                            fiber: 3,
                            sugar: 4,
                            sodium: 680,
                            servingSize: "1/4 recipe"
                        ),
                        tags: ["dinner", "asian", "fried-rice", "one-pan"]
                    )
                )
            }
            
            if (lower.contains("vegetable") || lower.contains("vegetables")) && (isVegetarian || isVegan) {
                recipes.append(
                    Recipe(
                        title: "Vegetable Fried Rice",
                        ingredients: ["3 cups Cooked rice", "2 cups Mixed vegetables", "3 tbsp Soy sauce", "2 cloves Garlic", "1 tbsp Ginger", "Green onions", "Sesame oil", "Salt", "Pepper"],
                        instructions: [
                            "Heat sesame oil in a large wok over high heat.",
                            "Add minced garlic and ginger, stir for 30 seconds.",
                            "Add mixed vegetables and stir-fry for 3-4 minutes.",
                            "Add rice and stir-fry, breaking up clumps.",
                            "Pour soy sauce over rice and vegetables.",
                            "Toss everything together until heated through.",
                            "Season with salt and pepper to taste.",
                            "Garnish with green onions and serve."
                        ],
                        timeMinutes: 20,
                        difficulty: .easy,
                        servings: 4,
                        cuisineType: "Asian",
                        nutrition: NutritionInfo(
                            calories: 280,
                            protein: 6,
                            carbohydrates: 54,
                            fat: 5,
                            fiber: 4,
                            sugar: 5,
                            sodium: 620,
                            servingSize: "1/4 recipe"
                        ),
                        tags: ["dinner", "vegan", "vegetarian", "asian", "healthy"]
                    )
                )
            }
        }

        // Salad Recipes
        if lower.contains("lettuce") || lower.contains("spinach") || lower.contains("greens") {
            
            if lower.contains("chicken") && !isVegetarian && !isVegan {
                recipes.append(
                    Recipe(
                        title: "Grilled Chicken Caesar Salad",
                        ingredients: ["2 Chicken breasts", "4 cups Romaine lettuce", "1/2 cup Caesar dressing", "1/2 cup Parmesan cheese", "Croutons", "Lemon", "Olive oil", "Salt", "Pepper"],
                        instructions: [
                            "Season chicken breasts with salt, pepper, and olive oil.",
                            "Grill or pan-fry chicken until cooked through, about 6-7 minutes per side.",
                            "Let chicken rest for 5 minutes, then slice.",
                            "Chop romaine lettuce and place in a large bowl.",
                            "Add Caesar dressing and toss to coat.",
                            "Top with sliced chicken, Parmesan cheese, and croutons.",
                            "Squeeze fresh lemon juice over the top and serve."
                        ],
                        timeMinutes: 20,
                        difficulty: .easy,
                        servings: 2,
                        cuisineType: "American",
                        nutrition: NutritionInfo(
                            calories: 480,
                            protein: 42,
                            carbohydrates: 18,
                            fat: 28,
                            fiber: 3,
                            sugar: 3,
                            sodium: 720,
                            servingSize: "1/2 recipe"
                        ),
                        tags: ["lunch", "salad", "high-protein", "low-carb"]
                    )
                )
            }
        }

        // Soup Recipes
        if lower.contains("broth") || lower.contains("stock") {
            
            if lower.contains("vegetables") || lower.contains("vegetable") {
                recipes.append(
                    Recipe(
                        title: "Hearty Vegetable Soup",
                        ingredients: ["4 cups Vegetable broth", "2 cups Mixed vegetables", "1 Onion diced", "2 cloves Garlic", "1 can Diced tomatoes", "Herbs (thyme, bay leaf)", "Olive oil", "Salt", "Pepper"],
                        instructions: [
                            "Heat olive oil in a large pot over medium heat.",
                            "Sauté onion until translucent, about 5 minutes.",
                            "Add garlic and cook for 1 minute.",
                            "Add vegetables and stir for 2-3 minutes.",
                            "Pour in vegetable broth and diced tomatoes.",
                            "Add herbs, salt, and pepper.",
                            "Bring to a boil, then reduce heat and simmer for 20 minutes.",
                            "Remove bay leaf and serve hot."
                        ],
                        timeMinutes: 35,
                        difficulty: .easy,
                        servings: 6,
                        cuisineType: "General",
                        nutrition: NutritionInfo(
                            calories: 120,
                            protein: 3,
                            carbohydrates: 22,
                            fat: 3,
                            fiber: 5,
                            sugar: 8,
                            sodium: 480,
                            servingSize: "1/6 recipe"
                        ),
                        tags: ["soup", "vegetarian", "vegan", "healthy", "comfort-food"]
                    )
                )
            }
        }

        // Stir-fry Recipes
        if lower.contains("soy sauce") || (lower.contains("vegetables") && lower.contains("oil")) {
            recipes.append(
                Recipe(
                    title: "Quick Vegetable Stir-Fry",
                    ingredients: ["3 cups Mixed vegetables", "2 tbsp Soy sauce", "1 tbsp Sesame oil", "2 cloves Garlic", "1 tsp Ginger", "Rice or noodles for serving"],
                    instructions: [
                        "Heat sesame oil in a wok over high heat.",
                        "Add minced garlic and ginger, stir for 30 seconds.",
                        "Add vegetables and stir-fry for 5-7 minutes.",
                        "Pour soy sauce over vegetables and toss.",
                        "Cook for another 2 minutes until vegetables are tender-crisp.",
                        "Serve over rice or noodles."
                    ],
                    timeMinutes: 15,
                    difficulty: .easy,
                    servings: 4,
                    cuisineType: "Asian",
                    nutrition: NutritionInfo(
                        calories: 110,
                        protein: 3,
                        carbohydrates: 14,
                        fat: 5,
                        fiber: 4,
                        sugar: 6,
                        sodium: 520,
                        servingSize: "1/4 recipe"
                    ),
                    tags: ["dinner", "vegetarian", "vegan", "quick", "healthy"]
                )
            )
        }

        // If no specific recipes found, generate a generic recipe
        if recipes.isEmpty {
            recipes.append(
                Recipe(
                    title: "Creative Pantry Medley",
                    ingredients: ingredients.isEmpty ? ["Use your available ingredients"] : ingredients,
                    instructions: [
                        "Heat oil in a large pan over medium-high heat.",
                        "Add your available ingredients, starting with the longest-cooking items.",
                        "Season generously with salt, pepper, and any available herbs or spices.",
                        "Cook, stirring occasionally, until everything is heated through and well combined.",
                        "Taste and adjust seasoning as needed.",
                        "Serve hot and enjoy your creative dish!"
                    ],
                    timeMinutes: 20,
                    difficulty: .easy,
                    servings: 4,
                    cuisineType: "Fusion",
                    nutrition: NutritionInfo(
                        calories: 250,
                        protein: 8,
                        carbohydrates: 30,
                        fat: 10,
                        fiber: 4,
                        sugar: 5,
                        sodium: 300,
                        servingSize: "1/4 recipe"
                    ),
                    tags: ["creative", "flexible", "pantry-staples"]
                )
            )
        }

        // Limit results
        return Array(recipes.prefix(maxResults))
    }

    //////////////////////////////////////////////////////////
    // AI Recipe Generator (Enhanced)
    //////////////////////////////////////////////////////////

    private static func generateAIRecipes(
        ingredients: [String],
        apiKey: String,
        preferences: DietaryPreferences,
        maxResults: Int
    ) async throws -> [Recipe] {

        let ingredientList = ingredients.joined(separator: ", ")
        
        var restrictionText = ""
        if !preferences.restrictions.isEmpty {
            let restrictionList = preferences.restrictions.map { $0.rawValue }.joined(separator: ", ")
            restrictionText = " The recipes must be \(restrictionList)."
        }
        
        var allergyText = ""
        if !preferences.allergies.isEmpty {
            let allergyList = preferences.allergies.joined(separator: ", ")
            allergyText = " Avoid these allergens: \(allergyList)."
        }

        let prompt =
        """
        Create \(maxResults) creative and delicious recipes using as many of these ingredients as possible: \(ingredientList).\(restrictionText)\(allergyText)
        
        Respond ONLY with a valid JSON array with this exact structure:
        [
          {
            "title": "Recipe Name",
            "ingredients": ["ingredient 1", "ingredient 2"],
            "instructions": ["step 1", "step 2"],
            "timeMinutes": 30,
            "difficulty": "Easy",
            "servings": 4,
            "cuisineType": "Italian",
            "tags": ["tag1", "tag2"]
          }
        ]
        
        Make the recipes practical, detailed, and appealing. Include proper measurements in ingredients.
        """

        let url = URL(string: "https://api.openai.com/v1/chat/completions")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": "You are a professional chef and recipe developer. Respond only with valid JSON."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.8,
            "max_tokens": 2000
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)

        let response = try JSONDecoder().decode(OpenAIResponse.self, from: data)

        guard let content = response.choices.first?.message.content else {
            throw RecipeError.noContent
        }
        
        // Clean up the response - remove markdown code blocks if present
        let cleanedContent = content
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let jsonData = cleanedContent.data(using: .utf8) else {
            throw RecipeError.invalidJSON
        }

        let recipes = try JSONDecoder().decode([Recipe].self, from: jsonData)
        return recipes
    }
}

//////////////////////////////////////////////////////////
// MARK: Recipe Error
//////////////////////////////////////////////////////////

enum RecipeError: Error {
    case noContent
    case invalidJSON
}

//////////////////////////////////////////////////////////
// MARK: OpenAI Response Model
//////////////////////////////////////////////////////////

struct OpenAIResponse: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let message: Message
}

struct Message: Codable {
    let content: String
}

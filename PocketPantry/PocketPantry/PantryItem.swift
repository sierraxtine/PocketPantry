//
//  PantryItem.swift
//  PocketPantry
//
//  Created by Sierra Christine on 3/8/26.
//


import SwiftUI
import Combine

//////////////////////////////////////////////////////////
// MARK: Pantry Item Model
//////////////////////////////////////////////////////////

struct PantryItem: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var dateAdded: Date
    var expirationDate: Date?
    var category: FoodCategory
    var quantity: Double
    var unit: MeasurementUnit
    var nutritionInfo: NutritionInfo?
    var storageLocation: StorageLocation
    var barcode: String?
    
    init(
        id: UUID = UUID(),
        name: String,
        dateAdded: Date = Date(),
        expirationDate: Date? = nil,
        category: FoodCategory = .other,
        quantity: Double = 1.0,
        unit: MeasurementUnit = .count,
        nutritionInfo: NutritionInfo? = nil,
        storageLocation: StorageLocation = .pantry,
        barcode: String? = nil
    ) {
        self.id = id
        self.name = name
        self.dateAdded = dateAdded
        self.expirationDate = expirationDate
        self.category = category
        self.quantity = quantity
        self.unit = unit
        self.nutritionInfo = nutritionInfo
        self.storageLocation = storageLocation
        self.barcode = barcode
    }
    
    var daysUntilExpiration: Int? {
        guard let expirationDate = expirationDate else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: expirationDate).day
    }
    
    var isExpiringSoon: Bool {
        guard let days = daysUntilExpiration else { return false }
        return days <= 7 && days >= 0
    }
    
    var isExpired: Bool {
        guard let days = daysUntilExpiration else { return false }
        return days < 0
    }
}

//////////////////////////////////////////////////////////
// MARK: Supporting Types
//////////////////////////////////////////////////////////

enum FoodCategory: String, Codable, CaseIterable {
    case vegetables = "Vegetables"
    case fruits = "Fruits"
    case dairy = "Dairy"
    case meat = "Meat"
    case grains = "Grains"
    case spices = "Spices"
    case canned = "Canned"
    case frozen = "Frozen"
    case beverages = "Beverages"
    case condiments = "Condiments"
    case snacks = "Snacks"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .vegetables: return "carrot.fill"
        case .fruits: return "leaf.fill"
        case .dairy: return "cup.and.saucer.fill"
        case .meat: return "flame.fill"
        case .grains: return "takeoutbag.and.cup.and.straw.fill"
        case .spices: return "sparkles"
        case .canned: return "circle.grid.2x2.fill"
        case .frozen: return "snowflake"
        case .beverages: return "drop.fill"
        case .condiments: return "bolt.fill"
        case .snacks: return "popcorn.fill"
        case .other: return "square.grid.2x2.fill"
        }
    }
}

enum MeasurementUnit: String, Codable, CaseIterable {
    case count = "items"
    case grams = "g"
    case kilograms = "kg"
    case ounces = "oz"
    case pounds = "lb"
    case milliliters = "ml"
    case liters = "L"
    case cups = "cups"
    case tablespoons = "tbsp"
    case teaspoons = "tsp"
}

enum StorageLocation: String, Codable, CaseIterable {
    case pantry = "Pantry"
    case refrigerator = "Refrigerator"
    case freezer = "Freezer"
    case cabinet = "Cabinet"
}

struct NutritionInfo: Codable, Equatable {
    var calories: Double
    var protein: Double // grams
    var carbohydrates: Double // grams
    var fat: Double // grams
    var fiber: Double? // grams
    var sugar: Double? // grams
    var sodium: Double? // mg
    var servingSize: String
}

//////////////////////////////////////////////////////////
// MARK: Pantry Store
//////////////////////////////////////////////////////////

@MainActor
class PantryStore: ObservableObject {

    //////////////////////////////////////////////////////////
    // Published Pantry Items
    //////////////////////////////////////////////////////////

    @Published var items: [PantryItem] = [] {
        didSet {
            savePantry()
            updateAnalytics()
        }
    }
    
    @Published var dietaryPreferences: DietaryPreferences = DietaryPreferences()
    @Published var analytics: PantryAnalytics = PantryAnalytics()

    //////////////////////////////////////////////////////////
    // Storage Keys
    //////////////////////////////////////////////////////////

    private let pantryKey = "PocketPantryItems"
    private let preferencesKey = "DietaryPreferences"

    //////////////////////////////////////////////////////////
    // AI Service
    //////////////////////////////////////////////////////////
    
    private let aiService = PantryAIService()

    //////////////////////////////////////////////////////////
    // Init
    //////////////////////////////////////////////////////////

    init() {
        loadPantry()
        loadPreferences()
        updateAnalytics()
    }

    //////////////////////////////////////////////////////////
    // Add Item with Enhanced Logic
    //////////////////////////////////////////////////////////

    func addItem(_ name: String) {
        let cleaned = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return }

        if !items.contains(where: { $0.name.lowercased() == cleaned.lowercased() }) {
            let category = aiService.predictCategory(for: cleaned)
            let expirationDate = aiService.estimateExpirationDate(for: cleaned, category: category)
            
            let newItem = PantryItem(
                name: cleaned,
                dateAdded: Date(),
                expirationDate: expirationDate,
                category: category
            )

            items.append(newItem)
            
            // Fetch nutrition info asynchronously
            Task {
                await fetchNutritionInfo(for: newItem)
            }
        }
    }
    
    //////////////////////////////////////////////////////////
    // Add Item with Full Details
    //////////////////////////////////////////////////////////
    
    func addItem(_ item: PantryItem) {
        if !items.contains(where: { $0.id == item.id }) {
            items.append(item)
        }
    }

    //////////////////////////////////////////////////////////
    // Add Multiple Items
    //////////////////////////////////////////////////////////

    func addItems(_ names: [String]) {
        for name in names {
            addItem(name)
        }
    }

    //////////////////////////////////////////////////////////
    // Remove Item
    //////////////////////////////////////////////////////////

    func removeItem(_ item: PantryItem) {
        items.removeAll { $0.id == item.id }
    }
    
    //////////////////////////////////////////////////////////
    // Update Item
    //////////////////////////////////////////////////////////
    
    func updateItem(_ item: PantryItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
        }
    }

    //////////////////////////////////////////////////////////
    // Clear Pantry
    //////////////////////////////////////////////////////////

    func clearPantry() {
        items.removeAll()
    }
    
    //////////////////////////////////////////////////////////
    // Smart Queries
    //////////////////////////////////////////////////////////
    
    var expiringSoonItems: [PantryItem] {
        items.filter { $0.isExpiringSoon }.sorted { ($0.daysUntilExpiration ?? 0) < ($1.daysUntilExpiration ?? 0) }
    }
    
    var expiredItems: [PantryItem] {
        items.filter { $0.isExpired }
    }
    
    func items(in category: FoodCategory) -> [PantryItem] {
        items.filter { $0.category == category }
    }
    
    func items(in location: StorageLocation) -> [PantryItem] {
        items.filter { $0.storageLocation == location }
    }
    
    //////////////////////////////////////////////////////////
    // Nutrition Analytics
    //////////////////////////////////////////////////////////
    
    func totalNutrition() -> NutritionInfo? {
        let itemsWithNutrition = items.compactMap { $0.nutritionInfo }
        guard !itemsWithNutrition.isEmpty else { return nil }
        
        return NutritionInfo(
            calories: itemsWithNutrition.reduce(0) { $0 + $1.calories },
            protein: itemsWithNutrition.reduce(0) { $0 + $1.protein },
            carbohydrates: itemsWithNutrition.reduce(0) { $0 + $1.carbohydrates },
            fat: itemsWithNutrition.reduce(0) { $0 + $1.fat },
            fiber: itemsWithNutrition.compactMap { $0.fiber }.reduce(0, +),
            sugar: itemsWithNutrition.compactMap { $0.sugar }.reduce(0, +),
            sodium: itemsWithNutrition.compactMap { $0.sodium }.reduce(0, +),
            servingSize: "Total"
        )
    }
    
    //////////////////////////////////////////////////////////
    // Fetch Nutrition Info
    //////////////////////////////////////////////////////////
    
    func fetchNutritionInfo(for item: PantryItem) async {
        guard item.nutritionInfo == nil else { return }
        
        if let nutrition = await aiService.fetchNutritionInfo(for: item.name) {
            if let index = items.firstIndex(where: { $0.id == item.id }) {
                items[index].nutritionInfo = nutrition
            }
        }
    }
    
    //////////////////////////////////////////////////////////
    // Update Analytics
    //////////////////////////////////////////////////////////
    
    private func updateAnalytics() {
        analytics = PantryAnalytics(
            totalItems: items.count,
            expiringSoon: expiringSoonItems.count,
            expired: expiredItems.count,
            categoryCounts: Dictionary(grouping: items, by: { $0.category }).mapValues { $0.count },
            totalCalories: totalNutrition()?.calories ?? 0
        )
    }

    //////////////////////////////////////////////////////////
    // Save Pantry
    //////////////////////////////////////////////////////////

    private func savePantry() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: pantryKey)
        }
    }

    //////////////////////////////////////////////////////////
    // Load Pantry
    //////////////////////////////////////////////////////////

    private func loadPantry() {
        guard let data = UserDefaults.standard.data(forKey: pantryKey) else { return }
        if let decoded = try? JSONDecoder().decode([PantryItem].self, from: data) {
            items = decoded
        }
    }
    
    //////////////////////////////////////////////////////////
    // Save/Load Preferences
    //////////////////////////////////////////////////////////
    
    private func loadPreferences() {
        guard let data = UserDefaults.standard.data(forKey: preferencesKey),
              let decoded = try? JSONDecoder().decode(DietaryPreferences.self, from: data) else { return }
        dietaryPreferences = decoded
    }
    
    func savePreferences() {
        if let encoded = try? JSONEncoder().encode(dietaryPreferences) {
            UserDefaults.standard.set(encoded, forKey: preferencesKey)
        }
    }
}

//////////////////////////////////////////////////////////
// MARK: Dietary Preferences
//////////////////////////////////////////////////////////

struct DietaryPreferences: Codable {
    var restrictions: Set<DietaryRestriction> = []
    var allergies: Set<String> = []
    var calorieGoal: Double?
    var proteinGoal: Double?
    var carbGoal: Double?
    var fatGoal: Double?
    var cuisinePreferences: Set<String> = []
}

enum DietaryRestriction: String, Codable, CaseIterable {
    case vegetarian = "Vegetarian"
    case vegan = "Vegan"
    case glutenFree = "Gluten-Free"
    case dairyFree = "Dairy-Free"
    case ketogenic = "Keto"
    case paleo = "Paleo"
    case lowCarb = "Low-Carb"
    case lowFat = "Low-Fat"
}

//////////////////////////////////////////////////////////
// MARK: Pantry Analytics
//////////////////////////////////////////////////////////

struct PantryAnalytics {
    var totalItems: Int = 0
    var expiringSoon: Int = 0
    var expired: Int = 0
    var categoryCounts: [FoodCategory: Int] = [:]
    var totalCalories: Double = 0
}


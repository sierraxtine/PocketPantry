//
//  ShoppingListView.swift
//  PocketPantry
//
//  AI-powered shopping list generation
//

import SwiftUI

struct ShoppingListView: View {
    
    @ObservedObject var pantry: PantryStore
    @State private var shoppingItems: [ShoppingItem] = []
    @State private var isGenerating = false
    @State private var customItem = ""
    
    var body: some View {
        
        ZStack {
            
            LinearGradient(
                colors: [Color.white, Color.teal.opacity(0.05)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                //////////////////////////////////////////////////////////
                // Header
                //////////////////////////////////////////////////////////
                
                VStack(spacing: 12) {
                    
                    Text("Smart Shopping List")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.teal, .cyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("AI suggests items based on your pantry")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    //////////////////////////////////////////////////////////
                    // Generate Button
                    //////////////////////////////////////////////////////////
                    
                    Button {
                        generateSmartList()
                    } label: {
                        HStack {
                            Image(systemName: "sparkles")
                            Text("Generate Smart List")
                        }
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                colors: [.teal, .cyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(14)
                    }
                    .disabled(isGenerating)
                    .padding(.horizontal)
                }
                .padding(.vertical, 20)
                .background(.ultraThinMaterial)
                
                //////////////////////////////////////////////////////////
                // Loading
                //////////////////////////////////////////////////////////
                
                if isGenerating {
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("AI is analyzing your pantry...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
                
                //////////////////////////////////////////////////////////
                // Shopping List
                //////////////////////////////////////////////////////////
                
                if !shoppingItems.isEmpty {
                    
                    List {
                        
                        Section {
                            ForEach($shoppingItems) { $item in
                                ShoppingItemRow(item: $item)
                            }
                            .onDelete(perform: deleteItems)
                        }
                        
                        Section("Add Custom Item") {
                            HStack {
                                TextField("Enter item name", text: $customItem)
                                
                                Button {
                                    addCustomItem()
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.teal)
                                        .font(.title3)
                                }
                                .disabled(customItem.isEmpty)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    
                    //////////////////////////////////////////////////////////
                    // Action Buttons
                    //////////////////////////////////////////////////////////
                    
                    HStack(spacing: 16) {
                        
                        Button {
                            clearCompleted()
                        } label: {
                            Text("Clear Completed")
                                .font(.subheadline.bold())
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.orange.opacity(0.2))
                                .foregroundColor(.orange)
                                .cornerRadius(12)
                        }
                        
                        Button {
                            shoppingItems.removeAll()
                        } label: {
                            Text("Clear All")
                                .font(.subheadline.bold())
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.red.opacity(0.2))
                                .foregroundColor(.red)
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    
                } else if !isGenerating {
                    
                    //////////////////////////////////////////////////////////
                    // Empty State
                    //////////////////////////////////////////////////////////
                    
                    VStack(spacing: 16) {
                        
                        Image(systemName: "cart.badge.plus")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("No Shopping List")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Generate a smart list or add items manually")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxHeight: .infinity)
                }
            }
        }
    }
    
    //////////////////////////////////////////////////////////
    // Generate Smart List
    //////////////////////////////////////////////////////////
    
    func generateSmartList() {
        isGenerating = true
        
        Task {
            // Simulate AI analysis
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            
            await MainActor.run {
                // Generate smart suggestions based on pantry
                var suggestions: [ShoppingItem] = []
                
                // Check for missing basics
                let basics = ["Milk", "Eggs", "Bread", "Butter", "Salt", "Pepper"]
                let currentItems = Set(pantry.items.map { $0.name.lowercased() })
                
                for basic in basics {
                    if !currentItems.contains(basic.lowercased()) {
                        suggestions.append(ShoppingItem(name: basic, category: .basics, priority: .medium))
                    }
                }
                
                // Add produce suggestions
                if currentItems.filter({ ["apple", "banana", "orange", "lettuce"].contains($0) }).count < 2 {
                    suggestions.append(ShoppingItem(name: "Fresh Vegetables", category: .produce, priority: .high))
                    suggestions.append(ShoppingItem(name: "Fresh Fruits", category: .produce, priority: .high))
                }
                
                // Add protein suggestions
                if !currentItems.contains(where: { ["chicken", "beef", "fish", "tofu"].contains($0) }) {
                    suggestions.append(ShoppingItem(name: "Protein (Chicken, Fish, or Tofu)", category: .protein, priority: .high))
                }
                
                // Check for expiring items
                for item in pantry.expiringSoonItems.prefix(3) {
                    suggestions.append(ShoppingItem(
                        name: "\(item.name) (Running Low)",
                        category: .restock,
                        priority: .high
                    ))
                }
                
                shoppingItems = suggestions
                isGenerating = false
            }
        }
    }
    
    //////////////////////////////////////////////////////////
    // Add Custom Item
    //////////////////////////////////////////////////////////
    
    func addCustomItem() {
        guard !customItem.isEmpty else { return }
        shoppingItems.append(ShoppingItem(name: customItem, category: .custom, priority: .medium))
        customItem = ""
    }
    
    //////////////////////////////////////////////////////////
    // Delete Items
    //////////////////////////////////////////////////////////
    
    func deleteItems(at offsets: IndexSet) {
        shoppingItems.remove(atOffsets: offsets)
    }
    
    //////////////////////////////////////////////////////////
    // Clear Completed
    //////////////////////////////////////////////////////////
    
    func clearCompleted() {
        shoppingItems.removeAll { $0.isCompleted }
    }
}

//////////////////////////////////////////////////////////
// MARK: Shopping Item Model
//////////////////////////////////////////////////////////

struct ShoppingItem: Identifiable {
    var id = UUID()
    var name: String
    var category: ShoppingCategory
    var priority: Priority
    var isCompleted: Bool = false
    
    enum ShoppingCategory: String {
        case basics = "Basics"
        case produce = "Produce"
        case protein = "Protein"
        case restock = "Restock"
        case custom = "Custom"
        
        var icon: String {
            switch self {
            case .basics: return "basket.fill"
            case .produce: return "leaf.fill"
            case .protein: return "flame.fill"
            case .restock: return "arrow.clockwise"
            case .custom: return "star.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .basics: return .blue
            case .produce: return .green
            case .protein: return .red
            case .restock: return .orange
            case .custom: return .purple
            }
        }
    }
    
    enum Priority {
        case low, medium, high
        
        var icon: String {
            switch self {
            case .low: return "exclamationmark"
            case .medium: return "exclamationmark.2"
            case .high: return "exclamationmark.3"
            }
        }
    }
}

//////////////////////////////////////////////////////////
// MARK: Shopping Item Row
//////////////////////////////////////////////////////////

struct ShoppingItemRow: View {
    
    @Binding var item: ShoppingItem
    
    var body: some View {
        
        HStack(spacing: 12) {
            
            Button {
                withAnimation {
                    item.isCompleted.toggle()
                }
            } label: {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.isCompleted ? .green : .gray)
                    .font(.title3)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                
                Text(item.name)
                    .strikethrough(item.isCompleted)
                    .foregroundColor(item.isCompleted ? .secondary : .primary)
                
                HStack(spacing: 8) {
                    
                    Label(item.category.rawValue, systemImage: item.category.icon)
                        .font(.caption)
                        .foregroundColor(item.category.color)
                    
                    if item.priority == .high {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ShoppingListView(pantry: PantryStore())
}

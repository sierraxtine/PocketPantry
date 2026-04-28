//
//  MealPlanningView.swift
//  PocketPantry
//
//  AI-powered meal planning
//

import SwiftUI

struct MealPlanningView: View {
    
    @ObservedObject var pantry: PantryStore
    @State private var mealPlans: [MealPlan] = []
    @State private var isGenerating = false
    @State private var selectedDays: Int = 7
    @State private var showPreferencesSheet = false
    
    private let aiService = PantryAIService()
    
    var body: some View {
        
        ZStack {
            
            LinearGradient(
                colors: [Color.white, Color.blue.opacity(0.05)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                
                VStack(spacing: 30) {
                    
                    //////////////////////////////////////////////////////////
                    // Header
                    //////////////////////////////////////////////////////////
                    
                    Text("AI Meal Planner")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("Let AI create personalized meal plans")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    //////////////////////////////////////////////////////////
                    // Configuration
                    //////////////////////////////////////////////////////////
                    
                    VStack(spacing: 16) {
                        
                        HStack {
                            Text("Plan Duration")
                                .font(.headline)
                            Spacer()
                            Picker("Days", selection: $selectedDays) {
                                Text("3 Days").tag(3)
                                Text("5 Days").tag(5)
                                Text("7 Days").tag(7)
                                Text("14 Days").tag(14)
                            }
                            .pickerStyle(.menu)
                        }
                        
                        HStack {
                            Text("Dietary Preferences")
                                .font(.headline)
                            Spacer()
                            Button {
                                showPreferencesSheet = true
                            } label: {
                                HStack {
                                    Text("\(pantry.dietaryPreferences.restrictions.count) set")
                                        .foregroundColor(.secondary)
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                }
                            }
                        }
                        
                        Button {
                            generateMealPlan()
                        } label: {
                            HStack {
                                Image(systemName: "sparkles")
                                Text("Generate Meal Plan")
                            }
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(14)
                        }
                        .disabled(pantry.items.isEmpty || isGenerating)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                    )
                    .padding(.horizontal)
                    
                    //////////////////////////////////////////////////////////
                    // Loading
                    //////////////////////////////////////////////////////////
                    
                    if isGenerating {
                        VStack(spacing: 12) {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("AI is creating your meal plan...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }
                    
                    //////////////////////////////////////////////////////////
                    // Meal Plans
                    //////////////////////////////////////////////////////////
                    
                    if !mealPlans.isEmpty {
                        
                        VStack(alignment: .leading, spacing: 20) {
                            
                            ForEach(mealPlans) { plan in
                                
                                MealPlanCard(plan: plan)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    //////////////////////////////////////////////////////////
                    // Empty State
                    //////////////////////////////////////////////////////////
                    
                    if mealPlans.isEmpty && !isGenerating {
                        
                        VStack(spacing: 16) {
                            
                            Image(systemName: "calendar.badge.clock")
                                .font(.system(size: 60))
                                .foregroundColor(.gray.opacity(0.5))
                            
                            Text("No Meal Plan Yet")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text("Generate a plan based on your pantry items")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(40)
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.top, 40)
            }
        }
        .sheet(isPresented: $showPreferencesSheet) {
            GoalsSettingsView(pantry: pantry)
        }
    }
    
    //////////////////////////////////////////////////////////
    // Generate Meal Plan
    //////////////////////////////////////////////////////////
    
    func generateMealPlan() {
        isGenerating = true
        
        Task {
            let ingredients = pantry.items.map { $0.name }
            let plans = await aiService.generateMealPlan(
                for: selectedDays,
                with: ingredients,
                preferences: pantry.dietaryPreferences
            )
            
            await MainActor.run {
                mealPlans = plans
                isGenerating = false
            }
        }
    }
}

//////////////////////////////////////////////////////////
// MARK: Meal Plan Card
//////////////////////////////////////////////////////////

struct MealPlanCard: View {
    
    let plan: MealPlan
    @State private var isExpanded = false
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
            
            Button {
                withAnimation(.spring()) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(plan.formattedDate)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("\(plan.meals.count) meals")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.blue)
                        .font(.caption)
                }
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                
                Divider()
                
                VStack(alignment: .leading, spacing: 12) {
                    
                    ForEach(Array(plan.meals.enumerated()), id: \.offset) { index, meal in
                        
                        HStack(spacing: 12) {
                            
                            ZStack {
                                Circle()
                                    .fill(mealColor(for: index))
                                    .frame(width: 40, height: 40)
                                
                                Image(systemName: mealIcon(for: index))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(mealTime(for: index))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text(meal)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
        )
    }
    
    func mealTime(for index: Int) -> String {
        switch index {
        case 0: return "Breakfast"
        case 1: return "Lunch"
        case 2: return "Dinner"
        default: return "Snack"
        }
    }
    
    func mealIcon(for index: Int) -> String {
        switch index {
        case 0: return "sunrise.fill"
        case 1: return "sun.max.fill"
        case 2: return "moon.stars.fill"
        default: return "leaf.fill"
        }
    }
    
    func mealColor(for index: Int) -> Color {
        switch index {
        case 0: return .orange
        case 1: return .blue
        case 2: return .purple
        default: return .green
        }
    }
}

#Preview {
    MealPlanningView(pantry: PantryStore())
}

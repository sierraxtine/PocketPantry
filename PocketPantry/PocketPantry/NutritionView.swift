import SwiftUI
import Charts

struct NutritionView: View {
    
    @ObservedObject var pantry: PantryStore
    @State private var selectedTimeRange: TimeRange = .week
    @State private var showGoalSheet = false
    
    private var totalNutrition: NutritionInfo {
        pantry.totalNutrition() ?? NutritionInfo(
            calories: 0,
            protein: 0,
            carbohydrates: 0,
            fat: 0,
            servingSize: "Total"
        )
    }
    
    var body: some View {
        
        ZStack {
            
            LinearGradient(
                colors: [Color.white, Color.purple.opacity(0.05)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                
                VStack(spacing: 30) {
                    
                    //////////////////////////////////////////////////////////
                    // Header
                    //////////////////////////////////////////////////////////
                    
                    Text("Nutrition Dashboard")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.purple, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    //////////////////////////////////////////////////////////
                    // Macro Summary Cards
                    //////////////////////////////////////////////////////////
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        
                        MacroCard(
                            title: "Calories",
                            value: String(format: "%.0f", totalNutrition.calories),
                            unit: "kcal",
                            color: .red,
                            icon: "flame.fill",
                            goal: pantry.dietaryPreferences.calorieGoal
                        )
                        
                        MacroCard(
                            title: "Protein",
                            value: String(format: "%.1f", totalNutrition.protein),
                            unit: "g",
                            color: .blue,
                            icon: "circle.hexagongrid.fill",
                            goal: pantry.dietaryPreferences.proteinGoal
                        )
                        
                        MacroCard(
                            title: "Carbs",
                            value: String(format: "%.1f", totalNutrition.carbohydrates),
                            unit: "g",
                            color: .orange,
                            icon: "leaf.fill",
                            goal: pantry.dietaryPreferences.carbGoal
                        )
                        
                        MacroCard(
                            title: "Fat",
                            value: String(format: "%.1f", totalNutrition.fat),
                            unit: "g",
                            color: .yellow,
                            icon: "drop.fill",
                            goal: pantry.dietaryPreferences.fatGoal
                        )
                    }
                    .padding(.horizontal)
                    
                    //////////////////////////////////////////////////////////
                    // Macro Distribution Chart
                    //////////////////////////////////////////////////////////
                    
                    VStack(alignment: .leading, spacing: 16) {
                        
                        Text("Macronutrient Distribution")
                            .font(.title2.bold())
                            .padding(.horizontal)
                        
                        Chart {
                            SectorMark(
                                angle: .value("Protein", totalNutrition.protein * 4),
                                innerRadius: .ratio(0.5),
                                angularInset: 2
                            )
                            .foregroundStyle(Color.blue)
                            .annotation(position: .overlay) {
                                Text("Protein")
                                    .font(.caption.bold())
                                    .foregroundColor(.white)
                            }
                            
                            SectorMark(
                                angle: .value("Carbs", totalNutrition.carbohydrates * 4),
                                innerRadius: .ratio(0.5),
                                angularInset: 2
                            )
                            .foregroundStyle(Color.orange)
                            .annotation(position: .overlay) {
                                Text("Carbs")
                                    .font(.caption.bold())
                                    .foregroundColor(.white)
                            }
                            
                            SectorMark(
                                angle: .value("Fat", totalNutrition.fat * 9),
                                innerRadius: .ratio(0.5),
                                angularInset: 2
                            )
                            .foregroundStyle(Color.yellow)
                            .annotation(position: .overlay) {
                                Text("Fat")
                                    .font(.caption.bold())
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(height: 220)
                        .padding()
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                    )
                    .padding(.horizontal)
                    
                    //////////////////////////////////////////////////////////
                    // Additional Nutrients
                    //////////////////////////////////////////////////////////
                    
                    if let fiber = totalNutrition.fiber,
                       let sugar = totalNutrition.sugar,
                       let sodium = totalNutrition.sodium {
                        
                        VStack(alignment: .leading, spacing: 12) {
                            
                            Text("Additional Nutrients")
                                .font(.title3.bold())
                            
                            NutrientRow(label: "Fiber", value: fiber, unit: "g", icon: "circle.grid.3x3.fill", color: .green)
                            NutrientRow(label: "Sugar", value: sugar, unit: "g", icon: "sparkle", color: .pink)
                            NutrientRow(label: "Sodium", value: sodium, unit: "mg", icon: "bolt.fill", color: .purple)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial)
                        )
                        .padding(.horizontal)
                    }
                    
                    //////////////////////////////////////////////////////////
                    // Dietary Preferences
                    //////////////////////////////////////////////////////////
                    
                    VStack(alignment: .leading, spacing: 12) {
                        
                        HStack {
                            Text("Dietary Preferences")
                                .font(.title3.bold())
                            
                            Spacer()
                            
                            Button {
                                showGoalSheet = true
                            } label: {
                                Image(systemName: "gearshape.fill")
                                    .foregroundColor(.purple)
                            }
                        }
                        
                        if pantry.dietaryPreferences.restrictions.isEmpty {
                            Text("No dietary restrictions set")
                                .foregroundColor(.secondary)
                                .font(.subheadline)
                        } else {
                            FlowLayout(spacing: 8) {
                                ForEach(Array(pantry.dietaryPreferences.restrictions), id: \.self) { restriction in
                                    Text(restriction.rawValue)
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.purple.opacity(0.2))
                                        .foregroundColor(.purple)
                                        .cornerRadius(12)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                    )
                    .padding(.horizontal)
                    
                    //////////////////////////////////////////////////////////
                    // AI Recommendations
                    //////////////////////////////////////////////////////////
                    
                    VStack(alignment: .leading, spacing: 12) {
                        
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundColor(.yellow)
                            Text("AI Recommendations")
                                .font(.title3.bold())
                        }
                        
                        AIRecommendationCard(
                            icon: "leaf.fill",
                            text: "Your pantry is rich in proteins! Consider adding more vegetables for a balanced diet.",
                            color: .green
                        )
                        
                        AIRecommendationCard(
                            icon: "flame.fill",
                            text: "Based on your items, you could create 8 different healthy meals this week.",
                            color: .orange
                        )
                        
                        if !pantry.expiringSoonItems.isEmpty {
                            AIRecommendationCard(
                                icon: "clock.fill",
                                text: "You have \(pantry.expiringSoonItems.count) item(s) expiring soon. Use them first!",
                                color: .red
                            )
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                    )
                    .padding(.horizontal)
                    
                    Spacer(minLength: 40)
                }
                .padding(.top, 40)
            }
        }
        .sheet(isPresented: $showGoalSheet) {
            GoalsSettingsView(pantry: pantry)
        }
    }
}

//////////////////////////////////////////////////////////
// MARK: Macro Card
//////////////////////////////////////////////////////////

struct MacroCard: View {
    
    let title: String
    let value: String
    let unit: String
    let color: Color
    let icon: String
    let goal: Double?
    
    var body: some View {
        
        VStack(spacing: 12) {
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(color)
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let goal = goal {
                ProgressView(value: Double(value) ?? 0, total: goal)
                    .tint(color)
                Text("Goal: \(Int(goal)) \(unit)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

//////////////////////////////////////////////////////////
// MARK: Nutrient Row
//////////////////////////////////////////////////////////

struct NutrientRow: View {
    
    let label: String
    let value: Double
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(label)
                .font(.subheadline)
            
            Spacer()
            
            Text(String(format: "%.1f", value))
                .font(.subheadline.bold())
            Text(unit)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

//////////////////////////////////////////////////////////
// MARK: AI Recommendation Card
//////////////////////////////////////////////////////////

struct AIRecommendationCard: View {
    
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        
        HStack(spacing: 12) {
            
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 32)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

//////////////////////////////////////////////////////////
// MARK: Flow Layout
//////////////////////////////////////////////////////////

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}

//////////////////////////////////////////////////////////
// MARK: Time Range
//////////////////////////////////////////////////////////

enum TimeRange: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
}

//////////////////////////////////////////////////////////
// MARK: Goals Settings View
//////////////////////////////////////////////////////////

struct GoalsSettingsView: View {
    
    @ObservedObject var pantry: PantryStore
    @Environment(\.dismiss) var dismiss
    
    @State private var calorieGoal: String
    @State private var proteinGoal: String
    @State private var carbGoal: String
    @State private var fatGoal: String
    @State private var selectedRestrictions: Set<DietaryRestriction>
    
    init(pantry: PantryStore) {
        self.pantry = pantry
        _calorieGoal = State(initialValue: pantry.dietaryPreferences.calorieGoal.map { String(Int($0)) } ?? "")
        _proteinGoal = State(initialValue: pantry.dietaryPreferences.proteinGoal.map { String(Int($0)) } ?? "")
        _carbGoal = State(initialValue: pantry.dietaryPreferences.carbGoal.map { String(Int($0)) } ?? "")
        _fatGoal = State(initialValue: pantry.dietaryPreferences.fatGoal.map { String(Int($0)) } ?? "")
        _selectedRestrictions = State(initialValue: pantry.dietaryPreferences.restrictions)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Daily Goals") {
                    HStack {
                        Text("Calories")
                        TextField("2000", text: $calorieGoal)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Protein (g)")
                        TextField("50", text: $proteinGoal)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Carbs (g)")
                        TextField("250", text: $carbGoal)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Fat (g)")
                        TextField("70", text: $fatGoal)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section("Dietary Restrictions") {
                    ForEach(DietaryRestriction.allCases, id: \.self) { restriction in
                        Toggle(restriction.rawValue, isOn: Binding(
                            get: { selectedRestrictions.contains(restriction) },
                            set: { isOn in
                                if isOn {
                                    selectedRestrictions.insert(restriction)
                                } else {
                                    selectedRestrictions.remove(restriction)
                                }
                            }
                        ))
                    }
                }
            }
            .navigationTitle("Nutrition Goals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveGoals()
                        dismiss()
                    }
                }
            }
        }
    }
    
    func saveGoals() {
        pantry.dietaryPreferences.calorieGoal = Double(calorieGoal)
        pantry.dietaryPreferences.proteinGoal = Double(proteinGoal)
        pantry.dietaryPreferences.carbGoal = Double(carbGoal)
        pantry.dietaryPreferences.fatGoal = Double(fatGoal)
        pantry.dietaryPreferences.restrictions = selectedRestrictions
        pantry.savePreferences()
    }
}

#Preview {
    NutritionView(pantry: PantryStore())
}

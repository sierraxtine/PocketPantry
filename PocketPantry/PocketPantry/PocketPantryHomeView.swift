import SwiftUI

struct PocketPantryHomeView: View {
    
    @StateObject private var pantry = PantryStore()
    @State private var animateStats = false
    @State private var animateTiles = false
    @State private var hoveredTile: String? = nil
    
    let columns = [
        GridItem(.adaptive(minimum: 240), spacing: 28)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                FloatingFoodBackground()
                
                LinearGradient(
                    colors: [
                        Color.white,
                        Color.green.opacity(0.06),
                        Color.blue.opacity(0.05),
                        Color.white
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 40) {
                        
                        AnimatedTitle()
                        
                        //////////////////////////////////////////////////////////
                        // MARK: Progress Rings
                        //////////////////////////////////////////////////////////
                        
                        HStack(spacing: 30) {
                            
                            PantryRing(
                                progress: min(Double(pantry.analytics.totalItems) / 50.0, 1.0),
                                title: "Pantry Full",
                                count: pantry.analytics.totalItems,
                                color: .green
                            )
                            
                            PantryRing(
                                progress: pantry.analytics.totalItems > 0 ? min(Double(pantry.analytics.expiringSoon) / Double(pantry.analytics.totalItems), 1.0) : 0,
                                title: "Expiring Soon",
                                count: pantry.analytics.expiringSoon,
                                color: .orange
                            )
                            
                            PantryRing(
                                progress: pantry.analytics.totalItems > 0 ? min(Double(pantry.analytics.expired) / Double(pantry.analytics.totalItems), 1.0) : 0,
                                title: "Expired",
                                count: pantry.analytics.expired,
                                color: .red
                            )
                        }
                        .padding(.horizontal)
                        .opacity(animateStats ? 1 : 0)
                        .offset(y: animateStats ? 0 : -40)
                        .animation(.easeOut(duration: 0.6).delay(0.2), value: animateStats)
                        
                        //////////////////////////////////////////////////////////
                        // MARK: Tiles
                        //////////////////////////////////////////////////////////
                        
                        LazyVGrid(columns: columns, spacing: 30) {
                            
                            Tile(
                                id: "about",
                                title: "About",
                                icon: "info.circle.fill",
                                color: .mint,
                                delay: 0.1,
                                animateTiles: animateTiles,
                                hoveredTile: $hoveredTile
                            )
                            
                            Tile(
                                id: "scan",
                                title: "AI Scanner",
                                icon: "barcode.viewfinder",
                                color: .blue,
                                delay: 0.2,
                                animateTiles: animateTiles,
                                hoveredTile: $hoveredTile
                            )
                            
                            Tile(
                                id: "enter",
                                title: "Enter Items",
                                icon: "square.and.pencil",
                                color: .orange,
                                delay: 0.3,
                                animateTiles: animateTiles,
                                hoveredTile: $hoveredTile
                            )
                            
                            Tile(
                                id: "nutrition",
                                title: "Nutrition AI",
                                icon: "leaf.fill",
                                color: .purple,
                                delay: 0.4,
                                animateTiles: animateTiles,
                                hoveredTile: $hoveredTile
                            )
                            
                            Tile(
                                id: "pantry",
                                title: "Smart Pantry",
                                icon: "shippingbox.fill",
                                color: .green,
                                delay: 0.5,
                                animateTiles: animateTiles,
                                hoveredTile: $hoveredTile
                            )
                            
                            Tile(
                                id: "mealplan",
                                title: "Meal Planner",
                                icon: "calendar.badge.clock",
                                color: .indigo,
                                delay: 0.6,
                                animateTiles: animateTiles,
                                hoveredTile: $hoveredTile
                            )
                            
                            Tile(
                                id: "shopping",
                                title: "Shopping List",
                                icon: "cart.fill",
                                color: .teal,
                                delay: 0.7,
                                animateTiles: animateTiles,
                                hoveredTile: $hoveredTile
                            )
                            
                            Tile(
                                id: "settings",
                                title: "Settings",
                                icon: "gearshape.fill",
                                color: .gray,
                                delay: 0.8,
                                animateTiles: animateTiles,
                                hoveredTile: $hoveredTile
                            )
                        }
                        .padding(.horizontal)
                        
                        //////////////////////////////////////////////////////////
                        // MARK: Navigation
                        //////////////////////////////////////////////////////////

                        .navigationDestination(for: String.self) { id in
                            
                            switch id {
                                
                            case "about":
                                AboutView()
                                
                            case "scan":
                                ScanView(pantry: pantry)
                                
                            case "enter":
                                EnterItemsView(pantry: pantry)
                                
                            case "nutrition":
                                NutritionView(pantry: pantry)
                                
                            case "pantry":
                                PantryView(pantry: pantry)
                            
                            case "mealplan":
                                MealPlanningView(pantry: pantry)
                            
                            case "shopping":
                                ShoppingListView(pantry: pantry)
                                
                            case "settings":
                                SettingsView(pantry: pantry)
                                
                            default:
                                Text("Coming Soon")
                            }
                        }

                        Spacer(minLength: 80)
                        }
                        .padding(.top, 40)
                        }
                //////////////////////////////////////////////////////////
                // MARK: Floating Scan Button
                //////////////////////////////////////////////////////////
                
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        NavigationLink(value: "scan") {
                            
                            ZStack {
                                
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.green, .mint],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 70, height: 70)
                                
                                Image(systemName: "barcode.viewfinder")
                                    .font(.system(size: 28))
                                    .foregroundColor(.white)
                            }
                            .shadow(radius: 14)
                        }
                        .padding()
                    }
                }
            }
            .onAppear {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    animateStats = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    animateTiles = true
                }
            }
        }
    }
}

//////////////////////////////////////////////////////////
// MARK: Animated Title
//////////////////////////////////////////////////////////

struct AnimatedTitle: View {
    
    @State private var shimmer = false
    
    var body: some View {
        
        Text("Welcome to Pocket Pantry")
            .font(.system(size: 46, weight: .bold))
            .foregroundStyle(
                LinearGradient(
                    colors: [.green, .mint, .blue],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .overlay(
                GeometryReader { geo in
                    
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.clear, .white.opacity(0.7), .clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .rotationEffect(.degrees(20))
                        .offset(x: shimmer ? geo.size.width : -geo.size.width)
                        .animation(
                            .easeInOut(duration: 2)
                                .repeatForever(autoreverses: false),
                            value: shimmer
                        )
                }
                .mask(
                    Text("Welcome to Pocket Pantry")
                        .font(.system(size: 46, weight: .bold))
                )
            )
            .onAppear {
                shimmer = true
            }
    }
}

//////////////////////////////////////////////////////////
// MARK: Floating Background
//////////////////////////////////////////////////////////

struct FloatingFoodBackground: View {
    
    @State private var animate = false
    
    let foods = [
        "leaf.fill",
        "carrot.fill",
        "flame.fill",
        "drop.fill"
    ]
    
    var body: some View {
        
        GeometryReader { geo in
            
            ZStack {
                
                ForEach(0..<10) { index in
                    
                    Image(systemName: foods[index % foods.count])
                        .font(.system(size: CGFloat.random(in: 28...60)))
                        .foregroundStyle(.green.opacity(0.12))
                        .position(
                            x: CGFloat.random(in: 0...geo.size.width),
                            y: CGFloat.random(in: 0...geo.size.height)
                        )
                        .offset(
                            x: animate ? CGFloat.random(in: -40...40) : 0,
                            y: animate ? CGFloat.random(in: -60...60) : 0
                        )
                        .animation(
                            .easeInOut(duration: Double.random(in: 10...16))
                                .repeatForever(autoreverses: true),
                            value: animate
                        )
                }
            }
        }
        .ignoresSafeArea()
        .onAppear { animate = true }
    }
}

//////////////////////////////////////////////////////////
// MARK: Pantry Ring
//////////////////////////////////////////////////////////

struct PantryRing: View {
    
    var progress: Double
    var title: String
    var count: Int
    var color: Color
    
    var body: some View {
        
        VStack {
            
            ZStack {
                
                Circle()
                    .stroke(color.opacity(0.15), lineWidth: 10)
                    .frame(width: 80)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            colors: [color, color.opacity(0.6)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 80)
                
                Text("\(count)")
                    .font(.title3.bold())
            }
            
            Text(title)
                .font(.caption)
        }
    }
}

//////////////////////////////////////////////////////////
// MARK: Tile
//////////////////////////////////////////////////////////

struct Tile: View {
    
    var id: String
    var title: String
    var icon: String
    var color: Color
    var delay: Double
    var animateTiles: Bool
    
    @Binding var hoveredTile: String?
    
    var isHovered: Bool { hoveredTile == id }
    
    var body: some View {
        
        NavigationLink(value: id) {
            
            VStack(spacing: 18) {
                
                ZStack {
                    Circle()
                        .fill(color.opacity(0.18))
                        .frame(width: 60)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 150)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(color.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.08), radius: isHovered ? 18 : 8)
            .scaleEffect(isHovered ? 1.05 : 1)
            .offset(y: animateTiles ? 0 : -80)
            .opacity(animateTiles ? 1 : 0)
            .animation(.spring().delay(delay), value: animateTiles)
            .animation(.spring(response: 0.35), value: isHovered)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            hoveredTile = hovering ? id : nil
        }
    }
}

#Preview {
    PocketPantryHomeView()
}


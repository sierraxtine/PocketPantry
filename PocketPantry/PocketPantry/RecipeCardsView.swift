import SwiftUI

//////////////////////////////////////////////////////////
// MARK: Recipe Cards View
//////////////////////////////////////////////////////////

struct RecipeCardsView: View {

    let ingredients: [String]

    @State private var recipes: [Recipe] = []
    @State private var loading = true

    var body: some View {

        ZStack {

            LinearGradient(
                colors: [
                    Color.white,
                    Color.green.opacity(0.05)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 25) {

                Text("Recipe Ideas")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.green)

                if loading {

                    ProgressView("Generating Recipes...")
                        .padding()

                } else {

                    recipeContent
                }

                Spacer()
            }
            .padding(.top, 40)
        }
        .task {

            recipes = await RecipeEngine.generateRecipes(from: ingredients)

            loading = false
        }
    }

    //////////////////////////////////////////////////////////
    // Platform Specific Layout
    //////////////////////////////////////////////////////////

    @ViewBuilder
    var recipeContent: some View {

#if os(iOS)

        TabView {

            ForEach(recipes) { recipe in
                RecipeCard(recipe: recipe)
                    .padding(.horizontal, 25)
            }
        }
        .tabViewStyle(.page)

#else

        ScrollView {

            VStack(spacing: 20) {

                ForEach(recipes) { recipe in
                    RecipeCard(recipe: recipe)
                        .padding(.horizontal, 25)
                }
            }
        }

#endif
    }
}

//////////////////////////////////////////////////////////
// MARK: Recipe Card
//////////////////////////////////////////////////////////

struct RecipeCard: View {

    let recipe: Recipe

    var body: some View {

        VStack(alignment: .leading, spacing: 18) {

            Text(recipe.title)
                .font(.title.bold())

            Label("\(recipe.timeMinutes) min", systemImage: "clock")
                .foregroundColor(.green)

            Divider()

            //////////////////////////////////////////////////////////
            // Ingredients
            //////////////////////////////////////////////////////////

            Text("Ingredients")
                .font(.headline)

            ForEach(recipe.ingredients, id: \.self) { ingredient in

                HStack {

                    Image(systemName: "leaf.fill")
                        .foregroundColor(.green)

                    Text(ingredient)

                    Spacer()
                }
            }

            Divider()

            //////////////////////////////////////////////////////////
            // Instructions
            //////////////////////////////////////////////////////////

            Text("Instructions")
                .font(.headline)

            ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, step in

                HStack(alignment: .top) {

                    Text("\(index + 1).")
                        .fontWeight(.bold)

                    Text(step)

                    Spacer()
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.white)
                .shadow(radius: 6)
        )
    }
}

//////////////////////////////////////////////////////////
// Preview
//////////////////////////////////////////////////////////

#Preview {
    RecipeCardsView(
        ingredients: ["eggs", "spinach", "pasta"]
    )
}

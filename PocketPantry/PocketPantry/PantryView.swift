import SwiftUI

//////////////////////////////////////////////////////////
// MARK: Pantry View
//////////////////////////////////////////////////////////

struct PantryView: View {

    @ObservedObject var pantry: PantryStore

    var body: some View {

        ZStack {

            //////////////////////////////////////////////////////////
            // Background
            //////////////////////////////////////////////////////////

            LinearGradient(
                colors: [
                    Color.white,
                    Color.green.opacity(0.05)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            //////////////////////////////////////////////////////////
            // Main Layout
            //////////////////////////////////////////////////////////

            VStack(spacing: 25) {

                //////////////////////////////////////////////////////////
                // Title
                //////////////////////////////////////////////////////////

                Text("Your Pantry")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.green)

                //////////////////////////////////////////////////////////
                // Empty State
                //////////////////////////////////////////////////////////

                if pantry.items.isEmpty {

                    VStack(spacing: 15) {

                        Image(systemName: "shippingbox")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)

                        Text("Your pantry is empty")
                            .foregroundColor(.gray)

                        Text("Add ingredients using Scan or Enter Items")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

                //////////////////////////////////////////////////////////
                // Pantry Items
                //////////////////////////////////////////////////////////

                else {

                    List {

                        ForEach(pantry.items) { item in

                            VStack(alignment: .leading, spacing: 4) {

                                HStack {

                                    Image(systemName: "leaf.fill")
                                        .foregroundColor(.green)

                                    Text(item.name)
                                        .fontWeight(.semibold)

                                    Spacer()
                                }

                                Text("Added \(item.dateAdded.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .onDelete(perform: deleteItem)
                    }
                    .listStyle(.inset)
                }

                //////////////////////////////////////////////////////////
                // Recipe Suggestions
                //////////////////////////////////////////////////////////

                if !pantry.items.isEmpty {

                    NavigationLink {

                        RecipeCardsView(
                            ingredients: pantry.items.map { $0.name }
                        )

                    } label: {

                        Label("Suggest Recipes", systemImage: "fork.knife")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }

                //////////////////////////////////////////////////////////
                // Clear Pantry
                //////////////////////////////////////////////////////////

                if !pantry.items.isEmpty {

                    Button {

                        pantry.clearPantry()

                    } label: {

                        Text("Clear Pantry")
                            .fontWeight(.semibold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.9))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }

                Spacer()
            }
            .padding(.top, 40)
        }
    }

    //////////////////////////////////////////////////////////
    // Delete Item
    //////////////////////////////////////////////////////////

    func deleteItem(at offsets: IndexSet) {

        for index in offsets {

            pantry.removeItem(pantry.items[index])
        }
    }
}

//////////////////////////////////////////////////////////
// Preview
//////////////////////////////////////////////////////////

#Preview {

    NavigationStack {

        PantryView(pantry: PantryStore())
    }
}

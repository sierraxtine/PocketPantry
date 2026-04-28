//
//  NutritionFactsView.swift
//  PocketPantry
//
//  Created by Sierra Christine on 3/8/26.
//


import SwiftUI

//////////////////////////////////////////////////////////
// MARK: Nutrition Facts View
//////////////////////////////////////////////////////////

struct NutritionFactsView: View {

    @State private var searchText: String = ""
    @State private var results: [NutritionItem] = []

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

            VStack(spacing: 25) {

                //////////////////////////////////////////////////////////
                // Title
                //////////////////////////////////////////////////////////

                Text("Nutrition Facts")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.green)

                //////////////////////////////////////////////////////////
                // Search Bar
                //////////////////////////////////////////////////////////

                HStack {

                    TextField("Search food...", text: $searchText)
                        .textFieldStyle(.roundedBorder)

                    Button {

                        searchFood()

                    } label: {

                        Image(systemName: "magnifyingglass.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.green)
                    }
                }
                .padding(.horizontal)

                //////////////////////////////////////////////////////////
                // Results
                //////////////////////////////////////////////////////////

                ScrollView {

                    VStack(spacing: 16) {

                        ForEach(results) { item in

                            NutritionCard(item: item)
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer()
            }
            .padding(.top, 40)
        }
    }

    //////////////////////////////////////////////////////////
    // Demo Nutrition Lookup
    //////////////////////////////////////////////////////////

    func searchFood() {

        let food = searchText.lowercased()

        results.removeAll()

        if food.contains("egg") {

            results.append(
                NutritionItem(
                    name: "Egg",
                    calories: 78,
                    protein: 6,
                    carbs: 1,
                    fat: 5
                )
            )
        }

        if food.contains("pasta") {

            results.append(
                NutritionItem(
                    name: "Pasta (1 cup)",
                    calories: 200,
                    protein: 7,
                    carbs: 42,
                    fat: 1
                )
            )
        }

        if food.contains("spinach") {

            results.append(
                NutritionItem(
                    name: "Spinach",
                    calories: 23,
                    protein: 3,
                    carbs: 4,
                    fat: 0
                )
            )
        }

        if results.isEmpty {

            results.append(
                NutritionItem(
                    name: searchText.capitalized,
                    calories: 120,
                    protein: 5,
                    carbs: 12,
                    fat: 3
                )
            )
        }
    }
}

//////////////////////////////////////////////////////////
// MARK: Nutrition Model
//////////////////////////////////////////////////////////

struct NutritionItem: Identifiable {

    let id = UUID()

    let name: String
    let calories: Int
    let protein: Int
    let carbs: Int
    let fat: Int
}

//////////////////////////////////////////////////////////
// MARK: Nutrition Card
//////////////////////////////////////////////////////////

struct NutritionCard: View {

    let item: NutritionItem

    var body: some View {

        VStack(alignment: .leading, spacing: 10) {

            Text(item.name)
                .font(.headline)

            Divider()

            HStack {

                NutritionStat(label: "Calories", value: "\(item.calories)")
                NutritionStat(label: "Protein", value: "\(item.protein)g")
                NutritionStat(label: "Carbs", value: "\(item.carbs)g")
                NutritionStat(label: "Fat", value: "\(item.fat)g")

            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(radius: 5)
        )
    }
}

//////////////////////////////////////////////////////////
// MARK: Nutrition Stat
//////////////////////////////////////////////////////////

struct NutritionStat: View {

    var label: String
    var value: String

    var body: some View {

        VStack {

            Text(value)
                .font(.headline)

            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

//////////////////////////////////////////////////////////
// Preview
//////////////////////////////////////////////////////////

#Preview {
    NutritionFactsView()
}
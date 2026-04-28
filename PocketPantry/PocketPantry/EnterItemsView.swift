//
//  EnterItemsView.swift
//  PocketPantry
//
//  Created by Sierra Christine on 3/8/26.
//


import SwiftUI

//////////////////////////////////////////////////////////
// MARK: Enter Items View
//////////////////////////////////////////////////////////

struct EnterItemsView: View {

    @ObservedObject var pantry: PantryStore

    @State private var newItem: String = ""

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

                //////////////////////////////////////////////////////////
                // Header
                //////////////////////////////////////////////////////////

                Text("Enter Pantry Items")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.green)

                //////////////////////////////////////////////////////////
                // Add Item Field
                //////////////////////////////////////////////////////////

                HStack {

                    TextField("Add ingredient...", text: $newItem)
                        .textFieldStyle(.roundedBorder)

                    Button {

                        addItem()

                    } label: {

                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.green)
                    }
                }
                .padding(.horizontal)

                //////////////////////////////////////////////////////////
                // Pantry Items List
                //////////////////////////////////////////////////////////

                List {

                    ForEach(pantry.items) { item in

                        HStack {

                            Image(systemName: "leaf.fill")
                                .foregroundColor(.green)

                            Text(item.name)

                            Spacer()
                        }
                    }
                    .onDelete(perform: deleteItem)
                }
                .listStyle(.inset)

                //////////////////////////////////////////////////////////
                // Clear Pantry Button
                //////////////////////////////////////////////////////////

                Button {

                    pantry.clearPantry()

                } label: {

                    Text("Clear Pantry")
                        .fontWeight(.semibold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.85))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top, 40)
        }
    }

    //////////////////////////////////////////////////////////
    // Add Item Logic
    //////////////////////////////////////////////////////////

    func addItem() {

        pantry.addItem(newItem)

        newItem = ""
    }

    //////////////////////////////////////////////////////////
    // Delete Item Logic
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
    EnterItemsView(pantry: PantryStore())
}
//
//  SettingsView.swift
//  PocketPantry
//
//  Created by Sierra Christine on 3/8/26.
//


import SwiftUI

//////////////////////////////////////////////////////////
// MARK: Settings View
//////////////////////////////////////////////////////////

struct SettingsView: View {

    @ObservedObject var pantry: PantryStore

    @AppStorage("chatGPTKey") private var chatGPTKey: String = ""
    @AppStorage("aiRecipesEnabled") private var aiRecipesEnabled: Bool = false

    @State private var tempKey: String = ""

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

            ScrollView {

                VStack(spacing: 30) {

                    //////////////////////////////////////////////////////////
                    // Title
                    //////////////////////////////////////////////////////////

                    Text("Settings")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.green)

                    //////////////////////////////////////////////////////////
                    // AI Recipe Toggle
                    //////////////////////////////////////////////////////////

                    VStack(alignment: .leading, spacing: 10) {

                        Toggle("Enable AI Recipe Suggestions", isOn: $aiRecipesEnabled)

                        Text("When enabled, Pocket Pantry will use your ChatGPT API key to generate personalized recipes based on your pantry.")
                            .font(.caption)
                            .foregroundColor(.gray)

                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.white)
                            .shadow(radius: 4)
                    )
                    .padding(.horizontal)

                    //////////////////////////////////////////////////////////
                    // ChatGPT API Key
                    //////////////////////////////////////////////////////////

                    VStack(alignment: .leading, spacing: 12) {

                        Text("ChatGPT API Key")
                            .font(.headline)

                        TextField("Enter API key...", text: $tempKey)
                            .textFieldStyle(.roundedBorder)

                        Button {

                            saveKey()

                        } label: {

                            Text("Save API Key")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }

                        if !chatGPTKey.isEmpty {

                            Text("API key saved ✓")
                                .font(.caption)
                                .foregroundColor(.green)
                        }

                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.white)
                            .shadow(radius: 4)
                    )
                    .padding(.horizontal)

                    //////////////////////////////////////////////////////////
                    // Pantry Management
                    //////////////////////////////////////////////////////////

                    VStack(spacing: 12) {

                        Button {

                            pantry.clearPantry()

                        } label: {

                            Text("Clear Entire Pantry")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.9))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }

                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.white)
                            .shadow(radius: 4)
                    )
                    .padding(.horizontal)

                    //////////////////////////////////////////////////////////
                    // App Info
                    //////////////////////////////////////////////////////////

                    VStack(spacing: 6) {

                        Text("Pocket Pantry")
                            .font(.headline)

                        Text("Version 1.0")
                            .font(.caption)
                            .foregroundColor(.gray)

                        Text("Scan your pantry, discover recipes, and reduce food waste.")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)

                    }
                    .padding(.top, 20)

                    Spacer()
                }
                .padding(.top, 40)
            }
        }
        .onAppear {
            tempKey = chatGPTKey
        }
    }

    //////////////////////////////////////////////////////////
    // Save API Key
    //////////////////////////////////////////////////////////

    func saveKey() {
        chatGPTKey = tempKey
    }
}

//////////////////////////////////////////////////////////
// Preview
//////////////////////////////////////////////////////////

#Preview {
    SettingsView(pantry: PantryStore())
}
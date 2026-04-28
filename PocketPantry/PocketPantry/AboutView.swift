//
//  AboutView.swift
//  PocketPantry
//
//  Created by Sierra Christine on 3/8/26.
//


import SwiftUI

private func gradientColors() -> [Color] {
    #if canImport(UIKit)
    return [
        Color.white,
        Color(UIColor.systemGray6),
        Color(UIColor.systemGray5)
    ]
    #elseif canImport(AppKit)
    return [
        Color.white,
        Color(nsColor: NSColor.windowBackgroundColor),
        Color(nsColor: NSColor.controlBackgroundColor)
    ]
    #else
    return [
        Color.white,
        Color.gray.opacity(0.1),
        Color.gray.opacity(0.2)
    ]
    #endif
}

struct AboutView: View {
    
    var body: some View {
        
        ZStack {
            
            // Light Gradient Background
            LinearGradient(
                colors: gradientColors(),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            
            ScrollView {
                
                VStack(spacing: 30) {
                    
                    // Title
                    VStack(spacing: 8) {
                        Text("About Pocket Pantry")
                            .font(.largeTitle.bold())
                        
                        Text("Your smart kitchen companion")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 30)
                    
                    
                    // Feature Cards
                    
                    FeatureCard(
                        icon: "barcode.viewfinder",
                        title: "Scan Items",
                        description: "Quickly scan food using your camera. Pocket Pantry automatically identifies the product and adds it to your pantry."
                    )
                    
                    FeatureCard(
                        icon: "square.and.pencil",
                        title: "Enter Items",
                        description: "Manually add groceries, ingredients, or pantry staples so you always know what you have available."
                    )
                    
                    FeatureCard(
                        icon: "archivebox",
                        title: "Pantry",
                        description: "View everything currently stored in your pantry. Track quantities and stay organized."
                    )
                    
                    FeatureCard(
                        icon: "leaf",
                        title: "Nutrition Facts",
                        description: "See nutritional information for the foods in your pantry to make healthier choices."
                    )
                    
                    FeatureCard(
                        icon: "gearshape",
                        title: "Settings",
                        description: "Customize your Pocket Pantry experience including preferences and pantry tracking options."
                    )
                    
                    
                    Spacer()
                    
                    Text("Pocket Pantry helps you reduce waste, stay organized, and always know what's in your kitchen.")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                    
                }
                .padding(.horizontal, 30)
            }
        }
    }
}

struct FeatureCard: View {
    
    var icon: String
    var title: String
    var description: String
    
    var body: some View {
        
        HStack(spacing: 20) {
            
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundStyle(.green)
                .frame(width: 50)
            
            
            VStack(alignment: .leading, spacing: 6) {
                
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
        )
    }
}


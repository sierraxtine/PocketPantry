//
//  PantryTile.swift
//  PocketPantry
//
//  Created by Sierra Christine on 3/8/26.
//


import SwiftUI

//////////////////////////////////////////////////////////
// MARK: Pantry Tile Component
//////////////////////////////////////////////////////////

struct PantryTile<Destination: View>: View {

    var title: String
    var icon: String
    var destination: Destination

    @State private var hovering = false
    @State private var pressed = false

    var body: some View {

        NavigationLink {
            destination
        } label: {

            VStack(spacing: 14) {

                //////////////////////////////////////////////////
                // Icon
                //////////////////////////////////////////////////

                ZStack {

                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.green.opacity(0.25),
                                    Color.mint.opacity(0.15)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)

                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.green, .mint],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }

                //////////////////////////////////////////////////
                // Title
                //////////////////////////////////////////////////

                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.black)

            }
            .frame(height: 130)
            .frame(maxWidth: .infinity)

            //////////////////////////////////////////////////
            // Tile Style
            //////////////////////////////////////////////////

            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
            )

            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        hovering ?
                        LinearGradient(
                            colors: [.green.opacity(0.6), .mint.opacity(0.6)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        :
                        LinearGradient(
                            colors: [.clear, .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 2
                    )
            )

            .shadow(
                color: hovering ?
                Color.green.opacity(0.25) :
                Color.black.opacity(0.08),
                radius: hovering ? 16 : 6
            )

            .scaleEffect(pressed ? 0.96 : 1)

            //////////////////////////////////////////////////
            // Animations
            //////////////////////////////////////////////////

            .animation(.easeInOut(duration: 0.18), value: hovering)
            .animation(.spring(response: 0.25), value: pressed)

            //////////////////////////////////////////////////
            // Hover + Click Effects
            //////////////////////////////////////////////////

            .onHover { hover in
                hovering = hover
            }

            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in pressed = true }
                    .onEnded { _ in pressed = false }
            )
        }
        .buttonStyle(.plain)
    }
}

//////////////////////////////////////////////////////////
// MARK: Placeholder Screen
//////////////////////////////////////////////////////////

struct PlaceholderView: View {

    var title: String

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

            VStack(spacing: 20) {

                Image(systemName: "fork.knife")
                    .font(.system(size: 60))
                    .foregroundColor(.green)

                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("This section will be built next.")
                    .foregroundColor(.gray)
            }
        }
    }
}

//////////////////////////////////////////////////////////
// MARK: Preview
//////////////////////////////////////////////////////////

#Preview {
    NavigationStack {
        PantryTile(
            title: "Scan",
            icon: "camera.viewfinder",
            destination: PlaceholderView(title: "Scan")
        )
        .padding()
    }
}
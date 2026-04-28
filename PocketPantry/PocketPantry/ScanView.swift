import SwiftUI
import PhotosUI

struct ScanView: View {

    @ObservedObject var pantry: PantryStore

    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: Image?
    @State private var platformImage: PlatformImage?

    @State private var detectedItems: [String] = []
    @State private var detectedBarcodes: [String] = []
    @State private var scanning = false
    @State private var scanMode: ScanMode = .smart
    @State private var showConfidenceInfo = false

    var body: some View {

        ZStack {

            LinearGradient(
                colors: [Color.white, Color.green.opacity(0.05)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {

                VStack(spacing: 30) {

                    //////////////////////////////////////////////////////////
                    // Header
                    //////////////////////////////////////////////////////////
                    
                    Text("AI Food Scanner")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.green, .mint],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("Use AI to identify food items from photos")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    //////////////////////////////////////////////////////////
                    // Scan Mode Picker
                    //////////////////////////////////////////////////////////
                    
                    Picker("Scan Mode", selection: $scanMode) {
                        ForEach(ScanMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    //////////////////////////////////////////////////////////
                    // Image Preview
                    //////////////////////////////////////////////////////////

                    if let image = selectedImage {

                        VStack(spacing: 12) {
                            
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 300)
                                .cornerRadius(20)
                                .shadow(color: .black.opacity(0.2), radius: 10)
                            
                            HStack(spacing: 16) {
                                
                                Button {
                                    selectedImage = nil
                                    platformImage = nil
                                    detectedItems = []
                                    detectedBarcodes = []
                                } label: {
                                    Label("Clear", systemImage: "xmark.circle.fill")
                                        .font(.subheadline)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.red.opacity(0.2))
                                        .foregroundColor(.red)
                                        .cornerRadius(10)
                                }
                                
                                Button {
                                    scanImage()
                                } label: {
                                    Label("Scan", systemImage: "sparkles")
                                        .font(.subheadline)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.green.opacity(0.2))
                                        .foregroundColor(.green)
                                        .cornerRadius(10)
                                }
                            }
                        }

                    } else {

                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: 260)
                            .overlay(
                                VStack(spacing: 16) {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(.gray.opacity(0.5))

                                    Text("No Image Selected")
                                        .font(.headline)
                                        .foregroundColor(.gray)
                                    
                                    Text("Take or select a photo to scan")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            )
                    }

                    //////////////////////////////////////////////////////////
                    // Photo Picker Button
                    //////////////////////////////////////////////////////////

                    PhotosPicker(
                        selection: $selectedItem,
                        matching: .images
                    ) {

                        HStack {
                            Image(systemName: "photo.on.rectangle")
                            Text("Select Photo from Library")
                        }
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                colors: [.green, .mint],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(14)
                    }
                    .padding(.horizontal)

                    //////////////////////////////////////////////////////////
                    // Scanning Indicator
                    //////////////////////////////////////////////////////////

                    if scanning {
                        VStack(spacing: 12) {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Analyzing with AI...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }

                    //////////////////////////////////////////////////////////
                    // Detected Barcodes
                    //////////////////////////////////////////////////////////
                    
                    if !detectedBarcodes.isEmpty {
                        
                        VStack(alignment: .leading, spacing: 12) {
                            
                            HStack {
                                Image(systemName: "barcode")
                                    .foregroundColor(.blue)
                                Text("Detected Barcodes")
                                    .font(.title3.bold())
                            }
                            
                            ForEach(detectedBarcodes, id: \.self) { barcode in
                                
                                HStack {
                                    Text(barcode)
                                        .font(.system(.body, design: .monospaced))
                                    Spacer()
                                }
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                        )
                        .padding(.horizontal)
                    }

                    //////////////////////////////////////////////////////////
                    // Detected Ingredients
                    //////////////////////////////////////////////////////////

                    if !detectedItems.isEmpty {

                        VStack(alignment: .leading, spacing: 16) {

                            HStack {
                                Image(systemName: "sparkles")
                                    .foregroundColor(.yellow)
                                Text("Detected Ingredients (\(detectedItems.count))")
                                    .font(.title2.bold())
                                
                                Spacer()
                                
                                Button {
                                    addAllItems()
                                } label: {
                                    Text("Add All")
                                        .font(.subheadline.bold())
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                            }

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                
                                ForEach(detectedItems, id: \.self) { item in

                                    Button {
                                        pantry.addItem(item)
                                    } label: {
                                        HStack {
                                            Image(systemName: "leaf.fill")
                                                .foregroundColor(.green)
                                                .font(.caption)

                                            Text(item.capitalized)
                                                .font(.subheadline)
                                                .lineLimit(1)

                                            Spacer(minLength: 4)
                                            
                                            Image(systemName: "plus.circle.fill")
                                                .foregroundColor(.green)
                                                .font(.caption)
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color.green.opacity(0.1))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.green.opacity(0.3), lineWidth: 1)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                        )
                        .padding(.horizontal)
                    }
                    
                    //////////////////////////////////////////////////////////
                    // Tips Section
                    //////////////////////////////////////////////////////////
                    
                    if detectedItems.isEmpty && !scanning {
                        VStack(alignment: .leading, spacing: 12) {
                            
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.yellow)
                                Text("Scanning Tips")
                                    .font(.headline)
                            }
                            
                            TipRow(icon: "camera.fill", text: "Take clear, well-lit photos")
                            TipRow(icon: "square.and.arrow.up", text: "Focus on food items")
                            TipRow(icon: "barcode.viewfinder", text: "Include product labels for better accuracy")
                            TipRow(icon: "sparkles", text: "AI works best with unpackaged fresh foods")
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.yellow.opacity(0.1))
                        )
                        .padding(.horizontal)
                    }

                    Spacer(minLength: 40)
                }
                .padding(.top, 40)
            }
        }

        //////////////////////////////////////////////////////////
        // Image Loader
        //////////////////////////////////////////////////////////

        .onChange(of: selectedItem) { _, newValue in

            guard let item = newValue else { return }

            Task {

                if let data = try? await item.loadTransferable(type: Data.self) {

                    if let img = PlatformImage(data: data) {

                        platformImage = img
                        selectedImage = Image(platformImage: img)
                        
                        // Auto-scan if enabled
                        await MainActor.run {
                            scanImage()
                        }
                    }
                }
            }
        }
    }

    //////////////////////////////////////////////////////////
    // Enhanced Scanning Logic
    //////////////////////////////////////////////////////////

    func scanImage() {

        guard let img = platformImage else { return }

        scanning = true
        detectedItems = []
        detectedBarcodes = []

        Task {
            
            switch scanMode {
            case .smart:
                let result = await FoodVisionScanner.smartDetection(from: img)
                await MainActor.run {
                    detectedItems = result.foodItems
                    detectedBarcodes = result.barcodes
                    scanning = false
                }
                
            case .vision:
                let foods = await FoodVisionScanner.detectFood(from: img)
                await MainActor.run {
                    detectedItems = foods
                    scanning = false
                }
                
            case .text:
                let texts = await FoodVisionScanner.detectText(from: img)
                await MainActor.run {
                    detectedItems = texts
                    scanning = false
                }
                
            case .barcode:
                let barcodes = await FoodVisionScanner.detectBarcodes(from: img)
                await MainActor.run {
                    detectedBarcodes = barcodes
                    scanning = false
                }
            }
        }
    }
    
    //////////////////////////////////////////////////////////
    // Add All Items
    //////////////////////////////////////////////////////////
    
    func addAllItems() {
        for item in detectedItems {
            pantry.addItem(item)
        }
    }
}

//////////////////////////////////////////////////////////
// MARK: Scan Mode
//////////////////////////////////////////////////////////

enum ScanMode: String, CaseIterable {
    case smart = "Smart"
    case vision = "Vision"
    case text = "Text"
    case barcode = "Barcode"
}

//////////////////////////////////////////////////////////
// MARK: Tip Row
//////////////////////////////////////////////////////////

struct TipRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.orange)
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

#Preview {
    ScanView(pantry: PantryStore())
}

import SwiftUI
@preconcurrency import Vision

#if os(iOS) || os(tvOS) || os(visionOS)
import UIKit
#elseif os(macOS)
import AppKit
#else
#error("Unsupported platform: expected iOS, tvOS, visionOS, or macOS")
#endif

#if !canImport(UniformTypeIdentifiers)
#if os(iOS) || os(tvOS) || os(visionOS)
internal typealias PlatformImage = UIImage
#elseif os(macOS)
internal typealias PlatformImage = NSImage
#endif
#endif

//////////////////////////////////////////////////////////
// MARK: Enhanced Food Vision Scanner
//////////////////////////////////////////////////////////

@MainActor
class FoodVisionScanner {
    
    //////////////////////////////////////////////////////////
    // Detect Food with Enhanced Classification
    //////////////////////////////////////////////////////////

    static func detectFood(from image: PlatformImage) async -> [String] {
        guard let cgImage = image.cgImageValue else { return [] }

        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                
                // Use multiple vision requests for better accuracy
                let classificationRequest = VNClassifyImageRequest()
                let recognizeTextRequest = VNRecognizeTextRequest()
                
                let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

                do {
                    try handler.perform([classificationRequest])

                    guard let results = classificationRequest.results else {
                        continuation.resume(returning: [])
                        return
                    }

                    // Enhanced food detection with better filtering
                    let foods = results
                        .filter { observation in
                            // Higher confidence threshold for better accuracy
                            observation.confidence > 0.3 &&
                            // Filter out non-food items
                            !isNonFoodItem(observation.identifier)
                        }
                        .map { observation -> (String, Float) in
                            let cleaned = cleanFoodName(observation.identifier)
                            return (cleaned, observation.confidence)
                        }
                        // Remove duplicates and keep highest confidence
                        .reduce(into: [String: Float]()) { dict, item in
                            let key = item.0.lowercased()
                            if let existing = dict[key] {
                                dict[key] = max(existing, item.1)
                            } else {
                                dict[key] = item.1
                            }
                        }
                        .sorted { $0.value > $1.value }
                        .prefix(15)
                        .map { $0.key.capitalized }

                    continuation.resume(returning: Array(foods))

                } catch {
                    continuation.resume(returning: [])
                }
            }
        }
    }
    
    //////////////////////////////////////////////////////////
    // Detect Text in Image (for labels, receipts)
    //////////////////////////////////////////////////////////
    
    static func detectText(from image: PlatformImage) async -> [String] {
        guard let cgImage = image.cgImageValue else { return [] }
        
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                
                let request = VNRecognizeTextRequest()
                request.recognitionLevel = .accurate
                request.usesLanguageCorrection = true
                
                let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                
                do {
                    try handler.perform([request])
                    
                    guard let observations = request.results else {
                        continuation.resume(returning: [])
                        return
                    }
                    
                    let recognizedStrings = observations
                        .compactMap { $0.topCandidates(1).first?.string }
                        .filter { !$0.isEmpty }
                    
                    // Try to extract food items from text
                    let foodItems = extractFoodItems(from: recognizedStrings)
                    
                    continuation.resume(returning: foodItems)
                    
                } catch {
                    continuation.resume(returning: [])
                }
            }
        }
    }
    
    //////////////////////////////////////////////////////////
    // Detect Barcodes
    //////////////////////////////////////////////////////////
    
    static func detectBarcodes(from image: PlatformImage) async -> [String] {
        guard let cgImage = image.cgImageValue else { return [] }
        
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                
                let request = VNDetectBarcodesRequest()
                let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                
                do {
                    try handler.perform([request])
                    
                    guard let observations = request.results else {
                        continuation.resume(returning: [])
                        return
                    }
                    
                    let barcodes = observations.compactMap { $0.payloadStringValue }
                    
                    continuation.resume(returning: barcodes)
                    
                } catch {
                    continuation.resume(returning: [])
                }
            }
        }
    }
    
    //////////////////////////////////////////////////////////
    // Smart Combined Detection
    //////////////////////////////////////////////////////////
    
    static func smartDetection(from image: PlatformImage) async -> DetectionResult {
        async let foods = detectFood(from: image)
        async let texts = detectText(from: image)
        async let barcodes = detectBarcodes(from: image)
        
        let (foodItems, textItems, barcodeItems) = await (foods, texts, barcodes)
        
        // Combine and deduplicate results
        var allItems = Set<String>()
        allItems.formUnion(foodItems.map { $0.lowercased() })
        allItems.formUnion(textItems.map { $0.lowercased() })
        
        return DetectionResult(
            foodItems: Array(allItems).map { $0.capitalized }.sorted(),
            barcodes: barcodeItems,
            confidence: foodItems.isEmpty ? .low : .high
        )
    }
    
    //////////////////////////////////////////////////////////
    // Helper: Clean Food Name
    //////////////////////////////////////////////////////////
    
    private static func cleanFoodName(_ identifier: String) -> String {
        // Remove technical terms and clean up the name
        let components = identifier.split(separator: ",")
        let mainName = components.first?.trimmingCharacters(in: .whitespaces) ?? identifier
        
        // Remove common prefixes
        let cleaned = mainName
            .replacingOccurrences(of: "food, ", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: "ingredient, ", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: "produce, ", with: "", options: .caseInsensitive)
        
        return cleaned
    }
    
    //////////////////////////////////////////////////////////
    // Helper: Filter Non-Food Items
    //////////////////////////////////////////////////////////
    
    private static func isNonFoodItem(_ identifier: String) -> Bool {
        let nonFoodKeywords = [
            "person", "face", "hand", "finger", "body",
            "table", "plate", "bowl", "fork", "knife", "spoon",
            "background", "wall", "floor", "ceiling",
            "container", "package", "wrapper",
            "text", "label", "logo", "sign"
        ]
        
        let lower = identifier.lowercased()
        return nonFoodKeywords.contains(where: { lower.contains($0) })
    }
    
    //////////////////////////////////////////////////////////
    // Helper: Extract Food Items from Text
    //////////////////////////////////////////////////////////
    
    private static func extractFoodItems(from texts: [String]) -> [String] {
        let commonFoods = [
            "milk", "eggs", "bread", "butter", "cheese", "yogurt",
            "chicken", "beef", "pork", "fish", "turkey",
            "apple", "banana", "orange", "grape", "tomato", "potato",
            "rice", "pasta", "noodle", "cereal",
            "onion", "garlic", "carrot", "broccoli", "spinach",
            "salt", "pepper", "sugar", "flour", "oil"
        ]
        
        var foundItems = Set<String>()
        
        for text in texts {
            let lowercased = text.lowercased()
            for food in commonFoods {
                if lowercased.contains(food) {
                    foundItems.insert(food.capitalized)
                }
            }
        }
        
        return Array(foundItems).sorted()
    }
}

//////////////////////////////////////////////////////////
// MARK: Detection Result
//////////////////////////////////////////////////////////

struct DetectionResult {
    let foodItems: [String]
    let barcodes: [String]
    let confidence: ConfidenceLevel
    
    enum ConfidenceLevel {
        case low, medium, high
    }
}

//////////////////////////////////////////////////////////
// MARK: Platform Image Extension
//////////////////////////////////////////////////////////

extension PlatformImage {

    var cgImageValue: CGImage? {

        #if os(iOS) || os(tvOS) || os(visionOS)
        return self.cgImage
        #elseif os(macOS)
        return self.cgImage(forProposedRect: nil, context: nil, hints: nil)
        #else
        return nil
        #endif
    }
}



//
//  Recipe.swift
//  EatsCalendar
//
//  Created by Nicholas Fang on 4/12/24.
//

import Foundation

// Structure for the entire API response
struct RecipeFeed: Decodable {
    let results: [Recipe]
}

// Structure for individual recipes
struct Recipe: Codable {
    let id: Int
    let title: String
    let sourceName: String
    let preparationMinutes: Int
    let cookingMinutes: Int
    let readyInMinutes: Int
    let servings: Int
    let sourceUrl: String
    let image: String
    let analyzedInstructions: [AnalyzedInstruction]
}

// Structure for analyzed instructions
struct AnalyzedInstruction: Codable {
    let name: String
    let steps: [InstructionStep]
}

// Structure for individual steps within an instruction
struct InstructionStep: Codable {
    let number: Int
    let step: String
    let ingredients: [Ingredient]
    let equipment: [Equipment]
    let length: InstructionLength?
}

// Structure for ingredients used in a step
struct Ingredient: Codable {
    let id: Int
    let name: String
    let localizedName: String
    let image: String
}

// Structure for equipment used in a step
struct Equipment: Codable {
    let id: Int
    let name: String
    let localizedName: String
    let image: String
}

// Optional structure for the length of a step
struct InstructionLength: Codable {
    let number: Int
    let unit: String
}


struct APIKey {
    static let key = "74ee6bfba6374514aa63b061d404b73f"
}

extension Int {
    func toHoursAndMinutes() -> String {
        if self < 60 {
            return "\(self) min"
        } else {
            let hours = self / 60
            let minutes = self % 60
            let hourUnit = hours == 1 ? "hr" : "hrs"
            if minutes == 0 {
                return "\(hours) \(hourUnit)"
            } else {
                return "\(hours) \(hourUnit) \(minutes) min"
            }
        }
    }
}

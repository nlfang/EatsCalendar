//
//  Meal.swift
//  EatsCalendar
//
//  Created by Nicholas Fang on 4/16/24.
//

import Foundation

struct Meal: Codable {
    var date: Date
    var recipe: Recipe
    var id: String = UUID().uuidString
}

extension Meal {
    static func save(_ meals: [Meal]) {
        let defaults = UserDefaults.standard
        let encodedData = try! JSONEncoder().encode(meals)
        defaults.set(encodedData, forKey: "meals")
    }
    
    static func getMeals() -> [Meal] {
        let defaults = UserDefaults.standard
        guard let current = defaults.data(forKey: "meals") else {
            return []
        }
        do {
            let decodedData = try JSONDecoder().decode([Meal].self, from: current)
            return decodedData
        } catch {
            print("Failed to decode meals: \(error)")
            return []
        }
    }
    
    func save() {
        var currentData = Meal.getMeals()
        if let i = currentData.firstIndex(where: { $0.id == self.id }) {
            currentData.remove(at: i)
            currentData.insert(self, at: i)
        } else {
            currentData.append(self)
        }
        
        Meal.save(currentData)
    }
}

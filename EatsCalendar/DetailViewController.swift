//
//  DetailViewController.swift
//  EatsCalendar
//
//  Created by Nicholas Fang on 4/15/24.
//

import UIKit
import Nuke

class DetailViewController: UIViewController {

    @IBOutlet weak var foodImageView: UIImageView!
    @IBOutlet weak var recipeLabel: UILabel!
    @IBOutlet weak var prepTimeLabel: UILabel!
    @IBOutlet weak var stepsTextView: UITextView!
    @IBOutlet weak var mealDatePicker: UIDatePicker!
    
    var recipe: Recipe!
    var meal: Meal!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        recipeLabel.text = recipe.title
        prepTimeLabel.text = "⏰ " + recipe.readyInMinutes.toHoursAndMinutes()
        stepsTextView.text = formatInstructions(from: recipe.analyzedInstructions[0].steps)
        
        if let imgUrl = URL(string: recipe.image) {
            Nuke.loadImage(with: imgUrl, into: foodImageView)
        }
        
        mealDatePicker.addTarget(self, action: #selector(datePickerChanged(_:)), for: .valueChanged)
    }
    
    @objc func datePickerChanged(_ sender: UIDatePicker) {
        guard let recipe = recipe else {
            print("Error: recipe is not set.")
            return
        }
        if meal == nil {
            meal = Meal(date: Date(), recipe: recipe)
        }
        let selectedDate = sender.date
        meal.recipe = recipe
        meal.date = selectedDate
        meal.save()
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let str = "Meal saved to date " + df.string(from: meal.date)
        print(str)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    private func formatInstructions(from steps: [InstructionStep]) -> String {
        var formattedText = ""
        
        for step in steps {
            // Step description
            formattedText += "\(step.number). \(step.step)\n"
            
            // Collecting ingredients
            let ingredients = step.ingredients.map { $0.localizedName }.joined(separator: ", ")
            if !ingredients.isEmpty {
                formattedText += "Ingredient(s) used: \(ingredients)\n\n"
            } else {
                formattedText += "\n\n"
            }
        }
        formattedText += "Read more here: " + recipe.sourceUrl
        
        return formattedText
    }
}

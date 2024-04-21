//
//  CalendarViewController.swift
//  EatsCalendar
//
//  Created by Nicholas Fang on 4/16/24.
//

import UIKit

class CalendarViewController: UIViewController {
    
    var meals: [Meal] = []
    
    private var selectedMeals: [Meal] = []
    private var calendarView: UICalendarView!
    
    @IBOutlet weak var calendarContainerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.tableHeaderView = UIView()
        setContentScrollView(tableView)
        self.calendarView = UICalendarView()
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarContainerView.addSubview(calendarView)
        
        NSLayoutConstraint.activate([
            calendarView.leadingAnchor.constraint(equalTo: calendarContainerView.leadingAnchor),
            calendarView.topAnchor.constraint(equalTo: calendarContainerView.topAnchor),
            calendarView.trailingAnchor.constraint(equalTo: calendarContainerView.trailingAnchor),
            calendarView.bottomAnchor.constraint(equalTo: calendarContainerView.bottomAnchor)
        ])
        
        let dateSelection = UICalendarSelectionSingleDate(delegate: self)
        calendarView.selectionBehavior = dateSelection
        
        meals = Meal.getMeals()
        let todayComponents = Calendar.current.dateComponents([.year, .month, .weekOfMonth, .day], from: Date())
        let todayMeals = filterMeals(for: todayComponents)
        if !todayMeals.isEmpty {
            let selection = calendarView.selectionBehavior as? UICalendarSelectionSingleDate
            selection?.setSelected(todayComponents, animated: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshMeals()
    }
    
    private func filterMeals(for dateComponents: DateComponents) -> [Meal] {
        let calendar = Calendar.current
        guard let date = calendar.date(from: dateComponents) else {
            return []
        }
        let mealsMatchingDate = meals.filter { meal in
            return calendar.isDate(meal.date, equalTo: date, toGranularity: .day)
        }
        return mealsMatchingDate
    }
    
    private func refreshMeals() {
        meals = Meal.getMeals()
        if let selection = calendarView.selectionBehavior as? UICalendarSelectionSingleDate,
           let selectedComponents = selection.selectedDate {
            selectedMeals = filterMeals(for: selectedComponents)
        }
        
        let mealDates = meals.map(\.date)
        
        var mealDateComponents = mealDates.map { date in
            Calendar.current.dateComponents([.year, .month, .weekOfMonth, .day], from: date)
        }

        mealDateComponents.removeDuplicates()
        
        calendarView.reloadDecorations(forDateComponents: mealDateComponents, animated: false)
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
}


extension CalendarViewController: UICalendarSelectionSingleDateDelegate {
    
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        guard let components = dateComponents else { return }
        selectedMeals = filterMeals(for: components)
        
        if selectedMeals.isEmpty {
            selection.setSelected(nil, animated: true)
        }
        
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
}


extension CalendarViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedMeals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell", for: indexPath) as! RecipeCell
        let meal = selectedMeals[indexPath.row]
        
        cell.recipeLabel.text = meal.recipe.title
        cell.prepTimeLabel.text = "⏰ " + meal.recipe.readyInMinutes.toHoursAndMinutes()
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if indexPath.row < selectedMeals.count {
                let mealToDelete = selectedMeals[indexPath.row]
                selectedMeals.remove(at: indexPath.row)

                if let index = meals.firstIndex(where: { $0.id == mealToDelete.id }) {
                    meals.remove(at: index)
                }
                
                Meal.save(meals)

                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let selectedIndexPath = tableView.indexPathForSelectedRow else { return }
        
        let selectedMeal = meals[selectedIndexPath.row]
        
        guard let detailViewController = segue.destination as? DetailViewController else { return }
        detailViewController.recipe = selectedMeal.recipe
    }
}

extension Array where Element: Equatable, Element: Hashable {
    mutating func removeDuplicates() {
        // 1.
        let set = Set(self)
        // 2.
        self = Array(set)
    }
}

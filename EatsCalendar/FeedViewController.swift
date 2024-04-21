//
//  FeedViewController.swift
//  ios101-lab6-flix
//

import UIKit
import Nuke

// Add table view data source conformance
class FeedViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    private var recipes: [Recipe] = []
    
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.dataSource = self
        fetchRecipes()
        
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // get the index path for the selected row
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            
            // Deselect the currently selected row
            tableView.deselectRow(at: selectedIndexPath, animated: animated)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let selectedIndexPath = tableView.indexPathForSelectedRow else { return }
        
        let selectedRecipe = recipes[selectedIndexPath.row]
        
        guard let detailViewController = segue.destination as? DetailViewController else { return }
        detailViewController.recipe = selectedRecipe
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell", for: indexPath) as! RecipeCell
        
        let recipe = recipes[indexPath.row]
        
        if let imgUrl = URL(string: recipe.image) {
            Nuke.loadImage(with: imgUrl, into: cell.foodImageView)
        }
        
        cell.recipeLabel.text = recipe.title
        cell.sourceLabel.text = recipe.sourceName
        cell.prepTimeLabel.text = "⏰ " + recipe.readyInMinutes.toHoursAndMinutes()
        return cell
    }
    
    
    private func fetchRecipes(query: String? = nil) {
        var str = "https://api.spoonacular.com/recipes/complexSearch?apiKey=" + APIKey.key + "&instructionsRequired=true&addRecipeInformation=true&sort=random&number=10"
        
        if let query = query {
            str += "&query=" + query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        }
        let url = URL(string: str)!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
        let session = URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                print("🚨 Request failed: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("🚨 Server Error: response: \(String(describing: response))")
                return
            }
            print(httpResponse)

            guard let data = data else {
                print("🚨 No data returned from request")
                return
            }
            print(data)

            do {
                // MARK: - jSONDecoder with custom date formatter
                let decoder = JSONDecoder()
                let recipeResponse = try decoder.decode(RecipeFeed.self, from: data)
                let recipes = recipeResponse.results

                DispatchQueue.main.async { [weak self] in
                    print("✅ SUCCESS!!! Fetched \(recipes.count) recipes")
                    for (index, recipe) in recipes.enumerated() {
                        print("RECIPE \(index) ------------------")
                        print("Title: \(recipe.title)")
                    }

                    // MARK: - Update the recipes property so we can access movie data anywhere in the view controller.
                    self?.recipes = recipes

                    self?.tableView.reloadData()
                }
            } catch {
                print("🚨 Error decoding JSON data into Recipe Response: \(error.localizedDescription)")
                return
            }
        }
        session.resume()
    }
    
    @objc func refresh(_ sender: AnyObject) {
        fetchRecipes()
        refreshControl.endRefreshing()
    }
}

extension FeedViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let searchText = searchBar.text, !searchText.isEmpty {
            fetchRecipes(query: searchText)
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        print("Search bar cancelled")
    }
}


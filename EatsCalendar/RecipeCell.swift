//
//  RecipeCell.swift
//  EatsCalendar
//
//  Created by Nicholas Fang on 4/12/24.
//

import UIKit

class RecipeCell: UITableViewCell {
    
    @IBOutlet weak var foodImageView: UIImageView!
    @IBOutlet weak var recipeLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var prepTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let imageView = foodImageView {
            imageView.layer.cornerRadius = 18
            imageView.layer.borderWidth = 2
            imageView.layer.borderColor = UIColor.white.cgColor
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

//
//  FilterSphereTVCell.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 10/12/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit

class FilterSphereTVCell: UITableViewCell {

    @IBOutlet weak var circleBackgroundView: UIView!
    @IBOutlet weak var selectedIcon: UIImageView!
    @IBOutlet weak var sphereNameLabel: UILabel!
    
    private var sphere: Sphere?{
        didSet{
            if let sphere = sphere{
                sphereNameLabel.text = sphere.name
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        circleBackgroundView.layer.cornerRadius = circleBackgroundView.frame.width / 2
        circleBackgroundView.layer.masksToBounds = true
        selectedIcon.layer.cornerRadius = selectedIcon.frame.width / 2
        selectedIcon.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupWith(sphere: Sphere){
        self.sphere = sphere
    }
    
}

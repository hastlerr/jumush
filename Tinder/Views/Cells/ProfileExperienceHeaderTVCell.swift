//
//  ProfileExperienceTVCell.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 9/24/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit

class ProfileExperienceHeaderTVCell: UITableViewCell {

    
    @IBOutlet weak var topGrayView: UIView!
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var expierenceLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupAsEducation(){
        iconImageView.image = UIImage(named: "ic_education")
        expierenceLabel.text = "ВЫСШЕЕ ОБРАЗОВАНИЕ"
        topGrayView.isHidden = true
    }
    
    func setupAsExpierence(){
        iconImageView.image = UIImage(named: "ic_experience")
        expierenceLabel.text = "ОПЫТ РАБОТЫ"
        topGrayView.isHidden = false
    }
    
}

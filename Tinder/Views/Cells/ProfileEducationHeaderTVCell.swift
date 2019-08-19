//
//  ProfileEducationHeaderTVCell.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 9/24/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit

class ProfileEducationHeaderTVCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    
    private var employee : Employee?{
        didSet{
            if let employee = employee{
                profileImageView.sd_setImage(with: employee.getImageUrl(), placeholderImage: Constants.placeholder, completed: nil)
                nameLabel.text = employee.name
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupWith(employee: Employee){
        self.employee = employee
    }
    
}

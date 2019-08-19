//
//  AboutCompanyCardTVCell.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 10/14/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit

class AboutCompanyCardTVCell: UITableViewCell {

    
    @IBOutlet weak var aboutCompanyLabel: UILabel!
    
    var employer: Employer?{
        didSet{
            if let employer = employer{
                aboutCompanyLabel.text = employer.about
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
    
    func setupWith(employer: Employer){
        self.employer = employer
    }
    
}

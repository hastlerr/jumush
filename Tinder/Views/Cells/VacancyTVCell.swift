//
//  VacancyTVCell.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 9/21/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit

class VacancyTVCell: UITableViewCell {

    @IBOutlet weak var companyImageView: UIImageView!
    @IBOutlet weak var companyNameLabel: UILabel!
    
    @IBOutlet weak var sphereLabel: UILabel!
    
    @IBOutlet weak var positionLabel: UILabel!
    
    @IBOutlet weak var scheduleLabel: UILabel!
    
    @IBOutlet weak var employmentTypeLabel: UILabel!
    
    @IBOutlet weak var aboutLabel: UILabel!
    
    private var vacancy: Vacancy?{
        didSet{
            if let vacancy = self.vacancy{
                positionLabel.text = vacancy.position
                aboutLabel.text = vacancy.description
                
                if let sphere = vacancy.sphere{
                    sphereLabel.text = sphere.name
                }
                
                if let employer = vacancy.employer{
                    companyNameLabel.text = employer.name
                    companyImageView.sd_setImage(with: employer.getImageUrl(), placeholderImage: Constants.placeholder, completed: nil)
                }
                
                scheduleLabel.text = Constants.SHEDULE_NAMES[vacancy.scheduleId]
                employmentTypeLabel.text = Constants.EMPLPOYMENT_TYPES[vacancy.employmentTypeId]
                
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
    
    func setupWith(vacancy: Vacancy){
        self.vacancy = vacancy
    }
    
}

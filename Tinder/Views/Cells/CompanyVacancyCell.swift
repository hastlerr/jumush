//
//  CompanyVacancyCell.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 9/26/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit

protocol CompanyVacancyCellDelegate: class {
    func showMenu(vacancy: Vacancy)
}

class CompanyVacancyCell: UITableViewCell {

    @IBOutlet weak var cardView: UIView!
    
    @IBOutlet weak var sphereNameLabel: UILabel!
    
    @IBOutlet weak var positionLabel: UILabel!
    
    @IBOutlet weak var applicationsCountLabel: UILabel!
    
    @IBOutlet weak var redView: UIView!
    
    
    var delegate : CompanyVacancyCellDelegate?
    var vacancy: Vacancy?{
        didSet{
            if let vacancy = self.vacancy{
                if let sphere = vacancy.sphere{
                    sphereNameLabel.text = sphere.name
                }else{
                    sphereNameLabel.text = ""
                }
                
                positionLabel.text = vacancy.position
                
                redView.isHidden = vacancy.applicationsCount == 0
                
                applicationsCountLabel.text = vacancy.applicationsCount > 0 ?  "\(vacancy.applicationsCount)" : ""
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.cardView.layer.shadowColor = UIColor.black.cgColor
        self.cardView.layer.shadowRadius = 4
        self.cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.cardView.layer.shadowOpacity = 0.1
        self.cardView.layer.masksToBounds = false
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupWith(vacancy: Vacancy){
        self.vacancy = vacancy
    }
    
    @IBAction func showMenu(_ sender: Any) {
        if let delegate = self.delegate, let vacancy = self.vacancy{
            delegate.showMenu(vacancy: vacancy)
        }
    }
    
    
}

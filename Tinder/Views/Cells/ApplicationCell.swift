//
//  ApplicationCell.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 9/16/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit

protocol ApplicationCellDelegate: class {
    func showMenu(application: Application)
}

class ApplicationCell: UITableViewCell {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var companyImageView: UIImageView!
    @IBOutlet weak var sphereLabel: UILabel!
    @IBOutlet weak var vacancyPositionLabel: UILabel!
    
    var delegate : ApplicationCellDelegate?
    var application: Application?{
        didSet{
            if let application = self.application{
                if let employer = application.vacancy?.employer{
                    companyImageView.sd_setImage(with: employer.getImageUrl(), placeholderImage: Constants.placeholder, completed: nil)
                }
                
                sphereLabel.text = application.vacancy?.sphere?.name ?? ""
                vacancyPositionLabel.text = application.vacancy?.position ?? ""
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
    
    func setupWith(application: Application){
        self.application = application
    }
    
    @IBAction func showMenu(_ sender: Any) {
        if let delegate = self.delegate, let application = self.application{
            delegate.showMenu(application: application)
        }
    }
    
    
}

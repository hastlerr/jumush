//
//  TableViewCell.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 9/20/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit
import Koloda

protocol VacancyKolodaViewDelegate {
    func didSelectApply(vacancy: Vacancy, view : VacancyKolodaView)
    func didSelectSkip(vacancy: Vacancy)
    func didSendMessage(vacancy: Vacancy)
}

class VacancyKolodaView: OverlayView {

    @IBOutlet weak var companyLogoView: UIView!
    @IBOutlet weak var companyLogoImageView: UIImageView!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var vacancyStatusImageView: UIImageView!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var sphereLabel: UILabel!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var scheduleLabel: UILabel!
    @IBOutlet weak var employmentLabel: UILabel!
    @IBOutlet weak var vacancyDescriptionLabel: UILabel!
    @IBOutlet weak var salaryLabel: UILabel!
    @IBOutlet weak var salaryTypeLabel: UILabel!
    @IBOutlet weak var applyButton: UIButton!
    
    
    private var vacancy : Vacancy? {
        didSet{
            if let vacancy = vacancy{
                if let employer = vacancy.employer{
                    companyNameLabel.text = employer.name
                    companyLogoImageView.sd_setImage(with: employer.getImageUrl(), placeholderImage: Constants.placeholder, completed: nil)
                }
                
                if let sphere = vacancy.sphere{
                    sphereLabel.text = sphere.name
                }
                
                positionLabel.text = vacancy.position
                scheduleLabel.text = Constants.SHEDULE_NAMES[vacancy.scheduleId]
                employmentLabel.text = Constants.EMPLPOYMENT_TYPES[vacancy.employmentTypeId]
                
                vacancyDescriptionLabel.text = vacancy.description
                
                if let salary = vacancy.salary{
                    salaryLabel.text = salary.getSalary()
                    salaryTypeLabel.text = salary.getSalaryType()
                }
                
                if let application = vacancy.application{
                    applyButton.isEnabled = application.status == ApplicationStatus.Rejected.rawValue || application.status == ApplicationStatus.Accepted.rawValue
                    applyButton.setImage(application.status == ApplicationStatus.Accepted.rawValue ? UIImage(named: "ic_application_send_message") : UIImage(named: "ic_vacancy_apply"), for: .normal)
                }else{
                    applyButton.isEnabled = true
                    applyButton.setImage(UIImage(named: "ic_vacancy_apply"), for: .normal)
                }
            }
        }
    }
    
    var delegate: VacancyKolodaViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        blurView.isHidden = true
        vacancyStatusImageView.isHidden = true
        
        self.companyLogoView.layer.shadowColor = UIColor.black.cgColor
        self.companyLogoView.layer.shadowRadius = 5
        self.companyLogoView.layer.shadowOffset = CGSize(width: 0, height: 5)
        self.companyLogoView.layer.shadowOpacity = 0.3
        self.companyLogoView.layer.masksToBounds = false
    }
    
    @IBAction func didSelectApply(_ sender: Any) {
        if let vacancy = self.vacancy{
            if let application = vacancy.application{
                if application.status == ApplicationStatus.Accepted.rawValue {
                    if let delegate = self.delegate{
                        delegate.didSendMessage(vacancy: vacancy)
                        return
                    }
                }
            }
            
            if let delegate = self.delegate{
                delegate.didSelectApply(vacancy: vacancy, view: self)
            }
        }
    }
    
    @IBAction func didSelectSkip(_ sender: Any) {
        blurView.isHidden = false
        blurView.backgroundColor = UIColor(hex: 0xEBEEF5)
        vacancyStatusImageView.isHidden = false
        vacancyStatusImageView.image = #imageLiteral(resourceName: "ic_vacancy_dissmised")

        
        perform(#selector(skip), with: nil, afterDelay: 1.0)
    }
    
    func setupWith(vacancy: Vacancy){
        self.vacancy = vacancy
    }
    
    func showSuccess(){
        blurView.isHidden = false
        blurView.backgroundColor = UIColor(hex: 0xD0FFE3)
        vacancyStatusImageView.isHidden = false
        vacancyStatusImageView.image = #imageLiteral(resourceName: "ic_vacancy_like")
    }
    
    @objc func skip(){
        if let delegate = self.delegate, let vacancy = self.vacancy{
            delegate.didSelectSkip(vacancy: vacancy)
        }
    }
    
}

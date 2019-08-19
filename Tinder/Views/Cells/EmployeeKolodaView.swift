//
//  EmployeeKolodaView.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 9/26/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit
import Koloda

protocol EmployeeKolodaViewDelegate {
    func didSelectAccept(application: Application, view: EmployeeKolodaView)
    func didSelectReject(application: Application, view: EmployeeKolodaView)
    func didSendMessage(application: Application, view: EmployeeKolodaView)
}

class EmployeeKolodaView: OverlayView {

    @IBOutlet weak var companyLogoView: UIView!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var vacancyStatusImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var employeeImageView: UIImageView!
    
    private var application : Application?{
        didSet{
            if let application = application{
                if let employee = application.employee{
                    employeeImageView.sd_setImage(with: employee.getImageUrl(), placeholderImage: Constants.placeholder, completed: nil)
                    nameLabel.text = employee.name
                    
                    educations = employee.educations
                    works = employee.works
                }
                
                acceptButton.isEnabled = application.status == ApplicationStatus.Created.rawValue || application.status == ApplicationStatus.Accepted.rawValue
                acceptButton.setImage(application.status == ApplicationStatus.Accepted.rawValue ? UIImage(named: "ic_employer_send_message") : UIImage(named: "ic_apply_employee_button"), for: .normal)
                
                skipButton.isEnabled = true
                acceptButton.isEnabled = true
                
            }else{
                skipButton.isEnabled = false
                acceptButton.isEnabled = false
                acceptButton.setImage(UIImage(named: "ic_apply_employee_button"), for: .normal)
            }
        }
    }
    
    private var educations = [Education](){
        didSet{
            tableView.reloadData()
        }
    }
    private var works = [Work](){
        didSet{
            tableView.reloadData()
        }
    }
    
    var delegate: EmployeeKolodaViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        blurView.isHidden = true
        vacancyStatusImageView.isHidden = true
        
        self.companyLogoView.layer.shadowColor = UIColor.black.cgColor
        self.companyLogoView.layer.shadowRadius = 5
        self.companyLogoView.layer.shadowOffset = CGSize(width: 0, height: 5)
        self.companyLogoView.layer.shadowOpacity = 0.3
        self.companyLogoView.layer.masksToBounds = false
        
        tableView.dataSource = self
        tableView.separatorStyle = .none
        registerXib()
    }
    
    func registerXib(){
        self.tableView.register(ProfileExperienceHeaderTVCell.nib, forCellReuseIdentifier: ProfileExperienceHeaderTVCell.identifier)
        self.tableView.register(ProfileEducationTVCell.nib, forCellReuseIdentifier: ProfileEducationTVCell.identifier)
    }
    
    @IBAction func didSelectApply(_ sender: Any) {
        if let delegate = self.delegate, let application = self.application{
            if application.status == ApplicationStatus.Accepted.rawValue{
                delegate.didSendMessage(application: application, view: self)
            }else{
                delegate.didSelectAccept(application: application, view: self)
            }
        }
    }
    
    @IBAction func didSelectSkip(_ sender: Any) {
        if let delegate = self.delegate, let application = self.application{
            delegate.didSelectReject(application: application, view: self)
        }
    }
    
    func showAcceptedSuccess(){
        blurView.isHidden = false
        blurView.backgroundColor = UIColor(hex: 0xD0FFE3)
        vacancyStatusImageView.isHidden = false
        vacancyStatusImageView.image = #imageLiteral(resourceName: "ic_vacancy_like")
    }
    
    func showRejectedSuccess(){
        blurView.isHidden = false
        blurView.backgroundColor = UIColor(hex: 0xEBEEF5)
        vacancyStatusImageView.isHidden = false
        vacancyStatusImageView.image = #imageLiteral(resourceName: "ic_vacancy_dissmised")
    }
    
    func setupWith(application: Application){
        self.application = application
    }
}

extension EmployeeKolodaView : UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? educations.count + 1 : works.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 && indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileExperienceHeaderTVCell.identifier, for: indexPath) as! ProfileExperienceHeaderTVCell
            
            cell.setupAsEducation()
            
            return cell
        }
        
        if indexPath.section == 1 && indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileExperienceHeaderTVCell.identifier, for: indexPath) as! ProfileExperienceHeaderTVCell
            
            cell.setupAsExpierence()
            
            return cell
        }
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileEducationTVCell.identifier, for: indexPath) as! ProfileEducationTVCell
        
        indexPath.section == 0 ? cell.setupWith(education: educations[indexPath.row - 1]) : cell.setupWith(work: works[indexPath.row - 1])
        
        return cell
    }
}


//
//  CreateVacancyVC.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 9/27/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit
import PKHUD

class CreateVacancyTVC: UITableViewController {
    
    @IBOutlet weak var createVacancyButton: UIButton!
    @IBOutlet weak var sphereLabel: UILabel!
    @IBOutlet weak var scheduleLabel: UILabel!
    @IBOutlet weak var salaryLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var sphereCardView: UIView!
    @IBOutlet weak var salaryCardView: UIView!
    
    var vacancy: Vacancy?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        
        tableView.separatorStyle = .none
        
        tableView.tableFooterView = UIView(frame: .zero)
        
        descriptionTextView.delegate = self
        
        titleTextField.addTarget(self, action: #selector(positionFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        
        if self.vacancy == nil{
            self.vacancy = Vacancy()
            self.vacancy?.id = CloudStoreRefManager.instance.vacanciesReferance.document().documentID
        }
        
        updateUI()
    }
    
   @objc func positionFieldDidChange(_ textField: UITextField) {
        if let vacancy = self.vacancy{
            vacancy.position = textField.text ?? ""
        }
    }
    
    func updateUI(){
        if let vacancy = self.vacancy{
            if let sphere = vacancy.sphere{
                sphereLabel.text = sphere.name
            }
            
            if let salary = vacancy.salary{
                salaryLabel.text = salary.getSalary()
            }
            
            titleTextField.text = vacancy.position
            if !vacancy.description.isEmpty{
                descriptionTextView.text = vacancy.description
                descriptionTextView.textColor = UIColor(hex: 0x25324C)
            }
            
            
            scheduleLabel.text = Constants.SHEDULE_NAMES[vacancy.scheduleId]
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        if let selectableCell = cell as? SelectVacancySphereTVCell{
            selectableCell.delegate = self

            switch indexPath.row{
            case 0 :
                selectableCell.type = .Sphere
            case 1 :
                selectableCell.type = .Schedule
            case 2 :
                selectableCell.type = .Salary
            default:
                break
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 40))
        let label = UILabel(frame: CGRect(x: 20, y: 0, width: headerView.frame.width - 20, height: headerView.frame.height))
        headerView.backgroundColor = UIColor.white
        label.backgroundColor = headerView.backgroundColor

        label.font = UIFont(name: "Raleway-Black", size: 24.0)
        label.text = self.vacancy == nil ? "Новая вакансия" : "Изменение вакансии"
        label.textColor = UIColor(hex: 0x25324C)

        headerView.addSubview(label)

        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
    
    @IBAction func createVacancy(_ sender: Any) {
        if let vacancy = self.vacancy{
            
            guard let title = titleTextField.text, !title.isEmpty else{
                titleTextField.shake()
                return
            }
            
            vacancy.position = title
            
            if vacancy.sphere == nil{
                sphereCardView.shake()
                return
            }
            
            if vacancy.salary == nil{
                salaryCardView.shake()
                return
            }
            
            HUD.show(.progress)
            
            CloudStoreRefManager.instance.vacanciesReferance
                .document(vacancy.id)
                .setData(vacancy.toCreateParams(), merge: true) { (error) in
                    HUD.hide()
                    
                    if let error = error{
                        self.showAlertWithMessage(message: error.localizedDescription)
                        return
                    }
                    
                    self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

extension CreateVacancyTVC : SelectVacancySphereTVCellDelegate{
    func didSelect(cell: SelectVacancySphereTVCell) {
        setupBackButton()
        
        switch cell.type {
        case .Schedule:
            let vc = UIStoryboard(name: Constants.EMPLOYER_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "SelectVacancySheduleTVC") as! SelectVacancySheduleTVC
            vc.delegate = self
            vc.vacancy = self.vacancy
            self.navigationController?.pushViewController(vc, animated: true)
        case .Sphere:
            let vc = UIStoryboard(name: Constants.EMPLOYER_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "SelectVacancySpheresTVC") as! SelectVacancySpheresTVC
            vc.vacancy = self.vacancy
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        case .Salary:
            let vc = UIStoryboard(name: Constants.EMPLOYER_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "SelectVacancyPriceTVC") as! SelectVacancyPriceTVC
            vc.vacancy = self.vacancy
            vc.delegate = self
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension CreateVacancyTVC : UITextViewDelegate{
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == "Описание"{
            textView.text = ""
            textView.textColor = UIColor(hex: 0x25324C)
        }
        
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textView.text.isEmpty{
            textView.text = "Описание"
            textView.textColor = UIColor(hex: 0xC0C4CC)
        }else{
            if let vacancy = self.vacancy{
                vacancy.description = textView.text
            }
        }
        
        return true
    }
}

extension CreateVacancyTVC : SelectVacancySheduleTVCDelegate{
    func didSelectSchedule(scheduleId: Int, employmentTypeId: Int) {
        if let vacancy = self.vacancy{
            vacancy.scheduleId = scheduleId
            vacancy.employmentTypeId = employmentTypeId
        }
        
        updateUI()
    }
}

extension CreateVacancyTVC : SelectVacancySpheresTVCDelegate{
    func didSelectSphere(sphere: Sphere) {
        if let vacancy = self.vacancy{
            vacancy.sphere = sphere
        }
        
        updateUI()
    }
}

extension CreateVacancyTVC : SelectVacancyPriceTVCDelegate{
    func didSelectSalary(salary: Salary) {
        if let vacancy = self.vacancy{
            vacancy.salary = salary
        }
        
        updateUI()
    }
}

//
//  EducationTVC.swift
//  Tinder
//
//  Created by Avaz on 15/09/2018.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit
import Firebase

class EducationTVCell: UITableViewCell {

    @IBOutlet weak var educationTypeTextField: UITextField!
    @IBOutlet weak var educationTitileTextField: UITextField!
    @IBOutlet weak var specializationTextField: UITextField!
    @IBOutlet weak var startTextField: UITextField!
    @IBOutlet weak var endTextField: UITextField!
    
    var education: Education?{
        didSet{
            if let education = education{
                educationTitileTextField.text = education.name
                specializationTextField.text = education.speciality
                startTextField.text = education.startDate.dateValue().toStringFormat(format: "MMMM YYYY")
                endTextField.text = education.endDate.dateValue().toStringFormat(format: "MMMM YYYY")
                
                if let picker = startTextField.inputView as? UIDatePicker{
                    picker.date = education.startDate.dateValue()
                }
                
                if let picker = endTextField.inputView as? UIDatePicker{
                    picker.date = education.endDate.dateValue()
                }
                
                if let index = Constants.EDUCATION_TYPE_IDS.firstIndex(of: education.type){
                    educationTypeTextField.text = Constants.EDUCATION_TYPES[index]
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let startDatePicker = UIDatePicker()
        startDatePicker.maximumDate = Date()
        startDatePicker.datePickerMode = .date
        startDatePicker.locale = Locale(identifier: "RU")
        startDatePicker.addTarget(self, action: #selector(startDateChanged(_:)), for: .valueChanged)
        startTextField.inputView = startDatePicker
        
        let endDatePicker = UIDatePicker()
        endDatePicker.maximumDate = Date()
        endDatePicker.datePickerMode = .date
        endDatePicker.locale = Locale(identifier: "RU")
        endDatePicker.addTarget(self, action: #selector(endDateChanged(_:)), for: .valueChanged)
        endTextField.inputView = endDatePicker
        
        let educationTypePicker = UIPickerView()
        educationTypePicker.dataSource = self
        educationTypePicker.delegate = self
        educationTypeTextField.inputView = educationTypePicker
        educationTypeTextField.text = Constants.EDUCATION_TYPES[0]
        
        educationTitileTextField.addTarget(self, action: #selector(titleDidChange(_:)), for: UIControlEvents.editingChanged)
        specializationTextField.addTarget(self, action: #selector(specializationDidChange(_:)), for: UIControlEvents.editingChanged)
    }
    
    @objc func titleDidChange(_ sender: UITextField){
        if let education = self.education{
            education.name = sender.text ?? ""
        }
    }
    
    @objc func specializationDidChange(_ sender: UITextField){
        if let education = self.education{
            education.speciality = sender.text ?? ""
        }
    }
    
    @objc func startDateChanged(_ sender: UIDatePicker) {
        startTextField.text = sender.date.toStringFormat(format: "MMMM YYYY")
        
        if let education = self.education{
            education.startDate = Timestamp(date: sender.date)
            
            if sender.date > education.endDate.dateValue(){
                education.endDate = education.startDate
                
                if let datePicker = endTextField.inputView as? UIDatePicker{
                    datePicker.date = sender.date
                }
                
                endTextField.text = sender.date.toStringFormat(format: "MMMM YYYY")
            }
        }
    }
    
    @objc func endDateChanged(_ sender: UIDatePicker) {
        endTextField.text = sender.date.toStringFormat(format: "MMMM YYYY")
        
        if let education = self.education{
            education.endDate = Timestamp(date: sender.date)
            
            if sender.date < education.startDate.dateValue(){
                education.startDate = education.endDate
                
                if let datePicker = startTextField.inputView as? UIDatePicker{
                    datePicker.date = sender.date
                }
                
                startTextField.text = sender.date.toStringFormat(format: "MMMM YYYY")
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setupWith(education : Education){
        self.education = education
    }
}

extension EducationTVCell : UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Constants.EDUCATION_TYPES.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Constants.EDUCATION_TYPES[row]
    }
}

extension EducationTVCell : UIPickerViewDelegate{
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        educationTypeTextField.text = Constants.EDUCATION_TYPES[row]
        
        if let education = self.education{
            education.type = Constants.EDUCATION_TYPE_IDS[row]
        }
    }
}

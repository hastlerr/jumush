//
//  EducationTVC.swift
//  Tinder
//
//  Created by Avaz on 15/09/2018.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit
import Firebase

class ExperienceTVCell: UITableViewCell {
    
    @IBOutlet weak var companyNameLabel: UITextField!
    @IBOutlet weak var positionTextField: UITextField!
    @IBOutlet weak var startTextField: UITextField!
    @IBOutlet weak var endTextField: UITextField!
    
    var work: Work?{
        didSet{
            if let work = work{
                companyNameLabel.text = work.company
                positionTextField.text = work.position
                startTextField.text = work.startDate.dateValue().toStringFormat(format: "MMMM YYYY")
                endTextField.text = work.endDate.dateValue().toStringFormat(format: "MMMM YYYY")
                
                if let picker = startTextField.inputView as? UIDatePicker{
                    picker.date = work.startDate.dateValue()
                }
                
                if let picker = endTextField.inputView as? UIDatePicker{
                    picker.date = work.endDate.dateValue()
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
        
        companyNameLabel.addTarget(self, action: #selector(nameDidChange(_:)), for: UIControlEvents.editingChanged)
        positionTextField.addTarget(self, action: #selector(positionDidChange(_:)), for: UIControlEvents.editingChanged)
    }
    
    @objc func nameDidChange(_ sender: UITextField){
        if let work = self.work{
            work.company = sender.text ?? ""
        }
    }
    
    @objc func positionDidChange(_ sender: UITextField){
        if let work = self.work{
            work.position = sender.text ?? ""
        }
    }
    
    @objc func startDateChanged(_ sender: UIDatePicker) {
        
        startTextField.text = sender.date.toStringFormat(format: "MMMM YYYY")
        
        if let work = self.work{
            work.startDate = Timestamp(date: sender.date)
            
            if sender.date > work.endDate.dateValue(){
                work.endDate = work.startDate
                
                if let datePicker = endTextField.inputView as? UIDatePicker{
                    datePicker.date = sender.date
                }
                
                endTextField.text = sender.date.toStringFormat(format: "MMMM YYYY")
            }
        }
    }
    
    @objc func endDateChanged(_ sender: UIDatePicker) {
        
        endTextField.text = sender.date.toStringFormat(format: "MMMM YYYY")
        
        if let work = self.work{
            work.endDate = Timestamp(date: sender.date)
            
            if sender.date < work.startDate.dateValue(){
                work.startDate = work.endDate
                
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
    
    func setupWith(work : Work){
        self.work = work
    }
}

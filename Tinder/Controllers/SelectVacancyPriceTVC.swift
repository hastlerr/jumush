//
//  SelectVacancyPriceTVC.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 10/1/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit

protocol SelectVacancyPriceTVCDelegate {
    func didSelectSalary(salary: Salary)
}

class SelectVacancyPriceTVC: UITableViewController {

    @IBOutlet weak var salaryRangeLabel: UILabel!
    @IBOutlet weak var salaryRangeSlider: RangeUISlider!
    private var selectedSalaryTypeIndexPath: IndexPath = IndexPath(row: 0, section: 0)
    private var salary = Salary()
    var vacancy: Vacancy?
    var delegate:SelectVacancyPriceTVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: .zero)
        salaryRangeSlider.delegate = self
        salaryRangeSlider.scaleMinValue = CGFloat(Constants.SALARY_START)
        salaryRangeSlider.scaleMaxValue = CGFloat(Constants.SALARY_END)
        
        if let vacancy = self.vacancy, let salary = vacancy.salary{
            self.salary = salary
            
            salaryRangeSlider.defaultValueLeftKnob = CGFloat(salary.start)
            salaryRangeSlider.defaultValueRightKnob = CGFloat(salary.end)
            
            switch salary.id{
            case SalaryType.Fixed.rawValue:
                selectedSalaryTypeIndexPath = IndexPath(row: 0, section: 0)
                salaryRangeSlider.disableRange = true
            case SalaryType.Range.rawValue:
                selectedSalaryTypeIndexPath = IndexPath(row: 1, section: 0)
                salaryRangeSlider.disableRange = false
            case SalaryType.Undefined.rawValue:
                selectedSalaryTypeIndexPath = IndexPath(row: 2, section: 0)
            default:
                break
            }
            
            tableView.reloadData()
        }
        
        updateUI()
    }
    
    func updateUI(){
         salaryRangeLabel.text = salary.getSalary()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return selectedSalaryTypeIndexPath.row == 2 ? 1 : 2
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
         return section == 0 ? 110 : CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 0 ? 5 : 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 60 : 140
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            return nil
        }
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 40))
        headerView.backgroundColor = tableView.backgroundColor
        let label = UILabel(frame: CGRect(x: 20, y: 20, width: headerView.frame.width - 20, height: headerView.frame.height))
        label.backgroundColor = headerView.backgroundColor
        label.font = UIFont(name: "Raleway-Black", size: 24.0)
        label.textColor = UIColor(hex: 0x25324C)
        label.text = "Зарплата"
        headerView.addSubview(label)
        
        let typeLabel = UILabel(frame: CGRect(x: 20, y: 60, width: headerView.frame.width - 20, height: headerView.frame.height))
        typeLabel.backgroundColor = headerView.backgroundColor
        typeLabel.font = UIFont(name: "Raleway-ExtraBold", size: 16)
        typeLabel.textColor = UIColor(hex: 0x25324C)
        typeLabel.text = "Тип"
        headerView.addSubview(typeLabel)
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if indexPath.section == 0{
            if let imageView = cell.viewWithTag(1) as? UIImageView{
                imageView.image = indexPath == selectedSalaryTypeIndexPath ? UIImage(named: "ic_select_box") : UIImage(named: "ic_select_box_gray")
            }
        }
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 40))
        footer.backgroundColor = UIColor(hex: 0xEBEEF5)
        
        return footer
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0{
            switch indexPath.row {
            case 0:
                salaryRangeSlider.disableRange = true
                salary.id = SalaryType.Fixed.rawValue
                salary.start = Int(salaryRangeSlider.scaleMinValue)
                salary.end = Int(salaryRangeSlider.scaleMinValue)
            case 1:
                salaryRangeSlider.disableRange = false
                salary.id = SalaryType.Range.rawValue
                salary.start = Int(salaryRangeSlider.scaleMinValue)
                salary.end = Int(salaryRangeSlider.scaleMaxValue)
            case 2:
                salaryRangeSlider.disableRange = true
                salary.id = SalaryType.Undefined.rawValue
                salary.start = Int(salaryRangeSlider.scaleMinValue)
                salary.end = Int(salaryRangeSlider.scaleMinValue)
            default:
                break
            }
            
            selectedSalaryTypeIndexPath = indexPath
            updateUI()
        }
        
        tableView.reloadData()
        
    }
    
    @IBAction func done(_ sender: Any) {
        if let delegate = self.delegate{
            delegate.didSelectSalary(salary: salary)
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension SelectVacancyPriceTVC : RangeUISliderDelegate{
    func rangeChangeFinished(minValueSelected: CGFloat, maxValueSelected: CGFloat, slider: RangeUISlider) {
        
    }
    
    func rangeIsChanging(minValueSelected: CGFloat, maxValueSelected: CGFloat, slider: RangeUISlider) {
        
        salary.start = Int(minValueSelected)
        salary.end = Int(maxValueSelected)
        
        updateUI()
    }
    
}

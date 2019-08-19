//
//  FilterSalaryTVCell.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 10/14/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit
import ObjectMapper

protocol FilterSalaryTVCellDelegate{
    func didSelectSalaryRange(start: Int, end: Int)
    func didSelectRegion(region: Region?)
}

class FilterSalaryTVCell: UITableViewCell {
    @IBOutlet weak var salaryRangeLabel: UILabel!
    
    @IBOutlet weak var rangeView: RangeUISlider!
    @IBOutlet weak var regionTextField: UITextField!
    
    private let regionPicker = UIPickerView()
    
    private let salary = Salary()
    
    private var regions = [Region](){
        didSet{
            regionPicker.reloadAllComponents()
            
            if let regionId = UserDefaults.standard.value(forKey: Constants.FILTER_SELECTED_REGION_ID) as? String{
                
                for region in regions{
                    if region.id == regionId{
                        self.selectedRegion = region
                        break
                    }
                }
            }
        }
    }
    
    private var selectedRegion : Region? {
        didSet{
            delegate?.didSelectRegion(region: selectedRegion)
            if let selectedRegion = selectedRegion{
                regionTextField.text = selectedRegion.name
            }else{
                regionTextField.text = ""
            }
            
        }
    }
    
    var delegate: FilterSalaryTVCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        regionPicker.dataSource = self
        regionPicker.delegate = self
        regionTextField.placeholder = "Весь Кыргызстан"
        regionTextField.inputView = regionPicker
        
        rangeView.delegate = self
        rangeView.scaleMinValue = CGFloat(Constants.SALARY_START)
        rangeView.scaleMaxValue = CGFloat(Constants.SALARY_END)
        
        if let salaryStart = UserDefaults.standard.value(forKey: Constants.FILTER_SELECTED_SALARY_START) as? Int{
            self.salary.start = salaryStart
            updateUI()
        }
        
        
        getRegions()
    }
    
    func updateUI(){
        salaryRangeLabel.text = salary.getSalary()
        delegate?.didSelectSalaryRange(start: salary.start, end: salary.end)
    }
    
    func getRegions(){
        CloudStoreRefManager.instance.regionsReferance
            .getDocuments(completion: { (snapshot, error) in
                if let error = error{
                    print("error: \(error.localizedDescription)")
                }
                
                if let snapshot = snapshot{
                    
                    var regions = [Region]()
                    
                    for item in snapshot.documents{
                        if let region = Mapper<Region>().map(JSON: item.data()){
                            region.id = item.documentID
                            regions.append(region)
                        }
                    }
                    
                    self.regions = regions
                }
            })
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
}

extension FilterSalaryTVCell : UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return regions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return regions[row].name
    }
}

extension FilterSalaryTVCell : UIPickerViewDelegate{
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let region = regions[row]
        
        if region.id == Constants.FILTER_REGION_ALL_KG{
            selectedRegion = nil
        }else{
            selectedRegion = region
        }
    }
}


extension FilterSalaryTVCell : RangeUISliderDelegate{
    func rangeChangeFinished(minValueSelected: CGFloat, maxValueSelected: CGFloat, slider: RangeUISlider) {
        
    }
    
    func rangeIsChanging(minValueSelected: CGFloat, maxValueSelected: CGFloat, slider: RangeUISlider) {
        salary.start = Int(minValueSelected)
        salary.end = Int(maxValueSelected)
        
        updateUI()
    }
    
}

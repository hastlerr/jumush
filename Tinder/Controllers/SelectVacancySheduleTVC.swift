//
//  SelectVacancySheduleTVC.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 9/28/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit

protocol SelectVacancySheduleTVCDelegate {
    func didSelectSchedule(scheduleId: Int, employmentTypeId: Int)
}

class SelectVacancySheduleTVC: UITableViewController {

    private var selectedGraphicIndexPath = IndexPath(row: 0, section: 0)
    private var selectedScheduleIndexPath = IndexPath(row: 0, section: 1)
    
    
    var vacancy: Vacancy?
    var delegate :SelectVacancySheduleTVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: .zero)
        
        if let vacancy = self.vacancy{
            selectedGraphicIndexPath = IndexPath(row: vacancy.employmentTypeId, section: 0)
            selectedScheduleIndexPath = IndexPath(row: vacancy.scheduleId, section: 1)
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0{
            selectedGraphicIndexPath = indexPath
        }else{
            selectedScheduleIndexPath = indexPath
        }
        
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 0 ? 5 : 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if indexPath.section == 1{
            if let imageView = cell.viewWithTag(1) as? UIImageView{
                imageView.image = indexPath == selectedScheduleIndexPath ? UIImage(named: "ic_select_box") :  UIImage(named: "ic_select_box_gray")
            }
        }else{
            if let imageView = cell.viewWithTag(1) as? UIImageView{
                imageView.image = indexPath == selectedGraphicIndexPath ? UIImage(named: "ic_select_box") :  UIImage(named: "ic_select_box_gray")
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 40))
        headerView.backgroundColor = tableView.backgroundColor
        let label = UILabel(frame: CGRect(x: 20, y: 20, width: headerView.frame.width - 20, height: headerView.frame.height))
        label.backgroundColor = headerView.backgroundColor
        label.font = UIFont(name: "Raleway-Black", size: 24.0)
        label.textColor = UIColor(hex: 0x25324C)
        
        switch section {
        case 0:
            label.text = "Занятость"
        case 1:
            label.text = "График"
        default:
            break
        }
        
        headerView.addSubview(label)
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 40))
        footer.backgroundColor = UIColor(hex: 0xEBEEF5)
        
        return footer
    }
    
    @IBAction func done(_ sender: Any) {
        if let delegate = self.delegate{
            delegate.didSelectSchedule(scheduleId: selectedScheduleIndexPath.row, employmentTypeId: selectedGraphicIndexPath.row)
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
}

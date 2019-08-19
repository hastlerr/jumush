//
//  VacancyFilterTVC.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 10/12/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit
import ObjectMapper

protocol VacancyFilterTVCDelegate {
    func didChangeFilter()
}

class VacancyFilterTVC: UITableViewController {

    private var selectedSpheres = [Sphere](){
        didSet{
            tableView.reloadData()
        }
    }
    
    private var salary = Salary()
    private var region: Region?
    
    private var spheres = [Sphere](){
        didSet{
            tableView.reloadData()
            getSelectedSphereIds()
        }
    }
    
    private var selectedCountLabel = UILabel()
    
    var delegate : VacancyFilterTVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        
        tableView.register(FilterSphereTVCell.nib, forCellReuseIdentifier: FilterSphereTVCell.identifier)
        tableView.register(FilterSalaryTVCell.nib, forCellReuseIdentifier: FilterSalaryTVCell.identifier)
        tableView.register(FIlterSphereHeaderTVCell.nib, forHeaderFooterViewReuseIdentifier: FIlterSphereHeaderTVCell.identifier)
        getSpheres()
    }
    
    func getSelectedSphereIds(){
        if let sphereIds = UserDefaults.standard.value(forKey: Constants.FILTER_SELECTED_SPHERE_IDS) as? [String]{
            
            selectedSpheres.removeAll()
            
            for sphere in spheres{
                if sphereIds.contains(sphere.id){
                    selectedSpheres.append(sphere)
                }
            }
        }
        
        tableView.reloadData()
    }
    
    func getSpheres(){
        CloudStoreRefManager.instance.spheresReferance
            .getDocuments(completion: { (snapshot, error) in
                if let error = error{
                    print("error: \(error.localizedDescription)")
                }
                
                if let snapshot = snapshot{
                    
                    var spheres = [Sphere]()
                    
                    for item in snapshot.documents{
                        if let sphere = Mapper<Sphere>().map(JSON: item.data()){
                            sphere.id = item.documentID
                            spheres.append(sphere)
                        }
                    }
                    
                    self.spheres = spheres
                }
            })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : spheres.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: FilterSalaryTVCell.identifier) as! FilterSalaryTVCell
            cell.delegate = self
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: FilterSphereTVCell.identifier) as! FilterSphereTVCell
        
        let sphere = spheres[indexPath.row]
        
        if indexPath.row < spheres.count{
            cell.setupWith(sphere: sphere)
        }
        
        cell.selectedIcon.isHidden = !selectedSpheres.contains(sphere)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? CGFloat.leastNormalMagnitude : 70
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 0 ? 10 : CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: FIlterSphereHeaderTVCell.identifier) as! FIlterSphereHeaderTVCell
        
        if let selectedCountLabel = header.viewWithTag(1) as? UILabel{
            self.selectedCountLabel = selectedCountLabel
            self.selectedCountLabel.text = "Выбрано \(selectedSpheres.count)"
        }
        
        return header
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 40))
        footer.backgroundColor = UIColor(hex: 0xEBEEF5)
        
        return footer
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let sphere = spheres[indexPath.row]
        
        if let index = selectedSpheres.firstIndex(where: { (item) -> Bool in
            return item == sphere
        }){
            selectedSpheres.remove(at: index)
        }else{
            selectedSpheres.append(sphere)
        }
        
        self.selectedCountLabel.text = "Выбрано \(selectedSpheres.count)"
        tableView.rectForRow(at: indexPath)
    }
    
    @IBAction func done(_ sender: Any) {
        UserDefaults.standard.set(salary.start, forKey: Constants.FILTER_SELECTED_SALARY_START)
        
        var ids = [String]()
        
        for sphere in selectedSpheres{
            ids.append(sphere.id)
        }
        
        UserDefaults.standard.set(ids, forKey: Constants.FILTER_SELECTED_SPHERE_IDS)
        if let region = self.region{
            UserDefaults.standard.set(region.id, forKey: Constants.FILTER_SELECTED_REGION_ID)
        }else{
            UserDefaults.standard.removeObject(forKey: Constants.FILTER_SELECTED_REGION_ID)
        }
        
        delegate?.didChangeFilter()
        self.navigationController?.popViewController(animated: true)
    }
}

extension VacancyFilterTVC : FilterSalaryTVCellDelegate{
    func didSelectSalaryRange(start: Int, end: Int) {
        salary.start = start
        salary.end = end
    }
    
    func didSelectRegion(region: Region?) {
        self.region = region
    }
    
    
}

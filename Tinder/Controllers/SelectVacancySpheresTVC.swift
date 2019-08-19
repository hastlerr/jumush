//
//  SelectVacancySpheresTVC.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 9/28/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit
import ObjectMapper

protocol SelectVacancySpheresTVCDelegate {
    func didSelectSphere(sphere: Sphere)
}

class SelectVacancySpheresTVC: UITableViewController {

    private var selectedSphereIndexPath = IndexPath(row: 0, section: 0)
    private var spheres = [Sphere](){
        didSet{
            if let vacancy = self.vacancy, let sphere = vacancy.sphere{
                
                if let index = spheres.firstIndex(where: { (item) -> Bool in
                    return item.id == sphere.id
                }){
                    selectedSphereIndexPath = IndexPath(row: index, section: 0)
                }
            }
            
            tableView.reloadData()
        }
    }
    
    var vacancy: Vacancy?
    var delegate:SelectVacancySpheresTVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: .zero)
        
        getSpheres()
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spheres.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        selectedSphereIndexPath = indexPath
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sphereCell")
        
        if let imageView = cell?.viewWithTag(1) as? UIImageView{
            imageView.image = indexPath == selectedSphereIndexPath ? UIImage(named: "ic_select_box") :  UIImage(named: "ic_select_box_gray")
        }
        
        if let titleLabel = cell?.viewWithTag(2) as? UILabel{
            titleLabel.text = self.spheres[indexPath.row].name
        }
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 40))
        headerView.backgroundColor = tableView.backgroundColor
        let label = UILabel(frame: CGRect(x: 20, y: 0, width: headerView.frame.width - 20, height: headerView.frame.height))
        label.backgroundColor = headerView.backgroundColor
        label.font = UIFont(name: "Raleway-Black", size: 24.0)
        label.textColor = UIColor(hex: 0x25324C)
        label.text = "Сфера"
        headerView.addSubview(label)
        
        return headerView
    }
    
    
    @IBAction func done(_ sender: Any) {
        if let delegate = self.delegate{
            delegate.didSelectSphere(sphere: spheres[selectedSphereIndexPath.row])
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
}

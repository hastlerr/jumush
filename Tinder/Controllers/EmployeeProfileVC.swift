//
//  EmployeeProfileVC.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 9/24/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit
import FirebaseAuth
import ObjectMapper

class EmployeeProfileVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
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
    private var employee: Employee?{
        didSet{
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        
        tableView.tableFooterView = UIView(frame: .zero)
        registerXib()

    }
    
    func registerXib(){
        self.tableView.register(ProfileEducationHeaderTVCell.nib, forCellReuseIdentifier: ProfileEducationHeaderTVCell.identifier)
        self.tableView.register(ProfileExperienceHeaderTVCell.nib, forCellReuseIdentifier: ProfileExperienceHeaderTVCell.identifier)
        self.tableView.register(ProfileEducationTVCell.nib, forCellReuseIdentifier: ProfileEducationTVCell.identifier)
    }
    
    func getProfile(){
        guard let user = Auth.auth().currentUser else{
            return
        }
        
        CloudStoreRefManager.instance.employeesReferance
            .document(user.uid)
            .getDocument { (snapshot, error) in
                if let error = error{
                    print("Firebase error: \(error.localizedDescription)")
                }
                
                if let snapshot = snapshot, let data = snapshot.data(), let employee = Mapper<Employee>().map(JSON: data){
                    
                    
                    
                    employee.id = snapshot.documentID
                    self.employee = employee
                }
        }
    }
    
    func getProfileEducation(){
        guard let user = Auth.auth().currentUser else{
            return
        }
        
        CloudStoreRefManager.instance.employeesReferance
            .document(user.uid)
            .collection(CloudRout.educations.rawValue)
            .getDocuments(completion: { (educationsSnaphot, error) in
                
                if let error = error{
                    print("Firebase error: \(error.localizedDescription)")
                }
                
                if let educationsSnaphot = educationsSnaphot{
                    
                    var educations = [Education]()
                    
                    for item in educationsSnaphot.documents{
                        if let education = Mapper<Education>().map(JSON: item.data()){
                            education.id = item.documentID
                            educations.append(education)
                        }
                    }
                    
                    self.educations = educations
                }
                
            })
    }
    
    func getProfileWorks(){
        guard let user = Auth.auth().currentUser else{
            return
        }
        
        CloudStoreRefManager.instance.employeesReferance
            .document(user.uid)
            .collection(CloudRout.works.rawValue)
            .getDocuments(completion: { (worksSnaphot, error) in
                
                if let error = error{
                    print("Firebase error: \(error.localizedDescription)")
                }
                
                if let worksSnaphot = worksSnaphot{
                    
                    var works = [Work]()
                    
                    for item in worksSnaphot.documents{
                        if let work = Mapper<Work>().map(JSON: item.data()){
                            work.id = item.documentID
                            works.append(work)
                        }
                    }
                    
                    self.works = works
                }
            })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        
        getProfile()
        getProfileEducation()
        getProfileWorks()
    }
    
    @IBAction func editProfile(_ sender: Any) {
        setupBackButton()
        let vc = SignupInfoTVC.newInstance()
        vc.popVCAfterUpdate = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension EmployeeProfileVC : UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? educations.count + 1 : works.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 && indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileEducationHeaderTVCell.identifier, for: indexPath) as! ProfileEducationHeaderTVCell
            if let employee = self.employee{
                cell.setupWith(employee: employee)
            }
            
            return cell
        }
        
        if indexPath.section == 1 && indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileExperienceHeaderTVCell.identifier, for: indexPath)
            
            return cell
        }
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileEducationTVCell.identifier, for: indexPath) as! ProfileEducationTVCell
        
        indexPath.section == 0 ? cell.setupWith(education: educations[indexPath.row - 1]) : cell.setupWith(work: works[indexPath.row - 1])
        
        return cell
    }
}



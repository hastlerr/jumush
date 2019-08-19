//
//  EmployerVacancyVC.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 9/26/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit
import ObjectMapper

class EmployerVacancyVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var salaryLabel: UILabel!
    
    @IBOutlet weak var salaryTypeLabel: UILabel!
    
    var vacancy = Vacancy()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Вакансия"
        
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        
        tableView.tableFooterView = UIView(frame: .zero)
        registerXib()
        
        if let salary = vacancy.salary{
            self.salaryLabel.text = salary.getSalary()
            self.salaryTypeLabel.text = salary.getSalaryType()
        }
    }
    
    func getVacancy(){
        CloudStoreRefManager.instance.vacanciesReferance
            .document(vacancy.id)
            .getDocument { (snapshot, error) in
                if let error = error{
                    print("Firebase error: \(error.localizedDescription)")
                }
                
                if let snapshot = snapshot, let data = snapshot.data(), let vacancy = Mapper<Vacancy>().map(JSON: data){
                    vacancy.id = snapshot.documentID
                    
                    CloudStoreRefManager.instance.employersReferance
                        .document(vacancy.creatorId)
                        .getDocument(completion: { (employerSnapshot, error) in
                            if let error = error{
                                print("Firebase error: \(error.localizedDescription)")
                            }
                            
                            if let snapshot = employerSnapshot, let data = snapshot.data(), let employer = Mapper<Employer>().map(JSON: data){
                                vacancy.employer = employer
                                
                                
                                CloudStoreRefManager.instance.spheresReferance
                                    .document(vacancy.sphereId)
                                    .getDocument(completion: { (sphereSnapshot, error) in
                                        if let error = error{
                                            print("Firebase error: \(error.localizedDescription)")
                                        }
                                        
                                        if let snapshot = sphereSnapshot, let sphereJson = snapshot.data(), let sphere = Mapper<Sphere>().map(JSON: sphereJson){
                                            sphere.id = vacancy.sphereId
                                            vacancy.sphere = sphere
                                            
                                            
                                            self.vacancy = vacancy
                                            if let salary = self.vacancy.salary{
                                                self.salaryLabel.text = salary.getSalary()
                                                self.salaryTypeLabel.text = salary.getSalaryType()
                                            }
                                            
                                            self.tableView.reloadData()
                                        }
                                    })
                                
                                
                            }
                            
                            
                        })
                }
        }
    }
    
    func registerXib(){
        self.tableView.register(VacancyTVCell.nib, forCellReuseIdentifier: VacancyTVCell.identifier)
        self.tableView.register(AboutCompanyCardTVCell.nib, forCellReuseIdentifier: AboutCompanyCardTVCell.identifier)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        getVacancy()
    }
    
    @IBAction func back(_ sender: Any) {
        let vc = UIStoryboard(name: Constants.EMPLOYER_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "EmployerVacanciesVC")
        UIApplication.shared.keyWindow?.rootViewController = UINavigationController(rootViewController: vc)
    }
    
    @IBAction func editVacancy(_ sender: Any) {
        setupBackButton()
        
        let vc = UIStoryboard(name: Constants.EMPLOYER_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "CreateVacancyTVC") as! CreateVacancyTVC
        vc.vacancy = self.vacancy
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension EmployerVacancyVC : UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 1 ? (vacancy.employer != nil ? 1 : 0) : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: VacancyTVCell.identifier, for: indexPath) as! VacancyTVCell
            cell.setupWith(vacancy: vacancy)
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: AboutCompanyCardTVCell.identifier, for: indexPath) as! AboutCompanyCardTVCell
            if let employer = vacancy.employer{
                cell.setupWith(employer: employer)
            }
            
            return cell
        }
    }
}


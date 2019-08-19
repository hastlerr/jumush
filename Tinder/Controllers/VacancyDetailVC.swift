//
//  VacancyDetailVC.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 9/21/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit
import Firebase
import ObjectMapper
import PKHUD

class VacancyDetailVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var salaryLabel: UILabel!
    
    @IBOutlet weak var salaryTypeLabel: UILabel!
    
    @IBOutlet weak var dissmisButton: UIButton!
    
    @IBOutlet weak var applyButton: UIButton!
    
    @IBOutlet weak var sendMessageButton: UIButton!
    
    private var application : Application?{
        didSet{
            if let application = application{
                
                switch application.status{
                case ApplicationStatus.Accepted.rawValue:
                    applyButton.isHidden = true
                    dissmisButton.isHidden = true
                    sendMessageButton.isHidden = false
                    applyButton.isEnabled = false
                    dissmisButton.isEnabled = false
                    sendMessageButton.isEnabled = true
                    break
                case ApplicationStatus.Created.rawValue:
                    applyButton.isHidden = false
                    dissmisButton.isHidden = false
                    sendMessageButton.isHidden = true
                    applyButton.isEnabled = false
                    dissmisButton.isEnabled = false
                    sendMessageButton.isEnabled = false
                    break
                case ApplicationStatus.Rejected.rawValue:
                    applyButton.isHidden = false
                    dissmisButton.isHidden = false
                    sendMessageButton.isHidden = true
                    applyButton.isEnabled = true
                    dissmisButton.isEnabled = true
                    sendMessageButton.isEnabled = false
                    break
                default:
                    break
                }
            }else{
                applyButton.isHidden = false
                dissmisButton.isHidden = false
                sendMessageButton.isHidden = true
                applyButton.isEnabled = true
                dissmisButton.isEnabled = true
                sendMessageButton.isEnabled = false
            }
        }
    }
    var vacancy : Vacancy?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Вакансия"
        
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        
        tableView.tableFooterView = UIView(frame: .zero)
        registerXib()
        
        application = nil
        
        getVacancy()
        getApplication()
        
        if let vacancy = self.vacancy, let salary = vacancy.salary{
            self.salaryLabel.text = salary.getSalary()
            self.salaryTypeLabel.text = salary.getSalaryType()
        }
    }
    
    func registerXib(){
        self.tableView.register(VacancyTVCell.nib, forCellReuseIdentifier: VacancyTVCell.identifier)
        self.tableView.register(AboutCompanyCardTVCell.nib, forCellReuseIdentifier: AboutCompanyCardTVCell.identifier)
    }
    
    func getVacancy(){
        guard let vacancy = self.vacancy else{
            return
        }
        BDManager.instance.getVacancy(vacancyId: vacancy.id) { (status, vacancy) in
            switch status{
            case .Success:
                self.vacancy = vacancy
                if let salary = vacancy.salary{
                    self.salaryLabel.text = salary.getSalary()
                    self.salaryTypeLabel.text = salary.getSalaryType()
                }
                self.tableView.reloadData()
                break
            case .Failed:
                break
            }
        }
    }
    
    func getApplication(){
        guard let user = Auth.auth().currentUser, let vacancy = self.vacancy, let employer = vacancy.employer else{
            return
        }
        
        CloudStoreRefManager.instance.applicationsReferance
            .whereField("authorId", isEqualTo: user.uid)
            .whereField("vacancyId", isEqualTo: vacancy.id)
            .whereField("employerId", isEqualTo: employer.id)
            .getDocuments { (snapshot, error) in
                if let error = error{
                    print("Firebase error: \(error.localizedDescription)")
                }
                
                if let snapshot = snapshot{
                    if snapshot.documents.isEmpty{
                        
                        self.application = nil
                        
                    }else{
                        if let application = Mapper<Application>().map(JSON: snapshot.documents.first!.data()){
                            self.application = application
                        }
                    }
                }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func apply(_ sender: Any) {
        
        if let application = self.application{
            if application.status == ApplicationStatus.Rejected.rawValue{
                
                HUD.show(.progress)
                
                let params = [
                    "id" : application.id,
                    "updatedAt" : Timestamp(),
                    "status" : ApplicationStatus.Created.rawValue
                    ] as [String : Any]
                
                CloudStoreRefManager.instance.applicationsReferance
                    .document(application.id)
                    .setData(params, merge: true, completion: { (error) in
                        if let error = error{
                            print("Firebase error: \(error.localizedDescription)")
                            return
                        }
                        
                        HUD.hide()
                        self.getApplication()
                    })
                
            }
        }else{
            guard let user = Auth.auth().currentUser, let vacancy = self.vacancy, let employer = vacancy.employer, let sphere = vacancy.sphere else{
                return
            }
            
            HUD.show(.progress)
            
            let applicationId = CloudStoreRefManager.instance.applicationsReferance.document().documentID
            
            let params = [
                "id" : applicationId,
                "authorId" : user.uid,
                "vacancyId" : vacancy.id,
                "employerId" : employer.id,
                "createdAt" : Timestamp(),
                "updatedAt" : Timestamp(),
                "status" : ApplicationStatus.Created.rawValue,
                "position" : vacancy.position,
                "sphere" : [
                    "id" : sphere.id,
                    "name" : sphere.name
                ]
                ] as [String : Any]
            
            CloudStoreRefManager.instance.applicationsReferance
                .document(applicationId)
                .setData(params, merge: true, completion: { (error) in
                    if let error = error{
                        print("Firebase error: \(error.localizedDescription)")
                        return
                    }
                    
                    HUD.hide()
                    self.getApplication()
                })
            
        }
        
        
    }
    
    
    @IBAction func dismiss(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        
        guard let user = Auth.auth().currentUser,let vacancy = self.vacancy, let employer = vacancy.employer else{
            return
        }
        
        HUD.show(.progress)
        
        CloudStoreRefManager.instance.chatsReferance
            .whereField("vacancyId", isEqualTo: vacancy.id)
            .whereField("users", arrayContains: user.uid)
            .getDocuments { (snapshot, error) in
                
                if let snapshot = snapshot, !snapshot.documents.isEmpty{
                    let chatId = snapshot.documents.first!.documentID
                    
                    CloudStoreRefManager.instance.chatsReferance
                        .document(chatId)
                        .setData(["updatedAt": Timestamp()], merge: true, completion: { (error) in
                            HUD.hide()
                            
                            if let error = error{
                                print("Firebase error: \(error.localizedDescription)")
                            }
                            
                            print("open chatId: \(chatId)")
                            self.openChat(chatId: chatId)
                            return
                        })
                }else{
                    BDManager.instance.getEmployee(employeeId: user.uid, completion: { (status, employee) in
                        switch status{
                        case .Success:
                            
                            let newChatId = CloudStoreRefManager.instance.chatsReferance.document().documentID
                            
                            let params = [
                                "id" : newChatId,
                                employer.id : [
                                    "name" : employer.name,
                                    "image" : employer.imageUrl
                                ],
                                user.uid : [
                                    "name" : employee.name,
                                    "image" : employee.imageUrl
                                ],
                                "vacancyId" : vacancy.id,
                                "users" : [user.uid, employer.id],
                                "updatedAt" : Timestamp()
                                ] as [String : Any]
                            
                            CloudStoreRefManager.instance.chatsReferance
                                .document(newChatId)
                                .setData(params, completion: { (error) in
                                    HUD.hide()
                                    
                                    if let error = error{
                                        print("Firebase error: \(error.localizedDescription)")
                                    }
                                    
                                    print("open newChatId: \(newChatId)")
                                    self.openChat(chatId: newChatId)
                                })
                            
                            break
                        case .Failed:
                            HUD.hide()
                            self.showAlertWithMessage(message: "Ошибка при создании чата")
                            break
                        }
                    })
                }       
        }
    }
}

extension VacancyDetailVC : UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: VacancyTVCell.identifier, for: indexPath) as! VacancyTVCell
            if let vacancy = vacancy{
                cell.setupWith(vacancy: vacancy)
            }
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: AboutCompanyCardTVCell.identifier, for: indexPath) as! AboutCompanyCardTVCell
            if let vacancy = vacancy, let employer = vacancy.employer{
                cell.setupWith(employer: employer)
            }
            
            return cell
        }
    }
}

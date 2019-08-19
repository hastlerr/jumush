//
//  EmployeeDetailVC.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 9/26/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit
import Firebase
import ObjectMapper
import PKHUD

class EmployeeDetailVC: UIViewController {

    @IBOutlet weak var employeeImageView: UIImageView!
    
    @IBOutlet weak var employeeNameLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var rejectButton: UIButton!
    
    @IBOutlet weak var acceptButton: UIButton!
    
    @IBOutlet weak var smallRejectButton: UIButton!
    
    @IBOutlet weak var sendMessageButton: UIButton!
    
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
    var employee: Employee?{
        didSet{
            tableView.reloadData()
            
            if let employee = employee{
                employeeImageView.sd_setImage(with: employee.getImageUrl(), placeholderImage: Constants.placeholder, completed: nil)
                employeeNameLabel.text = employee.name
            }
        }
    }
    
    var application : Application?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Соискатель"
        
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        
        tableView.tableFooterView = UIView(frame: .zero)
        registerXib()
        
        if let application = self.application, let employee = application.employee{
            self.employee = employee
            getProfile()
            getProfileEducation()
            getProfileWorks()
            
            if application.status == ApplicationStatus.Accepted.rawValue{
                smallRejectButton.isHidden = false
                sendMessageButton.isHidden = false
                rejectButton.isHidden = true
                acceptButton.isHidden = true
            }else{
                smallRejectButton.isHidden = true
                sendMessageButton.isHidden = true
                rejectButton.isHidden = false
                acceptButton.isHidden = false
            }
        }
        
        getApplication()
    }
    
    func registerXib(){
        self.tableView.register(ProfileExperienceHeaderTVCell.nib, forCellReuseIdentifier: ProfileExperienceHeaderTVCell.identifier)
        self.tableView.register(ProfileEducationTVCell.nib, forCellReuseIdentifier: ProfileEducationTVCell.identifier)
    }
    
    func getApplication(){
        if let application = self.application{
            BDManager.instance.getApplication(applicationId: application.id) { (status, application) in
                
                if status == .Success{
                    self.application = application
                }
            }
        }
    }
    
    
    func getProfile(){
        guard let employee = self.employee else{
            return
        }
        
        CloudStoreRefManager.instance.employeesReferance
            .document(employee.id)
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
         guard let employee = self.employee else{
            return
        }
        
        CloudStoreRefManager.instance.employeesReferance
            .document(employee.id)
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
         guard let employee = self.employee else{
            return
        }
        
        CloudStoreRefManager.instance.employeesReferance
            .document(employee.id)
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
    }
    
    
    @IBAction func rejectApplication(_ sender: Any) {
        guard let application = self.application else{
            return
        }
        
        let alert = UIAlertController(title: "Вы действительно хотите отклонить заявку?", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Отмена", style: UIAlertActionStyle.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Да", style: .destructive, handler: { (alert) in
            let params = [
                "id" : application.id,
                "updatedAt" : Timestamp(),
                "status" : ApplicationStatus.Rejected.rawValue
                ] as [String : Any]
            
            HUD.show(.progress)
            
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
        }))
        
        self.present(alert, animated: true, completion: nil)
        
        
        
    }
    
    @IBAction func acceptApplication(_ sender: Any) {
        guard let application = self.application else{
            return
        }
        
        let params = [
            "id" : application.id,
            "updatedAt" : Timestamp(),
            "status" : ApplicationStatus.Accepted.rawValue
            ] as [String : Any]
        
        HUD.show(.progress)
        
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
    
    @IBAction func sendMessage(_ sender: Any) {
        guard let user = Auth.auth().currentUser, let application = self.application, let employee = self.employee else{
            return
        }
        
        HUD.show(.progress)
        
        CloudStoreRefManager.instance.chatsReferance
            .whereField("vacancyId", isEqualTo: application.vacancyId)
            .whereField("users", arrayContains: application.authorId)
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
                    BDManager.instance.getEmployer(employerId: user.uid, completion: { (status, employer) in
                        switch status{
                        case .Success:
                            
                            let newChatId = CloudStoreRefManager.instance.chatsReferance.document().documentID
                            
                            let params = [
                                "id" : newChatId,
                                employee.id : [
                                    "name" : employee.name,
                                    "image" : employee.imageUrl
                                ],
                                user.uid : [
                                    "name" : employer.name,
                                    "image" : employer.imageUrl
                                ],
                                "vacancyId" : application.vacancyId,
                                "users" : [user.uid, employee.id],
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

extension EmployeeDetailVC : UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? (educations.isEmpty ? 0 : 1 ) +  educations.count : (works.isEmpty ? 0 : 1 ) + works.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 && indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileExperienceHeaderTVCell.identifier, for: indexPath) as! ProfileExperienceHeaderTVCell
            
            cell.setupAsEducation()
            
            return cell
        }
        
        if indexPath.section == 1 && indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileExperienceHeaderTVCell.identifier, for: indexPath) as! ProfileExperienceHeaderTVCell
            
            cell.setupAsExpierence()
            
            return cell
        }
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileEducationTVCell.identifier, for: indexPath) as! ProfileEducationTVCell
        
        indexPath.section == 0 ? cell.setupWith(education: educations[indexPath.row - 1]) : cell.setupWith(work: works[indexPath.row - 1])
        
        return cell
    }
}

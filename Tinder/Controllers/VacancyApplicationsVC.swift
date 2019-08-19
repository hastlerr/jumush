//
//  VacancyApplicationsVC.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 9/26/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit
import Koloda
import Firebase
import ObjectMapper
import PKHUD

class VacancyApplicationsVC: UIViewController {

    @IBOutlet weak var kolodaView: KolodaView!
    @IBOutlet weak var undoButton: UIButton!
    
    @IBOutlet weak var undoIcon: UIImageView!
    
    fileprivate var lastApplicationDocument : DocumentSnapshot?
    
    var vacancy = Vacancy()
    
    fileprivate var applications: [Application] = [] {
        didSet{
            kolodaView.reloadData()
        }
    }
    
    private var undoApplication: Application?{
        didSet{
            if let application = undoApplication, let employee = application.employee {
                undoButton.sd_setImage(with: employee.getImageUrl(), for: .normal, placeholderImage: Constants.placeholder, completed: nil)
                undoButton.isEnabled = true
                undoIcon.isHidden = false
                undoButton.isHidden = false
            }else{
                undoButton.setImage(nil, for: .normal)
                undoButton.isEnabled = false
                undoIcon.isHidden = true
                undoButton.isHidden = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        kolodaView.dataSource = self
        kolodaView.delegate = self
        
        getApplication()
    }
    
    func getApplication(){
        
        CloudStoreRefManager.instance.applicationsReferance
            .whereField("vacancyId", isEqualTo: vacancy.id)
//            .whereField("status", isEqualTo: ApplicationStatus.Created.rawValue)
            .limit(to: Constants.APPLICATOINS_PAGINATION)
            .getDocuments { (snapshot, error) in
                if let error = error{
                    print("Firebase error: \(error.localizedDescription)")
                }
                
                guard let snapshot = snapshot else{
                    return
                }
                
                self.lastApplicationDocument = snapshot.documents.count == Constants.APPLICATOINS_PAGINATION ? snapshot.documents.last : nil
                
                let myGroup = DispatchGroup()
                
                var applications = [Application]()
                for document in snapshot.documents {
                    myGroup.enter()
                    
                    if let application = Mapper<Application>().map(JSON: document.data()){
                        application.id = document.documentID
                        
                        
                        BDManager.instance.getEmployeeWithEducationAndWorks(employeeId: application.authorId, completion: { (status, employee) in
                            if status == .Success{
                                application.employee = employee
                            }
                            
                            applications.append(application)
                            myGroup.leave()
                        })
                    }else{
                        myGroup.leave()
                    }
                }
                
                myGroup.notify(queue: .main) {
                    self.applications = applications
                }
        }
    }
    
    func getNextPageApplication(){
        guard let lastApplicationDocument = self.lastApplicationDocument else{
            return
        }
        
        CloudStoreRefManager.instance.applicationsReferance
            .whereField("vacancyId", isEqualTo: vacancy.id)
//            .whereField("status", isEqualTo:ApplicationStatus.Created.rawValue)
            .start(afterDocument: lastApplicationDocument)
            .limit(to: Constants.APPLICATOINS_PAGINATION)
            .getDocuments { (snapshot, error) in
                if let error = error{
                    print("Firebase error: \(error.localizedDescription)")
                }
                
                guard let snapshot = snapshot else{
                    return
                }
                
                self.lastApplicationDocument = snapshot.documents.count == Constants.APPLICATOINS_PAGINATION ? snapshot.documents.last : nil
                
                let myGroup = DispatchGroup()
                
                var applications = [Application]()
                for document in snapshot.documents {
                    myGroup.enter()
                    
                    if let application = Mapper<Application>().map(JSON: document.data()){
                        application.id = document.documentID
                        
                        
                        BDManager.instance.getEmployeeWithEducationAndWorks(employeeId: application.authorId, completion: { (status, employee) in
                            if status == .Success{
                                application.employee = employee
                            }
                            
                            applications.append(application)
                            myGroup.leave()
                        })
                    }else{
                        myGroup.leave()
                    }
                }
                
                myGroup.notify(queue: .main) {
                    self.applications = applications
                }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func undo(_ sender: Any) {
        kolodaView.revertAction()
        undoApplication = nil
    }
    
    @IBAction func back(_ sender: Any) {
        let vc = UIStoryboard(name: Constants.EMPLOYER_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "EmployerVacanciesVC")
        UIApplication.shared.keyWindow?.rootViewController = UINavigationController(rootViewController: vc)
    }
    
    
}

// MARK: KolodaViewDelegate

extension VacancyApplicationsVC: KolodaViewDelegate {
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        applications.removeAll()
        kolodaView.reloadData()
        
        lastApplicationDocument == nil ? getApplication() : getNextPageApplication()
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        self.setupBackButton()
        
        let vc = UIStoryboard(name: Constants.EMPLOYER_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "EmployeeDetailVC") as! EmployeeDetailVC
        vc.application = applications[index]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        self.undoApplication = applications[index]
    }
    
}

// MARK: KolodaViewDataSource

extension VacancyApplicationsVC: KolodaViewDataSource {
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return applications.count
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .default
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let employeeCardView = Bundle.main.loadNibNamed("EmployeeKolodaView", owner: self, options: nil)?[0] as! EmployeeKolodaView
        employeeCardView.delegate = self
        
        if index < applications.count{
            employeeCardView.setupWith(application: applications[index])
        }
        
        return employeeCardView
    }
}

extension VacancyApplicationsVC : EmployeeKolodaViewDelegate{
    func didSelectAccept(application: Application, view: EmployeeKolodaView) {
        
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
                view.showAcceptedSuccess()
                self.perform(#selector(self.swipeRight), with: nil, afterDelay: 1.0)
            })
    }
    
    func didSendMessage(application: Application, view: EmployeeKolodaView) {
        guard let user = Auth.auth().currentUser, let employee = application.employee else{
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
    
    func didSelectReject(application: Application, view: EmployeeKolodaView) {
        
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
                    view.showRejectedSuccess()
                    self.perform(#selector(self.swipeLeft), with: nil, afterDelay: 1.0)
                })
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func swipeRight(){
        self.kolodaView.swipe(.right)
    }
    
    @objc func swipeLeft(){
        self.kolodaView.swipe(.left)
    }
}


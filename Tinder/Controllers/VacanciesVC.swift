//
//  VacanciesVC.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 9/20/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit
import Koloda
import ObjectMapper
import Firebase
import PKHUD

class VacanciesVC: UIViewController {

    @IBOutlet weak var kolodaView: KolodaView!
    
    @IBOutlet weak var undoButton: UIButton!
    
    @IBOutlet weak var undoIcon: UIImageView!
    
    
    private var sphereIds = [String]()
    private var regionId: String?
    private var salaryStart = Constants.SALARY_START
    
    fileprivate var vacancies: [Vacancy] = []{
        didSet{
            kolodaView.reloadData()
        }
    }
    
    private var undoVacancy : Vacancy?{
        didSet{
            
            if let vacancy = undoVacancy, let employer = vacancy.employer {
                undoButton.sd_setImage(with: employer.getImageUrl(), for: .normal, placeholderImage: Constants.placeholder, completed: nil)
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
    
    fileprivate var lastVacancyDocument : DocumentSnapshot?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        kolodaView.dataSource = self
        kolodaView.delegate = self
        
        didChangeFilter()
    }
    
    func refresh(){
        vacancies.removeAll()
        kolodaView.reloadData()
        
        getVacancies()
    }
    
    func isSupportFilter(vacancy: Vacancy) -> Bool{
        if !self.sphereIds.isEmpty{
            if !self.sphereIds.contains(vacancy.sphereId){
                return false
            }
        }
        
        if let regionId = self.regionId{
            if let employer = vacancy.employer{
                if employer.regionId != regionId{
                    return false
                }
            }
        }
        
        if let salary = vacancy.salary, salary.id != SalaryType.Undefined.rawValue{
            return salary.start >= self.salaryStart
        }
        
        return true
    }
    
    func getVacancies(){
        CloudStoreRefManager.instance.vacanciesReferance
            .whereField("status", isEqualTo: VacancyStatus.Opened.rawValue)
            .order(by: "createdAt", descending: true)
            .limit(to: Constants.VACANCIES_PAGINATION)
            .getDocuments { (snapshot, error) in
                if let error = error{
                    print("Firebase error: \(error.localizedDescription)")
                }
                
                guard let snapshot = snapshot else{
                    return
                }
                
                self.lastVacancyDocument = snapshot.documents.count == Constants.VACANCIES_PAGINATION ? snapshot.documents.last : nil
                
                let myGroup = DispatchGroup()
                
                var vacancies = [Vacancy]()
                for document in snapshot.documents {
                    myGroup.enter()
                    
                    BDManager.instance.getVacancyWithApplication(vacancyId: document.documentID, completion: { (status, vacancy) in
                        
                        if status == .Success {
                            if self.isSupportFilter(vacancy: vacancy){
                                vacancies.append(vacancy)
                            }
                        }
                        
                        myGroup.leave()
                    })
                }
                
                myGroup.notify(queue: .main) {
                    self.vacancies = vacancies
                }
        }
    }
    
    func getNextPageVacancies(){
        guard let lastVacancyDocument = self.lastVacancyDocument else{
            return
        }
        
        CloudStoreRefManager.instance.vacanciesReferance
            .whereField("status", isEqualTo: VacancyStatus.Opened.rawValue)
            .order(by: "createdAt", descending: true)
            .start(afterDocument: lastVacancyDocument)
            .limit(to: Constants.VACANCIES_PAGINATION)
            .getDocuments { (snapshot, error) in
                if let error = error{
                    print("Firebase error: \(error.localizedDescription)")
                }
                
                guard let snapshot = snapshot else{
                    return
                }
                
                self.lastVacancyDocument = snapshot.documents.count == Constants.VACANCIES_PAGINATION ? snapshot.documents.last : nil
                
                let myGroup = DispatchGroup()
                
                var vacancies = [Vacancy]()
                for document in snapshot.documents {
                    myGroup.enter()
                    
                    BDManager.instance.getVacancyWithApplication(vacancyId: document.documentID, completion: { (status, vacancy) in
                        
                        if status == .Success {
                            if self.isSupportFilter(vacancy: vacancy){
                                vacancies.append(vacancy)
                            }
                        }
                        
                        myGroup.leave()
                    })
                }
                
                myGroup.notify(queue: .main) {
                    self.vacancies = vacancies
                }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        
        if vacancies.isEmpty{
            refresh()
        }
    }
    
    @IBAction func undo(_ sender: Any) {
        kolodaView.revertAction()
        undoVacancy = nil
    }
    
    @IBAction func showFilter(_ sender: Any) {
        setupBackButton()
        
        let vc = UIStoryboard(name: Constants.EMPLOYEE_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "VacancyFilterTVC") as! VacancyFilterTVC
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

// MARK: KolodaViewDelegate

extension VacanciesVC: KolodaViewDelegate {
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        vacancies.removeAll()
        kolodaView.reloadData()
        
        lastVacancyDocument == nil ? getVacancies() : getNextPageVacancies()
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        self.setupBackButton()
        let vc = UIStoryboard(name: Constants.EMPLOYEE_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "VacancyDetailVC") as! VacancyDetailVC
        vc.vacancy = vacancies[index]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        self.undoVacancy = vacancies[index]
    }
}

// MARK: KolodaViewDataSource

extension VacanciesVC: KolodaViewDataSource {
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return vacancies.count
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .default
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let vacancyCardView = Bundle.main.loadNibNamed("VacancyKolodaView", owner: self, options: nil)?[0] as! VacancyKolodaView
        vacancyCardView.delegate = self
        
        if index < vacancies.count{
            vacancyCardView.setupWith(vacancy: vacancies[index])
        }
        
        return vacancyCardView
    }
}

extension VacanciesVC : VacancyKolodaViewDelegate{
    func didSelectApply(vacancy: Vacancy, view: VacancyKolodaView) {
        
        guard let user = Auth.auth().currentUser, let employer = vacancy.employer, let sphere = vacancy.sphere else{
            return
        }
        
        HUD.show(.progress)
        
        CloudStoreRefManager.instance.applicationsReferance
            .whereField("authorId", isEqualTo: user.uid)
            .whereField("vacancyId", isEqualTo: vacancy.id)
            .whereField("employerId", isEqualTo: employer.id)
            .whereField("status", isEqualTo: ApplicationStatus.Created.rawValue)
            .getDocuments { (snapshot, error) in
                if let error = error{
                    HUD.hide()
                    print("Firebase error: \(error.localizedDescription)")
                    return
                }
                
                if let snapshot = snapshot{
                    if snapshot.documents.isEmpty{
                        
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
                                view.showSuccess()
                                self.perform(#selector(self.swipeRight), with: nil, afterDelay: 1.0)
                            })
                    }else{
                        let applicationId = snapshot.documents.first!.documentID
                        
                        let params = [
                            "id" : applicationId,
                            "updatedAt" : Timestamp(),
                            "status" : ApplicationStatus.Created.rawValue
                            ] as [String : Any]
                        
                        CloudStoreRefManager.instance.applicationsReferance
                            .document(applicationId)
                            .setData(params, merge: true, completion: { (error) in
                                if let error = error{
                                    print("Firebase error: \(error.localizedDescription)")
                                    return
                                }
                                
                                HUD.hide()
                                view.showSuccess()
                                self.perform(#selector(self.swipeRight), with: nil, afterDelay: 1.0)
                            })
                    }
                }
        }
    }
    
    @objc func swipeRight(){
        self.kolodaView.swipe(.right)
    }
    
    func didSendMessage(vacancy: Vacancy) {
        
        guard let user = Auth.auth().currentUser, let employer = vacancy.employer else{
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
    
    func didSelectSkip(vacancy: Vacancy) {
        kolodaView.swipe(.left)
    }
}

extension VacanciesVC : VacancyFilterTVCDelegate{
    func didChangeFilter() {
        if let sphereIds = UserDefaults.standard.value(forKey: Constants.FILTER_SELECTED_SPHERE_IDS) as? [String]{
            self.sphereIds = sphereIds
        }
        
        if let regionId = UserDefaults.standard.value(forKey: Constants.FILTER_SELECTED_REGION_ID) as? String{
            self.regionId = regionId
        }else{
            self.regionId = nil
        }
        
        if let salaryStart = UserDefaults.standard.value(forKey: Constants.FILTER_SELECTED_SALARY_START) as? Int{
            self.salaryStart = salaryStart
        }
        
        refresh()
    }
}

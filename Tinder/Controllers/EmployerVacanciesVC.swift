//
//  EmployerVacanciesVC.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 9/25/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit
import FirebaseAuth
import ObjectMapper

class EmployerVacanciesVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var settingsButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var companyLogoImageView: UIImageView!
    @IBOutlet weak var companyNameLabel: UILabel!
    
    private var headerView: UIView!
    private var tableHeaderHeight: CGFloat = 200.0
    
    private var employer : Employer?{
        didSet{
            guard let employer = employer else {
                return
            }
            
            companyNameLabel.text = employer.name
            companyLogoImageView.sd_setImage(with: employer.getImageUrl(), placeholderImage: Constants.placeholder, completed: nil)
        }
    }
    
    private var currentVacanciesListStatus: VacancyType = .Active{
        didSet{
            tableView.reloadData()
        }
    }
    
    private var activeVacancies = [Vacancy](){
        didSet{
            tableView.reloadData()
        }
    }
    private var closedVacancies = [Vacancy](){
        didSet{
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        APNsManager.instance.setupTokens()
        
        setupHeaderView()
        registerXib()
        
        if UIScreen.main.bounds.size.height >= Constants.iPhoneXSize{
            settingsButtonTopConstraint.constant = 45
        }else if UIScreen.main.bounds.size.height == Constants.iPhone6sPlusSize{
            settingsButtonTopConstraint.constant = 50
        }else if UIScreen.main.bounds.size.height == Constants.iPhone6sSize{
            settingsButtonTopConstraint.constant = 55
        }else{
            settingsButtonTopConstraint.constant = 50
        }
        
        
        tableView.dataSource = self
        tableView.delegate = self
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user == nil{
                self.showLoginScreen()
                return
            }
        }
        
        getEmployer()
        getActiveVacancies()
        getClosedVacancies()
    }
    
    func getActiveVacancies(){
        guard let user = Auth.auth().currentUser else{
            return
        }
        
        CloudStoreRefManager.instance.vacanciesReferance
            .whereField("creatorId", isEqualTo: user.uid)
            .whereField("status", isEqualTo: VacancyStatus.Opened.rawValue)
            .addSnapshotListener { (querySnapshot, error) in
                
                if let error = error {
                    print("Firebase error: \(error.localizedDescription)")
                }
                
                guard let snapshot = querySnapshot else {
                    return
                }
                
                let myGroup = DispatchGroup()
                
                var vacancies = [Vacancy]()
                for document in snapshot.documents {
                    myGroup.enter()
                    
                    if let vacancy = Mapper<Vacancy>().map(JSON: document.data()){
                        vacancy.id = document.documentID
                        
                        CloudStoreRefManager.instance.spheresReferance
                            .document(vacancy.sphereId)
                            .getDocument(completion: { (sphereSnapshot, error) in
                                guard let snapshot = sphereSnapshot else {
                                    myGroup.leave()
                                    return
                                }
                                
                                if let sphereJson = snapshot.data(), let sphere = Mapper<Sphere>().map(JSON: sphereJson){
                                    sphere.id = vacancy.sphereId
                                    vacancy.sphere = sphere
                                }
                                
                                vacancies.append(vacancy)
                                myGroup.leave()
                            })
                        
                    }else{
                        myGroup.leave()
                    }
                }
                
                myGroup.notify(queue: .main) {
                    self.activeVacancies = vacancies
                }
        }
    }
    
    func getClosedVacancies(){
        guard let user = Auth.auth().currentUser else{
            return
        }
        
        CloudStoreRefManager.instance.vacanciesReferance
            .whereField("creatorId", isEqualTo: user.uid)
            .whereField("status", isEqualTo: VacancyStatus.Closed.rawValue)
            .addSnapshotListener { (querySnapshot, error) in
                
                if let error = error {
                    print("Firebase error: \(error.localizedDescription)")
                }
                
                guard let snapshot = querySnapshot else {
                    return
                }
                
                let myGroup = DispatchGroup()
                
                var vacancies = [Vacancy]()
                for document in snapshot.documents {
                    myGroup.enter()
                    
                    if let vacancy = Mapper<Vacancy>().map(JSON: document.data()){
                        vacancy.id = document.documentID
                        
                        CloudStoreRefManager.instance.spheresReferance
                            .document(vacancy.sphereId)
                            .getDocument(completion: { (sphereSnapshot, error) in
                                guard let snapshot = sphereSnapshot else {
                                    myGroup.leave()
                                    return
                                }
                                
                                if let sphereJson = snapshot.data(), let sphere = Mapper<Sphere>().map(JSON: sphereJson){
                                    sphere.id = vacancy.sphereId
                                    vacancy.sphere = sphere
                                }
                                
                                vacancies.append(vacancy)
                                myGroup.leave()
                            })
                        
                    }else{
                        myGroup.leave()
                    }
                }
                
                myGroup.notify(queue: .main) {
                     self.closedVacancies = vacancies
                }
                
               
        }
    }
    
    func getEmployer(){
        guard let user = Auth.auth().currentUser else{
            return
        }
        
        CloudStoreRefManager.instance.employersReferance
            .document(user.uid)
            .getDocument { (snapshot, error) in
                if let error = error{
                    print("error: \(error.localizedDescription)")
                }
                
                if let snapshot = snapshot, let data = snapshot.data(), let employer = Mapper<Employer>().map(JSON: data){
                    
                    employer.id = snapshot.documentID
                    self.employer = employer
                }
        }
    }
    
    func showLoginScreen(){
        UIApplication.shared.keyWindow?.rootViewController = UIStoryboard.init(name: Constants.LOGIN_STORYBOARD, bundle: nil).instantiateInitialViewController()
    }
    
    func setupHeaderView(){
        headerView = tableView.tableHeaderView
        tableView.tableHeaderView = nil
        tableView.addSubview(headerView)
        tableView.contentInset = UIEdgeInsets(top: tableHeaderHeight, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -tableHeaderHeight)
        tableView.estimatedRowHeight = 230
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
    }
    
    func registerXib(){
        self.tableView.register(CompanyVacancyCell.nib, forCellReuseIdentifier: CompanyVacancyCell.identifier)
        self.tableView.register(CompanyVacanciesHeaderTVCell.nib, forHeaderFooterViewReuseIdentifier: CompanyVacanciesHeaderTVCell.identifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        tableView.layoutIfNeeded()
    }
    
    func updateHeaderView(){
        var headerRect = CGRect(x: 0, y: -tableHeaderHeight, width: tableView.bounds.width, height: tableHeaderHeight)
        if tableView.contentOffset.y < -tableHeaderHeight{
            headerRect.origin.y = tableView.contentOffset.y
            headerRect.size.height = -tableView.contentOffset.y
        }
        
        headerView.frame = headerRect
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateHeaderView()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentVacanciesListStatus == .Active ? activeVacancies.count : closedVacancies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CompanyVacancyCell.identifier) as! CompanyVacancyCell
        cell.delegate = self
        
        let vacancy = currentVacanciesListStatus == .Active ? activeVacancies[indexPath.row] : closedVacancies[indexPath.row]
        cell.setupWith(vacancy: vacancy)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = UIStoryboard(name: Constants.EMPLOYER_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "EmployerTBC") as! EmployerTBC
        vc.vacancy = currentVacanciesListStatus == .Active ? activeVacancies[indexPath.row] : closedVacancies[indexPath.row]
        UIApplication.shared.keyWindow?.rootViewController = vc
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: CompanyVacanciesHeaderTVCell.identifier) as! CompanyVacanciesHeaderTVCell
        header.delegate = self
        
        return header
    }
    
    @IBAction func showProfile(_ sender: Any) {
        setupBackButton()
        
        if let employer = self.employer{
            let vc = UIStoryboard(name: Constants.EMPLOYEE_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "AboutCompanyVC") as! AboutCompanyVC
            vc.employerId = employer.id
                self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    @IBAction func createVacancy(_ sender: Any) {
        setupBackButton()
        
        let vc = UIStoryboard(name: Constants.EMPLOYER_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "CreateVacancyTVC")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func openSettings(_ sender: Any) {
        setupBackButton()
        
        let vc = UIStoryboard(name: Constants.SETTINGS_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "SettingsTVC") as! SettingsTVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension EmployerVacanciesVC : CompanyVacanciesHeaderTVCellDelegate{
    func didChangeState(state: VacancyType) {
        currentVacanciesListStatus = state
    }
}

extension EmployerVacanciesVC : CompanyVacancyCellDelegate{
    func showMenu(vacancy: Vacancy) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Редактировать", style: .default, handler: { aciton in
            self.setupBackButton()
            
            let vc = UIStoryboard(name: Constants.EMPLOYER_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "CreateVacancyTVC") as! CreateVacancyTVC
            vc.vacancy = vacancy
            self.navigationController?.pushViewController(vc, animated: true)
        }))
        alert.addAction(UIAlertAction(title: vacancy.status == VacancyStatus.Opened.rawValue ? "Закрыть вакансию" : "Открыть вакансию", style: .default, handler: { aciton in
            
            let newStatus = vacancy.status == VacancyStatus.Opened.rawValue ? VacancyStatus.Closed.rawValue : VacancyStatus.Opened.rawValue
            
            CloudStoreRefManager.instance.vacanciesReferance
                .document(vacancy.id)
                .setData(["status": newStatus], merge: true, completion: { (error) in
                    if let error = error{
                        print("Firebase error: \(error.localizedDescription)")
                        return
                    }
                    
                    if self.currentVacanciesListStatus == .Active{
                        self.getActiveVacancies()
                    }else{
                        self.getClosedVacancies()
                    }
                })
            
        }))
        
        alert.view.tintColor = UIColor(hex: 0x25324C)
        
        present(alert, animated: true, completion: nil)
    }
}


//
//  ProfileVC.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 9/15/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit
import FirebaseAuth
import ObjectMapper
import PKHUD

class ApplicationsTVC: UITableViewController {
    @IBOutlet weak var settingsButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    private var headerView: UIView!
    private var tableHeaderHeight: CGFloat = 200.0
    
    private var employee: Employee?{
        didSet{
            if let employee = employee{
                profileImageView.sd_setImage(with: employee.getImageUrl(), placeholderImage: Constants.placeholder, completed: nil)
                nameLabel.text = employee.name
            }
        }
    }
    
    private var groups = [ApplicationGroup]()
    
    private var applications = [Application](){
        didSet{
            groups.removeAll()
            
            for application in applications{
                let group = ApplicationGroup(date: application.createdAt.dateValue(), application: application)
                
                if let section = self.groups.index(where: {$0 == group}){
                    self.groups[section].addApplication(application: application)
                }else{
                    self.groups.append(group)
                    
                    self.groups.sort { (group1, group2) -> Bool in
                        return group1.date.compare(group2.date) == .orderedAscending
                    }
                }
            }
            
            self.tableView.reloadData()
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
            settingsButtonTopConstraint.constant = 35
        }else if UIScreen.main.bounds.size.height == Constants.iPhone6sSize{
            settingsButtonTopConstraint.constant = 30
        }else{
            settingsButtonTopConstraint.constant = 25
        }
        
        getProfile()
        getApplications()
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
    
    func getApplications(){
        guard let user = Auth.auth().currentUser else{
            return
        }
        
        CloudStoreRefManager.instance.applicationsReferance
            .whereField("authorId", isEqualTo: user.uid)
            .addSnapshotListener { (querySnapshot, error) in
                
                if let error = error {
                    print("Firebase error: \(error.localizedDescription)")
                }
                
                guard let snapshot = querySnapshot else {
                    return
                }
                
                let myGroup = DispatchGroup()
                
                var applications = [Application]()
                for document in snapshot.documents {
                    myGroup.enter()
                    
                    BDManager.instance.getApplication(applicationId: document.documentID, completion: { (status, application) in
                        switch status{
                        case .Success:
                            applications.append(application)
                            break
                        case .Failed:
                            break
                        }
                        
                        myGroup.leave()
                    })
                }
                
                myGroup.notify(queue: .main) {
                    self.applications = applications
                }
        }
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
        self.tableView.register(ApplicationCell.nib, forCellReuseIdentifier: ApplicationCell.identifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        getProfile()
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
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateHeaderView()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return groups.count + 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 0
        default:
            return groups[section-1].applications.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ApplicationCell.identifier) as! ApplicationCell
        
        cell.setupWith(application: groups[indexPath.section - 1].applications[indexPath.row])
        cell.delegate = self
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 40 : 40
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.setupBackButton()
        let vc = UIStoryboard(name: Constants.EMPLOYEE_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "VacancyDetailVC") as! VacancyDetailVC
        vc.vacancy = applications[indexPath.row].vacancy
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 40))
        let label = UILabel(frame: CGRect(x: 20, y: 0, width: headerView.frame.width - 20, height: headerView.frame.height))
        headerView.backgroundColor = UIColor.clear
        label.backgroundColor = headerView.backgroundColor
        
        switch section {
        case 0:
            label.font = UIFont(name: "Raleway-Black", size: 24.0)
            label.text = "Заявки"
            label.textColor = UIColor(hex: 0x25324C)
        default:
            let group = groups[section-1]
            label.font = UIFont(name: "Raleway-Regular", size: 13.0)
            label.text = group.date.toDayString()
            label.textColor = UIColor(hex: 0x778091)
        }
        
        headerView.addSubview(label)
        
        return headerView
    }
    
    @IBAction func showProfile(_ sender: Any) {
        setupBackButton()
        
        let vc = UIStoryboard(name: Constants.EMPLOYEE_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "EmployeeProfileVC") as! EmployeeProfileVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func openSettings(_ sender: Any) {
        setupBackButton()
        
        let vc = UIStoryboard(name: Constants.SETTINGS_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "SettingsTVC") as! SettingsTVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension ApplicationsTVC : ApplicationCellDelegate{
    func showMenu(application: Application) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive, handler: { aciton in
            
            HUD.show(.progress)
            
            CloudStoreRefManager.instance.applicationsReferance
                .document(application.id)
                .delete(completion: { (error) in
                    HUD.hide()
                    
                    if let error = error{
                        print("Firebase error: \(error.localizedDescription)")
                    }
                })
            
        }))
        
        alert.view.tintColor = UIColor(hex: 0x25324C)
        
        present(alert, animated: true, completion: nil)
    }
}


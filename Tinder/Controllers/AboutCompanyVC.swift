//
//  AboutCompanyVC.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 9/24/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit
import ObjectMapper
import FirebaseAuth

class AboutCompanyVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendMessageButton: UIButton!
    
    private var employer: Employer?{
        didSet{
            if employer != nil{
                tableView.reloadData()
            }
        }
    }
    var employerId:String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        
        tableView.tableFooterView = UIView(frame: .zero)
        registerXib()
        
        getEmployer()
        
        if let user = Auth.auth().currentUser{
            if employerId == user.uid{
                sendMessageButton.setImage(UIImage(named: "ic_edit_company"), for: .normal)
            }else{
                sendMessageButton.setImage(UIImage(named: "ic_send_message"), for: .normal)
            }
        }
    }
    
    func getEmployer(){
        guard !employerId.isEmpty else{
            return
        }
        
        CloudStoreRefManager.instance.employersReferance
            .document(employerId)
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
    
    func registerXib(){
        self.tableView.register(AboutCompanyTVCell.nib, forCellReuseIdentifier: AboutCompanyTVCell.identifier)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        setupBackButton()
        
        if let user = Auth.auth().currentUser{
            if employerId == user.uid{
                let vc = UIStoryboard(name: Constants.EMPLOYER_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "CreateCompanyTVC") as! CreateCompanyTVC
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

extension AboutCompanyVC : UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AboutCompanyTVCell.identifier, for: indexPath) as! AboutCompanyTVCell
        
        if let employer = self.employer{
            cell.setupWith(employer: employer)
        }
        
        return cell
    }
}


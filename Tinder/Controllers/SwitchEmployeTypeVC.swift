//
//  SwitchEmployeTypeVC.swift
//  Tinder
//
//  Created by Avaz on 15/09/2018.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit
import FirebaseAuth

enum EmployeeType : String{
    case Employee = "employee"
    case Employer = "employer"
}

class SwitchEmployeTypeVC: UIViewController {

    static func newInstance() -> SwitchEmployeTypeVC{
        return UIStoryboard(name: Constants.LOGIN_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "SwitchEmployeTypeVC") as! SwitchEmployeTypeVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }

    
    @IBAction func chooseEmployee(_ sender: UIButton) {
        
        guard let user = Auth.auth().currentUser else{
            return
            
        }
        
        CloudStoreRefManager.instance.usersReferance
            .document(user.uid)
            .setData(["role" : EmployeeType.Employee.rawValue]) { (error) in
                if let error = error{
                    self.showAlertWithMessage(message: error.localizedDescription)
                }else{
        UIApplication.shared.keyWindow?.rootViewController = UIStoryboard.init(name: Constants.EMPLOYEE_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "EmployeeTBC")
                }
        }
    }
    
    @IBAction func chooseEmployer(_ sender: UIButton) {
        
        guard let user = Auth.auth().currentUser else{
            return
            
        }
        
        CloudStoreRefManager.instance.usersReferance
            .document(user.uid)
            .setData(["role" : EmployeeType.Employer.rawValue]) { (error) in
                if let error = error{
                    self.showAlertWithMessage(message: error.localizedDescription)
                }else{
                    let vc = UIStoryboard.init(name: Constants.EMPLOYER_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "EmployerVacanciesVC") as! EmployerVacanciesVC
                    UIApplication.shared.keyWindow?.rootViewController = UINavigationController(rootViewController: vc)
                }
        }
    }
}

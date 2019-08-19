//
//  ViewController.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 9/10/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit
import FirebaseAuth

class SplashVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        
        if let user = Auth.auth().currentUser{
            
            print("current user: \(user.uid)")
            
            CloudStoreRefManager.instance.usersReferance
                .document(user.uid)
                .getDocument { (snapshot, error) in
                    if let error = error{
                        print("Firebase error: \(error.localizedDescription)")
                    }
                    
                    if let data = snapshot?.data(), let role = data["role"] as? String{
                        if role == EmployeeType.Employee.rawValue{
                            
                            BDManager.instance.getEmployee(employeeId: user.uid, completion: { (status, employee) in
                                
                                if status == .Failed{
                                    UIApplication.shared.keyWindow?.rootViewController = UINavigationController(rootViewController: SignupInfoTVC.newInstance())
                                    return
                                }
                                
                                if status == .Success{
                                    if employee.name.isEmpty{
                                        UIApplication.shared.keyWindow?.rootViewController = UINavigationController(rootViewController: SignupInfoTVC.newInstance())
                                        return
                                    }
                                }
                                
                                UIApplication.shared.keyWindow?.rootViewController = UIStoryboard.init(name: Constants.EMPLOYEE_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "EmployeeTBC")
                            })
                        }else{
                            
                            BDManager.instance.getEmployer(employerId: user.uid, completion: { (status, employer) in
                                if status == .Failed{
                                    let vc = UIStoryboard.init(name: Constants.EMPLOYER_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "CreateCompanyTVC")
                                    UIApplication.shared.keyWindow?.rootViewController = UINavigationController(rootViewController: vc)
                                    return
                                }
                                
                                if status == .Success{
                                    if employer.name.isEmpty{
                                        let vc = UIStoryboard.init(name: Constants.EMPLOYER_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "CreateCompanyTVC")
                                        UIApplication.shared.keyWindow?.rootViewController = UINavigationController(rootViewController: vc)
                                        return
                                    }
                                }
                                
                                let vc = UIStoryboard.init(name: Constants.EMPLOYER_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "EmployerVacanciesVC")
                                UIApplication.shared.keyWindow?.rootViewController = UINavigationController(rootViewController: vc)
                            })
                        }
                    }else{
                        UIApplication.shared.keyWindow?.rootViewController = UINavigationController(rootViewController: SwitchEmployeTypeVC.newInstance())
                    }
            }
            
        }else{
            UIApplication.shared.keyWindow?.rootViewController = UIStoryboard.init(name: Constants.LOGIN_STORYBOARD, bundle: nil).instantiateInitialViewController()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


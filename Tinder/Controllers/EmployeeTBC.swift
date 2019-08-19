//
//  MainTBC.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 9/15/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit
import FirebaseAuth

class EmployeeTBC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user == nil{
                self.showLoginScreen()
                return
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showLoginScreen(){
        UIApplication.shared.keyWindow?.rootViewController = UIStoryboard.init(name: Constants.LOGIN_STORYBOARD, bundle: nil).instantiateInitialViewController()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

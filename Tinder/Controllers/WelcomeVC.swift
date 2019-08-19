//
//  WelcomeVC.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 9/11/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit

class WelcomeVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func next(_ sender: Any) {
        setupBackButton()
        
        let vc = UIStoryboard(name: Constants.LOGIN_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        self.navigationController?.pushViewController(vc, animated: true)
//        self.navigationController?.pushViewController(SignupInfoTVC.newInstance(), animated: true)
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

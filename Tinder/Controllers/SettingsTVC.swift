//
//  SettingsTVC.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 9/16/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit
import FirebaseAuth

class SettingsTVC: UITableViewController {

    @IBOutlet weak var messageSwitch: UISwitch!
    
    @IBOutlet weak var applicationSwitch: UISwitch!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView(frame: .zero)
        updateSettings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? CGFloat.leastNormalMagnitude : 10
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard indexPath.section == 1 else {
            return
        }
        
        switch indexPath.row {
        case 0:
            userAgreements()
            break
        case 1:
            aboutApp()
            break
        case 2:
            logout()
            break
        default:
            break
        }
    }
    
    func updateSettings(){
        if let user = Auth.auth().currentUser{
            CloudStoreRefManager.instance.usersReferance
                .document(user.uid)
                .getDocument(completion: { (snapshot, error) in
                    if let snapshot = snapshot, let json = snapshot.data(){
                        if let messageNotificationsEnable = json["message_notifications"] as? Bool{
                            self.messageSwitch.isOn = messageNotificationsEnable
                        }
                        
                        if let applicationNotificationsEnable = json["application_notifications"] as? Bool{
                            self.applicationSwitch.isOn = applicationNotificationsEnable
                        }
                    }
                })
            
        }
    }
    
    func aboutApp() {
        setupBackButton()
        
        let vc = UIStoryboard(name: Constants.SETTINGS_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "AboutAppTVC") as! AboutAppTVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func userAgreements() {
        setupBackButton()
        
        let vc = UIStoryboard(name: Constants.SETTINGS_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "UserAgreementsTVC") as! UserAgreementsTVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func messageNotificationsChanged(_ sender: UISwitch) {
        
        if let user = Auth.auth().currentUser{
            CloudStoreRefManager.instance.usersReferance
                .document(user.uid)
                .setData(["message_notifications": sender.isOn], merge: true)
            
            updateSettings()
        }
    }
    
    
    @IBAction func applicationNotificationsChanged(_ sender: UISwitch) {
        if let user = Auth.auth().currentUser{
            CloudStoreRefManager.instance.usersReferance
                .document(user.uid)
                .setData(["application_notifications": sender.isOn], merge: true)
            
            updateSettings()
        }
    }
    
    func logout() {
        let alert = UIAlertController(title: "Вы действительно хотите выйти?", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Отмена", style: UIAlertActionStyle.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Да", style: .destructive, handler: { (alert) in
            let firebaseAuth = Auth.auth()
            do {
                APNsManager.instance.removeToken()
                try firebaseAuth.signOut()
            } catch let signOutError as NSError {
                self.showAlertWithMessage(message: signOutError.localizedDescription)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

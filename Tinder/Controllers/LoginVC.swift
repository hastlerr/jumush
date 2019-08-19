//
//  LoginVC.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 9/13/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit
import AKMaskField
import FirebaseAuth
import PKHUD

class LoginVC: UIViewController {

    @IBOutlet weak var selectCountryButton: UIButton!
    @IBOutlet weak var phoneNumberTextField: AKMaskField!
    @IBOutlet weak var nextButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.phoneNumberTextField.setMask("{ddd} {dddddd}", withMaskTemplate: "*** ******")
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    @objc func hideKeyboard(){
        phoneNumberTextField.resignFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.phoneNumberTextField.becomeFirstResponder()
        self.navigationController?.isNavigationBarHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func next(_ sender: Any) {
        guard let text = phoneNumberTextField.text, phoneNumberTextField.maskStatus == .complete else{
            phoneNumberTextField.shake()
            return
        }
        
        let phoneNumber = selectCountryButton.title(for: .normal)! + text.onlyDecimalCharacters()
        
        HUD.show(.progress)
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationId, error) in
            HUD.hide()
            
            if let error = error {
                self.showAlertWithMessage(message: error.localizedDescription)
                return
            }
            
            if let verificationId = verificationId {
                self.setupBackButton()
                
                let vc = UIStoryboard(name: Constants.LOGIN_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "CodeConfirmationVC") as! CodeConfirmationVC
                vc.verificationId = verificationId
                vc.phoneNumber = phoneNumber
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func selectCountry(_ sender: Any) {
        let vc = UIStoryboard(name: Constants.LOGIN_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "CountriesTVC") as! CountriesTVC
        vc.delegate = self
        let navController: UINavigationController = UINavigationController(rootViewController: vc)
        present(navController, animated: true, completion: nil)
    }
}

extension LoginVC : CountriesDelegate{
    func didChooseCountry(country: Country) {        
        if country.mask.count > 0{
            var maskString = ""
            var mask = ""
            var temp = ""
            var maskArray = [String]()
            var maskCount = [String]()
            
            for character in country.mask{
                maskString.append(character)
                var char = character
                if char != " "{
                    char = "d"
                    mask.append(char.description)
                    if country.mask.count == maskString.count{
                        maskArray.append(mask)
                    }
                }else{
                    maskArray.append(mask)
                    mask.removeAll()
                }
            }
            
            for mask in maskArray{
                maskCount.append(mask)
                if maskArray.count != maskCount.count{
                    temp += "{\(mask)} "
                }else{
                    temp += "{\(mask)}"
                }
            }
            let replacedString = maskString.replacingOccurrences(of: "X", with: "*", options: .literal, range: nil)
            
            self.phoneNumberTextField.setMask(temp, withMaskTemplate: "\(replacedString)")
        }else{
            self.phoneNumberTextField.setMask("{ddd} {dddddd}", withMaskTemplate: "*** ******")
        }
        
        self.selectCountryButton.setTitle("+" + country.isoNumber, for: .normal)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        HUD.hide()
    }
}

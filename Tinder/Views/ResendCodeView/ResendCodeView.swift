//
//  ResendCodeView.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 10/24/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit
import FirebaseAuth

protocol ResendCodeViewDelegate {
    func didUpdateVerificationId(verificationId: String)
}

class ResendCodeView: UIView {

    @IBOutlet weak var timeLeftLabel: UILabel!
    
    @IBOutlet weak var resendCodeLabel: UILabel!
    
    @IBOutlet weak var resendButton: UIButton!
    
    private var phoneNumber = ""
    private var timer = Timer()
    private var secondsCounter = 30
    private var resendCount = 1
    
    var delegate :ResendCodeViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupWith(phoneNumber: String){
        self.phoneNumber = phoneNumber
    }

    @IBAction func resendCode(_ sender: UIButton) {
        sender.isHidden = true
        self.resendCodeLabel.isHidden = false
        self.timeLeftLabel.isHidden = false
        
        PhoneAuthProvider.provider().verifyPhoneNumber(self.phoneNumber, uiDelegate: nil) { (verificationId, error) in
            if let error = error {
                print("error: \(error.localizedDescription)")
                return
            }

            if let verificationId = verificationId, let delegate = self.delegate{
                delegate.didUpdateVerificationId(verificationId: verificationId)
            }
        }
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
        secondsCounter = 30 * resendCount
        resendCount += 1
        updateTimer()
    }
    
    @objc func updateTimer() {
        
        let hours = Int(self.secondsCounter) / 3600
        let minutes = Int(self.secondsCounter) / 60 % 60
        let seconds = Int(self.secondsCounter) % 60
        
        //        print(String(format:"%02i:%02i:%02i", hours, minutes, seconds))
        
        if secondsCounter != 0{
            secondsCounter -= 1
            
            var leftTimeString = ""
            if hours > 0 {
                leftTimeString = String(format: "%.02ld:", hours)
            }
            
            self.timeLeftLabel.text = leftTimeString + String(format:"%02ld:%02ld",minutes,seconds)
            
        }else{
            timer.invalidate()
            
            self.resendButton.isHidden = false
            self.resendCodeLabel.isHidden = true
            self.timeLeftLabel.isHidden = true
        }
    }
}

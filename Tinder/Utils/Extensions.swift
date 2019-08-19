//
//  Extensions.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 9/10/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit
import Foundation
import FirebaseAuth

extension NSObject {
    var className: String {
        return String(describing: type(of: self)).components(separatedBy: ".").last!
    }
}

class TextField: UITextField {
    
    let padding = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
}

extension UITableViewCell{
    class var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    class var identifier: String {
        return String(describing: self)
    }
}

extension UITableViewHeaderFooterView{
    class var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    class var identifier: String {
        return String(describing: self)
    }
}

extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
        
    }
    
    func shake(count : Float? = nil,for duration : TimeInterval? = nil,withTranslation translation : Float? = nil) {
        let defaultRepeatCount: Float = 2.0
        let defaultTotalDuration = 0.15
        let defaultTranslation = -10
        
        let animation : CABasicAnimation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        animation.repeatCount = count ?? defaultRepeatCount
        animation.duration = (duration ?? defaultTotalDuration)/TimeInterval(animation.repeatCount)
        animation.autoreverses = true
        animation.byValue = translation ?? defaultTranslation
        layer.add(animation, forKey: "shake")
    }

}

extension UIViewController{
    
    func openChat(chatId : String){
        guard let user = Auth.auth().currentUser else{
            return
        }
        
        CloudStoreRefManager.instance.usersReferance
            .document(user.uid)
            .getDocument { (snapshot, error) in
                if let error = error{
                    print("Firebase error: \(error.localizedDescription)")
                }
                
                var isEmployer = true
                
                if let data = snapshot?.data(), let role = data["role"] as? String{
                    isEmployer = role == EmployeeType.Employer.rawValue
                }
                
                BDManager.instance.getChat(chatId: chatId) { (status, chat) in
                    if status == .Success{
                        let vc = UIStoryboard(name: Constants.EMPLOYEE_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
                        vc.chat = chat
                        vc.forEmployer = isEmployer

                        if self.view != nil{
                            if let navVC = self as? UINavigationController{
                                if let vc = navVC.viewControllers.last as? ChatVC{
                                    if let chat = vc.chat, chat.id != chatId{
                                        navVC.pushViewController(vc, animated: true)
                                    }
                                }else{
                                    navVC.pushViewController(vc, animated: true)
                                }
                            }else{
                                if let tabbar = self as? EmployerTBC{
                                    tabbar.selectedIndex = 2
                                    if let viewControllers = tabbar.viewControllers, let navVC = viewControllers.last as? UINavigationController {
                                        if let vc = navVC.viewControllers.last as? ChatVC{
                                            if let chat = vc.chat, chat.id != chatId{
                                                navVC.pushViewController(vc, animated: true)
                                            }
                                        }else{
                                            navVC.pushViewController(vc, animated: true)
                                        }
                                    }
                                }
                                
                                if let tabbar = self as? EmployeeTBC{
                                    tabbar.selectedIndex = 2
                                    if let viewControllers = tabbar.viewControllers, let navVC = viewControllers.last as? UINavigationController {
                                        if let vc = navVC.viewControllers.last as? ChatVC{
                                            if let chat = vc.chat, chat.id != chatId{
                                                navVC.pushViewController(vc, animated: true)
                                            }
                                        }else{
                                            navVC.pushViewController(vc, animated: true)
                                        }
                                    }
                                }
                                
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                        }
                    }
                }
        }
    }
    
    func setupNavigationBackButton(){
        if let nav = self.navigationController,let item = nav.navigationBar.topItem {
            item.backBarButtonItem  = UIBarButtonItem(title: "", style: .plain, target: nil, action:nil)
        } else {
            if let nav = self.navigationController,let backButton = nav.navigationBar.backItem {
                backButton.title = ""
            }
        }
    }
    
    func showAlertWithMessage(message:String){
        let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func setupBackButton(){
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
    }
}

extension UIColor{
    convenience init(red: Int, green: Int, blue: Int) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(hex: Int) {
        self.init(
            red: (hex >> 16) & 0xFF,
            green: (hex >> 8) & 0xFF,
            blue: hex & 0xFF
        )
    }
}


extension String{
    
    func onlyDecimalCharacters() -> String{
        return self.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression, range: nil)
    }
}


extension Date{
    
    func toDayString() ->String {
        if NSCalendar.current.isDateInYesterday(self) { return "Вчера" }
        else if NSCalendar.current.isDateInToday(self) { return "Сегодня" }
        else {
            let timePeriodFormatter = DateFormatter()
            timePeriodFormatter.locale = Locale(identifier: "RU")
            timePeriodFormatter.dateFormat = "d MMMM"
            return timePeriodFormatter.string(from: self)
        }
    }
    
    func toStringFormat(format: String) -> String{
        let dateFormatted = DateFormatter()
        dateFormatted.dateFormat = format
        dateFormatted.locale = Locale(identifier: "RU")
        
        return dateFormatted.string(from: self)
    }
    
    private var calendar: Calendar { return .current }
    
    private var components: DateComponents {
        let unitFlags = Set<Calendar.Component>([.second,.minute,.hour,.day,.weekOfYear,.month,.year])
        let now = Date()
        return calendar.dateComponents(unitFlags, from: self, to: now)
    }
    
    func isSameDate(date: Date) -> Bool{
        
        return Calendar.current.component(.year, from: self) == Calendar.current.component(.year, from: date) &&
            Calendar.current.component(.month, from: self) == Calendar.current.component(.month, from: date) &&
            Calendar.current.component(.day, from: self) == Calendar.current.component(.day, from: date)
    }
    
    public func timeAgo() -> String {
        
        if let year = components.year, year > 0 {
            return year >= 2 ? "\(year) г назад" : "Год назад"
        } else if let month = components.month, month > 0 {
            return month >= 2 ? "\(month) мес назад" : "Месяц назад"
        } else if let week = components.weekOfYear, week > 0 {
            return week >= 2 ? "\(week) нед назад" : "Неделю назад"
        } else if let day = components.day, day > 0 {
            return day >= 2 ? "\(day) дн назад" : "Вчера"
        } else if let hour = components.hour, hour > 0 {
            return hour >= 2 ? "\(hour) ч назад" : "Час назад"
        } else if let minute = components.minute, minute > 0 {
            return minute >= 2 ? "\(minute) мин назад" : "Минуту назад"
        } else if let second = components.second, second >= 2 {
            return "\(second) сек назад"
        }else{
            return "Сейчас"
        }
    }
}

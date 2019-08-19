//
//  Constants.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 9/13/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit

struct Constants {
    static let LOGIN_STORYBOARD = "Login"
    static let MAIN_STORYBOARD = "Main"
    static let SIGNUP_STORYBOARD = "SignUp"
    static let SETTINGS_STORYBOARD = "Settings"
    static let EMPLOYEE_STORYBOARD = "Employee"
    static let EMPLOYER_STORYBOARD = "Employer"
    
    static let iPhone5sSize: CGFloat = 568.0
    static let iPhone6sPlusSize: CGFloat = 736.0
    static let iPhoneXSize: CGFloat = 800.0
    static let iPhone6sSize: CGFloat = 667.0
    
    static let IMAGE_THUMBNAIL_QUALITY:CGFloat = 0.2
    
    static let EMPLPOYMENT_TYPES = ["Полная","Частичная","Стажировка","Временная","Удаленная"]
    static let SHEDULE_NAMES = ["Гибкий","Будни"]
    static let EDUCATION_TYPES = ["Высшее образование","Неполное высшее образование","Средне специальное образование","Среднее образование","Неполное среднее образование"]
    static let EDUCATION_TYPE_IDS = ["high_edu","nf_hight_edu","spec_edu","sec_edu","low_sec_edu"]
    
    static let SALARY_START = 5
    static let SALARY_END = 200
    
    static let VACANCIES_PAGINATION = 10
    static let APPLICATOINS_PAGINATION = 10
    
    static let FILTER_REGION_ALL_KG = "all_kg"
    
    static let FILTER_SELECTED_REGION_ID = "FILTER_SELECTED_REGION_ID"
    static let FILTER_SELECTED_SPHERE_IDS = "FILTER_SELECTED_SPHERE_IDS"
    static let FILTER_SELECTED_SALARY_START = "FILTER_SELECTED_SALARY_START"
    
    static let placeholder = UIImage(named: "ic_profile")


}

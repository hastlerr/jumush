//
//  CloudStoreRefManager.swift
//  NambaOne
//
//  Created by Ellan Esenaliev on 25.04.2018.
//  Copyright © 2018 Namba Soft OsOO. All rights reserved.
//

import Foundation
import FirebaseFirestore

enum Route : String{
    case Images = "images"
}

enum CloudRout: String {
    case spheres = "spheres"
    case employees = "employees"
    case employers = "employers"
    case regions = "regions"
    case applications = "applications"
    case users = "users"
    case vacancies = "vacancies"
    case educations = "educations"
    case works = "works"
    case chats = "chats"
    case messages = "messages"
    case devices = "devices"
}

class CloudStoreRefManager {
    
    static let instance = CloudStoreRefManager()
    
    let spheresReferance = Firestore.firestore().collection(CloudRout.spheres.rawValue)
    let usersReferance = Firestore.firestore().collection(CloudRout.users.rawValue)
    let regionsReferance = Firestore.firestore().collection(CloudRout.regions.rawValue)
    let employeesReferance = Firestore.firestore().collection(CloudRout.employees.rawValue)
    let employersReferance = Firestore.firestore().collection(CloudRout.employers.rawValue)
    let vacanciesReferance = Firestore.firestore().collection(CloudRout.vacancies.rawValue)
    let educationsReferance = Firestore.firestore().collection(CloudRout.educations.rawValue)
    let worksReferance = Firestore.firestore().collection(CloudRout.works.rawValue)
    let applicationsReferance = Firestore.firestore().collection(CloudRout.applications.rawValue)
    let chatsReferance = Firestore.firestore().collection(CloudRout.chats.rawValue)
    let messagesReferance = Firestore.firestore().collection(CloudRout.messages.rawValue)
}

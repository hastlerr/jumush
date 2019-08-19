//
//  Application.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 10/6/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit
import ObjectMapper
import Firebase

enum ApplicationStatus : String{
    case Rejected = "rejected"
    case Accepted = "accepted"
    case Created = "created"
}

class Application: NSObject,Mappable {
    var id : String = ""
    var authorId : String = ""
    var vacancyId : String = ""
    var employerId : String = ""
    var position: String = ""
    var status : String = ApplicationStatus.Created.rawValue
    var createdAt: Timestamp = Timestamp()
    var updatedAt: Timestamp = Timestamp()
    
    var vacancy : Vacancy?
    var employee : Employee?
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        id <- map["id"]
        authorId <- map["authorId"]
        vacancyId <- map["vacancyId"]
        employerId <- map["employerId"]
        position <- map["position"]
        status <- map["status"]
        createdAt <- map["createdAt"]
        updatedAt <- map["updatedAt"]
    }
}

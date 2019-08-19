//
//  Education.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 10/5/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit
import ObjectMapper
import Firebase

class Education: Mappable {
    var id : String = ""
    var name : String = ""
    var speciality : String = ""
    var startDate: Timestamp = Timestamp()
    var endDate: Timestamp = Timestamp()
    var type : String = Constants.EDUCATION_TYPE_IDS[0]
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        speciality <- map["speciality"]
        type <- map["description"]
        startDate <- map["startDate"]
        endDate <- map["endDate"]
    }
    
    func isFieldsValid() -> Bool{
        return !id.isEmpty && !name.isEmpty && !speciality.isEmpty && !type.isEmpty
    }
    
    func toCreateParams() -> [String: Any]{
        return [
            "id" : id,
            "name" : name,
            "speciality" : speciality,
            "startDate" : startDate,
            "endDate" : endDate,
            "type" : type
        ]
    }
}

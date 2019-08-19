//
//  Work.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 10/5/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit
import ObjectMapper
import Firebase

class Work: Mappable {
    var id : String = ""
    var company : String = ""
    var position : String = ""
    var startDate: Timestamp = Timestamp()
    var endDate: Timestamp = Timestamp()
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        company <- map["company"]
        position <- map["position"]
        startDate <- map["startDate"]
        endDate <- map["endDate"]
    }
    
    func isFieldsValid() -> Bool{
        return !id.isEmpty && !company.isEmpty && !position.isEmpty
    }
    
    func toCreateParams() -> [String: Any]{
        return [
            "id" : id,
            "company" : company,
            "position" : position,
            "startDate" : startDate,
            "endDate" : endDate
        ]
    }
}

//
//  Employer.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 10/1/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit
import ObjectMapper

class Employer: Mappable {
    var id : String = ""
    var name : String = ""
    var city : String = ""
    var region: Region?
    var regionId : String = ""
    var about : String = ""
    var imageUrl : String = ""
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        id <- map["id"]
        name <- map["name"]
        city <- map["city"]
        regionId <- map["regionId"]
        about <- map["about"]
        imageUrl <- map["image"]
    }
    
    func getImageUrl() -> URL?{
        return URL(string: imageUrl)
    }
}

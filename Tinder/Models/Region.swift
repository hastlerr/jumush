//
//  Region.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 10/1/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit
import ObjectMapper

class Region: Mappable {
    var id : String = ""
    var name : String = ""
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        id <- map["id"]
        name <- map["ru"]
    }
    
}

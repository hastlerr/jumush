//
//  Sphere.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 9/28/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit
import ObjectMapper

class Sphere: NSObject, Mappable {
    var id : String = ""
    var name : String = ""
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        id <- map["id"]
        name <- map["ru"]
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let sphere = object as? Sphere {
            return self.id == sphere.id
        } else {
            return false
        }
    }
}

//
//  Chat.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 10/8/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit
import ObjectMapper
import Firebase

class Chat: Mappable {
    var id : String = ""
    var name: String = ""
    var image : String = ""
    var users : [String] = []
    var vacancyId : String = ""
    var updatedAt : Timestamp = Timestamp()
    var lastMessage : Message?
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        vacancyId <- map["vacancyId"]
        users <- map["users"]
        updatedAt <- map["updatedAt"]
        lastMessage <- map["lastMessage"]
    }
    
    func getImageUrl() -> URL?{
        return URL(string: image)
    }
    
    func getPartnerId() -> String{
        guard let currentUser = Auth.auth().currentUser else {
            return ""
        }
        
        for userId in users{
            if userId != currentUser.uid{
                return userId
            }
        }
        
        return ""
    }
}

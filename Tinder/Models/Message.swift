//
//  Message.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 10/8/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit
import ObjectMapper
import Firebase

enum MessageStatus : String{
    case Read = "READ"
    case Sent = "SENT"
}

class Message: NSObject, Mappable {
    var id : String = ""
    var content: String = ""
    var from : String = ""
    var to : String = ""
    var status : String = MessageStatus.Sent.rawValue
    var createdAt : Timestamp = Timestamp()
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        content <- map["content"]
        status <- map["status"]
        createdAt <- map["createdAt"]
        from <- map["from"]
        to <- map["to"]
    }
    
    func isMyMessage() -> Bool{
        if let currentUser = Auth.auth().currentUser{
            return currentUser.uid == from
        }
        
        return false
    }
    
    func getTimeString() -> String{
        return createdAt.dateValue().toStringFormat(format: "HH:mm")
    }
    
    func toCreateParams() -> [String : Any]{
        return [
            "id" : id,
            "content" : content,
            "status" : status,
            "createdAt" : createdAt,
            "from" : from,
            "to" : to
        ]
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let message = object as? Message {
            return self.id == message.id
        } else {
            return false
        }
    }
}

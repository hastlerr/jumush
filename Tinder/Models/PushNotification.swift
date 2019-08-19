//
//  PushNotification.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 10/16/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit
import ObjectMapper

enum PushNotificationType : String{
    case NewMessage = "new/message"
    case Application = "new/app"
}

class PushNotification: Mappable {
    
    var notificationType: String = ""
    
    
    //chat
    var chatId: String = ""
    var applicationId: String = ""
    
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        self.notificationType   <- map["notificationType"]
        self.chatId     <- map["chatId"]
        self.applicationId     <- map["applicationId"]
    }
}

//
//  Group.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 10/10/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit

class Group: NSObject {
    var date = Date()
    var messages = [Message]()
    
    convenience init(date: Date, message: Message) {
        self.init()
        self.date = date
        self.messages = [message]
    }
    
    func addMessage(message: Message){
        
        if let index = messages.index(where: {$0.isEqual(message)}){
            messages[index] = message
        }else{
            messages.append(message)
        }
        
        messages.sort { (message, message1) -> Bool in
            return message.createdAt.dateValue() < message1.createdAt.dateValue()
        }
    }
    
    func editMessage(message: Message){
        
        if let index = messages.index(where: {$0.isEqual(message)}){
            messages[index] = message
        }
        
        messages.sort { (message, message1) -> Bool in
            return message.createdAt.dateValue() < message1.createdAt.dateValue()
        }
    }
    
    func deleteMessage(message: Message){
        
        if let index = messages.index(where: {$0.isEqual(message)}){
            messages.remove(at: index)
        }
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let group = object as? Group {
            return self.date.isSameDate(date: group.date)
        } else {
            return false
        }
    }
}


class ApplicationGroup: NSObject {
    var date = Date()
    var applications = [Application]()
    
    convenience init(date: Date, application: Application) {
        self.init()
        self.date = date
        self.applications = [application]
    }
    
    func addApplication(application: Application){
        
        if let index = applications.index(where: {$0.isEqual(application)}){
            applications[index] = application
        }else{
            applications.append(application)
        }
        
        applications.sort { (application, application1) -> Bool in
            return application.createdAt.dateValue() < application1.createdAt.dateValue()
        }
    }
    
    func editApplication(application: Application){
        
        if let index = applications.index(where: {$0.isEqual(application)}){
            applications[index] = application
        }
        
        applications.sort { (application, application1) -> Bool in
            return application.createdAt.dateValue() < application1.createdAt.dateValue()
        }
    }
    
    func deleteApplication(application: Application){
        
        if let index = applications.index(where: {$0.isEqual(application)}){
            applications.remove(at: index)
        }
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let group = object as? ApplicationGroup {
            return self.date.isSameDate(date: group.date)
        } else {
            return false
        }
    }
}

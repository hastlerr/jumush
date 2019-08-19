//
//  BDManager.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 10/6/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit
import ObjectMapper
import FirebaseAuth

enum TaskStatus{
    case Success
    case Failed
}

class BDManager {
    static let instance = BDManager()
    
    func getApplication(applicationId: String, completion: @escaping ((TaskStatus, _ application: Application) -> Swift.Void)){
        
        guard !applicationId.isEmpty else{
            completion(.Failed, Application())
            return
        }
        
        CloudStoreRefManager.instance.applicationsReferance
            .document(applicationId)
            .getDocument(completion: { (snapshot, error) in
                
                if let snapshot = snapshot, let json = snapshot.data(), let application = Mapper<Application>().map(JSON: json) {
                    application.id = applicationId
                    
                    self.getVacancy(vacancyId: application.vacancyId, completion: { (status, vacancy) in
                        switch status{
                        case .Success:
                            application.vacancy = vacancy
                            completion(.Success, application)
                            break
                        case .Failed:
                            completion(.Failed, Application())
                            break
                        }
                    })
                }else{
                    completion(.Failed, Application())
                }
            })
    }
    
    
    func getVacancy(vacancyId: String, completion: @escaping ((TaskStatus, _ vacancy: Vacancy) -> Swift.Void)){
        
        guard !vacancyId.isEmpty else{
            completion(.Failed, Vacancy())
            return
        }
        
        CloudStoreRefManager.instance.vacanciesReferance
            .document(vacancyId)
            .getDocument(completion: { (snapshot, error) in
                
                if let snapshot = snapshot, let json = snapshot.data(), let vacancy = Mapper<Vacancy>().map(JSON: json) {
                    vacancy.id = vacancyId
                    
                    self.getSphere(sphereId: vacancy.sphereId, completion: { (status, sphere) in
                        switch status{
                        case .Success:
                            vacancy.sphere = sphere
                            
                            self.getEmployer(employerId: vacancy.creatorId, completion: { (status, employer) in
                                switch status{
                                case .Success:
                                    vacancy.employer = employer
                                    completion(.Success, vacancy)
                                    break
                                case .Failed:
                                    completion(.Failed, vacancy)
                                    break
                                }
                            })
                            
                        case .Failed:
                            completion(.Failed, vacancy)
                        }
                    })
                }else{
                    completion(.Failed, Vacancy())
                }
            })
    }
    
    func getVacancyWithApplication(vacancyId: String, completion: @escaping ((TaskStatus, _ vacancy: Vacancy) -> Swift.Void)){
        
        getVacancy(vacancyId: vacancyId) { (status, vacancy) in
            switch status{
            case .Success:
                
                guard let employer = vacancy.employer else{
                    completion(.Failed, vacancy)
                    return
                }
                
                self.getApplication(vacancyId: vacancy.id, employerId: employer.id, completion: { (status, application) in
                    
                    switch status{
                    case .Success:
                        vacancy.application = application
                        break
                    case .Failed:
                        break
                    }
                    
                    completion(.Success, vacancy)
                })
                
                break
            case .Failed:
                completion(.Failed, vacancy)
                break
            }
        }
    }
    
    func getEmployeeWithEducationAndWorks(employeeId: String, completion: @escaping ((TaskStatus, _ employee: Employee) -> Swift.Void)){
        
        guard !employeeId.isEmpty else{
            completion(.Failed, Employee())
            return
        }
        
        getEmployee(employeeId: employeeId) { (status, employee) in
            
            CloudStoreRefManager.instance.employeesReferance
                .document(employeeId)
                .collection(CloudRout.educations.rawValue)
                .getDocuments(completion: { (educationsSnaphot, error) in
                    
                    if let educationsSnaphot = educationsSnaphot{
                        
                        var educations = [Education]()
                        
                        for item in educationsSnaphot.documents{
                            if let education = Mapper<Education>().map(JSON: item.data()){
                                education.id = item.documentID
                                educations.append(education)
                            }
                        }
                        
                        employee.educations = educations
                        
                        CloudStoreRefManager.instance.employeesReferance
                            .document(employeeId)
                            .collection(CloudRout.works.rawValue)
                            .getDocuments(completion: { (worksSnaphot, error) in
                                
                                if let worksSnaphot = worksSnaphot{
                                    
                                    var works = [Work]()
                                    
                                    for item in worksSnaphot.documents{
                                        if let work = Mapper<Work>().map(JSON: item.data()){
                                            work.id = item.documentID
                                            works.append(work)
                                        }
                                    }
                                    
                                    employee.works = works
                                    
                                }
                                
                                completion(.Success, employee)
                            })
                        
                    }else{
                        completion(.Success, employee)
                    }
                })
        }
    }
    
    func getSphere(sphereId: String, completion: @escaping ((TaskStatus, _ sphere: Sphere) -> Swift.Void)){
        
        guard !sphereId.isEmpty else{
            completion(.Failed, Sphere())
            return
        }
        
        CloudStoreRefManager.instance.spheresReferance
            .document(sphereId)
            .getDocument(completion: { (snapshot, error) in
                
                if let snapshot = snapshot, let json = snapshot.data(), let sphere = Mapper<Sphere>().map(JSON: json) {
                    sphere.id = sphereId
                    completion(.Success, sphere)
                }else{
                    completion(.Failed, Sphere())
                }
            })
    }
    
    func getChat(chatId: String, completion: @escaping ((TaskStatus, _ chat: Chat) -> Swift.Void)){
        
        guard let user = Auth.auth().currentUser, !chatId.isEmpty else{
            completion(.Failed, Chat())
            return
        }
        
        CloudStoreRefManager.instance.chatsReferance
            .document(chatId)
            .getDocument { (snapshot, error) in
                if let snapshot = snapshot, let json = snapshot.data(), let chat = Mapper<Chat>().map(JSON: json){
                    
                    for userId in chat.users{
                        if userId != user.uid{
                            
                            if let json = json[userId] as? [String : Any]{
                                if let chatName = json["name"] as? String{
                                    chat.name = chatName
                                }
                                
                                if let image = json["image"] as? String{
                                    chat.image = image
                                }
                            }
                            
                            break
                        }
                    }
                    
                    completion(.Success, chat)
                }else{
                    completion(.Failed, Chat())
                }
        }
    }
    
    func getEmployee(employeeId: String, completion: @escaping ((TaskStatus, _ employee: Employee) -> Swift.Void)){
        
        guard !employeeId.isEmpty else{
            completion(.Failed, Employee())
            return
        }
        
        CloudStoreRefManager.instance.employeesReferance
            .document(employeeId)
            .getDocument(completion: { (snapshot, error) in
                
                if let snapshot = snapshot, let json = snapshot.data(), let employee = Mapper<Employee>().map(JSON: json) {
                    employee.id = employeeId
                    completion(.Success, employee)
                }else{
                    completion(.Failed, Employee())
                }
            })
    }
    
    func getEmployer(employerId: String, completion: @escaping ((TaskStatus, _ employer: Employer) -> Swift.Void)){
        
        guard !employerId.isEmpty else{
            completion(.Failed, Employer())
            return
        }
        
        CloudStoreRefManager.instance.employersReferance
            .document(employerId)
            .getDocument(completion: { (snapshot, error) in
                
                if let snapshot = snapshot, let json = snapshot.data(), let employer = Mapper<Employer>().map(JSON: json) {
                    employer.id = employerId
                    completion(.Success, employer)
                }else{
                    completion(.Failed, Employer())
                }
            })
    }
    
    func getApplication(vacancyId: String, employerId: String, completion: @escaping ((TaskStatus, _ application: Application) -> Swift.Void)){
        
        guard let user = Auth.auth().currentUser, !vacancyId.isEmpty, !employerId.isEmpty else{
            completion(.Failed, Application())
            return
        }
        
        CloudStoreRefManager.instance.applicationsReferance
            .whereField("authorId", isEqualTo: user.uid)
            .whereField("vacancyId", isEqualTo: vacancyId)
            .whereField("employerId", isEqualTo: employerId)
            .getDocuments { (snapshot, error) in
                
                if let snapshot = snapshot{
                    if !snapshot.documents.isEmpty{
                        
                        self.getApplication(applicationId: snapshot.documents.first!.documentID, completion: { (status, application) in
                            switch status{
                            case .Success:
                                completion(.Success, application)
                                return
                            case .Failed:
                                completion(.Failed, Application())
                                return
                            }
                        })
                    }else{
                        completion(.Failed, Application())
                    }
                }else{
                    completion(.Failed, Application())
                }
                
                
        }
    }
}

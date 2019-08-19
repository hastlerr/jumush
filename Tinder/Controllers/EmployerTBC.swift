//
//  EmployerTBC.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 9/26/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit

class EmployerTBC: UITabBarController {

    var vacancy = Vacancy()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let viewControllers = viewControllers{
            for vc in viewControllers{
                if let navVC = vc as? UINavigationController, navVC.viewControllers.count > 0, let rootVC = navVC.viewControllers.first{
                    print(rootVC)
                    
                    if let vc = rootVC as? EmployerVacancyVC{
                        vc.vacancy = vacancy
                    }
                    
                    if let vc = rootVC as? VacancyApplicationsVC{
                        vc.vacancy = vacancy
                    }
                    
                    if let vc = rootVC as? EmployerChatsTVC{
                        vc.vacancy = vacancy
                    }
                }
            }
        }
    }
}

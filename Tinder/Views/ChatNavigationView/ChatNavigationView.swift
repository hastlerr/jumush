//
//  ChatNavigationView.swift
//  NambaOne
//
//  Created by Kuba Kadyrbekov on 19.12.2017.
//  Copyright © 2017 Namba Soft OsOO. All rights reserved.
//

import UIKit

protocol ChatNavigationViewDelegate {
    func didSelectChat()
}

class ChatNavigationView: UIView {

    @IBOutlet weak var nameLabel: UILabel!
    
    var delegate : ChatNavigationViewDelegate?
    
    @IBAction func openChatDetail(_ sender: Any) {
        if let delegate = self.delegate{
            delegate.didSelectChat()
        }
    }
}

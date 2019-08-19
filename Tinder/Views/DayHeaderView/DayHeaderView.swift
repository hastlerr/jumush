//
//  DayHeaderView.swift
//  NambaOne
//
//  Created by Avaz Abdrasulov on 3/5/18.
//  Copyright © 2018 Namba Soft OsOO. All rights reserved.
//

import UIKit

class DayHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var dayLabel: UILabel!
    static let headerId = "DayHeaderView"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func initWithGroup(group: Group){
        self.dayLabel.text = group.date.toDayString()
    }
    
}

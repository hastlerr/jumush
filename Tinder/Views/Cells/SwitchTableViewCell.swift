//
//  SwitchTableViewCell.swift
//  Tinder
//
//  Created by Avaz on 16/09/2018.
//  Copyright © 2018 Azamat Kushmanov. All rights reserved.
//

import UIKit

protocol SwitchTableViewCellDelegate{
    func turned(owner: AddMoreOwners, state: Bool)
}

class SwitchTableViewCell: UITableViewCell {

    @IBOutlet weak var switchTitle: UILabel!
    var delegate: SwitchTableViewCellDelegate?
    var cellOwner: AddMoreOwners!
    
  
    @IBAction func switchTapped(_ sender: UISwitch) {
        delegate?.turned(owner: cellOwner, state: sender.isOn)
    }
    
}

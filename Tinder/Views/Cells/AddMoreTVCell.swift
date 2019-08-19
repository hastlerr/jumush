//
//  AddMoreTVCell.swift
//  Tinder
//
//  Created by Avaz on 25/09/2018.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit

protocol  AddMoreTVCellDelegate{
    func addMoreTapped(owner: AddMoreOwners)
    
}

enum AddMoreOwners {
    case education
    case experience
}

class AddMoreTVCell: UITableViewCell {

    var cellOwner: AddMoreOwners!
    var delegate: AddMoreTVCellDelegate?

    
    @IBAction func addMore(_ sender: UIButton) {
        if let delegate = self.delegate{
            delegate.addMoreTapped(owner: cellOwner)
        }
    }
}

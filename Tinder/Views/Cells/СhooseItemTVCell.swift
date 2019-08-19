//
//  chooseItemTVCell.swift
//  Tinder
//
//  Created by Avaz on 23/09/2018.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit

class СhooseItemTVCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var itemName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        icon.image = UIImage(named: "ic_item_selected")

    }
    
}

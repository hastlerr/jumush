//
//  MessageTVCell.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 10/10/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit

class MessageTVCell: UITableViewCell {

    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    private var message : Message?{
        didSet{
            if let message = message{
                contentLabel.text = message.content
                dateLabel.text = message.getTimeString()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupWith(message: Message){
        self.message = message
    }
    
}

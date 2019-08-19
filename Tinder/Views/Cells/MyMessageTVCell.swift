//
//  MyMessageTVCell.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 10/10/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit

class MyMessageTVCell: UITableViewCell {

    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusImage: UIImageView!
    
    private var message : Message?{
        didSet{
            if let message = message{
                contentLabel.text = message.content
                dateLabel.text = message.getTimeString()
                statusImage.image = message.status == MessageStatus.Sent.rawValue ? UIImage(named: "ic_message_sent")?.withRenderingMode(.alwaysTemplate) : UIImage(named: "ic_message_readed")?.withRenderingMode(.alwaysTemplate)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        statusImage.tintColor = UIColor.lightText
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupWith(message: Message){
        self.message = message
    }
}

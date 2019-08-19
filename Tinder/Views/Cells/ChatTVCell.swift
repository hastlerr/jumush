//
//  ChatTVCell.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 9/24/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit

class ChatTVCell: UITableViewCell {

    @IBOutlet weak var chatImageView: UIImageView!
    
    @IBOutlet weak var chatTItleLabel: UILabel!
    
    @IBOutlet weak var lastMessageLabel: UILabel!
    
    @IBOutlet weak var lastMessageStatusImageView: UIImageView!
    
    @IBOutlet weak var lastMessageDateLabel: UILabel!
    
    private var chat: Chat?{
        didSet{
            if let chat = self.chat{
                chatImageView.sd_setImage(with: chat.getImageUrl(), placeholderImage: Constants.placeholder, completed: nil)
                chatTItleLabel.text = chat.name
                
                if let lastMessage = chat.lastMessage{
                    lastMessageLabel.text = lastMessage.content
                    lastMessageStatusImageView.image = lastMessage.status == MessageStatus.Sent.rawValue ? UIImage(named: "ic_message_sent") :  UIImage(named: "ic_message_readed")
                    lastMessageDateLabel.text = lastMessage.getTimeString()
                }else{
                    lastMessageLabel.text = ""
                    lastMessageDateLabel.text = ""
                    lastMessageStatusImageView.image = nil
                }
            }else{
                lastMessageLabel.text = ""
                lastMessageDateLabel.text = ""
                lastMessageStatusImageView.image = nil
                chatTItleLabel.text = ""
                chatImageView.image = nil
            }
        }
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupWith(chat: Chat){
        self.chat = chat
    }
    
}

//
//  CreateVacancyDescriptionTVCell.swift
//  Tinder
//
//  Created by Azamat Kushmanov on 9/27/18.
//  Copyright © 2018 Azamat Kushmanov. All rights reserved.
//

import UIKit

class CreateVacancyDescriptionTVCell: UITableViewCell {

    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

extension CreateVacancyDescriptionTVCell : UITextViewDelegate{
    
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == "Описание"{
            textView.text = ""
            textView.textColor = UIColor(hex: 0x25324C)
        }
        
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textView.text.isEmpty{
            textView.text = "Описание"
            textView.textColor = UIColor(hex: 0xC0C4CC)
        }
        
        return true
    }
    
}

//
//  CompanyVacanciesHeaderTVCell.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 9/26/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit

enum VacancyType{
    case Active
    case Closed
}

protocol CompanyVacanciesHeaderTVCellDelegate: class {
    func didChangeState(state: VacancyType)
}

class CompanyVacanciesHeaderTVCell: UITableViewHeaderFooterView {

    @IBOutlet weak var activeButton: UIButton!
    @IBOutlet weak var closedButton: UIButton!
    @IBOutlet weak var activeBottomView: UIView!
    @IBOutlet weak var closedBottomView: UIView!
    
    var delegate : CompanyVacanciesHeaderTVCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func showActiveVacancies(_ sender: UIButton) {
        activeButton.setTitleColor(UIColor(hex: 0x25324C), for: .normal)
        closedButton.setTitleColor(UIColor(hex: 0xC0C4CC), for: .normal)
        
        activeBottomView.isHidden = false
        closedBottomView.isHidden = true
        
        self.delegate?.didChangeState(state: .Active)
    }
    
    @IBAction func showClosedVacancies(_ sender: UIButton) {
        
        closedButton.setTitleColor(UIColor(hex: 0x25324C), for: .normal)
        activeButton.setTitleColor(UIColor(hex: 0xC0C4CC), for: .normal)
        
        activeBottomView.isHidden = true
        closedBottomView.isHidden = false
        
        self.delegate?.didChangeState(state: .Closed)
    }
    
}

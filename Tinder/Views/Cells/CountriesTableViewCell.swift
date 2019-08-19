//
//  CountriesTableViewCell.swift
//  NambaOne
//
//  Created by Kuba Kadyrbekov on 02.03.2018.
//  Copyright © 2018 Namba Soft OsOO. All rights reserved.
//

import UIKit

class CountriesTableViewCell: UITableViewCell {

    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var countryCodeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupWithCountry(country: Country){
        countryNameLabel.text = country.flag + "  " + country.name
        countryCodeLabel.text = "+" + country.isoNumber
    }
    
}

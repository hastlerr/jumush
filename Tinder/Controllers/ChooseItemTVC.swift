//
//  ChooseItemTVC.swift
//  Tinder
//
//  Created by Avaz on 23/09/2018.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit

class ChooseItemTVC: UITableViewController {
    
    static func newInstance() -> ChooseItemTVC{
        return UIStoryboard(name: Constants.SIGNUP_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "ChooseItemTVC") as! ChooseItemTVC
    }
    
    var typeTitle = ""
    var items = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = typeTitle
        self.tableView.register(СhooseItemTVCell.nib, forCellReuseIdentifier: СhooseItemTVCell.identifier)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: СhooseItemTVCell.identifier, for: indexPath) as! СhooseItemTVCell
//        cell.itemName = items[indexPath.row].name

        return cell
    }

}

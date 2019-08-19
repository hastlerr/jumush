//
//  ChatsTVC.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 9/24/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit
import Firebase
import ObjectMapper

class ChatsTVC: UITableViewController {

    var chats = [Chat]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: .zero)
        registerXib()
        getChats()
    }
    
    func getChats(){
        guard let user = Auth.auth().currentUser else{
            return
        }
        
        CloudStoreRefManager.instance.chatsReferance
            .whereField("users", arrayContains: user.uid)
            .order(by: "updatedAt", descending: true)
            .addSnapshotListener { (snapshot, error) in
                if let error = error{
                    print("Firebase error: \(error.localizedDescription)")
                }
                
                guard let snapshot = snapshot else {
                    return
                }
                
                var chats = [Chat]()
                for document in snapshot.documents {
                    if let chat = Mapper<Chat>().map(JSON: document.data()){
                        chat.id = document.documentID
                        
                        for userId in chat.users{
                            if userId != user.uid{
                                
                                if let json = document.data()[userId] as? [String : Any]{
                                    if let chatName = json["name"] as? String{
                                        chat.name = chatName
                                    }
                                    
                                    if let image = json["image"] as? String{
                                        chat.image = image
                                    }
                                }
                                
                                break
                            }
                        }
                        
                        chat.id = document.documentID
                        chats.append(chat)
                    }
                }
                
                self.chats = chats
                self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func registerXib(){
        self.tableView.register(ChatTVCell.nib, forCellReuseIdentifier: ChatTVCell.identifier)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if chats.count == 0{
            tableView.backgroundView = UINib(nibName: "HolderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! HolderView
        }else{
            tableView.backgroundView = nil
        }
        
        return chats.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatTVCell.identifier, for: indexPath) as! ChatTVCell
        cell.setupWith(chat: self.chats[indexPath.row])
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        setupBackButton()
        
        let vc = UIStoryboard(name: Constants.EMPLOYEE_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        vc.chat = chats[indexPath.row]
        vc.forEmployer = false
        self.navigationController?.pushViewController(vc, animated: true)
    }

}

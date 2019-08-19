//
//  ChatVC.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 10/10/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit
import GrowingTextView
import FirebaseAuth
import ObjectMapper
import IQKeyboardManagerSwift

class ChatVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textView: GrowingTextView!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var textViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var emptyChatHolder: UIImageView!
    
    @IBOutlet weak var emptyChatLabel: UILabel!
    
    private var chatNavigationView = UIView()
    private var vacancyNameLabel = UILabel()
    
    private var groups = [Group]()
    var chat:Chat?
    var forEmployer = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView(frame: .zero)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        self.tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        textView.delegate = self
        
        registerXib()
        
        setupNavBar()
        subscribeToMessages()
    }
    
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        if let endFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            var keyboardHeight = view.bounds.height - endFrame.origin.y
            if keyboardHeight > 0 {
                keyboardHeight = keyboardHeight - view.safeAreaInsets.bottom
            }
            textViewBottomConstraint.constant = keyboardHeight + 8
            view.layoutIfNeeded()
            scrollToLastRow(animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    @objc fileprivate func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func subscribeToMessages(){
        if let chat = self.chat {
            
            CloudStoreRefManager.instance.chatsReferance
                .document(chat.id)
                .collection(CloudRout.messages.rawValue)
                .addSnapshotListener { (snapshot, error) in
                    guard let snapshot = snapshot else {
                        print("Error fetching snapshots: \(error!)")
                        return
                    }
                    snapshot.documentChanges.forEach { diff in
                        if (diff.type == .added) {
                            if let message = Mapper<Message>().map(JSON: diff.document.data()){
                                self.addMessage(message: message)
                            }
                        }
                        
                        if (diff.type == .modified) {
                            if let message = Mapper<Message>().map(JSON: diff.document.data()){
                                self.editMessage(message: message)
                            }
                        }
                    }
            }
        }
    }
    
    func getVacancy(){
        if let chat = self.chat {
            CloudStoreRefManager.instance.vacanciesReferance
                .document(chat.vacancyId)
                .getDocument { (vacancySnapshot, error) in
                    if let error = error{
                        print("Firebase error: \(error.localizedDescription)")
                    }
                    
                    if let shapshot = vacancySnapshot, let json = shapshot.data(), let vacancy = Mapper<Vacancy>().map(JSON: json){
                        self.vacancyNameLabel.text = vacancy.position
                    }
            }
        }
    }
    
    func sendMessage(message: Message, completion: @escaping (_ success: Bool) -> Void){
        if let chat = self.chat {
            CloudStoreRefManager.instance.chatsReferance
                .document(chat.id)
                .collection(CloudRout.messages.rawValue)
                .document(message.id)
                .setData(message.toCreateParams()) { (error) in
                    if let error = error{
                        completion(false)
                        self.showAlertWithMessage(message: error.localizedDescription)
                        return
                    }
                    
                    completion(true)
            }
        }
    }
    
    func addMessage(message: Message){
        
        let group = Group(date: message.createdAt.dateValue(), message: message)
        
        if let section = self.groups.index(where: {$0 == group}){
            self.groups[section].addMessage(message: message)
        }else{
            self.groups.append(group)
            
            self.groups.sort { (group1, group2) -> Bool in
                return group1.date.compare(group2.date) == .orderedAscending
            }
        }
        
        self.tableView.reloadData()
        scrollToLastRow(animated: true)
    }
    
    func editMessage(message: Message){
        let group = Group(date: message.createdAt.dateValue(), message: message)
        
        if let section = self.groups.index(where: {$0 == group}){
            self.groups[section].editMessage(message:message)
            tableView.reloadData()
        }
    }
    
    @objc func scrollToLastRow(animated: Bool) {
        let sectionsCount = tableView.numberOfSections
        if sectionsCount > 0{
            let numberOfRows = tableView.numberOfRows(inSection: sectionsCount - 1)
            if numberOfRows > 0 {
                tableView.scrollToRow(at: IndexPath(row: numberOfRows - 1, section: sectionsCount - 1), at: .none, animated: false)
            }
        }
    }
    
    func registerXib(){
        tableView.register(MessageTVCell.nib, forCellReuseIdentifier: MessageTVCell.identifier)
        tableView.register(MyMessageTVCell.nib, forCellReuseIdentifier: MyMessageTVCell.identifier)
        tableView.register(UINib(nibName: "DayHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: DayHeaderView.headerId)
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        guard let user = Auth.auth().currentUser, let chat = self.chat, textView.text != "Написать", !textView.text.isEmpty else{
            return
        }
        
        sender.isEnabled = false
        
        let message = Message()
        message.id = CloudStoreRefManager.instance.messagesReferance.document(chat.id).collection(CloudRout.messages.rawValue).document().documentID
        message.content = textView.text
        message.status = MessageStatus.Sent.rawValue
        message.from = user.uid
        message.to = chat.getPartnerId()
        
        sendMessage(message: message) { (success) in
            if success{
                self.textView.text = ""
            }else{
                sender.isEnabled = true
            }
        }
    }
    
    func setupNavBar(){
        guard let chat = self.chat else {return}
        
        let rect = CGRect(
            origin: CGPoint(x: 0, y: 0),
            size: CGSize(width: (self.navigationController?.navigationBar.frame.size.width)! - 150, height: (self.navigationController?.navigationBar.frame.size.height)!)
        )
        
        self.chatNavigationView = UINib(nibName: "ChatNavigationView",bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ChatNavigationView
        
        let chatNavView = self.chatNavigationView as! ChatNavigationView
        
        chatNavView.frame = rect
        chatNavView.isUserInteractionEnabled = true
        
        chatNavView.delegate = self
        
        if let chatImageView = chatNavView.viewWithTag(1) as? UIImageView{
            chatImageView.layer.cornerRadius = chatImageView.frame.width / 2
            chatImageView.layer.masksToBounds = true
            
            chatImageView.sd_setImage(with: chat.getImageUrl(), placeholderImage: Constants.placeholder, completed: nil)
        }
        
        if let chatTitle = chatNavView.viewWithTag(2) as? UILabel{
            chatTitle.text = chat.name + "                                                                                          "
        }
        
        if let vacancyNameLabel = chatNavView.viewWithTag(3) as? UILabel{
            self.vacancyNameLabel = vacancyNameLabel
            getVacancy()
        }
        
        self.navigationItem.titleView?.isUserInteractionEnabled = true
        self.navigationItem.titleView = chatNavView
    }
    
    @objc func goToAboutChatVC() {
        guard let chat = self.chat else {return}
        
        setupBackButton()
        
        if forEmployer{
            let vc = UIStoryboard(name: Constants.EMPLOYER_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "EmployeeInfoTVC") as! EmployeeInfoTVC
            vc.employeeId = chat.getPartnerId()
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            let vc = UIStoryboard(name: Constants.EMPLOYEE_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "AboutCompanyVC") as! AboutCompanyVC
            vc.employerId = chat.getPartnerId()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension ChatVC : UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if groups.isEmpty{
            emptyChatHolder.isHidden = false
            emptyChatLabel.isHidden = false
        }else{
            emptyChatHolder.isHidden = true
            emptyChatLabel.isHidden = true
        }
        
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups[section].messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = groups[indexPath.section].messages[indexPath.row]
        
        if message.isMyMessage(){
            let cell = tableView.dequeueReusableCell(withIdentifier: MyMessageTVCell.identifier) as! MyMessageTVCell
        
            cell.setupWith(message: message)
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageTVCell.identifier) as! MessageTVCell
        
        cell.setupWith(message: message)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: DayHeaderView.headerId) as! DayHeaderView
        
        header.initWithGroup(group: groups[section])
        
        return header
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let chat = self.chat{
            let message = groups[indexPath.section].messages[indexPath.row]
            
            if !message.isMyMessage(), message.status == MessageStatus.Sent.rawValue{
                CloudStoreRefManager.instance.chatsReferance
                    .document(chat.id)
                    .collection(CloudRout.messages.rawValue)
                    .document(message.id)
                    .setData(["status" : MessageStatus.Read.rawValue], merge: true)
            }
        }
    }
}

extension ChatVC : UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    
}

extension ChatVC : UITextViewDelegate{
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == "Написать"{
            textView.text = ""
            textView.textColor = UIColor.black
        }
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        sendButton.isEnabled = !textView.text.isEmpty
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textView.text.isEmpty{
            textView.text = "Написать"
            textView.textColor = UIColor.lightGray
        }
        
        return true
    }
}

extension ChatVC : ChatNavigationViewDelegate{
    func didSelectChat() {
        goToAboutChatVC()
    }
}

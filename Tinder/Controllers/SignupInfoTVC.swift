//
//  ProfileTVC.swift
//  Tinder
//
//  Created by Avaz on 15/09/2018.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit
import FirebaseAuth
import PKHUD
import Firebase
import ObjectMapper

class SignupInfoTVC: UITableViewController {
    
    static func newInstance() -> SignupInfoTVC{
        return UIStoryboard(name: Constants.SIGNUP_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "SignupInfoTVC") as! SignupInfoTVC
    }
    
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var nameTextField: TextField!
    
    private var imagePicker: UIImagePickerController!
    private var selectedImage : UIImage?
    
    private let educationTitle = "Образование"
    private let experinceTitle = "Опыт работы"
    
    private var deletedEducations = [Education]()
    private var deletedWorks = [Work]()
    
    private var educations = [Education](){
        didSet{
            tableView.reloadData()
        }
    }
    private var works = [Work](){
        didSet{
            tableView.reloadData()
        }
    }
    private var employee: Employee?{
        didSet{
            if let employee = employee{
                avatarButton.sd_setImage(with: employee.getImageUrl(), for: .normal,  placeholderImage: Constants.placeholder, completed: nil)
                nameTextField.text = employee.name

                tableView.reloadData()
            }
        }
    }
    
    var popVCAfterUpdate = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(EducationTVCell.nib, forCellReuseIdentifier: EducationTVCell.identifier)
        self.tableView.register(ExperienceTVCell.nib, forCellReuseIdentifier: ExperienceTVCell.identifier)
        self.tableView.register(AddMoreTVCell.nib, forCellReuseIdentifier: AddMoreTVCell.identifier)
        
        getProfile()
        getProfileEducation()
        getProfileWorks()
    }
    
    func getProfile(){
        guard let user = Auth.auth().currentUser else{
            return
        }
        
        CloudStoreRefManager.instance.employeesReferance
            .document(user.uid)
            .getDocument { (snapshot, error) in
                if let error = error{
                    print("Firebase error: \(error.localizedDescription)")
                }
                
                if let snapshot = snapshot, let data = snapshot.data(), let employee = Mapper<Employee>().map(JSON: data){
                    
                    
                    
                    employee.id = snapshot.documentID
                    self.employee = employee
                }
        }
    }
    
    func getProfileEducation(){
        guard let user = Auth.auth().currentUser else{
            return
        }
        
        CloudStoreRefManager.instance.employeesReferance
            .document(user.uid)
            .collection(CloudRout.educations.rawValue)
            .getDocuments(completion: { (educationsSnaphot, error) in
                
                if let error = error{
                    print("Firebase error: \(error.localizedDescription)")
                }
                
                if let educationsSnaphot = educationsSnaphot{
                    
                    var educations = [Education]()
                    
                    for item in educationsSnaphot.documents{
                        if let education = Mapper<Education>().map(JSON: item.data()){
                            education.id = item.documentID
                            educations.append(education)
                        }
                    }
                    
                    self.educations = educations
                }
                
            })
    }
    
    func getProfileWorks(){
        guard let user = Auth.auth().currentUser else{
            return
        }
        
        CloudStoreRefManager.instance.employeesReferance
            .document(user.uid)
            .collection(CloudRout.works.rawValue)
            .getDocuments(completion: { (worksSnaphot, error) in
                
                if let error = error{
                    print("Firebase error: \(error.localizedDescription)")
                }
                
                if let worksSnaphot = worksSnaphot{
                    
                    var works = [Work]()
                    
                    for item in worksSnaphot.documents{
                        if let work = Mapper<Work>().map(JSON: item.data()){
                            work.id = item.documentID
                            works.append(work)
                        }
                    }
                    
                    self.works = works
                }
            })
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return educations.count
        case 1:
            return works.count
        default:
            return 1
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: EducationTVCell.identifier, for: indexPath) as! EducationTVCell
            
            cell.setupWith(education: educations[indexPath.row])
            
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: ExperienceTVCell.identifier, for: indexPath) as! ExperienceTVCell
            
           cell.setupWith(work: works[indexPath.row])
            
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 40))
        let label = UILabel(frame: CGRect(x: 20, y: 15, width: headerView.frame.width - 20, height: headerView.frame.height))
        headerView.backgroundColor = UIColor.clear
        label.backgroundColor = headerView.backgroundColor
        label.font = UIFont(name: "Raleway-Black", size: 20.0)
        label.textColor = UIColor(hex: 0x25324C)
        
        
        switch section {
        case 0:
            label.text = "Образование"
        case 1:
            label.text = "Опыт работы"
        default:
            label.text = ""
        }
        
        headerView.addSubview(label)
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Удалить") { (action, indexPath) in
            if indexPath.section == 0{
                self.deletedEducations.append(self.educations[indexPath.row])
                self.educations.remove(at: indexPath.row)
                tableView.reloadData()
            }else{
                self.deletedWorks.append(self.works[indexPath.row])
                self.works.remove(at: indexPath.row)
                tableView.reloadData()
            }
        }
        
        return [delete]
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: AddMoreTVCell.identifier) as! AddMoreTVCell
        cell.delegate = self
        
        switch section {
        case 0:
            cell.cellOwner = AddMoreOwners.education
        default:
            cell.cellOwner = AddMoreOwners.experience
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 55
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 310 : 240
    }
    
    
    @IBAction func next(_ sender: Any) {
        
        guard let user = Auth.auth().currentUser else{
            return
        }
        
        guard let name = nameTextField.text, !name.isEmpty else {
            nameTextField.shake()
            return
        }
        
        var params = [
            "name" : name
        ]
        
        if let image = selectedImage{
            
            HUD.show(.progress)
            
            FileUploaderManager.instance.uploadImage(image: image, completion: { (status, fileUrl) in
                HUD.hide()
                
                if status == .success{
                    params["image"] = fileUrl
                    
                    let db = Firestore.firestore()
                    let batch = db.batch()
                    
                    let employeeProfileRef =  CloudStoreRefManager.instance.employeesReferance
                        .document(user.uid)
                    batch.setData(params, forDocument: employeeProfileRef, merge: true)
                    
                    for education in self.educations{
                        if education.isFieldsValid(){
                            
                            let educationRef = CloudStoreRefManager.instance.employeesReferance
                                .document(user.uid)
                                .collection(CloudRout.educations.rawValue)
                                .document(education.id)
                            
                            batch.setData(education.toCreateParams(), forDocument: educationRef)
                        }
                    }
                    
                    for work in self.works{
                        if work.isFieldsValid(){
                            
                            let workRef = CloudStoreRefManager.instance.employeesReferance
                                .document(user.uid)
                                .collection(CloudRout.works.rawValue)
                                .document(work.id)
                            
                            batch.setData(work.toCreateParams(), forDocument: workRef)
                        }
                    }
                    
                    for education in self.deletedEducations{
                        if education.isFieldsValid(){
                            
                            let educationRef = CloudStoreRefManager.instance.employeesReferance
                                .document(user.uid)
                                .collection(CloudRout.educations.rawValue)
                                .document(education.id)
                            
                            batch.deleteDocument(educationRef)
                        }
                    }
                    
                    for work in self.deletedWorks{
                        if work.isFieldsValid(){
                            
                            let workRef = CloudStoreRefManager.instance.employeesReferance
                                .document(user.uid)
                                .collection(CloudRout.works.rawValue)
                                .document(work.id)
                            
                            batch.deleteDocument(workRef)
                        }
                    }
                    
                    
                    batch.commit() { err in
                        HUD.hide()
                        
                        if let err = err {
                            self.showAlertWithMessage(message: err.localizedDescription)
                        } else {
                            self.popVCAfterUpdate ? self.goBack() : self.goToDashboard()
                        }
                    }
                }else{
                    HUD.hide()
                    self.showAlertWithMessage(message: "Ошибка при сохранении данных")
                }
            })
        }else{
            HUD.show(.progress)
            
            let db = Firestore.firestore()
            let batch = db.batch()
            
            let employeeProfileRef =  CloudStoreRefManager.instance.employeesReferance
                .document(user.uid)
            batch.setData(params, forDocument: employeeProfileRef, merge: true)
            
            for education in self.educations{
                if education.isFieldsValid(){
                    
                    let educationRef = CloudStoreRefManager.instance.employeesReferance
                        .document(user.uid)
                        .collection(CloudRout.educations.rawValue)
                        .document(education.id)
                    
                    batch.setData(education.toCreateParams(), forDocument: educationRef)
                }
                
            }
            
            for work in self.works{
                if work.isFieldsValid(){
                    
                    let workRef = CloudStoreRefManager.instance.employeesReferance
                        .document(user.uid)
                        .collection(CloudRout.works.rawValue)
                        .document(work.id)
                    
                    batch.setData(work.toCreateParams(), forDocument: workRef)
                }
            }
            
            for education in self.deletedEducations{
                if education.isFieldsValid(){
                    
                    let educationRef = CloudStoreRefManager.instance.employeesReferance
                        .document(user.uid)
                        .collection(CloudRout.educations.rawValue)
                        .document(education.id)
                    
                    batch.deleteDocument(educationRef)
                }
            }
            
            for work in self.deletedWorks{
                if work.isFieldsValid(){
                    
                    let workRef = CloudStoreRefManager.instance.employeesReferance
                        .document(user.uid)
                        .collection(CloudRout.works.rawValue)
                        .document(work.id)
                    
                    batch.deleteDocument(workRef)
                }
            }
            
            
            batch.commit() { err in
                HUD.hide()
                
                if let err = err {
                    self.showAlertWithMessage(message: err.localizedDescription)
                } else {
                    self.popVCAfterUpdate ? self.goBack() : self.goToDashboard()
                }
            }
        }
    }
    
    func goBack(){
        self.navigationController?.popViewController(animated: true)
    }
    
    func goToDashboard(){
        UIApplication.shared.keyWindow?.rootViewController = UIStoryboard.init(name: Constants.EMPLOYEE_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "EmployeeTBC")
    }
}

extension SignupInfoTVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBAction func addAvatar(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Загрузить фотографию", style: .default, handler: { (action) in
            self.imagePicker = UIImagePickerController()
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.imagePicker.allowsEditing = true
            self.imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: self.imagePicker.sourceType)!
            
            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Отменить", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let editingImage = info[UIImagePickerControllerEditedImage] as? UIImage{
            self.avatarButton.setImage(editingImage, for: .normal)
            self.selectedImage = editingImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    
}

extension SignupInfoTVC: AddMoreTVCellDelegate{
    
    func addNewEducation(){
        
        guard let user = Auth.auth().currentUser else{
            return
        }
        
        let newEducation = Education()
        
        newEducation.id = CloudStoreRefManager.instance.employeesReferance
            .document(user.uid)
            .collection(CloudRout.educations.rawValue)
            .document()
            .documentID
        
        educations.append(newEducation)
        tableView.reloadData()
    }
    
    func addNewWork(){
        
        guard let user = Auth.auth().currentUser else{
            return
        }
        
        let newWork = Work()
        
        newWork.id = CloudStoreRefManager.instance.employeesReferance
            .document(user.uid)
            .collection(CloudRout.works.rawValue)
            .document()
            .documentID
        
        works.append(newWork)
        tableView.reloadData()
    }
    
    func addMoreTapped(owner: AddMoreOwners) {

        if owner == .education{
            if educations.isEmpty{
                addNewEducation()
                return
            }else{
                if educations.last!.isFieldsValid(){
                    addNewEducation()
                }
            }
        }else{
            if works.isEmpty{
                addNewWork()
                return
            }else{
                if works.last!.isFieldsValid(){
                    addNewWork()
                }
            }
        }
    }
}



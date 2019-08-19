//
//  CreateCompanyTVC.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 10/1/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit
import ObjectMapper
import FirebaseAuth
import PKHUD
import SDWebImage

class CreateCompanyTVC: UITableViewController {
    
    @IBOutlet weak var companyLogoImageView: UIImageView!
    
    @IBOutlet weak var changeImageButton: UIButton!
    
    @IBOutlet weak var companyNameTextField: UITextField!
    @IBOutlet weak var companyDescriptionTextView: UITextView!
    @IBOutlet weak var companyRegionTextField: UITextField!
    @IBOutlet weak var companyTownTextField: UITextField!
    
    private var imagePicker: UIImagePickerController!
    
    private var regions = [Region](){
        didSet{
            regionPicker.reloadAllComponents()
            
            if !regions.isEmpty, selectedRegion == nil{
                selectedRegion = regions.first
            }
        }
    }
    
    private var companyImage : UIImage?{
        didSet{
            if let image = companyImage{
                changeImageButton.setTitle("", for: .normal)
                companyLogoImageView.image = image
            }else{
                changeImageButton.setTitle("LOGO", for: .normal)
                companyLogoImageView.image = nil
            }
            
        }
    }
    
    private let regionPicker = UIPickerView()
    private var employer : Employer?{
        didSet{
            guard let employer = employer else {
                return
            }
            
            companyNameTextField.text = employer.name
            companyDescriptionTextView.text = employer.about
            companyTownTextField.text = employer.city
            
            companyDescriptionTextView.textColor = UIColor(hex: 0x25324C)
            
            companyLogoImageView.sd_setImage(with: employer.getImageUrl(), placeholderImage: Constants.placeholder) { (image, error, cache, url) in
                if error == nil{
                    self.changeImageButton.setTitle("", for: .normal)
                }
            }
        }
    }
    
    private var selectedRegion : Region? {
        didSet{
            guard let selectedRegion = selectedRegion else {
                return
            }
            
            companyRegionTextField.text = selectedRegion.name
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView(frame: .zero)
        
        companyDescriptionTextView.delegate = self
        
        regionPicker.dataSource = self
        regionPicker.delegate = self
        companyRegionTextField.inputView = regionPicker
        
        getRegions()
        getEmployer()
    }
    
    func getEmployer(){
        guard let user = Auth.auth().currentUser else{
            return
        }
        
        CloudStoreRefManager.instance.employersReferance
            .document(user.uid)
            .getDocument { (snapshot, error) in
                if let error = error{
                    print("error: \(error.localizedDescription)")
                }
                
                if let snapshot = snapshot, let data = snapshot.data(), let employer = Mapper<Employer>().map(JSON: data){
                    
                    employer.id = snapshot.documentID
                    
                    CloudStoreRefManager.instance.regionsReferance
                        .document(employer.regionId)
                        .getDocument(completion: { (regionSnapshot, error) in
                            if let error = error{
                                print("error: \(error.localizedDescription)")
                            }
                            
                            if let regionSnapshot = regionSnapshot, let data = regionSnapshot.data(), let region = Mapper<Region>().map(JSON: data){
                                region.id = regionSnapshot.documentID
                                
                                employer.region = region
                                self.selectedRegion = region
                            }
                            
                            self.employer = employer
                        })
                }
        }
    }
    
    func getRegions(){
        CloudStoreRefManager.instance.regionsReferance
            .getDocuments(completion: { (snapshot, error) in
                if let error = error{
                    print("error: \(error.localizedDescription)")
                }
                
                if let snapshot = snapshot{
                    
                    var regions = [Region]()
                    
                    for item in snapshot.documents{
                        if let region = Mapper<Region>().map(JSON: item.data()){
                            region.id = item.documentID
                            regions.append(region)
                        }
                    }
                    
                    self.regions = regions
                }
            })
    }
    
    @IBAction func changeImage(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { action in
            self.dismiss(animated: true, completion: nil)
        }
        let libraryAction = UIAlertAction(title: "Галлерея", style: .default) { action in
            let vc =  UIImagePickerController()
            vc.delegate = self
            vc.sourceType = UIImagePickerControllerSourceType.photoLibrary
            vc.allowsEditing = true
            vc.mediaTypes = UIImagePickerController.availableMediaTypes(for: vc.sourceType)!
            
            self.present(vc, animated: true, completion: nil)
        }
        
        let cameraAction = UIAlertAction(title: "Камера", style: .default) { action in
            let vc =  UIImagePickerController()
            vc.delegate = self
            vc.sourceType = UIImagePickerControllerSourceType.camera
            vc.allowsEditing = true
            vc.mediaTypes = UIImagePickerController.availableMediaTypes(for: vc.sourceType)!
            
            self.present(vc, animated: true, completion: nil)
        }
        
        alert.addAction(cameraAction)
        alert.addAction(cancelAction)
        alert.addAction(libraryAction)
        alert.view.tintColor = UIColor(red: 55/255, green: 55/255, blue: 55/255, alpha: 1)
        self.present(alert, animated: true)
    }
    
    
    @IBAction func next(_ sender: Any) {
        
        guard let name = companyNameTextField.text, !name.isEmpty else{
            companyNameTextField.shake()
            return
        }
        
        guard let region = self.selectedRegion else{
            companyRegionTextField.shake()
            return
        }
        
        guard let city = companyTownTextField.text, !city.isEmpty else{
            companyTownTextField.shake()
            return
        }
        
        guard let user = Auth.auth().currentUser else{
            return
        }
        
        var params = [
            "name" : name,
            "city" : city,
            "regionId" : region.id
            ] as [String : Any]
        
        if companyDescriptionTextView.text != "О компании"{
            params["about"] = companyDescriptionTextView.text
        }
        
        HUD.show(.progress)
        
        if let image = companyImage{
            FileUploaderManager.instance.uploadImage(image: image, completion: { (status, fileUrl) in
                HUD.hide()
                
                if status == .success{
                    params["image"] = fileUrl
                    
                    CloudStoreRefManager.instance.employersReferance
                        .document(user.uid)
                        .setData(params, merge: true, completion: { (error) in
                            if let error = error{
                                HUD.hide()
                                self.showAlertWithMessage(message: error.localizedDescription)
                                return
                            }
                            
                            HUD.flash(.success, onView: nil, delay: 0.5, completion: { (bool) in
                                let vc = UIStoryboard.init(name: Constants.EMPLOYER_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "EmployerVacanciesVC") as! EmployerVacanciesVC
                                UIApplication.shared.keyWindow?.rootViewController = UINavigationController(rootViewController: vc)
                            })
                        })
                }else{
                    self.showAlertWithMessage(message: "Ошибка при сохранении данных")
                }
            })
        }else{
            CloudStoreRefManager.instance.employersReferance
                .document(user.uid)
                .setData(params, merge: true, completion: { (error) in
                    if let error = error{
                        HUD.hide()
                        self.showAlertWithMessage(message: error.localizedDescription)
                        return
                    }
                    
                    HUD.flash(.success, onView: nil, delay: 0.5, completion: { (bool) in
                        let vc = UIStoryboard.init(name: Constants.EMPLOYER_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "EmployerVacanciesVC") as! EmployerVacanciesVC
                        UIApplication.shared.keyWindow?.rootViewController = UINavigationController(rootViewController: vc)
                    })
                })
        }
    }
}

extension CreateCompanyTVC : UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return regions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return regions[row].name
    }
}

extension CreateCompanyTVC : UIPickerViewDelegate{
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRegion = regions[row]
        companyRegionTextField.text = regions[row].name
    }
}

extension CreateCompanyTVC : UITextViewDelegate{
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

extension CreateCompanyTVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker: UIImage?
        if let editingImage = info[UIImagePickerControllerEditedImage] as? UIImage{
            selectedImageFromPicker = editingImage
        }else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker{
            self.companyImage = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
}


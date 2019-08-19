//
//  FileUploaderManager.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 10/1/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit
import Firebase

import FirebaseStorage

class StorageRefManager {
    
    static let instance = StorageRefManager()
    
    let imagesReferences = Storage.storage().reference().child(Route.Images.rawValue)
    
}

class FileUploaderManager: NSObject {
    static let instance = FileUploaderManager()
    
    func uploadImage(image: UIImage, completion: @escaping ((StorageTaskStatus, _ fileUrl: String) -> Swift.Void)){
        
        let fileName = NSUUID().uuidString
        let storageRef = StorageRefManager.instance.imagesReferences.child(fileName)
        let metadata = StorageMetadata()
        if let thumbnailImageData = UIImageJPEGRepresentation(image, Constants.IMAGE_THUMBNAIL_QUALITY){
            let thumbnailUploadTask = storageRef.putData(thumbnailImageData, metadata: metadata)
            
            thumbnailUploadTask.observe(.success) { thumbnailSnapshot in
                
                storageRef.downloadURL(completion: { (url, error) in
                    if let thumbUrl = url{
                        completion(.success, thumbUrl.absoluteString)
                    }
                })
                
                thumbnailUploadTask.removeAllObservers()
            }
            
            thumbnailUploadTask.observe(.failure) { (originalSnapshot) in
                completion(.failure, "")
            }
        }
    }
}

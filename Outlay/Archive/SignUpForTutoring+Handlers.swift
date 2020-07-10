//
//  SignUpForTutoring+Handlers.swift
//  Outlay
//
//  Created by Sebastian Sanso on 1/16/18.
//  Copyright © 2018 Sebastian Sanso. All rights reserved.
//

import UIKit
import Firebase

extension signUpForTutoring: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func handleRegister() {
        guard let phone = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else {
            print("Form is not valid")
            return
        }
        
        Auth.auth().createUser(withEmail: phone, password: password, completion: { (user, error) in
            if let error = error {
                print(error)
                return
            }
            guard let uid = user?.user.uid else {
                return
            }
            //successfully authenticated user
            let imageName = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).png")
            
            
            if let uploadData = self.profileImageView.image!.pngData() {
                storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        print(error as Any)
                        return
                    }
                    storageRef.downloadURL { url, error in
                        if let error = error {
                            
                        } else {
                            let values = ["name": name, "email": phone, "profileImageUrl": url!] as [String : Any]
                            self.registerUserIntoDatabaseWithUID(uid: uid, values: values as [String : AnyObject])
                        }
                    }
                    
                })
            }
        })
    }
    
    private func registerUserIntoDatabaseWithUID(uid: String, values: [String: AnyObject]) {
        let ref = Database.database().reference()
        let usersReference = ref.child("tutor").child(uid)
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if let err = err {
                print(err)
                return
            }
            print("Tutor made!")
        })
    }
    
    
    
    
    
    @objc func handleSelectProfileImageView() {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        
        present(picker, animated: true, completion: nil)
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profileImageView.image = selectedImage
            
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

//
//  EditProfileController.swift
//  Outlay
//
//  Created by Sebastian Sanso on 8/26/18.
//  Copyright © 2018 Sebastian Sanso. All rights reserved.
//

import UIKit
import Firebase

class EditProfileController: UICollectionViewController {
    var user = [User]()
    
    let uid = Auth.auth().currentUser?.uid
    let captionLabel: UITextView = {
        let label = UITextView()
        label.backgroundColor = UIColor.clear
        label.isUserInteractionEnabled = false
        label.font = UIFont.systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUser()
        
    }
    
    func fetchUser() {
        let ref = Database.database().reference().child("users").child(uid!)
        ref.observe(.value, with: { (snapshot) in
            let name = snapshot.child("name").value
            let email = snapshot.child("email").value
            let profilePicture = snapshot.child("profileImageUrl").value
            let user = User(email: email as! String, name: name as! String, profilePicture: profilePicture as! URL)
            self.user.append(user)
        }, withCancel: nil)
    }
}

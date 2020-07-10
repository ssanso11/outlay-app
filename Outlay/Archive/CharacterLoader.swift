//
//  CharacterLoader.swift
//  Outlay
//
//  Created by Sebastian Sanso on 9/4/18.
//  Copyright © 2018 Sebastian Sanso. All rights reserved.
//

import UIKit
import ARKit
import Firebase

class CharacterLoader: SCNNode {
    var users = [UserWithoutEmail]()
    
    let ARView = ARViewController()
    
    func loadModel(completion: @escaping (Error?) -> Void) {
        for each in users {
            print("users")
            //set textures from post array to basic avatar scn
            //set 3d model to random .scn file stored in firebase
            guard let virtualObjectScene = SCNScene(named: "art.scnassets/ship.scn") else {
                return
            }
            let wrapperNode = SCNNode()
            
            for child in virtualObjectScene.rootNode.childNodes {
                print(child)
                wrapperNode.addChildNode(child)
            }
            
            self.addChildNode(wrapperNode)
            print(virtualObjectScene.rootNode.childNodes.count)
        }
        completion(nil)
    }
    
    func fetchUsers(completion: @escaping (Error?) -> Void) {
        Database.database().reference().child("users").observe(.value, with: { (snapshot) in
            
            for snap in snapshot.children {
                let userSnap = snap as! DataSnapshot
                let userName = userSnap.child("name").value
                let userProfilePicture = userSnap.child("profileImageUrl").value
                
                
                let userSetup = UserWithoutEmail(name: userName as! String, profilePicture: userProfilePicture as! String)
                self.users.append(userSetup)
            }
            self.loadModel(completion: { (error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    self.ARView.fetchUsers(user: self.users)
                }
            })
            completion(nil)
            
          
        }, withCancel: nil)
        
        
    }
    
}

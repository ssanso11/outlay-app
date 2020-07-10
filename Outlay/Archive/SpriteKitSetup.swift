//
//  SpriteKitSetup.swift
//  Outlay
//
//  Created by Sebastian Sanso on 9/13/18.
//  Copyright © 2018 Sebastian Sanso. All rights reserved.
//

import UIKit
import SpriteKit

class SpriteKitController: SKScene, ButtonDelegate {
    func buttonClicked(sender: Button) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showSocialNetworksID"), object: nil)
        
    }
    private var button = Button()
    
    
    
    let profilePictureNode: SKSpriteNode = {
        let pc = SKSpriteNode()
        return pc
    }()
    let usernameLabel: SKLabelNode = {
        let ul = SKLabelNode()
        ul.text = "Hello World"
        return ul
    }()
    let descriptionNode: SKLabelNode = {
        let dn = SKLabelNode()
        return dn
    }()
    
    
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        


    }
    
    func setupViews() {
        usernameLabel.position = CGPoint(x: (view?.frame.width)! / 3, y: (view?.frame.height)!-25)
        profilePictureNode.position = CGPoint(x: (view?.frame.width)! / 2, y: (view?.frame.height)!-25)
        descriptionNode.position = CGPoint(x: (view?.frame.width)! / 2, y: (view?.frame.height)!-50)
    }
}



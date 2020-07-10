//
//  SideViewController.swift
//  Outlay
//
//  Created by Sebastian Sanso on 12/24/18.
//  Copyright © 2018 Sebastian Sanso. All rights reserved.
//

import UIKit
import Firebase

class SideViewController: UIViewController {
    static var inputHeight = 50
    
    let addProfileImage: UIImageView = {
        let pf = UIImageView()
        pf.image = UIImage(named: "Outlay Username")
        pf.contentMode = .scaleAspectFill
        pf.layer.masksToBounds = true
        return pf
    }()
    
    let nameLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.boldSystemFont(ofSize: 18)
        lb.textColor = .white
        lb.textAlignment = .center
        return lb
    }()
    
    let dummyView: UIView = {
        let view = UIView()
        view.backgroundColor = .rgb(r: 5, g: 220, b: 163)
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        view.layer.shadowOpacity = 0.4
        view.layer.shadowRadius = 4.0
        
        return view
    }()
    let dummyViewTwo: UIView = {
        let view = UIView()
        view.backgroundColor = .rgb(r: 50, g: 50, b: 50)
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        view.layer.shadowOpacity = 0.4
        view.layer.shadowRadius = 4.0
        return view
    }()
    let oneOnButton: UIButton = {
        let button = UIButton()
        button.setTitle("1 on 1", for: .normal)
        button.backgroundColor = .rgb(r: 50, g: 50, b: 50)
        button.heightAnchor.constraint(equalToConstant: CGFloat(inputHeight)).isActive = true
        return button
    }()
    
    let settingsButton: UIButton = {
        let button = UIButton()
        button.setTitle("Settings", for: .normal)
        button.backgroundColor = .rgb(r: 50, g: 50, b: 50)
        button.heightAnchor.constraint(equalToConstant: CGFloat(inputHeight)).isActive = true
        button.addTarget(self, action: #selector(handlePush), for: .touchUpInside)
        return button
    }()
    
    let settingsImage: UIImageView = {
        let pf = UIImageView()
        pf.image = UIImage(named: "Outlay Username")
        pf.contentMode = .scaleAspectFill
        pf.layer.masksToBounds = true
        return pf
    }()
    
    
    let logoutButton: UIButton = {
        let button = UIButton()
        button.setTitle("Logout", for: .normal)
        button.backgroundColor = .rgb(r: 50, g: 50, b: 50)
        button.heightAnchor.constraint(equalToConstant: CGFloat(inputHeight)).isActive = true
        button.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUserData()
        view.backgroundColor = .white
        view.addSubview(dummyView)
        view.addSubview(dummyViewTwo)
        view.addSubview(addProfileImage)
        view.addSubview(nameLabel)
        dummyView.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: view.frame.height/3)
        dummyViewTwo.anchor(dummyView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 12, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        addProfileImage.anchor(dummyView.topAnchor, left: view.leftAnchor, bottom: dummyView.bottomAnchor, right: view.rightAnchor, topConstant: 25, leftConstant: 50, bottomConstant: 60, rightConstant: 50, widthConstant: 0, heightConstant: 0)
        nameLabel.anchor(addProfileImage.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 8, leftConstant: 32, bottomConstant: 0, rightConstant: 32, widthConstant: 0, heightConstant: 0)
        
        let stackView = UIStackView(arrangedSubviews: [oneOnButton, settingsButton, logoutButton])
        stackView.axis = .vertical
        view.addSubview(stackView)
        stackView.anchor(dummyViewTwo.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addProfileImage.layer.cornerRadius = (addProfileImage.bounds.size.width)/2

    }
    
    func fetchUserData() {
        if Auth.auth().currentUser?.uid == nil {
            print("no")
            let loginController = NewLoginController()
            present(loginController, animated: true, completion: nil)
        } else {
            let fireRef = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!)
            fireRef.observe(.value, with: { (snapshot) in
                if let dictionary = snapshot.child("profileImageUrl").value {
                    if let url = NSURL(string: dictionary as! String) {
                        DispatchQueue.main.async {
                            self.addProfileImage.sd_setImage(with: url as URL, placeholderImage: UIImage(named: "Outlay Username"))
                        }
                    }
                }
                if let name = snapshot.child("username").value {
                    self.nameLabel.text = name as? String
                }
                
            }, withCancel: nil)
        }
        
    }
    
    @objc func handlePush() {
        let profileSettingsPage = SettingsTableView()
        self.navigationController?.pushViewController(profileSettingsPage, animated: true)
        let navigationBar = profileSettingsPage.navigationController!.navigationBar
        profileSettingsPage.navigationController!.isNavigationBarHidden = false
        profileSettingsPage.title = "Settings"
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.rgb(r: 5, g: 220, b: 163), NSAttributedString.Key.font: UIFont.init(name: "Avenir-Black", size: 24)!]
        navigationBar.barTintColor = .white
        navigationBar.isTranslucent = false
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
    }
    @objc func handleLogout() {
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let loginController = NewLoginController()
        present(loginController, animated: true, completion: nil)
    }
    
    
}

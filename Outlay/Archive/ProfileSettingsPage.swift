//
//  ProfileSettingsPage.swift
//  Outlay
//
//  Created by Sebastian Sanso on 1/14/18.
//  Copyright © 2018 Sebastian Sanso. All rights reserved.
//

import UIKit
import Firebase

class ProfileSettingsPage: UITableViewController {
    
    let cellId = "cellId"
    var thingsInSettings: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        view.backgroundColor = UIColor.white
        self.thingsInSettings.append("Edit Profile")
        self.thingsInSettings.append("Share")
        self.thingsInSettings.append("Report an issue")
        self.thingsInSettings.append("Terms")
        self.thingsInSettings.append("Logout")
        navigationItem.title = "Settings"
        tableView.rowHeight = 155
        tableView.register(SettingsCell.self, forCellReuseIdentifier: cellId)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return thingsInSettings.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! SettingsCell
        cell.signUpLabel.text = self.thingsInSettings[indexPath.item]
        return cell
    }
    @objc func handleLogout() {
        
        do {
            try Auth.auth().signOut()
            
        } catch let logoutError{
            print(logoutError)
        }
        
        let loginController = LoginController()
        present(loginController, animated: true, completion: nil)
        
    }
    
}
class SettingsCell: UITableViewCell {
    
    let signUpLabel: UILabel = {
        let label = UILabel()
        label.text = "Register for tutoring"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let buttonSettings: UIButton = {
        let button = UIButton()
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        addSubview(signUpLabel)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": signUpLabel]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": signUpLabel]))
    }
   
    
    
    
}

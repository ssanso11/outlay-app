//
//  SeachResultsTV.swift
//  Outlay
//
//  Created by Sebastian Sanso on 8/25/18.
//  Copyright © 2018 Sebastian Sanso. All rights reserved.
//

import UIKit
import Firebase


class SearchUsersTv: UITableViewController, UISearchResultsUpdating {
    let cellId = "cellId"
    var users = [User]()
    
    var usersArray = [NSDictionary?]()
    var filteredUsers = [NSDictionary?]()
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(SearchUsersTvCell.self, forCellReuseIdentifier: cellId)
        fecthUsers()
        fetchSearchUsers()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! SearchUsersTvCell
        var user : NSDictionary?
        user = filteredUsers[indexPath.row]
        //fix logic here
//        if filteredUsers.count != 0 {
//            user = filteredUsers[indexPath.row]
//            print("yes")
//        } else {
//            user = self.usersArray[indexPath.row]
//            print("no")
//        }
        
        cell.textLabel?.text = user?["name"] as? String
        
        if let profileImageUrl = user?["profileImageUrl"] {
            if let finalUrl = URL(string: (profileImageUrl as? String)!) {
                DispatchQueue.main.async {
                    cell.profileImageView.sd_setImage(with: finalUrl, placeholderImage: UIImage(named: "Outlay Username"))
                }
            }
            
            
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    
    func fecthUsers() {
        let ref = Database.database().reference().child("users")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            for snap in snapshot.children {
                let userSnap = snap as! DataSnapshot
                print(userSnap.key)
                let name = snapshot.child(userSnap.key).child("name").value
                let email = snapshot.child(userSnap.key).child("email").value
                let profilePicture = snapshot.child(userSnap.key).child("profileImageUrl").value
                let finalUrl = URL(string: profilePicture as! String)
                let userInit = User(email: email as! String, name: name as! String, profilePicture: finalUrl as! URL)
                self.users.append(userInit)
            }
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
            
        }, withCancel: nil)
    }
    
    func fetchSearchUsers() {
        let ref = Database.database().reference().child("users")
        ref.queryOrdered(byChild: "name").observe(.value, with: { (snapshot) in

            for snap in snapshot.children {
                let userSnap = snap as! DataSnapshot
                let name = snapshot.child(userSnap.key).value
                self.usersArray.append(name as? NSDictionary)
            }
            
            
            self.tableView.insertRows(at: [IndexPath(row: self.usersArray.count-1, section: 0)], with: UITableView.RowAnimation.automatic)
            
        }, withCancel: nil)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
        
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        //addsearch query results
        self.filteredUsers = usersArray.filter {user in
            let username = user!["name"] as? String
            return((username!.lowercased().contains(searchText.lowercased())))
            
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
    }
}

class SearchUsersTvCell: UITableViewCell {
    
    let profileImageView: UIImageView = {
        let pv = UIImageView()
        pv.backgroundColor = UIColor.clear
        pv.layer.cornerRadius = 25
        pv.clipsToBounds = true
        return pv
    }()
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 66, y: textLabel!.frame.origin.y, width: textLabel!.frame.width, height: textLabel!.frame.height)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        
        profileImageView.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, topConstant: 2, leftConstant: 4, bottomConstant: 2, rightConstant: 0, widthConstant: 50, heightConstant: 50)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



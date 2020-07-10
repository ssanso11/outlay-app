//
//  BrowseTutorsController.swift
//  Outlay
//
//  Created by Sebastian Sanso on 1/15/18.
//  Copyright © 2018 Sebastian Sanso. All rights reserved.
//



import UIKit
import Firebase
import Kingfisher
import SDWebImage

class SearchBarHeaderCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Browse By Category"
        label.font.withSize(16)
        label.textColor = UIColor.black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    func setupViews() {
        backgroundColor = .clear
    
        
        addSubview(nameLabel)
        
        
        nameLabel.anchor(self.topAnchor, left: self.leftAnchor, bottom: nil, right: nil, topConstant: 12, leftConstant: 12, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class BrowseCell: UICollectionViewCell {
    
    var posts = [Post]()
    
    
    //this gets called when a cell is dequeued
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        setupViews()
        fetchUserPosts()
    }
    
    func fetchUserPosts() {
        
        Database.database().reference().child("posts").child((Auth.auth().currentUser?.uid)!).observe(.value, with: { (snapshot) in
            let postId = snapshot.key
            
            for snap in snapshot.children {
                let userSnap = snap as! DataSnapshot
                let postText = userSnap.child("postText").value
                let postUrl = userSnap.child("postLinks").value
                let postDate = userSnap.child("postDate").value
                if let urls = userSnap.child("postImageUrl").value as? [String:String] {
                    let finalUrl = urls.map {k,v in URL(string: v)}
                    let user = Post(postText: postText as! String , postLinks: postUrl as! String, postDate: postDate as! NSNumber, postId: postId , postImageUrl: finalUrl as! [URL])
                    self.posts.append(user)
                }
                
            }
            //print(self.posts.count)
            
            
            //this will crash because of background thread, so lets use dispatch_async to fix
            
            
        }, withCancel: nil)
        
        
    }
    
    let separatorLineView: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        lineView.isHidden = false
        return lineView
    }()
    
    
    let mainImageView: UIImageView = {
        let pv = UIImageView()
        pv.contentMode = .scaleAspectFill
        pv.clipsToBounds = true
        pv.backgroundColor = UIColor.clear
        return pv
    }()
    
    
    
    //add like and comment views
    
    func setupViews() {
        backgroundColor = .clear
        
        
        addSubview(mainImageView)
        
        mainImageView.fillSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class BrowsePostsController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, UISearchDisplayDelegate {
    
    
    
    var searchController: UISearchController!

    
    var posts = [Post]()
    var usersArray = [NSDictionary?]()
    var filteredUsers = [NSDictionary?]()
    
    
    let cellId = "cellId"
    let headerId = "headerId"
    
    let separatorLineView: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        lineView.isHidden = false
        return lineView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        collectionView?.register(BrowseCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(SearchBarHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
        
        
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.showsVerticalScrollIndicator = false
        
        
        fetchUserPosts()
        fetchUsers()
        
        let src = SearchUsersTv()
        searchController = UISearchController(searchResultsController: src)
        
        searchController.searchResultsUpdater = src
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        
        
        
        
        view.addSubview(separatorLineView)
        separatorLineView.anchor(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0.5)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! BrowseCell
        let user = posts[indexPath.item]
        
        if let profileImageUrl = user.postImageUrl?.first {
            DispatchQueue.main.async {
                cell.mainImageView.sd_setImage(with: profileImageUrl, placeholderImage: UIImage(named: "Outlay Username"))
            }
            
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width-2)/3
        return CGSize(width: width, height: width)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! SearchBarHeaderCell
            
            
            
            return header
        } else {
            fatalError("Unexpected element kind")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 250)
    }
    
    
    func fetchUsers() {
        Database.database().reference().child("users").queryOrdered(byChild: "name").observe(.childAdded, with: { (snapshot) in
            self.usersArray.append(snapshot.value as? NSDictionary)
            
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
            
            
        }, withCancel: nil)
        
        
    }
    
    
    func fetchUserPosts() {
        
        Database.database().reference().child("posts").observe(.value, with: { (snapshot) in
            for snap in snapshot.children {
                let userSnap = snap as! DataSnapshot
                let postId = userSnap.key
                for snap in userSnap.children {
                    let userSnap = snap as! DataSnapshot
                    let postText = userSnap.child("postText").value
                    let postUrl = userSnap.child("postLinks").value
                    let postDate = userSnap.child("postDate").value
                    if let urls = userSnap.child("postImageUrl").value as? [String:String] {
                        let finalUrl = urls.map {k,v in URL(string: v)}
                        let user = Post(postText: postText as! String , postLinks: postUrl as! String, postDate: postDate as! NSNumber, postId: postId , postImageUrl: finalUrl as! [URL])
                        self.posts.append(user)
                    }
                }
                
                
            }
            //print(self.posts.count)
            
            
            //this will crash because of background thread, so lets use dispatch_async to fix
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
            
        }, withCancel: nil)
        
        
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    
    
    
}















//
//  FullCells.swift
//  Outlay
//
//  Created by Sebastian Sanso on 1/11/18.
//  Copyright © 2018 Sebastian Sanso. All rights reserved.
//

import UIKit
import Firebase

class FullCells: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var viewController: ViewController?
    var posts = [Post]()
    
    var subjectCategory: SubjectCategory? {
        didSet {
            if let name = subjectCategory?.name {
                nameLabel.text = name
            }
        }
    }
    
    private let cellId = "appCellId"
    
    let appsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = UIColor.white//init(red: 61/255, green: 201/255, blue: 150/255, alpha: 1)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font.withSize(16)
        label.textColor = UIColor.black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        fetchUserPosts()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fetchUserPosts() {
        Database.database().reference().child("posts").observe(.value, with: { (snapshot) in
            //print(snapshot)
            
            
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
            
            
            //this will crash because of background thread, so lets use dispatch_async to fix
            DispatchQueue.main.async {
                self.appsCollectionView.reloadData()
            }
            
        }, withCancel: nil)
        
        
    }
    
    
    
    
    
    
    func setupViews() {
        backgroundColor = UIColor.clear
        addSubview(appsCollectionView)
        addSubview(nameLabel)
        appsCollectionView.dataSource = self
        appsCollectionView.delegate = self
        
        appsCollectionView.register(AppCell.self, forCellWithReuseIdentifier: cellId)
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-14-[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": nameLabel]))
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": appsCollectionView]))
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[nameLabel(30)][v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": appsCollectionView, "nameLabel": nameLabel]))
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! AppCell
        let user = posts[indexPath.item]
        if let id = tutorUser?.postId {
            let ref = Database.database().reference().child("users").child(id)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.child("name").value {
                    let formattedString = NSMutableAttributedString()
                    cell.mathLabel.text = dictionary as? String
                    formattedString.bold("\(dictionary): ").normal(user.postText)
                    //cell.captionLabel.attributedText = formattedString
                }
                if let dictionary = snapshot.child("profileImageUrl").value {
                    if let url = NSURL(string: dictionary as! String) {
                        DispatchQueue.main.async {
                            cell.profileImage.sd_setImage(with: url as URL, placeholderImage: UIImage(named: "Outlay Username"))
                        }
                        
                    }
                    
                }
                
                
            }, withCancel: nil)
        }
        //cell.categoryLabel.text = user.postLinks
        cell.backgroundColor = UIColor.init(red: 61/255, green: 201/255, blue: 150/255, alpha: 1)
        cell.layer.cornerRadius = 5
        if let profileImageUrl = user.postImageUrl?.first {
            DispatchQueue.main.async {
                cell.profileImage.sd_setImage(with: profileImageUrl, placeholderImage: UIImage(named: "Outlay Username"))
            }
            
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let subject = posts[indexPath.item]
        viewController?.showTutorDetailForTutor(subject: subject)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 250, height: frame.height-32)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 0, left: 14, bottom: 0, right: 14)
    }
    var tutorUser: Post? {
        didSet {
            setupNameAndProfileImage()
        }
    }
    
    func setupNameAndProfileImage() {
        //change
        
        if let id = tutorUser?.postId {
            let ref = Database.database().reference().child("users").child(id)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if snapshot.child("name").value != nil {
                    //self.navigationItem.title = dictionary as? String
                    
                }
                
            }, withCancel: nil)
        }
    }
    
}

class AppCell: UICollectionViewCell {
    
    var tutorUser: Post? {
        didSet {
            setupNameAndProfileImage()
        }
    }
    
    func setupNameAndProfileImage() {
        //change
        
        if let id = tutorUser?.postId {
            let ref = Database.database().reference().child("users").child(id)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.child("name").value {
                    self.mathLabel.text = dictionary as? String
                    
                }
                
            }, withCancel: nil)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    
    lazy var mathLabel: UILabel = {
        let label = UILabel()
        label.font.withSize(14)
        label.textColor = UIColor.white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.bringSubviewToFront(label)
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        return label
    }()
    
    let categoryLabel: UILabel = {
        let label = UILabel()
        label.font.withSize(10)
        label.textColor = UIColor.white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font.withSize(6)
        label.textColor = UIColor.white
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let profileImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.masksToBounds = true
        image.clipsToBounds = true
        image.layer.cornerRadius = 5
        image.backgroundColor = .white
        return image
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupViews() {
        
        addSubview(profileImage)
        addSubview(mathLabel)
        addSubview(categoryLabel)
        addSubview(descriptionLabel)
        
        mathLabel.frame = CGRect(x: 0, y: -200, width: frame.width, height: frame.height)
        categoryLabel.frame = CGRect(x: 55, y: -30, width: frame.width, height: frame.height)
        descriptionLabel.frame = CGRect(x: 25, y: 30, width: frame.width, height: frame.height)
        profileImage.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        
    }
}

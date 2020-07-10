//
//  DummyViewController.swift
//  Outlay
//
//  Created by Sebastian Sanso on 8/5/18.
//  Copyright © 2018 Sebastian Sanso. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher
import SDWebImage
import ImageSlideshow

class HeaderCell: UICollectionViewCell {
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    let profileImageView: UIImageView = {
        let pv = UIImageView()
        pv.backgroundColor = UIColor.clear
        pv.layer.cornerRadius = 50
        pv.clipsToBounds = true
        return pv
    }()
    let wordLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    func setupViews() {
        backgroundColor = .clear
        
        addSubview(profileImageView)
        addSubview(wordLabel)
        
        profileImageView.anchor(self.topAnchor, left: self.leftAnchor, bottom: nil, right: nil, topConstant: 12, leftConstant: 12, bottomConstant: 0, rightConstant: 0, widthConstant: 100, heightConstant: 100)
        wordLabel.anchor(profileImageView.topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: self.rightAnchor, topConstant: 30, leftConstant: 12, bottomConstant: 0, rightConstant: 12, widthConstant: 0, heightConstant: 40)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class WordCell: UICollectionViewCell {
    
    var posts = [Post]()
    let cellId = "cellId"
    var mainImagesCount: Int?
    
    //this gets called when a cell is dequeued
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        fetchImages()
        setupViews()
        
    }
    
    
    let separatorLineView: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        lineView.isHidden = false
        return lineView
    }()
    
    let wordLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let profileImageView: UIImageView = {
        let pv = UIImageView()
        pv.backgroundColor = UIColor.clear
        pv.layer.cornerRadius = 25
        pv.clipsToBounds = true
        return pv
    }()
    let mainImageView: ImageSlideshow = {
        let pv = ImageSlideshow()
        pv.contentScaleMode = .scaleAspectFill
        pv.zoomEnabled = true
        pv.circular = false
        return pv
    }()
    let appsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    let captionLabel: UITextView = {
        let label = UITextView()
        label.backgroundColor = UIColor.clear
        label.isUserInteractionEnabled = true
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    //add like and comment views
    let likeButton: UIButton = {
        let lb = UIButton()
        lb.setImage(#imageLiteral(resourceName: "thumbs-up-unfilled"), for: .normal)
        lb.imageView?.contentMode = .scaleAspectFit
        
        return lb
    }()
    let unlikeButton: UIButton = {
        let lb = UIButton(type: .system)
        lb.setImage(#imageLiteral(resourceName: "thumbs-up-unfilled"), for: .normal)
        lb.imageView?.contentMode = .scaleAspectFit
        lb.addTarget(self, action: #selector(handleUnlike), for: .touchUpInside)
        return lb
    }()
    let likeLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.green
        return label
    }()
    
    
    @objc func handleUnlike() {
        self.unlikeButton.isEnabled = false
        print("nay")
        let ref = Database.database().reference()
        Database.database().reference().child("posts").observe(.value, with: { (snapshot) in
            for snap in snapshot.children {
                let userSnap = snap as! DataSnapshot
                let postId = userSnap.key
                for snap in userSnap.children {
                    let userSnap = snap as! DataSnapshot
                    if let properties = userSnap.value as? [String : AnyObject] {
                        if let peopleWhoLike = properties["peopleWhoLike"] as? [String : AnyObject] {
                            for (id,person) in peopleWhoLike {
                                if person as? String == Auth.auth().currentUser!.uid {
                                ref.child("posts").child(postId).child(userSnap.key).child("peopleWhoLike").child(id).removeValue(completionBlock: { (error, reff) in
                                        if error == nil {
                                            ref.child("posts").child(postId).child(userSnap.key).observeSingleEvent(of: .value, with: { (snap) in
                                                if let prop = snap.value as? [String : AnyObject] {
                                                    if let likes = prop["peopleWhoLike"] as? [String : AnyObject] {
                                                        let count = likes.count
                                                        self.likeLabel.text = "\(count) Likes"
                                                        ref.child("posts").child(postId).child(userSnap.key).updateChildValues(["likes" : count])
                                                    }else {
                                                        self.likeLabel.text = "0 Likes"
                                                        print("disliked")
                                                            ref.child("posts").child(postId).child(userSnap.key).updateChildValues(["likes" : 0])
                                                    }
                                                }
                                            })
                                        }
                                    })
                                    
                                    self.likeButton.isHidden = false
                                    self.unlikeButton.isHidden = true
                                    self.unlikeButton.isEnabled = true
                                    break
                                    
                                }
                            }
                        }
                    }
                }
                
                
            }
            
            
        }, withCancel: nil)
        
        ref.removeAllObservers()
        
        
       
    }
    @objc func handleLike() {
        print("yay")
        self.likeButton.isEnabled = false
        let ref = Database.database().reference()
        let keyToPost = ref.child("posts").childByAutoId().key
        Database.database().reference().child("posts").observe(.value, with: { (snapshot) in
            //print(snapshot)
            
            
            for snap in snapshot.children {
                let userSnap = snap as! DataSnapshot
                let postId = userSnap.key
                for snap in userSnap.children {
                    let userSnap = snap as! DataSnapshot
                    if let post = userSnap.value as? [String : AnyObject] {
                        let updateLikes: [String : Any] = ["peopleWhoLike/\(keyToPost)" : Auth.auth().currentUser!.uid]
                        ref.child("posts").child(postId).child(userSnap.key).updateChildValues(updateLikes, withCompletionBlock: { (error, reff) in
                            
                            if error == nil {
                                ref.child("posts").child(postId).child(userSnap.key).observeSingleEvent(of: .value, with: { (snap) in
                                    if let properties = snap.value as? [String : AnyObject] {
                                        if let likes = properties["peopleWhoLike"] as? [String : AnyObject] {
                                            let count = likes.count
                                            self.likeLabel.text = "\(count) Likes"
                                            
                                            let update = ["likes" : count]
                                            ref.child("posts").child(postId).child(userSnap.key).updateChildValues(update)
                                            
                                            self.likeButton.isHidden = true
                                            self.unlikeButton.isHidden = false
                                            self.unlikeButton.bringSubviewToFront(self.unlikeButton)
                                            self.likeButton.isEnabled = true
                                        }
                                    }
                                })
                            }
                        })
                    }
                }
                
                
            }
            
            
        }, withCancel: nil)
        
        ref.removeAllObservers()
    }
    
    
    
    func setupViews() {
        backgroundColor = .clear
        
        
        
        addSubview(wordLabel)
        addSubview(profileImageView)
        addSubview(separatorLineView)
        addSubview(captionLabel)
        addSubview(likeButton)
        addSubview(unlikeButton)
        addSubview(likeLabel)
        addSubview(mainImageView)
        
        likeButton.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        unlikeButton.addTarget(self, action: #selector(handleUnlike), for: .touchUpInside)
        
//        appsCollectionView.delegate = self
//        appsCollectionView.dataSource = self
//        appsCollectionView.register(MainImageCollectionView.self, forCellWithReuseIdentifier: cellId)
        
        profileImageView.anchor(self.topAnchor, left: self.leftAnchor, bottom: nil, right: nil, topConstant: 12, leftConstant: 12, bottomConstant: 0, rightConstant: 0, widthConstant: 50, heightConstant: 50)
        wordLabel.anchor(profileImageView.topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: self.rightAnchor, topConstant: 12, leftConstant: 12, bottomConstant: 0, rightConstant: 12, widthConstant: 0, heightConstant: 20)
        separatorLineView.anchor(nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0.5)
        mainImageView.anchor(profileImageView.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 500)
        captionLabel.anchor(mainImageView.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 50)
        likeButton.anchor(mainImageView.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topConstant: 50, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 20)
        unlikeButton.anchor(mainImageView.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topConstant: 50, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 20)
        likeLabel.anchor(mainImageView.bottomAnchor, left: self.leftAnchor, bottom: nil, right: nil, topConstant: 10, leftConstant: 100, bottomConstant: 0, rightConstant: 5, widthConstant: 0, heightConstant: 20)
    }
    
    
    
    func fetchImages() {
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
            
            
            DispatchQueue.main.async {
                self.appsCollectionView.reloadData()
            }
            
        }, withCancel: nil)
    }
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



class UserProfileController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    

    var posts = [Post]()
    var images = [Images]()
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
        collectionView?.register(WordCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(HeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
        
        fetchUserPosts()
        
        view.addSubview(separatorLineView)
        separatorLineView.anchor(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0.5)
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! WordCell
        let user = posts[indexPath.item]
        //let image = images[indexPath.item]

        
        if user.peopleWhoLikePost != nil {
            for person in (user.peopleWhoLikePost)! {
                if person == Auth.auth().currentUser?.uid {
                    cell.likeButton.isHidden = true
                    cell.unlikeButton.isHidden = false
                }
            }
        }
        
        var imageSource: [KingfisherSource?] = []
        
        for each in user.postImageUrl! {
            let imgUrl = KingfisherSource(url: each)
            let kfURL = imgUrl
            imageSource.append(kfURL)
            cell.mainImageView.setImageInputs(imageSource as! [InputSource])
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
            
        }
            
    
        

        if let id = tutorUser?.postId {
            let ref = Database.database().reference().child("users").child(id)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.child("name").value {
                    let formattedString = NSMutableAttributedString()
                    cell.wordLabel.text = dictionary as? String
                    formattedString.bold("\(dictionary): ").normal(user.postText)
                    cell.captionLabel.attributedText = formattedString
                }
                if let dictionary = snapshot.child("profileImageUrl").value {
                    if let url = NSURL(string: dictionary as! String) {
                        DispatchQueue.main.async {
                            cell.profileImageView.sd_setImage(with: url as URL, placeholderImage: UIImage(named: "Outlay Username"))
                        }
                        
                    }
                    
                }

                
            }, withCancel: nil)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 650)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! HeaderCell
            
            if let id = tutorUser?.postId {
                let ref = Database.database().reference().child("users").child(id)
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let dictionary = snapshot.child("name").value {
                        header.wordLabel.text = dictionary as? String
                    }
                    if let dictionary = snapshot.child("profileImageUrl").value {
                        if let url = NSURL(string: dictionary as! String) {
                            DispatchQueue.main.async {
                                header.profileImageView.sd_setImage(with: url as URL, placeholderImage: UIImage(named: "Outlay Username"))
                            }
                            
                        }
                        
                    }
                    
                    
                }, withCancel: nil)
            }

            
            
            
            return header
        } else {
            fatalError("Unexpected element kind")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 250)
    }
    
    
    var tutorUser: Post? {
        didSet {
            setupNameAndProfileImage()
        }
    }
    
    func setupNameAndProfileImage() {
        
        if let id = tutorUser?.postId {
            let ref = Database.database().reference().child("users").child(id)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.child("name").value {
                    self.navigationItem.title = dictionary as? String
                    
                }
                
            }, withCancel: nil)
        }

    }
    
    
    func fetchUserPosts() {
        let uid = tutorUser?.postId
        Database.database().reference().child("posts").child(uid!).observe(.value, with: { (snapshot) in

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
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }

        }, withCancel: nil)


    }
    
}

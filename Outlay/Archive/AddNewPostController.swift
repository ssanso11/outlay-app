//
//  addNewPostController.swift
//  Outlay
//
//  Created by Sebastian Sanso on 7/30/18.
//  Copyright © 2018 Sebastian Sanso. All rights reserved.
//

import Foundation
import UIKit
import UITextView_Placeholder
import ImagePicker
import Lightbox
import Firebase
import FirebaseStorage


//View controller for adding a post
class AddNewPostController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ImagePickerDelegate {
    
    var imageArray = [UIImage]()
    let now = Date()
    let pastDate = Date(timeIntervalSinceNow: 60)
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
        guard images.count > 0 else { return }
        
        
        let lightboxImages = images.map {
            return LightboxImage(image: $0)
        }
        let lightbox = LightboxController(images: lightboxImages, startIndex: 0)
        imagePicker.present(lightbox, animated: true, completion: nil)
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
        let lightboxImages = images.first
        addImagesToPost.image = lightboxImages
        imageArray.append(contentsOf: images)
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    
    lazy var addImagesToPost: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "addPostCustomTabBar")
        imageView.backgroundColor = UIColor.white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        imageView.isUserInteractionEnabled = true
        imageView.layer.cornerRadius = 5
        navigationItem.title = "Post a Project"
        return imageView
    }()
    
    
    @objc func handleSelectProfileImageView() {
        
        if addImagesToPost.image == UIImage(named: "addPostCustomTabBar") {
            let picker = ImagePickerController()
            
            picker.delegate = self
            
            
            present(picker, animated: true, completion: nil)
        } else {
            let lightboxImages = imageArray.map {
                return LightboxImage(image: $0)
            }
            let lightbox = LightboxController(images: lightboxImages, startIndex: 0)
            present(lightbox, animated: true, completion: nil)
        }
        
    }
    
    let postText: UITextView = {
        let pt = UITextView()
        let myColor = UIColor.init(red: 61/255, green: 201/255, blue: 150/255, alpha: 1)
        pt.placeholder = "Add a short summary or a how-to..."
        pt.font = pt.font?.withSize(14)
//        pt.layer.borderColor = myColor.cgColor
//        pt.layer.borderWidth = 1.0
        pt.autocorrectionType = .yes
        pt.translatesAutoresizingMaskIntoConstraints = false
        return pt
    }()
    
    let additionalLinksText: UITextField = {
        let at = UITextField()
        let myColor = UIColor.init(red: 61/255, green: 201/255, blue: 150/255, alpha: 1)
        at.placeholder = "Any additional links or references..."
        at.font = at.font?.withSize(14)
//        at.layer.borderColor = myColor.cgColor
//        at.layer.borderWidth = 1.0
        at.translatesAutoresizingMaskIntoConstraints = false
        at.autocorrectionType = .no
        at.autocapitalizationType = .none
        return at
    }()
    
    let blurryView: UIVisualEffectView = {
        let bv = UIVisualEffectView()
        return bv
    }()
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let ati = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        ati.translatesAutoresizingMaskIntoConstraints = false
        return ati
    }()
    var effect: UIVisualEffect!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        view.addSubview(addImagesToPost)
        view.addSubview(postText)
        view.addSubview(additionalLinksText)
        view.addSubview(activityIndicatorView)
        view.addSubview(blurryView)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: .plain, target: self, action: #selector(addPostToFirebase))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelPostAction))
        effect = blurryView.effect
        blurryView.effect = nil
        
        setupAddImagesToPost()
        setupPostText()
        setupAdditionalLinksText()
        addUILines()
        setupActivityIndicator()
    }
    
    func setupAddImagesToPost() {
        //need x, y, width, height constraints
        addImagesToPost.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        addImagesToPost.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -210).isActive = true
        addImagesToPost.widthAnchor.constraint(equalToConstant: 350).isActive = true
        addImagesToPost.heightAnchor.constraint(equalToConstant: 170).isActive = true
    }
    
    func setupPostText() {
        //need x, y, width, height constraints
        postText.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        postText.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 40).isActive = true
        postText.widthAnchor.constraint(equalToConstant: 400).isActive = true
        postText.heightAnchor.constraint(equalToConstant: 300).isActive = true
    }
    func setupAdditionalLinksText() {
        
        additionalLinksText.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        additionalLinksText.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 250).isActive = true
        additionalLinksText.widthAnchor.constraint(equalToConstant: 400).isActive = true
        additionalLinksText.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
    
    func setupActivityIndicator() {
        activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        activityIndicatorView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        activityIndicatorView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
//        blurryView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        blurryView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
//        blurryView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
//        blurryView.widthAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
    
    func addUILines() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 20, y: 563))
        path.addLine(to: CGPoint(x: 400, y: 563))
        path.move(to: CGPoint(x: 20, y: 255))
        path.addLine(to: CGPoint(x: 400, y: 255))
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.lineWidth = 1.0
        
        view.layer.addSublayer(shapeLayer)
    }
    
    
    @objc func cancelPostAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //adding the post to firebase
    @objc func addPostToFirebase() {
        activityIndicatorView.startAnimating()
        self.blurryView.effect = self.effect
        let imageCount = imageArray.count
        let postTextCount = postText.text.count
        let postTextText = postText.text
        let postTextLinks = additionalLinksText.text
        let postId = Auth.auth().currentUser?.uid
        


        let ref = Database.database().reference().child("posts")
        
        let childRef = ref.child(postId!).childByAutoId()
        
        if(postTextCount>0 && imageCount>0) {
            for image in imageArray {
                let postRef = childRef.child("postImageUrl")
                //change this to imagenumberXX add for loop
                let autoID = postRef.childByAutoId().key
                let imageName = NSUUID().uuidString
                let storageRef = Storage.storage().reference().child("post_images")
                let childStorageRef = storageRef.child("Images").child(postId!).child(autoID).child("\(imageName).jpeg")
                
                
            
                if let uploadData = image.jpeg(.medium) {
                    print(uploadData.count)
                    childStorageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                        if error != nil {
                            print(error as Any)
                            return
                        }
                        storageRef.downloadURL { url, error in
                            if let error = error {
                                
                            } else {
                                let values = ["postText": postTextText!, "postLinks": postTextLinks!, "postDate":  Date().timeIntervalSince1970, "likes": 0] as [String : Any]
                                let value = [autoID: url!]  as [String : Any]
                                childRef.updateChildValues(values)
                                postRef.updateChildValues(value)
                                self.dismiss(animated: true, completion: nil)
                                self.activityIndicatorView.stopAnimating()
                                self.blurryView.effect = nil
                            }
                        }
                        
                    })
                }
            }
            
        }
        else if(postTextCount>0){
             print("add an image")
        }
            
        else if(imageCount>0)
        {
           print("add a description")
        }  else {
            //showAlert(title: "error", message: "enter something.")
            print("Please enter something")
        }
    }
    
}



//
//  tutorProfileController.swift
//  Outlay
//
//  Created by Sebastian Sanso on 1/21/18.
//  Copyright © 2018 Sebastian Sanso. All rights reserved.
//

import UIKit
import Cosmos

class TutorProfileController: UICollectionViewController {
    //private let headerId = "headerId"
    var tutorUser: Post? {
        didSet {
            navigationItem.title = tutorUser?.postText
            //nameLabel.text = tutorUser?.postText
//            if let profileImageUrl = tutorUser?.profileImageUrl {
//                let url = URL(string: profileImageUrl)
//                self.profileImage.sd_setImage(with: url, placeholderImage: UIImage(named: "Outlay Username"))
//            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        setupViews()
    }
    
    
    let profileImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.masksToBounds = false
        image.clipsToBounds = true
        image.layer.cornerRadius = 50
        image.backgroundColor = .white
        return image
    }()
    let nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = UIColor.white
        lbl.textAlignment = .center
        lbl.font = lbl.font.withSize(26)
        return lbl
    }()
    let subNameLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Math tutor"
        lbl.textColor = UIColor.white
        lbl.textAlignment = .center
        lbl.font = lbl.font.withSize(15)
        return lbl
    }()
    let cosmosView: CosmosView = {
        let cv = CosmosView()
        cv.rating = 4
        cv.text = "(123)"
        cv.settings.fillMode = .precise
        // Other fill modes: .half, .precise
        
        cv.settings.updateOnTouch = false
        //not editable
        
        // Change the size of the stars
        cv.settings.starSize = 30
        // Set the distance between stars
        cv.settings.starMargin = 5
        
        // Set the color of a filled star
        cv.settings.filledColor = UIColor.orange
        
        // Set the border color of an empty star
        cv.settings.emptyBorderColor = UIColor.orange
        
        // Set the border color of a filled star
        cv.settings.filledBorderColor = UIColor.orange
        
        // A closure that is called when user changes the rating by touching the view.
        // This can be used to update UI as the rating is being changed by moving a finger.
        //cv.didTouchCosmos = { rating in }

        return cv
    }()
    let submitRatingButton: UIButton = {
        let sr = UIButton()
        
        return sr
    }()
    func submitRating() {
        return
    }
    
    
    func setupViews() {
        view.addSubview(profileImage)
        view.addSubview(nameLabel)
        view.addSubview(subNameLabel)
        view.addSubview(cosmosView)
        
        profileImage.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -140)
        profileImage.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -150).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: 100).isActive = true
        profileImage.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
//        nameLabel.anchorWithConstantsToTop(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 100, bottomConstant: 450, rightConstant: 0)
//        subNameLabel.anchorWithConstantsToTop(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 100, bottomConstant: 400, rightConstant: 0)
//        cosmosView.anchorWithConstantsToTop(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
        
    }
}

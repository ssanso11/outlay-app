//
//  ViewController.swift
//  Outlay
//
//  Created by Sebastian Sanso on 1/5/18.
//  Copyright © 2018 Sebastian Sanso. All rights reserved.
//

import UIKit
import Firebase
import MapKit
import CoreLocation
//import LBTAComponents


class ViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UITabBarControllerDelegate {
    
    
    
    private let cellId = "cellId"
    var subjectCategories: [SubjectCategory]?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Home"
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
        collectionView?.backgroundColor = UIColor.white
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.showsVerticalScrollIndicator = false
        subjectCategories = SubjectCategory.sampleSubjectCategories()
        collectionView?.register(FullCells.self, forCellWithReuseIdentifier: cellId)
    }
    
    func showTutorDetailForTutor(subject: Post) {
        let layout = UICollectionViewFlowLayout()
        let userProfileController = UserProfileController(collectionViewLayout: layout)
        userProfileController.tutorUser = subject
        self.navigationController?.pushViewController(userProfileController, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! FullCells
        
        cell.subjectCategory = subjectCategories?[indexPath.item]
        cell.viewController = self
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = subjectCategories?.count {
            return count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 500)
    }
    

    
    
    @objc func handleLogout() {
        
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let loginController = LoginController()
        present(loginController, animated: true, completion: nil)
    }
    
    
    
}












//extension UIView {
//
//    func anchorToTop(_ top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil) {
//
//        anchorWithConstantsToTop(top, left: left, bottom: bottom, right: right, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
//    }
//
//    func anchorWithConstantsToTop(_ top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, topConstant: CGFloat = 0, leftConstant: CGFloat = 0, bottomConstant: CGFloat = 0, rightConstant: CGFloat = 0) {
//
////        _ = anchor(top, left: left, bottom: bottom, right: right, topConstant: topConstant, leftConstant: leftConstant, bottomConstant: bottomConstant, rightConstant: rightConstant)
//    }
//
//    func anchor(_ top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, topConstant: CGFloat = 0, leftConstant: CGFloat = 0, bottomConstant: CGFloat = 0, rightConstant: CGFloat = 0, widthConstant: CGFloat = 0, heightConstant: CGFloat = 0) -> [NSLayoutConstraint] {
//        translatesAutoresizingMaskIntoConstraints = false
//
//        var anchors = [NSLayoutConstraint]()
//
//        if let top = top {
//            anchors.append(topAnchor.constraint(equalTo: top, constant: topConstant))
//        }
//
//        if let left = left {
//            anchors.append(leftAnchor.constraint(equalTo: left, constant: leftConstant))
//        }
//
//        if let bottom = bottom {
//            anchors.append(bottomAnchor.constraint(equalTo: bottom, constant: -bottomConstant))
//        }
//
//        if let right = right {
//            anchors.append(rightAnchor.constraint(equalTo: right, constant: -rightConstant))
//        }
//
//        if widthConstant > 0 {
//            anchors.append(widthAnchor.constraint(equalToConstant: widthConstant))
//        }
//
//        if heightConstant > 0 {
//            anchors.append(heightAnchor.constraint(equalToConstant: heightConstant))
//        }
//
//        anchors.forEach({$0.isActive = true})
//
//        return anchors
//    }
//
//}
//

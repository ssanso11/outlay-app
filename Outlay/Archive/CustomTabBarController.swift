//
//  CustomTabBarController.swift
//  Outlay
//
//  Created by Sebastian Sanso on 1/14/18.
//  Copyright © 2018 Sebastian Sanso. All rights reserved.
//

import UIKit

class OutlayCustomTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    let titleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "OutlayWordLogoBlack")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        UINavigationBar.appearance().barTintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        tabBar.tintColor = UIColor.init(red: 61/255, green: 201/255, blue: 150/255, alpha: 1)
        tabBar.barTintColor = UIColor.white
        let layout = UICollectionViewFlowLayout()
        let firstViewController = ViewController(collectionViewLayout: layout)
        let mainViewHomePageController = UINavigationController(rootViewController: firstViewController)
        mainViewHomePageController.title = "Home"
        mainViewHomePageController.tabBarItem.image = UIImage(named: "Outlay Username")
        
        let profileSettingsPage = AvatarSelectionController()
        let settingsPageController = UINavigationController(rootViewController: profileSettingsPage)
        settingsPageController.title = "Settings"
        settingsPageController.tabBarItem.image = UIImage(named: "Outlay Password")
        
        let browseTutorsPage = MapViewController()
        let browsePageController = UINavigationController(rootViewController: browseTutorsPage)
        browsePageController.title = "Browse"
        browsePageController.tabBarItem.image = UIImage(named: "Outlay Email")
        
        let signUpTutorsPage = ARViewController()
        let signUpForTutorPageController = UINavigationController(rootViewController: signUpTutorsPage)
        signUpForTutorPageController.title = "AR"
        signUpForTutorPageController.tabBarItem.image = UIImage(named: "AppIcon")
        
        let addNewPostPage = AddNewPostController()
        addNewPostPage.title = "Add Post"
        addNewPostPage.tabBarItem.image = UIImage(named: "addPostCustomTabBar-40")
        
    
        viewControllers = [mainViewHomePageController, browsePageController, addNewPostPage, signUpForTutorPageController, settingsPageController]
    }
    


    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let isModalView = viewController is AddNewPostController
        
        if isModalView {
            let addPostPopUpController = UINavigationController(rootViewController: AddNewPostController())
            self.present(addPostPopUpController, animated: true, completion: nil)
            
            return false
        } else {
            return true
        }
    }
}

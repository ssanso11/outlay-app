//
//  SettingsViewController.swift
//  Outlay
//
//  Created by Sebastian Sanso on 12/29/18.
//  Copyright © 2018 Sebastian Sanso. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

class NewEditProfileController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var pushToken: String?
    
    let currentUser = Auth.auth().currentUser
    
    
    let addProfileImage: UIImageView = {
        let pf = UIImageView()
        pf.image = UIImage(named: "Outlay Username")
        pf.contentMode = .scaleAspectFill
        pf.layer.masksToBounds = true
        return pf
    }()
    
    let dummyButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(handleSelectProfileImageView), for: .touchUpInside)
        return button
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
    
    
    let userNameText: TextField = {
        let fn = TextField()
        fn.backgroundColor = .rgb(r: 50, g: 50, b: 50)
        //fn.layer.cornerRadius = 30
        fn.autocorrectionType = .no
        fn.autocapitalizationType = .none
        fn.textColor = .white
        
        fn.addTarget(self, action: #selector(handleTextFieldChange), for: .editingChanged)
        return fn
    }()
    
    let emailText: TextField = {
        let fn = TextField()
        fn.autocorrectionType = .no
        fn.autocapitalizationType = .none
        fn.setBottomBorder(withColor: .blue)
        fn.backgroundColor = .rgb(r: 50, g: 50, b: 50)
        //fn.layer.cornerRadius = 30
        
        fn.textColor = .white
        fn.addTarget(self, action: #selector(handleTextFieldChange), for: .editingChanged)
        return fn
    }()
    
    let passwordText: TextField = {
        let fn = TextField()
        fn.autocorrectionType = .no
        fn.autocapitalizationType = .none
        fn.setBottomBorder(withColor: .blue)
        fn.backgroundColor = .rgb(r: 50, g: 50, b: 50)
        fn.isSecureTextEntry = true
        //fn.layer.cornerRadius = 30
        
        fn.textColor = .white
        fn.addTarget(self, action: #selector(handleTextFieldChange), for: .editingChanged)
        return fn
    }()
    
    let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Submit Changes", for: .normal)
        button.backgroundColor = .rgb(r: 5, g: 220, b: 163)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setTitleColor(UIColor(white: 1, alpha: 0.5), for: .disabled)
        button.isEnabled = false
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(updateUserInfo), for: .touchUpInside)
        button.layer.cornerRadius = 60/2
        return button
    }()
    let editPictureButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(handleSelectProfileImageView), for: .touchUpInside)
        button.setTitleColor(UIColor(white: 0.9, alpha: 1), for: .normal)
        
        return button
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
    
    let editNameLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Edit name"
        lb.textColor = .gray
        return lb
    }()
    
    let editEmailLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Confirm email"
        lb.textColor = .gray
        return lb
    }()
    
    let confirmPasswordLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Confirm Password"
        lb.textColor = .gray
        return lb
    }()
    
    let registerViewModel = RegisterViewModel()
    var effect: UIVisualEffect!
    
    @objc func handleTextFieldChange(textField: UITextField) {
        if textField == userNameText {
            registerViewModel.username = textField.text
        } else if textField == emailText {
            registerViewModel.email = textField.text
        } else if textField == passwordText {
            registerViewModel.password = textField.text
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        userNameText.setBottomBorder(withColor: .gray)
        emailText.setBottomBorder(withColor: .gray)
        passwordText.setBottomBorder(withColor: .gray)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUserData()
        view.backgroundColor = .white
        view.addSubview(dummyView)
        view.addSubview(dummyViewTwo)
        view.addSubview(addProfileImage)
        view.addSubview(userNameText)
        view.addSubview(emailText)
        view.addSubview(registerButton)
        view.addSubview(editPictureButton)
        view.addSubview(dummyButton)
        view.addSubview(activityIndicatorView)
        view.addSubview(blurryView)
        view.addSubview(editNameLabel)
        view.addSubview(editEmailLabel)
        view.addSubview(passwordText)
        view.addSubview(confirmPasswordLabel)
        
        dummyView.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: view.frame.height/4)
        dummyViewTwo.anchor(dummyView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 12, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        addProfileImage.anchor(dummyView.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 120, bottomConstant: 0, rightConstant: 120, widthConstant: 0, heightConstant: view.frame.width-240)
        editPictureButton.anchor(addProfileImage.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 8, leftConstant: 32, bottomConstant: 0, rightConstant: 32, widthConstant: 0, heightConstant: 0)
        dummyButton.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 30, leftConstant: 100, bottomConstant: 0, rightConstant: 100, widthConstant: 0, heightConstant: view.frame.width-200)
        userNameText.anchor(dummyViewTwo.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 30, leftConstant: 32, bottomConstant: 0, rightConstant: 32, widthConstant: 0, heightConstant: 60)
        emailText.anchor(userNameText.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 35, leftConstant: 32, bottomConstant: 0, rightConstant: 32, widthConstant: 0, heightConstant: 50)
        registerButton.anchor(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 32, bottomConstant: 20, rightConstant: 32, widthConstant: 0, heightConstant: 60)
        passwordText.anchor(emailText.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 35, leftConstant: 32, bottomConstant: 0, rightConstant: 32, widthConstant: 0, heightConstant: 50)
        editNameLabel.anchor(nil, left: userNameText.leftAnchor, bottom: userNameText.topAnchor, right: userNameText.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 15)
        editEmailLabel.anchor(nil, left: emailText.leftAnchor, bottom: emailText.topAnchor, right: emailText.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 15)
        confirmPasswordLabel.anchor(nil, left: passwordText.leftAnchor, bottom: passwordText.topAnchor, right: passwordText.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 15)
        
        
        addProfileImage.layer.cornerRadius = (view.frame.width-240)/2
        effect = blurryView.effect
        blurryView.effect = nil
        registerViewModel.isValidListener = { [unowned self] (isValid) in
            self.registerButton.isEnabled = true
        }
    }
    
    @objc func switchStateDidChange(_ sender:UISwitch!) {
        if (sender.isOn == true) {
            print("UISwitch state is now ON")
        } else {
            print("UISwitch state is now Off")
        }
    }
    
    @objc func handleSelectProfileImageView() {
        print("yay")
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        
        present(picker, animated: true, completion: nil)
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            addProfileImage.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Canceled")
        dismiss(animated: true, completion: nil)
    }
    func fetchUserData() {
        let fireRef = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!)
        fireRef.observe(.value, with: { (snapshot) in
            if let dictionary = snapshot.childSnapshot(forPath: "profileImageUrl").value {
                if let url = NSURL(string: dictionary as! String) {
                    DispatchQueue.main.async {
                        self.addProfileImage.sd_setImage(with: url as URL, placeholderImage: UIImage(named: "Outlay Username"))
                        
                    }
                    
                }
                
            }
            if let userName = snapshot.childSnapshot(forPath: "username").value {
                self.userNameText.text = userName as? String
            }
            //eventually we will support email changing
//            if let email = snapshot.childSnapshot(forPath: "email").value {
//                self.emailText.text = email as? String
//            }
            //this will crash because of background thread, so lets use dispatch_async to fix
            
            
        }, withCancel: nil)
    }
    
    @objc func updateUserInfo() {

        // Prompt the user to re-provide their sign-in credentials
        
        guard let email = self.emailText.text, let userName = self.userNameText.text, let currentPassword = self.passwordText.text else {
            return
            
        }
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        Auth.auth().currentUser?.reauthenticateAndRetrieveData(with: credential, completion: { (result, error) in
                if error != nil {
                    let viewController = ErrorLoginViewController()
                    viewController.errorTextView.text = error?.localizedDescription
                    viewController.modalTransitionStyle = .crossDissolve
                    viewController.modalPresentationStyle = .overCurrentContext
                    UIApplication.topViewController()?.present(viewController, animated: true, completion: nil)
                } else {
                    Auth.auth().currentUser?.updateEmail(to: email) { error in
                        if let error = error {
                            
                            print(error)
                            self.userNameText.text = ""
                            self.emailText.text = ""
                            let viewController = ErrorLoginViewController()
                            viewController.errorTextView.text = error.localizedDescription
                            viewController.modalTransitionStyle = .crossDissolve
                            viewController.modalPresentationStyle = .overCurrentContext
                            UIApplication.topViewController()?.present(viewController, animated: true, completion: nil)
                            return
                        }
                        else {
                            // Email updated
                            let imageName = NSUUID().uuidString
                            let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).png")
                            do {
                                if let uploadData = self.addProfileImage.image!.jpeg(.low) {
                                storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                                    if error != nil {
                                        let viewController = ErrorLoginViewController()
                                        viewController.errorTextView.text = error?.localizedDescription
                                        viewController.modalTransitionStyle = .crossDissolve
                                        viewController.modalPresentationStyle = .overCurrentContext
                                        UIApplication.topViewController()?.present(viewController, animated: true, completion: nil)
                                        return
                                    }
                                    
                                    storageRef.downloadURL { url, error in
                                        if let error = error {
                                            let viewController = ErrorLoginViewController()
                                            viewController.errorTextView.text = error.localizedDescription
                                            viewController.modalTransitionStyle = .crossDissolve
                                            viewController.modalPresentationStyle = .overCurrentContext
                                            UIApplication.topViewController()?.present(viewController, animated: true, completion: nil)
                                            return
                                        } else {
                                            print("success")
                                            let fireRef = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!)
                                            let values = ["email": email, "username": userName, "profileImageUrl": url!.absoluteString] as [String: Any]
                                            fireRef.updateChildValues(values)
                                            if let user = Auth.auth().currentUser {
                                                if !user.isEmailVerified{
                                                    let alertVC = UIAlertController(title: "Verify", message: "Please verify your email address to continue.", preferredStyle: .alert)
                                                    let alertActionOkay = UIAlertAction(title: "Okay", style: .default) {
                                                        (_) in
                                                        user.sendEmailVerification(completion: nil)
                                                    }
                                                    

                                                    alertVC.addAction(alertActionOkay)
                                                    self.present(alertVC, animated: true, completion: nil)
                                                    }
                                                }
                                            }
                                        }
                                    })
                                }
                            }
                        }
                    }
                }
            }
        )
    }
}

class EditPasswordController: UIViewController {
    
    static let inputHeight: CGFloat = 60
    
    
    let passwordText: TextField = {
        let fn = TextField()
        fn.backgroundColor = .clear
        //fn.layer.cornerRadius = 30
        fn.autocorrectionType = .no
        fn.autocapitalizationType = .none
        fn.isSecureTextEntry = true
        fn.textColor = .white
        fn.attributedPlaceholder = NSAttributedString(string: "Old Password",
                                                      attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(white: 0.9, alpha: 0.6)])
        fn.heightAnchor.constraint(equalToConstant: inputHeight).isActive = true
        return fn
    }()
    
    let newPasswordText: TextField = {
        let fn = TextField()
        fn.backgroundColor = .clear
        //fn.layer.cornerRadius = 30
        fn.autocorrectionType = .no
        fn.autocapitalizationType = .none
        fn.isSecureTextEntry = true
        fn.textColor = .white
        fn.attributedPlaceholder = NSAttributedString(string: "New Password",
                                                      attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(white: 0.9, alpha: 0.6)])
        fn.heightAnchor.constraint(equalToConstant: inputHeight).isActive = true
        return fn
    }()
    
    let confirmPasswordText: TextField = {
        let fn = TextField()
        fn.backgroundColor = .clear
        //fn.layer.cornerRadius = 30
        fn.autocorrectionType = .no
        fn.autocapitalizationType = .none
        fn.isSecureTextEntry = true
        fn.textColor = .white
        fn.attributedPlaceholder = NSAttributedString(string: "Confirm Password",
                                                      attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(white: 0.9, alpha: 0.6)])
        fn.heightAnchor.constraint(equalToConstant: inputHeight).isActive = true
        return fn
    }()
    
    let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Submit Changes", for: .normal)
        button.backgroundColor = .rgb(r: 5, g: 220, b: 163)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(updateUserInfo), for: .touchUpInside)
        button.heightAnchor.constraint(equalToConstant: inputHeight).isActive = true
        return button
    }()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .rgb(r: 50, g: 50, b: 50)
        
        setupStackView()
        
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        passwordText.setBottomBorder(withColor: .gray)
        newPasswordText.setBottomBorder(withColor: .gray)
        confirmPasswordText.setBottomBorder(withColor: .gray)
        registerButton.layer.cornerRadius = (registerButton.bounds.height)/2


    }
    
    @objc func updateUserInfo() {
        print("yay")
        guard let email = Auth.auth().currentUser?.email, let currentPassword = passwordText.text, let newPassword = newPasswordText.text, let confirmPassword = confirmPasswordText.text else {return}
        if confirmPassword == newPassword {
            let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
            Auth.auth().currentUser?.reauthenticateAndRetrieveData(with: credential, completion: { (result, error) in
                if error != nil {
                    let viewController = ErrorLoginViewController()
                    viewController.errorTextView.text = error?.localizedDescription
                    viewController.modalTransitionStyle = .crossDissolve
                    viewController.modalPresentationStyle = .overCurrentContext
                    UIApplication.topViewController()?.present(viewController, animated: true, completion: nil)
                } else {
                    Auth.auth().currentUser?.updatePassword(to: confirmPassword, completion: { (error) in
                        if let error = error {
                            let viewController = ErrorLoginViewController()
                            viewController.errorTextView.text = error.localizedDescription
                            viewController.modalTransitionStyle = .crossDissolve
                            viewController.modalPresentationStyle = .overCurrentContext
                            UIApplication.topViewController()?.present(viewController, animated: true, completion: nil)
                            return
                        }
                        self.navigationController?.popViewController(animated: true)
                            
                        
                    })

                }
            })
        } else {
            let viewController = ErrorLoginViewController()
            viewController.errorTextView.text = "Passwords don't match!"
            viewController.modalTransitionStyle = .crossDissolve
            viewController.modalPresentationStyle = .overCurrentContext
            UIApplication.topViewController()?.present(viewController, animated: true, completion: nil)
        }
        
    }
    
    fileprivate func setupStackView() {
        let stackView = UIStackView(arrangedSubviews: [passwordText, newPasswordText, confirmPasswordText, registerButton])
        stackView.axis = .vertical
        stackView.spacing = 18
        stackView.setCustomSpacing(60, after: confirmPasswordText)
        
        
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
    }
}

class SettingsTableView: UITableViewController {
    
    let cellId = "cellId"
    let sections: [String] = ["Account", "Us"]
    let sectionOneImages: [String] = ["icons8-add-user-male-480", "icons8-lock-50", "icons8-alarm-480", "icons8-exit-500-black"]
    let sectionTwoImages: [String] = ["icons8-terms-and-conditions-480", "icons8-more-info-480"]
    let s1Data: [String] = ["Edit Profile", "Change Password", "Notifications", "Logout"]
    let s2Data: [String] = ["Terms of Service", "About Us"]
    
    var sectionData: [Int: [String]] = [:]
    var sectionImageData: [Int: [String]] = [:]
    
    override func viewDidAppear(_ animated: Bool) {
        let navigationBar = self.navigationController?.navigationBar
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.rgb(r: 5, g: 220, b: 163), NSAttributedString.Key.font: UIFont.init(name: "Avenir-Black", size: 24)!]
        navigationBar?.tintColor = UIColor.rgb(r: 5, g: 220, b: 163)
        navigationBar?.barTintColor = .rgb(r: 50, g: 50, b: 50)
        navigationBar?.isTranslucent = false
        navigationBar?.setBackgroundImage(UIImage(), for: .default)
        navigationBar?.shadowImage = UIImage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .rgb(r: 50, g: 50, b: 50)
        
        tableView.contentInset = UIEdgeInsets.init(top: 50, left: 0, bottom: 0, right: 0)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none

        
        sectionData = [0:s1Data, 1:s2Data]
        sectionImageData = [0:sectionOneImages, 1:sectionTwoImages]
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (sectionData[section]?.count)!
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
        (view as! UITableViewHeaderFooterView).textLabel?.textColor = .rgb(r: 5, g: 220, b: 163)
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
            
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        
        if indexPath.row == 2 {
            let notificationSwitch = UISwitch()
            notificationSwitch.isOn = true
            notificationSwitch.addTarget(self, action: #selector(switchStateDidChange(_:)), for: .valueChanged)
            cell?.accessoryView = notificationSwitch
        }
        cell?.backgroundColor = .rgb(r: 74, g: 74, b: 74)
        
        cell?.textLabel?.text = sectionData[indexPath.section]![indexPath.row]
        cell?.textLabel?.textColor = UIColor.init(white: 0.9, alpha: 0.6)
        cell?.imageView?.image = UIImage(named: sectionImageData[indexPath.section]![indexPath.row])
        cell?.imageView?.contentMode = .scaleAspectFit
        let itemSize = CGSize.init(width: 25, height: 25)
        UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale)
        let imageRect = CGRect.init(origin: CGPoint.zero, size: itemSize)
        cell?.imageView?.image!.draw(in: imageRect)
        cell?.imageView?.image! = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.section)
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let profileSettingsPage = NewEditProfileController()
                self.navigationController?.pushViewController(profileSettingsPage, animated: true)
                let navigationBar = profileSettingsPage.navigationController!.navigationBar
                profileSettingsPage.title = "Edit Profile"
                navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.init(name: "Avenir-Black", size: 24)!]
                navigationBar.barTintColor = .rgb(r: 5, g: 220, b: 163)
                navigationBar.tintColor = .white
                navigationBar.isTranslucent = false
                navigationBar.setBackgroundImage(UIImage(), for: .default)
                navigationBar.shadowImage = UIImage()
                


            case 1:
                print("change password")
                let profileSettingsPage = EditPasswordController()
                self.navigationController?.pushViewController(profileSettingsPage, animated: true)
            case 2:
                print("off")
            case 3:
                print("logout")
                handleLogout()
            default:
                print("nothing")
            }
        case 1:
            switch indexPath.row {
            case 0:
                print("terms of service")
                let profileSettingsPage = TermsOfServiceController()
                self.navigationController?.pushViewController(profileSettingsPage, animated: true)
            case 1:
                print("about us")
                let profileSettingsPage = AboutUsController()
                self.navigationController?.pushViewController(profileSettingsPage, animated: true)
            default:
                print("nothing")
            }
        default:
            print("nothing")
        }
    }
    
    @objc func handleLogout() {
        
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            let viewController = ErrorLoginViewController()
            viewController.errorTextView.text = logoutError.localizedDescription
            viewController.modalTransitionStyle = .crossDissolve
            viewController.modalPresentationStyle = .overCurrentContext
            UIApplication.topViewController()?.present(viewController, animated: true, completion: nil)
            return
        }
        let loginController = NewLoginController()
        if #available(iOS 13.0, *) {
            loginController.isModalInPresentation = true
        } else {
            // Fallback on earlier versions
        }
        present(loginController, animated: true, completion: nil)
    }
    
    @objc func switchStateDidChange(_ sender:UISwitch!) {
        if (sender.isOn == true) {
            print("UISwitch state is now ON")
            let center  = UNUserNotificationCenter.current()
            center.delegate = self as? UNUserNotificationCenterDelegate
            center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
                if error == nil{
                    DispatchQueue.main.async(execute: {
                        UIApplication.shared.registerForRemoteNotifications()
                    })
                }
            }
        } else {
            print("UISwitch state is now Off")
            UIApplication.shared.unregisterForRemoteNotifications()
        }
    }
}




class AboutUsController: UIViewController {
    
    let boldLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Sebastian Sanso"
        lb.font = UIFont.boldSystemFont(ofSize: 26)
        lb.textAlignment = .center
        lb.textColor = .rgb(r:5, g: 220, b: 163)
        return lb
    }()
    
    let userPicture: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "sebastian-sanso-picture")
        iv.layer.masksToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let positionLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Creator"
        lb.textColor = .white
        lb.textAlignment = .center
        return lb
    }()
    
    let noMoreLabel: UILabel = {
        let lb = UILabel()
        lb.text = "There are no more members at the moment"
        lb.textColor = UIColor.init(white: 0.9, alpha: 0.6)
        lb.textAlignment = .center
        return lb
    }()
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .rgb(r: 50, g: 50, b: 50)
        view.addSubview(userPicture)
        view.addSubview(boldLabel)
        view.addSubview(positionLabel)
        view.addSubview(noMoreLabel)
        
        userPicture.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 40, leftConstant: 40, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: view.frame.width-80)
        boldLabel.anchor(userPicture.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 12, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 30)
        positionLabel.anchor(boldLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 5, leftConstant: 25, bottomConstant: 0, rightConstant: 25, widthConstant: 0, heightConstant: 20)
        noMoreLabel.anchor(positionLabel.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 50, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 30)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        userPicture.layer.cornerRadius = (userPicture.bounds.size.width)/2
    }
}
class TermsOfServiceCell: UITableViewCell {
    let termsLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.numberOfLines = 0
        return textLabel
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(termsLabel)
        termsLabel.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor
            , topConstant: 8, leftConstant: 12, bottomConstant: 8, rightConstant: 8, widthConstant: 0, heightConstant: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TermsOfServiceController: UITableViewController {
    
    let cellId = "cellId"
    let sectionHeader: [String] = ["TERMS OF USE", "AGREEMENT TO TERMS", "INTELLECTUAL PROPERTY RIGHTS", "USER REPRESENTATIONS", "USER REGISTRATION", "PROHIBITED ACTIVITIES", "USER GENERATED CONTRIBUTIONS", "GUIDELINES FOR REVIEWS", "MOBILE APPLICATION LICENSE", "CONTRIBUTION LICENSE", "SOCIAL MEDIA", "SUBMISSIONS", "THIRD-PARTY WEBSITES AND CONTENT", "ADVERTISERS", "SITE MANAGMENT", "PRIVACY POLICY", "COPYRIGHT INFRINGMENTS", "TERM AND TERMINATION", "MODIFICATIONS AND INTERRUPTIONS", "GOVERNING LAW", "DISPUTE RESOLUTION", "CORRECTIONS", "DISCLAIMER", "LIMITS OF LIABILITY", "INDEMNIFICATION", "ELECTRONIC COMMUNICATIONS, TRANSACTIONS, AND SIGNATURES", "USER DATA", "CALIFORNIA USERS AND RESIDENTS", "MISCELLANEOUS", "CONTACT US"]
    let termsSection: [String] = ["Last updated January 03, 2019", "These Terms of Use constitute a legally binding agreement made between you, whether personally or on behalf of an entity (“you”) and Quirks ('Company', “we”, “us”, or “our”), concerning your access to and use of the www.quirksapp.com website as well as any other media form, media channel, mobile website or mobile application related, linked, or otherwise connected thereto (collectively, the “Site”). You agree that by accessing the Site, you have read, understood, and agreed to be bound by all of these Terms of Use. IF YOU DO NOT AGREE WITH ALL OF THESE TERMS OF USE, THEN YOU ARE EXPRESSLY PROHIBITED FROM USING THE SITE AND YOU MUST DISCONTINUE USE IMMEDIATELY.Supplemental terms and conditions or documents that may be posted on the Site from time to time are hereby expressly incorporated herein by reference. We reserve the right, in our sole discretion, to make changes or modifications to these Terms of Use at any time and for any reason. We will alert you about any changes by updating the “Last updated” date of these Terms of Use, and you waive any right to receive specific notice of each such change. It is your responsibility to periodically review these Terms of Use to stay informed of updates. You will be subject to, and will be deemed to have been made aware of and to have accepted, the changes in any revised Terms of Use by your continued use of the Site after the date such revised Terms of Use are posted.  The information provided on the Site is not intended for distribution to or use by any person or entity in any jurisdiction or country where such distribution or use would be contrary to law or regulation or which would subject us to any registration requirement within such jurisdiction or country. Accordingly, those persons who choose to access the Site from other locations do so on their own initiative and are solely responsible for compliance with local laws, if and to the extent local laws are applicable.The Site is intended for users who are at least 13 years of age. All users who are minors in the jurisdiction in which they reside (generally under the age of 18) must have the permission of, and be directly supervised by, their parent or guardian to use the Site. If you are a minor, you must have your parent or guardian read and agree to these Terms of Use prior to you using the Site.", "Unless otherwise indicated, the Site is our proprietary property and all source code, databases, functionality, software, website designs, audio, video, text, photographs, and graphics on the Site (collectively, the “Content”) and the trademarks, service marks, and logos contained therein (the “Marks”) are owned or controlled by us or licensed to us, and are protected by copyright and trademark laws and various other intellectual property rights and unfair competition laws of the United States, foreign jurisdictions, and international conventions. The Content and the Marks are provided on the Site “AS IS” for your information and personal use only. Except as expressly provided in these Terms of Use, no part of the Site and no Content or Marks may be copied, reproduced, aggregated, republished, uploaded, posted, publicly displayed, encoded, translated, transmitted, distributed, sold, licensed, or otherwise exploited for any commercial purpose whatsoever, without our express prior written permission. Provided that you are eligible to use the Site, you are granted a limited license to access and use the Site and to download or print a copy of any portion of the Content to which you have properly gained access solely for your personal, non-commercial use. We reserve all rights not expressly granted to you in and to the Site, the Content and the Marks.", "By using the Site, you represent and warrant that: (1) all registration information you submit will be true, accurate, current, and complete; (2) you will maintain the accuracy of such information and promptly update such registration information as necessary; (3) you have the legal capacity and you agree to comply with these Terms of Use;  (4) you are not under the age of 13; (5) you are not a minor in the jurisdiction in which you reside, or if a minor, you have received parental permission to use the Site; (6) you will not access the Site through automated or non-human means, whether through a bot, script, or otherwise; (7) you will not use the Site for any illegal or unauthorized purpose; and (8) your use of the Site will not violate any applicable law or regulation. If you provide any information that is untrue, inaccurate, not current, or incomplete, we have the right to suspend or terminate your account and refuse any and all current or future use of the Site (or any portion thereof).", "You may be required to register with the Site. You agree to keep your password confidential and will be responsible for all use of your account and password. We reserve the right to remove, reclaim, or change a username you select if we determine, in our sole discretion, that such username is inappropriate, obscene, or otherwise objectionable.", "You may not access or use the Site for any purpose other than that for which we make the Site available. The Site may not be used in connection with any commercial endeavors except those that are specifically endorsed or approved by us. As a user of the Site, you agree not to:1.  Make any unauthorized use of the Site, including collecting usernames and/or email addresses of users by electronic or other means for the purpose of sending unsolicited email, or creating user accounts by automated means or under false pretenses. 2.  Circumvent, disable, or otherwise interfere with security-related features of the Site, including features that prevent or restrict the use or copying of any Content or enforce limitations on the use of the Site and/or the Content contained therein. 3.  Trick, defraud, or mislead us and other users, especially in any attempt to learn sensitive account information such as user passwords. 4.  Make improper use of our support services or submit false reports of abuse or misconduct. 5.  Attempt to impersonate another user or person or use the username of another user. 6.  Engage in any automated use of the system, such as using scripts to send comments or messages, or using any data mining, robots, or similar data gathering and extraction tools. 7.  Decipher, decompile, disassemble, or reverse engineer any of the software comprising or in any way making up a part of the Site. 8.  Use the Site as part of any effort to compete with us or otherwise use the Site and/or the Content for any revenue-generating endeavor or commercial enterprise. 9.  Use any information obtained from the Site in order to harass, abuse, or harm another person. 10.  Harass, annoy, intimidate, or threaten any of our employees or agents engaged in providing any portion of the Site to you. 11.  Delete the copyright or other proprietary rights notice from any Content. 12.  Copy or adapt the Site’s software, including but not limited to Flash, PHP, HTML, JavaScript, or other code. 13.  Attempt to bypass any measures of the Site designed to prevent or restrict access to the Site, or any portion of the Site. 14.  Upload or transmit (or attempt to upload or to transmit) viruses, Trojan horses, or other material, including excessive use of capital letters and spamming (continuous posting of repetitive text), that interferes with any party’s uninterrupted use and enjoyment of the Site or modifies, impairs, disrupts, alters, or interferes with the use, features, functions, operation, or maintenance of the Site. 15.  Upload or transmit (or attempt to upload or to transmit) any material that acts as a passive or active information collection or transmission mechanism, including without limitation, clear graphics interchange formats (“gifs”), 1×1 pixels, web bugs, cookies, or other similar devices (sometimes referred to as “spyware” or “passive collection mechanisms” or “pcms”). 16.  Disparage, tarnish, or otherwise harm, in our opinion, us and/or the Site. 17.  Use the Site in a manner inconsistent with any applicable laws or regulations. 18.  Except as may be the result of standard search engine or Internet browser usage, use, launch, develop, or distribute any automated system, including without limitation, any spider, robot, cheat utility, scraper, or offline reader that accesses the Site, or using or launching any unauthorized script or other software. ", "The Site may invite you to chat, contribute to, or participate in blogs, message boards, online forums, and other functionality, and may provide you with the opportunity to create, submit, post, display, transmit, perform, publish, distribute, or broadcast content and materials to us or on the Site, including but not limited to text, writings, video, audio, photographs, graphics, comments, suggestions, or personal information or other material (collectively, 'Contributions'). Contributions may be viewable by other users of the Site and through third-party websites. As such, any Contributions you transmit may be treated as non-confidential and non-proprietary. When you create or make available any Contributions, you thereby represent and warrant that:  1.  The creation, distribution, transmission, public display, or performance, and the accessing, downloading, or copying of your Contributions do not and will not infringe the proprietary rights, including but not limited to the copyright, patent, trademark, trade secret, or moral rights of any third party.2.  You are the creator and owner of or have the necessary licenses, rights, consents, releases, and permissions to use and to authorize us, the Site, and other users of the Site to use your Contributions in any manner contemplated by the Site and these Terms of Use.3.  You have the written consent, release, and/or permission of each and every identifiable individual person in your Contributions to use the name or likeness of each and every such identifiable individual person to enable inclusion and use of your Contributions in any manner contemplated by the Site and these Terms of Use.4.  Your Contributions are not false, inaccurate, or misleading.5.  Your Contributions are not unsolicited or unauthorized advertising, promotional materials, pyramid schemes, chain letters, spam, mass mailings, or other forms of solicitation.6.  Your Contributions are not obscene, lewd, lascivious, filthy, violent, harassing, libelous, slanderous, or otherwise objectionable (as determined by us).7.  Your Contributions do not ridicule, mock, disparage, intimidate, or abuse anyone.8.  Your Contributions do not advocate the violent overthrow of any government or incite, encourage, or threaten physical harm against another.9.  Your Contributions do not violate any applicable law, regulation, or rule.10.  Your Contributions do not violate the privacy or publicity rights of any third party.11.  Your Contributions do not contain any material that solicits personal information from anyone under the age of 18 or exploits people under the age of 18 in a sexual or violent manner.12.  Your Contributions do not violate any federal or state law concerning child pornography, or otherwise intended to protect the health or well-being of minors;13.  Your Contributions do not include any offensive comments that are connected to race, national origin, gender, sexual preference, or physical handicap.14.  Your Contributions do not otherwise violate, or link to material that violates, any provision of these Terms of Use, or any applicable law or regulation.Any use of the Site in violation of the foregoing violates these Terms of Use and may result in, among other things, termination or suspension of your rights to use the Site.", "By posting your Contributions to any part of the Site or making Contributions accessible to the Site by linking your account from the Site to any of your social networking accounts, you automatically grant, and you represent and warrant that you have the right to grant, to us an unrestricted, unlimited, irrevocable, perpetual, non-exclusive, transferable, royalty-free, fully-paid, worldwide right, and license to host, use, copy, reproduce, disclose, sell, resell, publish, broadcast, retitle, archive, store, cache, publicly perform, publicly display, reformat, translate, transmit, excerpt (in whole or in part), and distribute such Contributions (including, without limitation, your image and voice) for any purpose, commercial, advertising, or otherwise, and to prepare derivative works of, or incorporate into other works, such Contributions, and grant and authorize sublicenses of the foregoing. The use and distribution may occur in any media formats and through any media channels. This license will apply to any form, media, or technology now known or hereafter developed, and includes our use of your name, company name, and franchise name, as applicable, and any of the trademarks, service marks, trade names, logos, and personal and commercial images you provide. You waive all moral rights in your Contributions, and you warrant that moral rights have not otherwise been asserted in your Contributions. We do not assert any ownership over your Contributions. You retain full ownership of all of your Contributions and any intellectual property rights or other proprietary rights associated with your Contributions. We are not liable for any statements or representations in your Contributions provided by you in any area on the Site. You are solely responsible for your Contributions to the Site and you expressly agree to exonerate us from any and all responsibility and to refrain from any legal action against us regarding your Contributions.   We have the right, in our sole and absolute discretion, (1) to edit, redact, or otherwise change any Contributions; (2) to re-categorize any Contributions to place them in more appropriate locations on the Site; and (3) to pre-screen or delete any Contributions at any time and for any reason, without notice. We have no obligation to monitor your Contributions.", "We may provide you areas on the Site to leave reviews or ratings. When posting a review, you must comply with the following criteria: (1) you should have firsthand experience with the person/entity being reviewed; (2) your reviews should not contain offensive profanity, or abusive, racist, offensive, or hate language; (3) your reviews should not contain discriminatory references based on religion, race, gender, national origin, age, marital status, sexual orientation, or disability; (4) your reviews should not contain references to illegal activity; (5) you should not be affiliated with competitors if posting negative reviews; (6) you should not make any conclusions as to the legality of conduct; (7) you may not post any false or misleading statements; and (8) you may not organize a campaign encouraging others to post reviews, whether positive or negative.  We may accept, reject, or remove reviews in our sole discretion. We have absolutely no obligation to screen reviews or to delete reviews, even if anyone considers reviews objectionable or inaccurate. Reviews are not endorsed by us, and do not necessarily represent our opinions or the views of any of our affiliates or partners. We do not assume liability for any review or for any claims, liabilities, or losses resulting from any review. By posting a review, you hereby grant to us a perpetual, non-exclusive, worldwide, royalty-free, fully-paid, assignable, and sublicensable right and license to reproduce, modify, translate, transmit by any means, display, perform, and/or distribute all content relating to reviews.", "If you access the Site via a mobile application, then we grant you a revocable, non-exclusive, non-transferable, limited right to install and use the mobile application on wireless electronic devices owned or controlled by you, and to access and use the mobile application on such devices strictly in accordance with the terms and conditions of this mobile application license contained in these Terms of Use. You shall not: (1) decompile, reverse engineer, disassemble, attempt to derive the source code of, or decrypt the application; (2) make any modification, adaptation, improvement, enhancement, translation, or derivative work from the application; (3) violate any applicable laws, rules, or regulations in connection with your access or use of the application; (4) remove, alter, or obscure any proprietary notice (including any notice of copyright or trademark) posted by us or the licensors of the application; (5) use the application for any revenue generating endeavor, commercial enterprise, or other purpose for which it is not designed or intended; (6) make the application available over a network or other environment permitting access or use by multiple devices or users at the same time; (7) use the application for creating a product, service, or software that is, directly or indirectly, competitive with or in any way a substitute for the application; (8) use the application to send automated queries to any website or to send any unsolicited commercial e-mail; or (9) use any proprietary information or any of our interfaces or our other intellectual property in the design, development, manufacture, licensing, or distribution of any applications, accessories, or devices for use with the application. Apple and Android Devices The following terms apply when you use a mobile application obtained from either the Apple Store or Google Play (each an “App Distributor”) to access the Site: (1) the license granted to you for our mobile application is limited to a non-transferable license to use the application on a device that utilizes the Apple iOS or Android operating systems, as applicable, and in accordance with the usage rules set forth in the applicable App Distributor’s terms of service; (2) we are responsible for providing any maintenance and support services with respect to the mobile application as specified in the terms and conditions of this mobile application license contained in these Terms of Use or as otherwise required under applicable law, and you acknowledge that each App Distributor has no obligation whatsoever to furnish any maintenance and support services with respect to the mobile application; (3) in the event of any failure of the mobile application to conform to any applicable warranty, you may notify the applicable App Distributor, and the App Distributor, in accordance with its terms and policies, may refund the purchase price, if any, paid for the mobile application, and to the maximum extent permitted by applicable law, the App Distributor will have no other warranty obligation whatsoever with respect to the mobile application; (4) you represent and warrant that (i) you are not located in a country that is subject to a U.S. government embargo, or that has been designated by the U.S. government as a “terrorist supporting” country and (ii) you are not listed on any U.S. government list of prohibited or restricted parties; (5) you must comply with applicable third-party terms of agreement when using the mobile application, e.g., if you have a VoIP application, then you must not be in violation of their wireless data service agreement when using the mobile application; and (6) you acknowledge and agree that the App Distributors are third-party beneficiaries of the terms and conditions in this mobile application license contained in these Terms of Use, and that each App Distributor will have the right (and will be deemed to have accepted the right) to enforce the terms and conditions in this mobile application license contained in these Terms of Use against you as a third-party beneficiary thereof.", "As part of the functionality of the Site, you may link your account with online accounts you have with third-party service providers (each such account, a “Third-Party Account”) by either: (1) providing your Third-Party Account login information through the Site; or (2) allowing us to access your Third-Party Account, as is permitted under the applicable terms and conditions that govern your use of each Third-Party Account. You represent and warrant that you are entitled to disclose your Third-Party Account login information to us and/or grant us access to your Third-Party Account, without breach by you of any of the terms and conditions that govern your use of the applicable Third-Party Account, and without obligating us to pay any fees or making us subject to any usage limitations imposed by the third-party service provider of the Third-Party Account. By granting us access to any Third-Party Accounts, you understand that (1) we may access, make available, and store (if applicable) any content that you have provided to and stored in your Third-Party Account (the “Social Network Content”) so that it is available on and through the Site via your account, including without limitation any friend lists and (2) we may submit to and receive from your Third-Party Account additional information to the extent you are notified when you link your account with the Third-Party Account. Depending on the Third-Party Accounts you choose and subject to the privacy settings that you have set in such Third-Party Accounts, personally identifiable information that you post to your Third-Party Accounts may be available on and through your account on the Site. Please note that if a Third-Party Account or associated service becomes unavailable or our access to such Third Party Account is terminated by the third-party service provider, then Social Network Content may no longer be available on and through the Site. You will have the ability to disable the connection between your account on the Site and your Third-Party Accounts at any time. PLEASE NOTE THAT YOUR RELATIONSHIP WITH THE THIRD-PARTY SERVICE PROVIDERS ASSOCIATED WITH YOUR THIRD-PARTY ACCOUNTS IS GOVERNED SOLELY BY YOUR AGREEMENT(S) WITH SUCH THIRD-PARTY SERVICE PROVIDERS. We make no effort to review any Social Network Content for any purpose, including but not limited to, for accuracy, legality, or non-infringement, and we are not responsible for any Social Network Content. You acknowledge and agree that we may access your email address book associated with a Third-Party Account and your contacts list stored on your mobile device or tablet computer solely for purposes of identifying and informing you of those contacts who have also registered to use the Site. You can deactivate the connection between the Site and your Third-Party Account by contacting us using the contact information below or through your account settings (if applicable). We will attempt to delete any information stored on our servers that was obtained through such Third-Party Account, except the username and profile picture that become associated with your account.", "You acknowledge and agree that any questions, comments, suggestions, ideas, feedback, or other information regarding the Site ('Submissions') provided by you to us are non-confidential and shall become our sole property. We shall own exclusive rights, including all intellectual property rights, and shall be entitled to the unrestricted use and dissemination of these Submissions for any lawful purpose, commercial or otherwise, without acknowledgment or compensation to you. You hereby waive all moral rights to any such Submissions, and you hereby warrant that any such Submissions are original with you or that you have the right to submit such Submissions. You agree there shall be no recourse against us for any alleged or actual infringement or misappropriation of any proprietary right in your Submissions.", "The Site may contain (or you may be sent via the Site) links to other websites ('Third-Party Websites') as well as articles, photographs, text, graphics, pictures, designs, music, sound, video, information, applications, software, and other content or items belonging to or originating from third parties ('Third-Party Content'). Such Third-Party Websites and Third-Party Content are not investigated, monitored, or checked for accuracy, appropriateness, or completeness by us, and we are not responsible for any Third-Party Websites accessed through the Site or any Third-Party Content posted on, available through, or installed from the Site, including the content, accuracy, offensiveness, opinions, reliability, privacy practices, or other policies of or contained in the Third-Party Websites or the Third-Party Content. Inclusion of, linking to, or permitting the use or installation of any Third-Party Websites or any Third-Party Content does not imply approval or endorsement thereof by us. If you decide to leave the Site and access the Third-Party Websites or to use or install any Third-Party Content, you do so at your own risk, and you should be aware these Terms of Use no longer govern. You should review the applicable terms and policies, including privacy and data gathering practices, of any website to which you navigate from the Site or relating to any applications you use or install from the Site. Any purchases you make through Third-Party Websites will be through other websites and from other companies, and we take no responsibility whatsoever in relation to such purchases which are exclusively between you and the applicable third party. You agree and acknowledge that we do not endorse the products or services offered on Third-Party Websites and you shall hold us harmless from any harm caused by your purchase of such products or services. Additionally, you shall hold us harmless from any losses sustained by you or harm caused to you relating to or resulting in any way from any Third-Party Content or any contact with Third-Party Websites.", "We allow advertisers to display their advertisements and other information in certain areas of the Site, such as sidebar advertisements or banner advertisements. If you are an advertiser, you shall take full responsibility for any advertisements you place on the Site and any services provided on the Site or products sold through those advertisements. Further, as an advertiser, you warrant and represent that you possess all rights and authority to place advertisements on the Site, including, but not limited to, intellectual property rights, publicity rights, and contractual rights. We simply provide the space to place such advertisements, and we have no other relationship with advertisers.", "We reserve the right, but not the obligation, to: (1) monitor the Site for violations of these Terms of Use; (2) take appropriate legal action against anyone who, in our sole discretion, violates the law or these Terms of Use, including without limitation, reporting such user to law enforcement authorities; (3) in our sole discretion and without limitation, refuse, restrict access to, limit the availability of, or disable (to the extent technologically feasible) any of your Contributions or any portion thereof; (4) in our sole discretion and without limitation, notice, or liability, to remove from the Site or otherwise disable all files and content that are excessive in size or are in any way burdensome to our systems; and (5) otherwise manage the Site in a manner designed to protect our rights and property and to facilitate the proper functioning of the Site.", "We care about data privacy and security. By using the Site, you agree to be bound by our Privacy Policy posted on the Site, which is incorporated into these Terms of Use. Please be advised the Site is hosted in the United States. If you access the Site from the European Union, Asia, or any other region of the world with laws or other requirements governing personal data collection, use, or disclosure that differ from applicable laws in the United States, then through your continued use of the Site, you are transferring your data to the United States, and you expressly consent to have your data transferred to and processed in the United States. Further, we do not knowingly accept, request, or solicit information from children or knowingly market to children. Therefore, in accordance with the U.S. Children’s Online Privacy Protection Act, if we receive actual knowledge that anyone under the age of 13 has provided personal information to us without the requisite and verifiable parental consent, we will delete that information from the Site as quickly as is reasonably practical.", "We respect the intellectual property rights of others. If you believe that any material available on or through the Site infringes upon any copyright you own or control, please immediately notify us using the contact information provided below (a “Notification”). A copy of your Notification will be sent to the person who posted or stored the material addressed in the Notification. Please be advised that pursuant to federal law you may be held liable for damages if you make material misrepresentations in a Notification. Thus, if you are not sure that material located on or linked to by the Site infringes your copyright, you should consider first contacting an attorney.", "These Terms of Use shall remain in full force and effect while you use the Site. WITHOUT LIMITING ANY OTHER PROVISION OF THESE TERMS OF USE, WE RESERVE THE RIGHT TO, IN OUR SOLE DISCRETION AND WITHOUT NOTICE OR LIABILITY, DENY ACCESS TO AND USE OF THE SITE (INCLUDING BLOCKING CERTAIN IP ADDRESSES), TO ANY PERSON FOR ANY REASON OR FOR NO REASON, INCLUDING WITHOUT LIMITATION FOR BREACH OF ANY REPRESENTATION, WARRANTY, OR COVENANT CONTAINED IN THESE TERMS OF USE OR OF ANY APPLICABLE LAW OR REGULATION. WE MAY TERMINATE YOUR USE OR PARTICIPATION IN THE SITE OR DELETE YOUR ACCOUNT AND ANY CONTENT OR INFORMATION THAT YOU POSTED AT ANY TIME, WITHOUT WARNING, IN OUR SOLE DISCRETION. If we terminate or suspend your account for any reason, you are prohibited from registering and creating a new account under your name, a fake or borrowed name, or the name of any third party, even if you may be acting on behalf of the third party. In addition to terminating or suspending your account, we reserve the right to take appropriate legal action, including without limitation pursuing civil, criminal, and injunctive redress.", "We reserve the right to change, modify, or remove the contents of the Site at any time or for any reason at our sole discretion without notice. However, we have no obligation to update any information on our Site. We also reserve the right to modify or discontinue all or part of the Site without notice at any time. We will not be liable to you or any third party for any modification, price change, suspension, or discontinuance of the Site.   We cannot guarantee the Site will be available at all times. We may experience hardware, software, or other problems or need to perform maintenance related to the Site, resulting in interruptions, delays, or errors. We reserve the right to change, revise, update, suspend, discontinue, or otherwise modify the Site at any time or for any reason without notice to you. You agree that we have no liability whatsoever for any loss, damage, or inconvenience caused by your inability to access or use the Site during any downtime or discontinuance of the Site. Nothing in these Terms of Use will be construed to obligate us to maintain and support the Site or to supply any corrections, updates, or releases in connection therewith.", "These Terms of Use and your use of the Site are governed by and construed in accordance with the laws of the State of California applicable to agreements made and to be entirely performed within the State of California, without regard to its conflict of law principles. ", "Informal Negotiations To expedite resolution and control the cost of any dispute, controversy, or claim related to these Terms of Use (each a 'Dispute' and collectively, the “Disputes”) brought by either you or us (individually, a “Party” and collectively, the “Parties”), the Parties agree to first attempt to negotiate any Dispute (except those Disputes expressly provided below) informally for at least thirty (30) days before initiating arbitration. Such informal negotiations commence upon written notice from one Party to the other Party. Binding Arbitration If the Parties are unable to resolve a Dispute through informal negotiations, the Dispute (except those Disputes expressly excluded below) will be finally and exclusively resolved by binding arbitration. YOU UNDERSTAND THAT WITHOUT THIS PROVISION, YOU WOULD HAVE THE RIGHT TO SUE IN COURT AND HAVE A JURY TRIAL. The arbitration shall be commenced and conducted under the Commercial Arbitration Rules of the American Arbitration Association ('AAA') and, where appropriate, the AAA’s Supplementary Procedures for Consumer Related Disputes ('AAA Consumer Rules'), both of which are available at the AAA website www.adr.org. Your arbitration fees and your share of arbitrator compensation shall be governed by the AAA Consumer Rules and, where appropriate, limited by the AAA Consumer Rules. The arbitration may be conducted in person, through the submission of documents, by phone, or online. The arbitrator will make a decision in writing, but need not provide a statement of reasons unless requested by either Party. The arbitrator must follow applicable law, and any award may be challenged if the arbitrator fails to do so. Except where otherwise required by the applicable AAA rules or applicable law, the arbitration will take place in United States County, California. Except as otherwise provided herein, the Parties may litigate in court to compel arbitration, stay proceedings pending arbitration, or to confirm, modify, vacate, or enter judgment on the award entered by the arbitrator. If for any reason, a Dispute proceeds in court rather than arbitration, the Dispute shall be commenced or prosecuted in the state and federal courts located in United States County, California, and the Parties hereby consent to, and waive all defenses of lack of personal jurisdiction, and forum non conveniens with respect to venue and jurisdiction in such state and federal courts. Application of the United Nations Convention on Contracts for the International Sale of Goods and the the Uniform Computer Information Transaction Act (UCITA) are excluded from these Terms of Use. If this provision is found to be illegal or unenforceable, then neither Party will elect to arbitrate any Dispute falling within that portion of this provision found to be illegal or unenforceable and such Dispute shall be decided by a court of competent jurisdiction within the courts listed for jurisdiction above, and the Parties agree to submit to the personal jurisdiction of that court.", " Restrictions The Parties agree that any arbitration shall be limited to the Dispute between the Parties individually. To the full extent permitted by law, (a) no arbitration shall be joined with any other proceeding; (b) there is no right or authority for any Dispute to be arbitrated on a class-action basis or to utilize class action procedures; and (c) there is no right or authority for any Dispute to be brought in a purported representative capacity on behalf of the general public or any other persons. Exceptions to Informal Negotiations and Arbitration The Parties agree that the following Disputes are not subject to the above provisions concerning informal negotiations and binding arbitration: (a) any Disputes seeking to enforce or protect, or concerning the validity of, any of the intellectual property rights of a Party; (b) any Dispute related to, or arising from, allegations of theft, piracy, invasion of privacy, or unauthorized use; and (c) any claim for injunctive relief. If this provision is found to be illegal or unenforceable, then neither Party will elect to arbitrate any Dispute falling within that portion of this provision found to be illegal or unenforceable and such Dispute shall be decided by a court of competent jurisdiction within the courts listed for jurisdiction above, and the Parties agree to submit to the personal jurisdiction of that court.", "There may be information on the Site that contains typographical errors, inaccuracies, or omissions, including descriptions, pricing, availability, and various other information. We reserve the right to correct any errors, inaccuracies, or omissions and to change or update the information on the Site at any time, without prior notice.", "THE SITE IS PROVIDED ON AN AS-IS AND AS-AVAILABLE BASIS. YOU AGREE THAT YOUR USE OF THE SITE AND OUR SERVICES WILL BE AT YOUR SOLE RISK. TO THE FULLEST EXTENT PERMITTED BY LAW, WE DISCLAIM ALL WARRANTIES, EXPRESS OR IMPLIED, IN CONNECTION WITH THE SITE AND YOUR USE THEREOF, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT. WE MAKE NO WARRANTIES OR REPRESENTATIONS ABOUT THE ACCURACY OR COMPLETENESS OF THE SITE’S CONTENT OR THE CONTENT OF ANY WEBSITES LINKED TO THE SITE AND WE WILL ASSUME NO LIABILITY OR RESPONSIBILITY FOR ANY (1) ERRORS, MISTAKES, OR INACCURACIES OF CONTENT AND MATERIALS, (2) PERSONAL INJURY OR PROPERTY DAMAGE, OF ANY NATURE WHATSOEVER, RESULTING FROM YOUR ACCESS TO AND USE OF THE SITE, (3) ANY UNAUTHORIZED ACCESS TO OR USE OF OUR SECURE SERVERS AND/OR ANY AND ALL PERSONAL INFORMATION AND/OR FINANCIAL INFORMATION STORED THEREIN, (4) ANY INTERRUPTION OR CESSATION OF TRANSMISSION TO OR FROM THE SITE, (5) ANY BUGS, VIRUSES, TROJAN HORSES, OR THE LIKE WHICH MAY BE TRANSMITTED TO OR THROUGH THE SITE BY ANY THIRD PARTY, AND/OR (6) ANY ERRORS OR OMISSIONS IN ANY CONTENT AND MATERIALS OR FOR ANY LOSS OR DAMAGE OF ANY KIND INCURRED AS A RESULT OF THE USE OF ANY CONTENT POSTED, TRANSMITTED, OR OTHERWISE MADE AVAILABLE VIA THE SITE. WE DO NOT WARRANT, ENDORSE, GUARANTEE, OR ASSUME RESPONSIBILITY FOR ANY PRODUCT OR SERVICE ADVERTISED OR OFFERED BY A THIRD PARTY THROUGH THE SITE, ANY HYPERLINKED WEBSITE, OR ANY WEBSITE OR MOBILE APPLICATION FEATURED IN ANY BANNER OR OTHER ADVERTISING, AND WE WILL NOT BE A PARTY TO OR IN ANY WAY BE RESPONSIBLE FOR MONITORING ANY TRANSACTION BETWEEN YOU AND ANY THIRD-PARTY PROVIDERS OF PRODUCTS OR SERVICES. AS WITH THE PURCHASE OF A PRODUCT OR SERVICE THROUGH ANY MEDIUM OR IN ANY ENVIRONMENT, YOU SHOULD USE YOUR BEST JUDGMENT AND EXERCISE CAUTION WHERE APPROPRIATE.IN NO EVENT WILL WE OR OUR DIRECTORS, EMPLOYEES, OR AGENTS BE LIABLE TO YOU OR ANY THIRD PARTY FOR ANY DIRECT, INDIRECT, CONSEQUENTIAL, EXEMPLARY, INCIDENTAL, SPECIAL, OR PUNITIVE DAMAGES, INCLUDING LOST PROFIT, LOST REVENUE, LOSS OF DATA, OR OTHER DAMAGES ARISING FROM YOUR USE OF THE SITE, EVEN IF WE HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. NOTWITHSTANDING ANYTHING TO THE CONTRARY CONTAINED HEREIN, OUR LIABILITY TO YOU FOR ANY CAUSE WHATSOEVER AND REGARDLESS OF THE FORM OF THE ACTION, WILL AT ALL TIMES BE LIMITED TO THE AMOUNT PAID, IF ANY, BY YOU TO US DURING THE SIX (6) MONTH PERIOD PRIOR TO ANY CAUSE OF ACTION ARISING. CERTAIN STATE LAWS DO NOT ALLOW LIMITATIONS ON IMPLIED WARRANTIES OR THE EXCLUSION OR LIMITATION OF CERTAIN DAMAGES. IF THESE LAWS APPLY TO YOU, SOME OR ALL OF THE ABOVE DISCLAIMERS OR LIMITATIONS MAY NOT APPLY TO YOU, AND YOU MAY HAVE ADDITIONAL RIGHTS.", "You agree to defend, indemnify, and hold us harmless, including our subsidiaries, affiliates, and all of our respective officers, agents, partners, and employees, from and against any loss, damage, liability, claim, or demand, including reasonable attorneys’ fees and expenses, made by any third party due to or arising out of: (1) your Contributions; (2) use of the Site; (3) breach of these Terms of Use; (4) any breach of your representations and warranties set forth in these Terms of Use; (5) your violation of the rights of a third party, including but not limited to intellectual property rights; or (6) any overt harmful act toward any other user of the Site with whom you connected via the Site. Notwithstanding the foregoing, we reserve the right, at your expense, to assume the exclusive defense and control of any matter for which you are required to indemnify us, and you agree to cooperate, at your expense, with our defense of such claims. We will use reasonable efforts to notify you of any such claim, action, or proceeding which is subject to this indemnification upon becoming aware of it.", "We will maintain certain data that you transmit to the Site for the purpose of managing the performance of the Site, as well as data relating to your use of the Site. Although we perform regular routine backups of data, you are solely responsible for all data that you transmit or that relates to any activity you have undertaken using the Site. You agree that we shall have no liability to you for any loss or corruption of any such data, and you hereby waive any right of action against us arising from any such loss or corruption of such data.", "Visiting the Site, sending us emails, and completing online forms constitute electronic communications. You consent to receive electronic communications, and you agree that all agreements, notices, disclosures, and other communications we provide to you electronically, via email and on the Site, satisfy any legal requirement that such communication be in writing. YOU HEREBY AGREE TO THE USE OF ELECTRONIC SIGNATURES, CONTRACTS, ORDERS, AND OTHER RECORDS, AND TO ELECTRONIC DELIVERY OF NOTICES, POLICIES, AND RECORDS OF TRANSACTIONS INITIATED OR COMPLETED BY US OR VIA THE SITE. You hereby waive any rights or requirements under any statutes, regulations, rules, ordinances, or other laws in any jurisdiction which require an original signature or delivery or retention of non-electronic records, or to payments or the granting of credits by any means other than electronic means. ", "If any complaint with us is not satisfactorily resolved, you can contact the Complaint Assistance Unit of the Division of Consumer Services of the California Department of Consumer Affairs in writing at 1625 North Market Blvd., Suite N 112, Sacramento, California 95834 or by telephone at (800) 952-5210 or (916) 445-1254.", "These Terms of Use and any policies or operating rules posted by us on the Site or in respect to the Site constitute the entire agreement and understanding between you and us. Our failure to exercise or enforce any right or provision of these Terms of Use shall not operate as a waiver of such right or provision. These Terms of Use operate to the fullest extent permissible by law. We may assign any or all of our rights and obligations to others at any time. We shall not be responsible or liable for any loss, damage, delay, or failure to act caused by any cause beyond our reasonable control. If any provision or part of a provision of these Terms of Use is determined to be unlawful, void, or unenforceable, that provision or part of the provision is deemed severable from these Terms of Use and does not affect the validity and enforceability of any remaining provisions. There is no joint venture, partnership, employment or agency relationship created between you and us as a result of these Terms of Use or use of the Site. You agree that these Terms of Use will not be construed against us by virtue of having drafted them. You hereby waive any and all defenses you may have based on the electronic form of these Terms of Use and the lack of signing by the parties hereto to execute these Terms of Use.", "In order to resolve a complaint regarding the Site or to receive further information regarding use of the Site, please contact us at:  Quirks     144 Beachview Avenue   Santa Cruz, CA 95060  United States  Phone: 8312950334  ssanso@lyrecoin.top This terms of service was made possible by Termly. Some personal data may be collected from Users."]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(TermsOfServiceCell.self, forCellReuseIdentifier: cellId)
        view.backgroundColor = .rgb(r: 50, g: 50, b: 50)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return termsSection.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < sectionHeader.count {
            return sectionHeader[section]
        }
        return nil
    }
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = .rgb(r: 50, g: 50, b: 50)
        (view as! UITableViewHeaderFooterView).textLabel?.textColor = .rgb(r: 5, g: 220, b: 163)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! TermsOfServiceCell
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell") as! TermsOfServiceCell
        }
        cell.termsLabel.text = termsSection[indexPath.section]
        cell.backgroundColor = .rgb(r: 74, g: 74, b: 74)
        cell.termsLabel.textColor = UIColor.init(white: 0.9, alpha: 0.6)
        return cell
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

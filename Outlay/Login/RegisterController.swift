//
//  RegisterController.swift
//  Outlay
//
//  Created by Sebastian Sanso on 12/22/18.
//  Copyright © 2018 Sebastian Sanso. All rights reserved.
//

import UIKit
import Firebase

class RegisterController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var pushToken: String?
    
    let addProfileImage: UIImageView = {
        let pf = UIImageView()
        pf.image = UIImage(named: "addPostCustomTabBar")
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
    
    let userNameText: TextField = {
        let fn = TextField()
        fn.backgroundColor = .rgb(r: 75, g: 75, b: 75)
        fn.layer.cornerRadius = 30
        fn.autocorrectionType = .no
        fn.autocapitalizationType = .none
        fn.textColor = .white
        fn.attributedPlaceholder = NSAttributedString(string: "Username",
                                                      attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(white: 0.9, alpha: 0.6)])
        fn.addTarget(self, action: #selector(handleTextFieldChange), for: .editingChanged)
        return fn
    }()
    
    let emailText: TextField = {
        let fn = TextField()
        fn.autocorrectionType = .no
        fn.autocapitalizationType = .none
        fn.backgroundColor = .rgb(r: 75, g: 75, b: 75)
        fn.layer.cornerRadius = 30
        fn.attributedPlaceholder = NSAttributedString(string: "Email",
                                                      attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(white: 0.9, alpha: 0.6)])
        fn.textColor = .white
        fn.addTarget(self, action: #selector(handleTextFieldChange), for: .editingChanged)
        return fn
    }()
    
    let passwordTextField: TextField = {
        let fn = TextField()
        fn.backgroundColor = .rgb(r: 75, g: 75, b: 75)
        fn.layer.cornerRadius = 30
        fn.textColor = .white
        fn.attributedPlaceholder = NSAttributedString(string: "Password",
                                                               attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(white: 0.9, alpha: 0.6)])
        fn.isSecureTextEntry = true
        fn.addTarget(self, action: #selector(handleTextFieldChange), for: .editingChanged)
        return fn
    }()
    
    let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .rgb(r: 5, g: 220, b: 163)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setTitleColor(UIColor(white: 1, alpha: 0.5), for: .disabled)
        button.isEnabled = false
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 60/2
        button.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        return button
    }()
    let alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.setTitleColor(UIColor(white: 0.9, alpha: 1), for: .normal)
        button.addTarget(self, action: #selector(pushRegisterController), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
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
    
    let registerViewModel = RegisterViewModel()
    var effect: UIVisualEffect!

    @objc func handleTextFieldChange(textField: UITextField) {
        if textField == userNameText {
            registerViewModel.username = textField.text
        } else if textField == passwordTextField {
            registerViewModel.password = textField.text
        } else if textField == emailText {
            registerViewModel.email = textField.text
        }
    }
    @objc func pushRegisterController() {
        let viewController = NewLoginController()
//        present some type of user profile modally
        viewController.modalTransitionStyle = .crossDissolve
        viewController.modalPresentationStyle = .overCurrentContext
        UIApplication.topViewController()?.present(viewController, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .rgb(r: 50, g: 50, b: 50)
        view.addSubview(addProfileImage)
        view.addSubview(userNameText)
        view.addSubview(emailText)
        view.addSubview(passwordTextField)
        view.addSubview(registerButton)
        view.addSubview(dummyButton)
        view.addSubview(activityIndicatorView)
        view.addSubview(blurryView)
        view.addSubview(alreadyHaveAccountButton)
        
        addProfileImage.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 50, leftConstant: 100, bottomConstant: 0, rightConstant: 100, widthConstant: 0, heightConstant: view.frame.width-200)
        dummyButton.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 30, leftConstant: 100, bottomConstant: 0, rightConstant: 100, widthConstant: 0, heightConstant: view.frame.width-200)
        userNameText.anchor(addProfileImage.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 50, leftConstant: 32, bottomConstant: 0, rightConstant: 32, widthConstant: 0, heightConstant: 60)
        emailText.anchor(userNameText.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 16, leftConstant: 32, bottomConstant: 0, rightConstant: 32, widthConstant: 0, heightConstant: 60)
        passwordTextField.anchor(emailText.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 16, leftConstant: 32, bottomConstant: 0, rightConstant: 32, widthConstant: 0, heightConstant: 60)
        registerButton.anchor(passwordTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 16, leftConstant: 32, bottomConstant: 0, rightConstant: 32, widthConstant: 0, heightConstant: 60)
        alreadyHaveAccountButton.anchor(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 32, bottomConstant: 10, rightConstant: 32, widthConstant: 0, heightConstant: 60)
        
        
        addProfileImage.layer.cornerRadius = (view.frame.width-200)/2
        effect = blurryView.effect
        blurryView.effect = nil
        //setupActivityIndicator()
        registerViewModel.isValidListener = { [unowned self] (isValid) in
            self.registerButton.isEnabled = isValid
        }
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
    
    @objc func handleRegister() {
        self.blurryView.effect = self.effect
        if pushToken == nil {
            pushToken = Messaging.messaging().fcmToken!
        }
        
        
        guard let email = emailText.text, let password = passwordTextField.text, let name = userNameText.text else {
            print("Form is not valid")
            return
        }
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            if let error = error {
//                self.userNameText.text = ""
//                self.emailText.text = ""
//                self.passwordTextField.text = ""
                let viewController = ErrorLoginViewController()
                viewController.errorTextView.text = error.localizedDescription
                viewController.modalTransitionStyle = .crossDissolve
                viewController.modalPresentationStyle = .overCurrentContext
                UIApplication.topViewController()?.present(viewController, animated: true, completion: nil)
                return
            }
            guard let uid = user?.user.uid else {
                return
            }
            
            if let user = Auth.auth().currentUser {
                
                    let firebaseRef = Database.database().reference().child("users").child(uid)
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
                                        
                                            //add value for avatar
                                            //save texture png file for avatar in firebase as well
                                            let values = ["username": name, "email": email, "profileImageUrl": url!.absoluteString, "pushToken": self.pushToken as Any, "flagged": 0] as [String : Any]
                                            firebaseRef.updateChildValues(values)
                                            //self.registerUserIntoDatabaseWithUID(uid: uid, values: values as [String : AnyObject])
                                            if !user.isEmailVerified{
                                                
                                                let alertVC = UIAlertController(title: "Verify", message: "Please verify your email address to continue.", preferredStyle: .alert)
                                                let alertActionOkay = UIAlertAction(title: "Okay", style: .default) {
                                                    (_) in
                                                    user.sendEmailVerification(completion: nil)
                                                }
                                                

                                                alertVC.addAction(alertActionOkay)
                                                self.present(alertVC, animated: true, completion: nil)
                                            } else { self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                                            self.blurryView.effect = nil
                                        }
                                    }
                                }
                                
                            })
                        }
                    }
                
            }
        })
    }
    
    
    
    private func registerUserIntoDatabaseWithUID(uid: String, values: [String: AnyObject]) {
        let ref = Database.database().reference()
        let usersReference = ref.child("users").child(uid)
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if let err = err {
                print(err)
                return
            }
            print("success")
            MapViewController().queryEvents()
        })
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
}

class TextField: UITextField {
    
    let padding = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 5)
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}

class RegisterViewModel {
    
    var username: String? {
        didSet {
            emitValidity()
        }
    }
    
    var password: String? {
        didSet {
            emitValidity()
        }
    }
    var email: String? {
        didSet {
            emitValidity()
        }
    }
    
    
    
    
    fileprivate func emitValidity() {
        let isValid = username?.isEmpty == false && password?.isEmpty == false && email?.isEmpty == false
        isValidListener?(isValid)
    }
    
    // use a hook to check for form valid
    var isValidListener: ((Bool) -> ())?
    
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

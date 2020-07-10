//
//  NewLoginController.swift
//  Outlay
//
//  Created by Sebastian Sanso on 12/17/18.
//  Copyright © 2018 Sebastian Sanso. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging
import GoogleSignIn

class NewLoginController: UIViewController, UINavigationControllerDelegate{
    
    static let inputHeight: CGFloat = 60
    
    let logoImageView: UIImageView = {
        let iv = UIImageView()
        //this logo will be white
        iv.image = UIImage(named: "Outlay Word Logo White")
        iv.backgroundColor = .clear
        iv.contentMode = .scaleAspectFit
        iv.heightAnchor.constraint(equalToConstant: 160).isActive = true
        return iv
    }()
    
    let usernameTextField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: "Email",
                                                       attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(white: 0.9, alpha: 0.6)])
        tf.backgroundColor = .rgb(r: 75, g: 75, b: 75)
        tf.autocapitalizationType = .none
        tf.textColor = .white
        tf.heightAnchor.constraint(equalToConstant: inputHeight).isActive = true
        tf.layer.cornerRadius = inputHeight / 2
        tf.textAlignment = .center
        tf.addTarget(self, action: #selector(handleTextFieldChange), for: .editingChanged)
        return tf
    }()
    
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: "Password",
                                                       attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(white: 0.9, alpha: 0.6)])
        tf.isSecureTextEntry = true
        tf.textColor = .white
        tf.backgroundColor = .rgb(r: 75, g: 75, b: 75)
        tf.heightAnchor.constraint(equalToConstant: inputHeight).isActive = true
        tf.layer.cornerRadius = inputHeight / 2
        tf.textAlignment = .center
        tf.addTarget(self, action: #selector(handleTextFieldChange), for: .editingChanged)
        return tf
    }()
    
    let registerViewModel = LoginViewModel()
    
    @objc func handleTextFieldChange(textField: UITextField) {
        if textField == usernameTextField {
            registerViewModel.username = textField.text
        } else if textField == passwordTextField {
            registerViewModel.password = textField.text
        }
    }
    
    let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Login", for: .normal)
        button.backgroundColor = .rgb(r: 5, g: 220, b: 163)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.heightAnchor.constraint(equalToConstant: inputHeight).isActive = true
        button.setTitleColor(UIColor(white: 1, alpha: 0.5), for: .disabled)
        button.isEnabled = false
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = inputHeight/2
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    
    let alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Register", for: .normal)
        button.setTitleColor(UIColor(white: 0.9, alpha: 1), for: .normal)
        button.addTarget(self, action: #selector(pushRegisterController), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.delegate = self
        view.backgroundColor = .rgb(r: 50, g: 50, b: 50)

        registerViewModel.isValidListener = { [unowned self] (isValid) in
            self.registerButton.isEnabled = isValid
        }
        
        setupStackView()
    }
    
    fileprivate func setupStackView() {
        let stackView = UIStackView(arrangedSubviews: [logoImageView, usernameTextField, passwordTextField, registerButton, alreadyHaveAccountButton])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.setCustomSpacing(40, after: passwordTextField)
        stackView.setCustomSpacing(50, after: logoImageView)
        
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
    }
    
    @objc func pushRegisterController() {
        let viewController = RegisterController()
//        present some type of user profile modally
        viewController.modalTransitionStyle = .crossDissolve
        viewController.modalPresentationStyle = .overCurrentContext
        UIApplication.topViewController()?.present(viewController, animated: true, completion: nil)
        
    }
    
    @objc func handleLogin() {
        
        
        guard let email = usernameTextField.text, let password = passwordTextField.text else {
            print("Form is not valid")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            
            if let error = error {
                self.usernameTextField.text = ""
                self.passwordTextField.text = ""
                let viewController = ErrorLoginViewController()
                viewController.errorTextView.text = error.localizedDescription
                viewController.modalTransitionStyle = .crossDissolve
                viewController.modalPresentationStyle = .overCurrentContext
                UIApplication.topViewController()?.present(viewController, animated: true, completion: nil)
                return
            }
            if let user = Auth.auth().currentUser {
              
                if !user.isEmailVerified{
                    let alertVC = UIAlertController(title: "Verify", message: "Please verify your email to continue.", preferredStyle: .alert)
                    let alertActionOkay = UIAlertAction(title: "Okay", style: .default) {
                        (_) in
                        user.sendEmailVerification(completion: nil)
                    }
                    let alertActionCancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)

                    alertVC.addAction(alertActionOkay)
                    alertVC.addAction(alertActionCancel)
                    self.present(alertVC, animated: true, completion: nil)
                } else {

                    //successfully logged in our user
                    
                    self.dismiss(animated: true, completion: nil)
                    MapViewController().queryEvents()
                }
            }
            
        })
        
    }
    

    
}

class RegisterButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        setTitleColor(.white, for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var gradientLayer: CAGradientLayer!
    
    override func draw(_ rect: CGRect) {
        backgroundColor = .red
        
        if gradientLayer == nil {
            gradientLayer = CAGradientLayer()
            let startColor = UIColor.rgb(r: 104, g: 205, b: 167).cgColor
            let endColor = UIColor.rgb(r: 153, g: 153, b: 205).cgColor
            gradientLayer.colors = [startColor, endColor]
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
            layer.insertSublayer(gradientLayer, at: 0)
        }
        
        gradientLayer.frame = rect
        layer.cornerRadius = rect.height / 2
        layer.masksToBounds = true
        super.draw(rect)
    }
    
    
}

class LoginViewModel {
    
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
        let isValid = username?.isEmpty == false && password?.isEmpty == false
        isValidListener?(isValid)
    }
    
    // use a hook to check for form valid
    var isValidListener: ((Bool) -> ())?
    
}

class ErrorLoginViewController: UIViewController {
    static let inputHeight: CGFloat = 50

    let errorTextView: UITextView = {
        let et = UITextView()
        et.isEditable = false
        et.isScrollEnabled = false
        et.heightAnchor.constraint(equalToConstant: 80).isActive = true
        et.font = .systemFont(ofSize: 18)
        et.layer.cornerRadius = 5
        et.textAlignment = .center
        et.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        return et
    }()
    
    let tryAgainButton: UIButton = {
        let ta = UIButton()
        ta.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        ta.backgroundColor = .rgb(r: 5, g: 220, b: 163)
        ta.setTitle("Try Again", for: .normal)
        ta.heightAnchor.constraint(equalToConstant: 50).isActive = true
        ta.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        ta.layer.cornerRadius = 5
        ta.addTarget(self, action: #selector(dismissErrorViewController), for: .touchUpInside)
        return ta
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 1, alpha: 0.25)
        
        setupStackView()
        
    }
    fileprivate func setupStackView() {
        let stackView = UIStackView(arrangedSubviews: [errorTextView, tryAgainButton])
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.backgroundColor = UIColor.white
        stackView.layer.cornerRadius = 10
        stackView.layer.masksToBounds = true
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -14).isActive = true
        
    }
    
    @objc func dismissErrorViewController() {
        print("yay")
        dismiss(animated: true, completion: nil)
    }
}

class TryAgain: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setTitle("Try Again", for: .normal)
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        setTitleColor(.white, for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var gradientLayer: CAGradientLayer!
    
    override func draw(_ rect: CGRect) {
        backgroundColor = .red
        
        if gradientLayer == nil {
            gradientLayer = CAGradientLayer()
            let startColor = UIColor.rgb(r: 104, g: 205, b: 167).cgColor
            let endColor = UIColor.rgb(r: 153, g: 153, b: 205).cgColor
            gradientLayer.colors = [startColor, endColor]
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
            layer.insertSublayer(gradientLayer, at: 0)
        }
        
        gradientLayer.frame = rect
        layer.cornerRadius = rect.height / 2
        layer.masksToBounds = true
        super.draw(rect)
    }
    
    
}


extension UIColor {
    static let mainBlue = UIColor.rgb(r: 0, g: 119, b: 245)
    
    static func rgb(r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
        return UIColor(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}

extension UIViewController {
    func setupGradient() {
        let gradientLayer = CAGradientLayer()
        let topColor = UIColor.rgb(r: 0, g: 128, b: 255).cgColor
        let bottomColor = UIColor.rgb(r: 9, g: 153, b: 76).cgColor
        gradientLayer.colors = [topColor, bottomColor]
        gradientLayer.locations = [0, 1]
        
        view.layer.addSublayer(gradientLayer)
        gradientLayer.frame = view.bounds
    }
}

extension UIView {
    public func addConstraintsWithFormat(_ format: String, views: UIView...) {
        
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewsDictionary))
    }
    
    public func fillSuperview() {
        translatesAutoresizingMaskIntoConstraints = false
        if let superview = superview {
            leftAnchor.constraint(equalTo: superview.leftAnchor).isActive = true
            rightAnchor.constraint(equalTo: superview.rightAnchor).isActive = true
            topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
            bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
        }
    }
    
    public func anchor(_ top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, topConstant: CGFloat = 0, leftConstant: CGFloat = 0, bottomConstant: CGFloat = 0, rightConstant: CGFloat = 0, widthConstant: CGFloat = 0, heightConstant: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        
        _ = anchorWithReturnAnchors(top, left: left, bottom: bottom, right: right, topConstant: topConstant, leftConstant: leftConstant, bottomConstant: bottomConstant, rightConstant: rightConstant, widthConstant: widthConstant, heightConstant: heightConstant)
    }
    
    public func anchorWithReturnAnchors(_ top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, topConstant: CGFloat = 0, leftConstant: CGFloat = 0, bottomConstant: CGFloat = 0, rightConstant: CGFloat = 0, widthConstant: CGFloat = 0, heightConstant: CGFloat = 0) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        
        var anchors = [NSLayoutConstraint]()
        
        if let top = top {
            anchors.append(topAnchor.constraint(equalTo: top, constant: topConstant))
        }
        
        if let left = left {
            anchors.append(leftAnchor.constraint(equalTo: left, constant: leftConstant))
        }
        
        if let bottom = bottom {
            anchors.append(bottomAnchor.constraint(equalTo: bottom, constant: -bottomConstant))
        }
        
        if let right = right {
            anchors.append(rightAnchor.constraint(equalTo: right, constant: -rightConstant))
        }
        
        if widthConstant > 0 {
            anchors.append(widthAnchor.constraint(equalToConstant: widthConstant))
        }
        
        if heightConstant > 0 {
            anchors.append(heightAnchor.constraint(equalToConstant: heightConstant))
        }
        
        anchors.forEach({$0.isActive = true})
        
        return anchors
    }
    
    public func anchorCenterXToSuperview(constant: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        if let anchor = superview?.centerXAnchor {
            centerXAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
        }
    }
    
    public func anchorCenterYToSuperview(constant: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        if let anchor = superview?.centerYAnchor {
            centerYAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
        }
    }
    
    public func anchorCenterSuperview() {
        anchorCenterXToSuperview()
        anchorCenterYToSuperview()
    }
}

extension UITextField {
    func setBottomBorder(withColor color: UIColor) {
        self.borderStyle = UITextField.BorderStyle.none
        self.backgroundColor = UIColor.clear
        let width: CGFloat = 1.0
        let borderLine = UIView(frame: CGRect(x: 0, y: self.frame.height - width, width: self.frame.width, height: width))
        borderLine.backgroundColor = color
        self.addSubview(borderLine)
    }
}

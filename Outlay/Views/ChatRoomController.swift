//
//  ChatRoomController.swift
//  Outlay
//
//  Created by Sebastian Sanso on 12/14/18.
//  Copyright © 2018 Sebastian Sanso. All rights reserved.
//

import UIKit
import Firebase
import GeoFire
import MapKit
import SDWebImage

class ChatRoomController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    var uniqueKey: String?
    var message = [Messages]()
    let cellId = "cellId"
    let cellSpacingHeight: CGFloat = 5

    

    
    let chatTypeView: UIView = {
        let cv = UIView()
        cv.backgroundColor = .rgb(r: 74, g: 74, b: 74)
        return cv
    }()
    
    let sendButton: UIButton = {
        let sb = UIButton()
        sb.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        return sb
    }()
    
    let textField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: "Send something... ",
                                                      attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(white: 0.9, alpha: 0.6)])
        tf.textColor = UIColor.init(white: 0.8, alpha: 1)
        
        return tf
    }()
    
    let tableView: UITableView = {
        let tf = UITableView()
        return tf
    }()
    override func viewWillDisappear(_ animated: Bool) {
        //probelmatic lines for rendering collectionview componets in MapViewController
        //will investigate tomorrow, maybe firebase query is calling on didUpdate?
//        let fireRef = Database.database().reference().child("events").child(uniqueKey!).child("UsersInEvent").child(Messaging.messaging().fcmToken!)
//        fireRef.removeValue()
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.backgroundColor = .rgb(r: 50, g: 50, b: 50)
        tableView.backgroundColor = .rgb(r: 50, g: 50, b: 50)
        
        let btn1 = UIButton(type: .custom)
        btn1.setImage(UIImage(named: "icons8-exit-500"), for: .normal)
        btn1.imageView?.contentMode = .scaleAspectFit
        btn1.widthAnchor.constraint(equalToConstant: 32.0).isActive = true
        btn1.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        btn1.addTarget(self, action: #selector(leaveChatroom), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: btn1)
        self.navigationItem.rightBarButtonItem = item1
        
       // self.navigationItem.setHidesBackButton(true, animated: false)

        tableView.dataSource = self
        fetchMessages()
        tableView.register(ChatControllerCell.self, forCellReuseIdentifier: cellId)
        tableView.transform = CGAffineTransform(rotationAngle: (-.pi))
        tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        
        setupViews()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            sendMessage()
            return true
        }
        
        return false
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return message.count
    }
    
    
    
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatControllerCell
        cell.backgroundColor = .rgb(r: 74, g: 74, b: 74)
        cell.transform = CGAffineTransform(rotationAngle: (-.pi))
        cell.transform = CGAffineTransform(scaleX: 1, y: -1)
        let user = self.message.reversed()[indexPath.item]
        cell.messageText.text = user.message
        cell.layer.borderColor = UIColor.rgb(r: 50, g: 50, b: 50).cgColor
        cell.layer.borderWidth = 3.5
        cell.layer.cornerRadius = 10

        
        let fireRef = Database.database().reference().child("users").child(user.fromId)
        fireRef.observe(.value, with: { (snapshot) in
            
            
            if let dictionary = snapshot.childSnapshot(forPath: "profileImageUrl").value {
                if let url = NSURL(string: dictionary as! String) {
                    DispatchQueue.main.async {
                        cell.profileImageView.sd_setImage(with: url as URL, placeholderImage: UIImage(named: "Outlay Username"))
                        
                    }
                    
                }
                
            }
            
            if let userName = snapshot.childSnapshot(forPath: "username").value {
                let formattedString = NSMutableAttributedString()
                formattedString
                    .bold(userName as! String)
                cell.usernameText.attributedText = formattedString
            }
            
            
            
            cell.messageText.text = user.message
            

            
            
            //this will crash because of background thread, so lets use dispatch_async to fix
            
            
        }, withCancel: nil)
        
        return cell
    }
    
    
    
    func setupViews() {
        textField.delegate = self
        setupLongPressGesture()
        
        view.addSubview(chatTypeView)
        view.addSubview(sendButton)
        view.addSubview(textField)
        view.addSubview(tableView)
        
        chatTypeView.anchor(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: view.frame.width, heightConstant: 50)
        tableView.anchor(view.topAnchor, left: view.leftAnchor, bottom: chatTypeView.topAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 5, bottomConstant: 10, rightConstant: 5, widthConstant: 0, heightConstant: 0)
        sendButton.anchor(chatTypeView.topAnchor, left: nil, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 2, leftConstant: 0, bottomConstant: 2, rightConstant: 2, widthConstant: 50, heightConstant: view.frame.height-2)
        textField.anchor(chatTypeView.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: sendButton.leftAnchor, topConstant: 0, leftConstant: 8, bottomConstant: 0, rightConstant: 2, widthConstant: 0, heightConstant: 0)
    }
    
    @objc func sendMessage() {
        let fireRef = Database.database().reference().child("messages").child(uniqueKey!).childByAutoId()
        if let userID = Auth.auth().currentUser?.uid {
            print(userID)
            let values = ["messageText": textField.text!, "fromId": userID] as [String: Any]
            print(values)
            fireRef.updateChildValues(values)
            self.textField.text = ""
        } else {
            // ask the user to login in
            // present your login view controller
            UIApplication.topViewController()?.present(NewLoginController(), animated: true, completion: nil)
        }
        
    }
    
    @objc func leaveChatroom() {
//        let fireRef = Database.database().reference().child("events").child(uniqueKey!).child("UsersInEvent").child(Messaging.messaging().fcmToken!)
//        fireRef.removeValue()
        self.navigationController?.popToRootViewController(animated: true)

    }
    
    func fetchMessages() {
        let fireRef = Database.database().reference().child("messages").child(uniqueKey!)
        fireRef.observe(.childAdded, with: { (snapshot) in
            let messageText = snapshot.childSnapshot(forPath: "messageText").value
            let fromId = snapshot.childSnapshot(forPath: "fromId").value
            let newMessage = Messages(message: messageText as! String, fromId: fromId as! String)
            self.message.append(newMessage)
            
            
            
            //this will crash because of background thread, so lets use dispatch_async to fix
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }, withCancel: nil)
    }
    
    func setupLongPressGesture() {
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        longPressGesture.minimumPressDuration = 1.0 // 1 second press
        longPressGesture.delegate = self as? UIGestureRecognizerDelegate
        self.tableView.addGestureRecognizer(longPressGesture)
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == .ended {
            let touchPoint = gestureRecognizer.location(in: self.tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                let user = self.message.reversed()[indexPath.item]
                if user.fromId != Auth.auth().currentUser!.uid {
                    let viewController = ReportController()
                    viewController.uid = user.fromId
                    viewController.uniqueKey = self.uniqueKey
                    
                    //present some type of user profile modally
                    viewController.modalTransitionStyle = .coverVertical
                    viewController.modalPresentationStyle = .overCurrentContext
                    UIApplication.topViewController()?.present(viewController, animated: true, completion: nil)
                }
                
            }
        }
    }
   
    func attributedText(withString string: String, boldString: String, font: UIFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string,
                                                         attributes: [NSAttributedString.Key.font: font])
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: font.pointSize)]
        let range = (string as NSString).range(of: boldString)
        attributedString.addAttributes(boldFontAttribute, range: range)
        return attributedString
    }
    
    
}

class ChatControllerCell: UITableViewCell {
    
    var messageText: UILabel = {
        let label = UILabel()
        label.text = "..."
        label.backgroundColor = .clear
        label.textAlignment = .left
        label.font.withSize(18)
        label.numberOfLines = 0
        label.textColor = UIColor.init(white: 0.8, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = true
        return label
    }()
    let usernameText: UILabel = {
        let ut = UILabel()
        ut.backgroundColor = .clear
        ut.font.withSize(14)
        ut.textColor = .rgb(r: 5, g: 220, b: 163)
        ut.textAlignment = .left
        return ut
    }()
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 45/2
        iv.layer.masksToBounds = true
        return iv
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(messageText)
        addSubview(profileImageView)
        addSubview(usernameText)
        profileImageView.anchor(self.topAnchor, left: self.leftAnchor, bottom: nil, right: nil, topConstant: 8, leftConstant: 8, bottomConstant: 2, rightConstant: 0, widthConstant: self.frame.height, heightConstant: self.frame.height)
        usernameText.anchor(self.topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: nil, topConstant: 5, leftConstant: 8, bottomConstant: 0, rightConstant: 0, widthConstant: self.frame.width, heightConstant: 25)
        messageText.anchor(usernameText.bottomAnchor, left: profileImageView.rightAnchor, bottom: self.bottomAnchor, right: nil, topConstant: 5, leftConstant: 8, bottomConstant: 5, rightConstant: 0, widthConstant: self.frame.width, heightConstant: 0)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

class ReportController: UIViewController {
    
    var uid: String?
    var uniqueKey: String?

    
    let reportView: UIView = {
        let rv = UIView()
        rv.backgroundColor = .rgb(r: 50, g: 50, b: 50)
        return rv
    }()
    
    lazy var reportButton: UIButton = {
        let rb = UIButton()
        rb.setTitle("Report", for: .normal)
        rb.backgroundColor = .rgb(r: 6, g: 220, b: 163)
        rb.addTarget(self, action: #selector(reportUser), for: .touchUpInside)
        return rb
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.init(white: 0.3, alpha: 0.3)
        view.addSubview(reportView)
        view.addSubview(reportButton)
        
        
        
        reportView.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: view.frame.height/3.5, leftConstant: 50, bottomConstant: 0, rightConstant: 50, widthConstant: 0, heightConstant: 140)
        reportButton.anchor(reportView.topAnchor, left: reportView.leftAnchor, bottom: nil, right: reportView.rightAnchor, topConstant: 40, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: reportView.frame.height/2)
        
        reportView.layer.cornerRadius = 10
        reportButton.layer.cornerRadius = 20
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        //location is relative to the current view
        // do something with the touched point
        if touch?.view != reportView {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func reportUser() {
        print("yay")
        
        let userRef = Database.database().reference().child("users").child(uid!).child("blockedGroups")
        let values = [self.uniqueKey!: true] as [String : Any]
        userRef.updateChildValues(values)
            
            //this will crash because of background thread, so lets use dispatch_async to fix
            
            
            
    }

}



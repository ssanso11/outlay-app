//
//  MapViewController.swift
//  Outlay
//
//  Created by Sebastian Sanso on 12/8/18.
//  Copyright © 2018 Sebastian Sanso. All rights reserved.
//

import UIKit
import MapKit
import GeoFire
import Firebase
import SideMenu
import Mapbox

class MapViewController: UIViewController, CLLocationManagerDelegate, MGLMapViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource , UINavigationControllerDelegate{
    //THE IDEA IS THIS: YOU ARE CATEGORIZED BY WHAT YOU LIKE. THEN YOU CAN QUERY AND FIND EVENTS, WHICH ARE BASICALLY CHAT ROOMS, BASED ON WHAT YOU LIKE. THE CHAT ROOMS ARE ALSO CATEGORIZED I.E. SWIMMING, BICYCLING, DANCING, ETC., AND USING THESE GEOLOCATED ROOMS, YOU FIND PEOPLE YOU LIKE.
    
    
    let locationManager = CLLocationManager()
    var geoFireRef: DatabaseReference?
    var geoFire: GeoFire?
    let cellId = "cellId"
    var event = [Event]()
    var handle: UInt?
    var handleGeoFire: DatabaseHandle!
    var myQuery: GFCircleQuery!
    
    

    let mapView: MGLMapView = {
        let mv = MGLMapView()
        return mv
    }()
    let createEventButton: UIButton = {
        let eb = UIButton()
        eb.setTitle("Create", for: UIControl.State())
        eb.backgroundColor = .rgb(r: 5, g: 220, b: 163)
        eb.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        eb.addTarget(self, action: #selector(popupCreateEvent), for: .touchUpInside)
        eb.layer.shadowColor = UIColor.black.cgColor
        eb.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        eb.layer.shadowOpacity = 0.4
        eb.layer.shadowRadius = 4.0
        return eb
    }()
    let hamgurgerMenu: UIButton = {
        let lb = UIButton()
        lb.backgroundColor = .clear
        lb.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        lb.setImage(UIImage(named: "icons8-settings-500"), for: .normal)
        lb.contentMode = .scaleAspectFit
        lb.addTarget(self, action: #selector(settingsPush), for: .touchUpInside)
        return lb
    }()
    
    let eventsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        cv.backgroundColor = .clear
        return cv
    }()
    
    override func viewWillDisappear(_ animated: Bool) {
        //self.event = []
        //self.eventsCollectionView.reloadData()

        if handle != nil {
            print("Removed the handle")
            geoFireRef?.removeObserver(withHandle: handle!)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("hiii")
        self.event = []
        doSomething()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        NotificationCenter.default.addObserver(self, selector:#selector(doSomething), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        
        self.navigationController?.delegate = self
        //check if user email is verified!
        if Auth.auth().currentUser?.uid == nil {
            print("no")
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else if !Auth.auth().currentUser!.isEmailVerified {
            print("not verified")
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
        
        eventsCollectionView.delegate = self
        eventsCollectionView.dataSource = self
        eventsCollectionView.register(EventCell.self, forCellWithReuseIdentifier: cellId)
        
        mapView.delegate = self
        mapView.frame = view.bounds
        mapView.styleURL = MGLStyle.darkStyleURL
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        //queryEvents()

        
        view.addSubview(mapView)
        view.addSubview(createEventButton)
        view.addSubview(hamgurgerMenu)
        view.addSubview(eventsCollectionView)
        
        hamgurgerMenu.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 30, leftConstant: 12, bottomConstant: 0, rightConstant: 0, widthConstant: 50, heightConstant: 50)
        createEventButton.anchor(view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, topConstant: 30, leftConstant: 0, bottomConstant: 0, rightConstant: 12, widthConstant: 100, heightConstant: 50)
        eventsCollectionView.anchor(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 250)
        view.bringSubviewToFront(createEventButton)
        view.bringSubviewToFront(hamgurgerMenu)
        view.bringSubviewToFront(eventsCollectionView)
        
        
        mapView.showsUserLocation = true
        guard let userLocation = locationManager.location?.coordinate else {return}
        mapView.setCenter(userLocation, zoomLevel: 9, animated: false)
        //print(event)
        
        
    }
    
    @objc func doSomething(){
        //...
        print("yay")
        mapView.showsUserLocation = true
        guard let userLocation = locationManager.location?.coordinate else {return}
        mapView.setCenter(userLocation, zoomLevel: 9, animated: false)
        queryEvents()

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController == self.navigationController?.viewControllers.first {
            self.navigationController?.setNavigationBarHidden(true, animated: animated)
        } else {
            self.navigationController?.setNavigationBarHidden(false, animated: animated)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createEventButton.layer.cornerRadius = (createEventButton.bounds.size.height)/2
        
    }
    
    
    
    @objc func settingsPush() {
        let profileSettingsPage = SettingsTableView()
        self.navigationController?.pushViewController(profileSettingsPage, animated: true)
        let navigationBar = profileSettingsPage.navigationController!.navigationBar
        profileSettingsPage.navigationController!.isNavigationBarHidden = false
        profileSettingsPage.title = "Settings"
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.rgb(r: 5, g: 220, b: 163), NSAttributedString.Key.font: UIFont.init(name: "Avenir-Black", size: 24)!]
        navigationBar.tintColor = UIColor.rgb(r: 5, g: 220, b: 163)
        navigationBar.barTintColor = .rgb(r: 50, g: 50, b: 50)
        navigationBar.isTranslucent = false
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
    }
    
    @objc func popupCreateEvent() {
        let viewController = CreateEventController()
        
        
        //present some type of user profile modally
        //viewController.modalTransitionStyle = .crossDissolve
        viewController.modalPresentationStyle = .currentContext
        //self.event = []
        UIApplication.topViewController()?.present(viewController, animated: true, completion: {
            self.event = []
            self.eventsCollectionView.reloadData()
            if self.handle != nil {
                print("Removed the handle")
                self.geoFireRef?.removeObserver(withHandle: self.handle!)
            }
        })
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
    
    func queryEvents() {
        guard let eventLocation = locationManager.location else {return}
        geoFireRef = Database.database().reference().child("events")
        geoFire = GeoFire(firebaseRef: geoFireRef!)
        
        let myQuery = geoFire?.query(at: eventLocation, withRadius: 10)
        //maybe keyenetered is a problem?
        self.handleGeoFire = myQuery?.observe(.keyEntered, with: { (key:String!, location:CLLocation!) in
            //this below should give us the data relating to the nearby events
            
            
            
            self.handle = (self.geoFireRef?.observe(.value, with: { (snapshot) in
                let eventText = snapshot.childSnapshot(forPath: key).childSnapshot(forPath: "eventName").value
                let eventCatgory = snapshot.childSnapshot(forPath: key).childSnapshot(forPath: "category").value
                let eventImageUrl = snapshot.childSnapshot(forPath: key).childSnapshot(forPath: "eventImageUrl").value
                let newEvent = Event(title: eventText as! String, eventCoordinate: location.coordinate, uniqueId: key as String, subtitle: eventCatgory as! String, eventImageUrl: eventImageUrl as! String)
                self.event.append(newEvent)
                //add image related to category of event
                DispatchQueue.main.async {
                    self.mapView.addAnnotation(newEvent as MGLAnnotation)
                    self.eventsCollectionView.reloadData()
                    
                }
                
                
                
            }, withCancel: nil))!
    
            
        })
        myQuery!.observeReady({
            print("All initial data has been loaded and events have been fired!")
            myQuery?.removeObserver(withFirebaseHandle: self.handleGeoFire)
        })
        
    }
    
    private func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        if let eventAnnotation = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier) as? MKMarkerAnnotationView {
            //WE CAN DO A CASE STATEMENT FOR EACH CATEGORY AND ASSIGN AN IMAGE
            eventAnnotation.animatesWhenAdded = true
            eventAnnotation.titleVisibility = .adaptive
            
            
            return eventAnnotation
        }
        
        return nil
    }
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        let viewController = JoinEventController()
        guard let annotation = annotation as? Event else {return false}
        viewController.uniqueId = annotation.uniqueId!
        viewController.eventImage = annotation.eventImageUrl!
        viewController.eventName = annotation.title!
        viewController.eventSubtitle = annotation.subtitle!
        
        
        //present some type of user profile modally
        viewController.modalTransitionStyle = .crossDissolve
        viewController.modalPresentationStyle = .overCurrentContext
        UIApplication.topViewController()?.present(viewController, animated: true, completion: nil)
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return event.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print(indexPath.item)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! EventCell
        if indexPath.item >= 0 && indexPath.item < event.count {
            
            let event = self.event[indexPath.item]
            cell.nameLabel.text = event.title
            cell.categoryLabel.text = event.subtitle
            cell.uniqueId = event.uniqueId
            cell.joinChat.tag = indexPath.row
            cell.joinChat.addTarget(self, action: #selector(submitAndPushChat(sender:)), for: .touchUpInside)
            if let url = NSURL(string: event.eventImageUrl) {
                DispatchQueue.main.async {
                    cell.profileImage.sd_setImage(with: url as URL, placeholderImage: UIImage(named: "Outlay Username"))
                }
                
            }
            return cell
        }
        return cell
        
    
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: collectionView.frame.height-32)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 0, left: 14, bottom: 0, right: 14)
    }
    
    @objc func submitAndPushChat(sender: UIButton) {
        let objectIndex = sender.tag
        let object = event[objectIndex]
        
        let fireRef = Database.database().reference().child("events").child(object.uniqueId).child("UsersInEvent").child(Messaging.messaging().fcmToken!)
        let userRef = Database.database().reference().child("users").child(Auth.auth().currentUser!.uid)
        userRef.observe(.value, with: { (snapshot) in
            let pushToken = snapshot.childSnapshot(forPath: "pushToken").value
            let values = [pushToken as! String: pushToken as Any] as [String : Any]
            fireRef.updateChildValues(values)
            
            //this will crash because of background thread, so lets use dispatch_async to fix
            
            
            
        }, withCancel: nil)
        
        let viewController = ChatRoomController()
        viewController.uniqueKey = object.uniqueId
        
        self.navigationController?.pushViewController(viewController, animated: true)
        let navigationBar = viewController.navigationController!.navigationBar
        viewController.navigationController!.isNavigationBarHidden = false
        viewController.title = object.title
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.rgb(r: 5, g: 220, b: 163), NSAttributedString.Key.font: UIFont.init(name: "Avenir-Black", size: 24)!]
        navigationBar.tintColor = UIColor.rgb(r: 5, g: 220, b: 163)
        navigationBar.barTintColor = .rgb(r: 50, g: 50, b: 50)
        navigationBar.isTranslucent = false
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
    }

    
}



class EventCell: UICollectionViewCell {
    
    var uniqueId: String?



    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = 10
        joinChat.layer.cornerRadius = 5
    }
    
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 25)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.bringSubviewToFront(label)
        label.textColor = .rgb(r: 5, g: 220, b: 163)
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        return label
    }()
    
    let categoryLabel: UILabel = {
        let label = UILabel()
        label.font.withSize(10)
        label.textColor = .rgb(r: 5, g: 220, b: 163)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let profileImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.layer.masksToBounds = true
        image.clipsToBounds = true
        image.layer.cornerRadius = 10
        image.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        image.backgroundColor = .white
        return image
    }()
    
    lazy var joinChat: UIButton = {
        let eb = UIButton()
        eb.setTitle("Join", for: UIControl.State())
        eb.backgroundColor = .rgb(r: 5, g: 220, b: 163)
        eb.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        eb.titleLabel?.textColor = UIColor.white
        eb.layer.shadowColor = UIColor.black.cgColor
        eb.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        eb.layer.shadowOpacity = 0.4
        eb.layer.shadowRadius = 4.0
        return eb
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupViews() {
        backgroundColor = .rgb(r: 50, g: 50, b: 50)
        addSubview(profileImage)
        addSubview(nameLabel)
        addSubview(categoryLabel)
        addSubview(joinChat)
    
        profileImage.anchor(topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: frame.height/2)
        nameLabel.anchor(profileImage.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: -40, leftConstant: 8, bottomConstant: 0, rightConstant: 8, widthConstant: 0, heightConstant: 30)
        categoryLabel.anchor(profileImage.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 8, leftConstant: 15, bottomConstant: 0, rightConstant: 15, widthConstant: 0, heightConstant: 30)
        joinChat.anchor(categoryLabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 20, leftConstant: 8, bottomConstant: 8, rightConstant: 8, widthConstant: 0, heightConstant: 0)
    }
    
    
}




class JoinEventController: UIViewController {
    
    var uniqueId: String?
    var eventImage: String?
    var eventName: String?
    var eventSubtitle: String?


    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        joinChat.layer.cornerRadius = 5
        joinView.layer.cornerRadius = 10
    }
    

    let joinView: UIView = {
        let jv = UIView()
        jv.backgroundColor = .white
        jv.layer.shadowColor = UIColor.black.cgColor
        jv.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        jv.layer.shadowOpacity = 0.4
        jv.layer.shadowRadius = 4.0
        return jv
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 25)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.bringSubviewToFront(label)
        label.textColor = .rgb(r: 5, g: 220, b: 163)
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        return label
    }()
    
    
    let categoryLabel: UILabel = {
        let label = UILabel()
        label.font.withSize(10)
        label.textColor = .rgb(r: 5, g: 220, b: 163)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let profileImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.layer.masksToBounds = true
        image.clipsToBounds = true
        image.layer.cornerRadius = 10
        image.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        image.backgroundColor = .white
        return image
    }()
    
    lazy var joinChat: UIButton = {
        let eb = UIButton()
        
        eb.setTitle("Join", for: UIControl.State())
        eb.backgroundColor = .rgb(r: 5, g: 220, b: 163)
        eb.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        eb.titleLabel?.textColor = UIColor.white
        eb.addTarget(self, action: #selector(submitAndPushChat), for: .touchUpInside)
        eb.layer.shadowColor = UIColor.black.cgColor
        eb.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        eb.layer.shadowOpacity = 0.4
        eb.layer.shadowRadius = 4.0
        return eb
    }()
    
    func setupViews() {
        view.backgroundColor = UIColor.init(white: 0.3, alpha: 0.3)
        
        
        view.addSubview(joinView)
        view.addSubview(profileImage)
        view.addSubview(nameLabel)
        view.addSubview(categoryLabel)
        view.addSubview(joinChat)
        
        joinView.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 200, leftConstant: 50, bottomConstant: 250, rightConstant: 50, widthConstant: 0, heightConstant: 0)
        profileImage.anchor(joinView.topAnchor, left: joinView.leftAnchor, bottom: nil, right: joinView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: joinView.frame.height/2)
        nameLabel.anchor(profileImage.bottomAnchor, left: joinView.leftAnchor, bottom: nil, right: profileImage.rightAnchor, topConstant: -40, leftConstant: 8, bottomConstant: 0, rightConstant: 8, widthConstant: 0, heightConstant: 30)
        categoryLabel.anchor(profileImage.bottomAnchor, left: joinView.leftAnchor, bottom: nil, right: joinView.rightAnchor, topConstant: 8, leftConstant: 15, bottomConstant: 0, rightConstant: 15, widthConstant: 0, heightConstant: 30)
        joinChat.anchor(categoryLabel.bottomAnchor, left: joinView.leftAnchor, bottom: joinView.bottomAnchor, right: joinView.rightAnchor, topConstant: 20, leftConstant: 8, bottomConstant: 8, rightConstant: 8, widthConstant: 0, heightConstant: 0)
        
        if let url = NSURL(string: eventImage!) {
            DispatchQueue.main.async {
                self.profileImage.sd_setImage(with: url as URL, placeholderImage: UIImage(named: "Outlay Username"))
            }
        }
        
        self.nameLabel.text = eventName
        self.categoryLabel.text = eventSubtitle
        
    }
    
    @objc func submitAndPushChat() {
        print("yay")
        let fireRef = Database.database().reference().child("events").child(uniqueId!).child("UsersInEvent").child(Messaging.messaging().fcmToken!)
        let userRef = Database.database().reference().child("users").child(Auth.auth().currentUser!.uid)
        userRef.observe(.value, with: { (snapshot) in
            let pushToken = snapshot.childSnapshot(forPath: "pushToken").value
            let values = [pushToken as! String: pushToken as Any] as [String : Any]
            fireRef.updateChildValues(values)
            
            //this will crash because of background thread, so lets use dispatch_async to fix
            
            
            
        }, withCancel: nil)
        
        
        dismiss(animated: true) {
            let viewController = ChatRoomController()
            viewController.uniqueKey = self.uniqueId
            
            //present some type of user profile modally
            viewController.modalTransitionStyle = .crossDissolve
            viewController.modalPresentationStyle = .overCurrentContext
            UIApplication.topViewController()?.present(viewController, animated: true, completion: nil)
        }
    }
    

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        //location is relative to the current view
        // do something with the touched point
        if touch?.view != joinView {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ quality: JPEGQuality) -> Data? {
        return self.jpegData(compressionQuality: quality.rawValue)
    }
}

extension UIApplication {
    class func topViewController(viewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = viewController as? UINavigationController {
            return topViewController(viewController: nav.visibleViewController)
        }
        if let tab = viewController as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(viewController: selected)
            }
        }
        if let presented = viewController?.presentedViewController {
            return topViewController(viewController: presented)
        }
        return viewController
    }
}

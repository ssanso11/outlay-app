//
//  CreateEventController.swift
//  Outlay
//
//  Created by Sebastian Sanso on 10/3/18.
//  Copyright © 2018 Sebastian Sanso. All rights reserved.
//

import UIKit
import Firebase
import MapKit
import CoreLocation
import GeoFire
import YPImagePicker

class CreateEventController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    var data = ["Random", "Meet-up", "Sports", "Politics", "News", "Music", "Art", "Movies", "Books", "Technology", "Fashion", "Community"]
    var picker = UIPickerView()
    
    

    
    let locationManager = CLLocationManager()
    var geoFireRef: DatabaseReference?
    var geoFire: GeoFire?

    //add private or public event later
    let eventView: UIView = {
        let ev = UIView()
        ev.layer.cornerRadius = 10
        ev.backgroundColor = .rgb(r: 50, g: 50, b: 50)
        return ev
    }()
    
    let eventImage: UIImageView = {
        let ei = UIImageView()
        ei.backgroundColor = .clear
        ei.contentMode = .scaleAspectFit
        ei.image = UIImage(named: "icons8-compact-camera-500")
        ei.layer.masksToBounds = true
        return ei
    }()
    
    let dummyButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(YPPickerSetup), for: .touchUpInside)
        return button
    }()
    
    let eventNameText: UITextField = {
        let en = UITextField()
        en.backgroundColor = UIColor.clear
        en.textColor = UIColor.init(white: 0.9, alpha: 0.6)
        en.placeholder = "Event Name"
        en.attributedPlaceholder = NSAttributedString(string: "Event Name",
                                                      attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(white: 0.9, alpha: 0.6)])
        return en
    }()
    
    let eventCategory: UITextField = {
        let en = UITextField()
        en.backgroundColor = UIColor.clear
        en.textColor = UIColor.init(white: 0.9, alpha: 0.6)
        en.attributedPlaceholder = NSAttributedString(string: "Pick a Category",
                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(white: 0.9, alpha: 0.6)])
        return en
    }()
    
    let submitButton: UIButton = {
        let sb = UIButton()
        sb.backgroundColor = .rgb(r: 5, g: 220, b: 163)
        sb.setTitle("Create", for: UIControl.State())
        sb.titleLabel?.textColor = UIColor.white
        sb.addTarget(self, action: #selector(submitAndDismiss), for: .touchUpInside)
        return sb
    }()
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("modal gone")
        if let firstVC = presentingViewController as? MapViewController {
            print("e")
            DispatchQueue.main.async {
                firstVC.doSomething()
                firstVC.eventsCollectionView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.init(white: 0.3, alpha: 0.3)
        view.addSubview(eventView)
        view.addSubview(eventImage)
        view.addSubview(eventNameText)
        view.addSubview(submitButton)
        view.addSubview(eventCategory)
        view.addSubview(dummyButton)
        eventView.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: view.frame.height/3.5, leftConstant: 50, bottomConstant: 250, rightConstant: 50, widthConstant: 0, heightConstant: 270)
        eventImage.anchor(eventView.topAnchor, left: eventView.leftAnchor, bottom: nil, right: nil, topConstant: 12, leftConstant: 12, bottomConstant: 0, rightConstant: 0, widthConstant: 75, heightConstant: 75)
        eventNameText.anchor(eventView.topAnchor, left: eventImage.rightAnchor, bottom: nil, right: eventView.rightAnchor, topConstant: 12 + (75/3), leftConstant: 12, bottomConstant: 0, rightConstant: 12, widthConstant: 0, heightConstant: 35)
        eventCategory.anchor(eventImage.bottomAnchor, left: eventView.leftAnchor, bottom: nil, right: eventView.rightAnchor, topConstant: 20, leftConstant: 12, bottomConstant: 0, rightConstant: 12, widthConstant: 0, heightConstant: 35)
        submitButton.anchor(nil, left: eventView.leftAnchor, bottom: eventView.bottomAnchor, right: eventView.rightAnchor, topConstant: 0, leftConstant: 12, bottomConstant: 12, rightConstant: 12, widthConstant: 0, heightConstant: 50)
        dummyButton.anchor(eventImage.topAnchor, left: eventImage.leftAnchor, bottom: eventImage.bottomAnchor, right: eventImage.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        picker.delegate = self
        picker.dataSource = self
        eventCategory.inputView = picker
        eventCategory.delegate = self
        
        
    }
    
    override func viewDidLayoutSubviews() {
        submitButton.layer.cornerRadius = (submitButton.bounds.height)/2
        eventImage.layer.cornerRadius = (eventImage.bounds.height)/2
        eventNameText.setBottomBorder(withColor: .gray)
        eventCategory.setBottomBorder(withColor: .gray)
    }
    
    @objc func YPPickerSetup() {
        var config = YPImagePickerConfiguration()
        // [Edit configuration here ...]
        config.library.maxNumberOfItems = 1
        config.library.minNumberOfItems = 1
        config.showsFilters = false

        // Build a picker with your configuration
        let ypPicker = YPImagePicker(configuration: config)
        ypPicker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                self.eventImage.image = photo.image
                
            }
            ypPicker.dismiss(animated: true, completion: nil)
        }
        present(ypPicker, animated: true, completion: nil)
    }
    
    
    @objc func submitAndDismiss() {
        print("adding event")
        guard let eventName = self.eventNameText.text, let eventLocation = locationManager.location, let category = self.eventCategory.text, let image = eventImage.image else {return}
        
        
        
        geoFireRef = Database.database().reference().child("events")
        geoFire = GeoFire(firebaseRef: geoFireRef!)
        let childId = geoFireRef?.childByAutoId()
        let uid = childId?.key
        
        
        let imageName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("event_image")
        let childStorageRef = storageRef.child("Images").child("\(imageName).jpeg")
        
        
        
        if let uploadData = image.jpeg(.medium) {
            print(uploadData.count)
            childStorageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if let error = error {
                    let viewController = ErrorLoginViewController()
                    viewController.errorTextView.text = error.localizedDescription
                    viewController.modalTransitionStyle = .crossDissolve
                    viewController.modalPresentationStyle = .overCurrentContext
                    UIApplication.topViewController()?.present(viewController, animated: true, completion: nil)
                    return
                } else {
                    childStorageRef.downloadURL { url, error in
                        if let error = error {
                            let viewController = ErrorLoginViewController()
                            viewController.errorTextView.text = error.localizedDescription
                            viewController.modalTransitionStyle = .crossDissolve
                            viewController.modalPresentationStyle = .overCurrentContext
                            UIApplication.topViewController()?.present(viewController, animated: true, completion: nil)
                            return
                        } else {
                            let values = ["eventName": eventName, "category": category, "eventImageUrl": url?.absoluteString as Any] as [String : Any]
                            childId!.updateChildValues(values)
                            self.geoFire?.setLocation(eventLocation, forKey: uid!)
                            print(values)
                            //self.navigationController?.popToRootViewController(animated: true)
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
                
            })
        }
    
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        eventCategory.text = data[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return data[row]
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
            eventImage.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Canceled")
        dismiss(animated: true, completion: nil)
    }
    
//    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        eventCategory.resignFirstResponder()
//        // Additional code here
//        return false
//    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        if touch?.view != eventView {
            self.dismiss(animated: true, completion: nil)
        }
    }

}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

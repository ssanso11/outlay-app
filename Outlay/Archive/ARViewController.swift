//
//  PagerViewController.swift
//  Outlay
//
//  Created by Sebastian Sanso on 8/26/18.
//  Copyright © 2018 Sebastian Sanso. All rights reserved.
//

import UIKit
import ARKit
import Firebase
import MapKit
import CoreLocation
import SpriteKit
import SceneKit

class ARViewController: UIViewController, CLLocationManagerDelegate {
    

    
    var users = [UserWithoutEmail]()
    var usersInEvent = [Any]()
    let createEventController = CreateEventController()
    let locationManager = CLLocationManager()
    
    var ARView: ARSCNView {
        return self.view as! ARSCNView
    }

    
    override func loadView() {
        self.view = ARSCNView(frame: .zero)
        self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let scnView = self.view as! SCNView
        let overlayScene = ButtonScene(size: CGSize(width: 500, height: 500))
        scnView.overlaySKScene = overlayScene
        scnView.overlaySKScene?.isUserInteractionEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        

        setupViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        ARView.session.run(configuration)
    }
    

    func addObject() {
        let ship = CharacterLoader()
        
        ship.fetchUsers(completion: { (error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                for each in ship.childNodes {
                    let xPos = self.randomPosition(lowerBound: -1.5, upperBound: 1.5)
//                    let yPos = self.randomPosition(lowerBound: -1.5, upperBound: 1.5)
                    
                    each.position = SCNVector3(xPos, 0, -1)
                    
                    
                    self.ARView.scene.rootNode.addChildNode(each)
                    print(self.ARView.scene.rootNode.childNodes.count)
                }
                
            }
        })
        
        //have to wait for fetchusers and loadModal to finish before running this code
    }
    
    func fetchUsers(user: [UserWithoutEmail]) {
        //self.users.append(user)
    }
    
    func randomPosition (lowerBound lower:Float, upperBound upper:Float) -> Float {
        return Float(arc4random()) / Float(UInt32.max) * (lower - upper) + upper
    }
    

    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: ARView)
            
            let hitList = ARView.hitTest(location, options: nil)
            
            if let hitObject = hitList.first {
                //find out which .scn file stored in firebase with uid matches hitnode, then print that users name
                let node = hitObject.node
                let skScene = SKScene(size: CGSize(width: 200, height: 200))
                let rectangle = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 200, height: 200), cornerRadius: 10)
                rectangle.fillColor = #colorLiteral(red: 0.807843148708344, green: 0.0274509806185961, blue: 0.333333343267441, alpha: 1.0)
                rectangle.strokeColor = #colorLiteral(red: 0.439215689897537, green: 0.0117647061124444, blue: 0.192156866192818, alpha: 1.0)
                rectangle.lineWidth = 5
                rectangle.alpha = 0.4
                let labelNode = SKLabelNode(text: "Hello World")
                labelNode.fontSize = 20
                labelNode.position = CGPoint(x:100,y:100)
                skScene.addChild(rectangle)
                skScene.addChild(labelNode)
                let plane = SCNPlane(width: 0.1, height: 0.1)
                let material = SCNMaterial()
                material.isDoubleSided = true
                material.diffuse.contents = skScene
                material.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(1, -1, 1), 1,0,1)
                plane.materials = [material]
                //let node = SCNNode(geometry: plane)
                self.ARView.scene.rootNode.addChildNode(node)
//                let height = node.boundingBox.max.y-node.boundingBox.min.y

//                let positionPlane = SCNPlane(width: 0.1, height: 0.1)
//                positionPlane.cornerRadius = positionPlane.width/8
//                let spriteKitScene = SpriteKitController(size: CGSize(width: 200, height: 200))
//                let material = SCNMaterial()
//                material.isDoubleSided = true
//                material.diffuse.contents = spriteKitScene
//                positionPlane.materials = [material]
//                let planeNode = SCNNode(geometry: positionPlane)
//                let xPos = self.randomPosition(lowerBound: -1.5, upperBound: 1.5)
//                planeNode.position = SCNVector3(xPos, 0, -1)//SCNVector3(node.worldPosition.x
////, node.worldPosition.y+height, node.worldPosition.z)
//                self.ARView.scene.rootNode.addChildNode(planeNode)
//                print("done")
            }
            
        }
    }

    
    func setupViews() {
        let scene = SCNScene()
        ARView.scene = scene
        ARView.delegate = self as? ARSCNViewDelegate
        addObject()
        NotificationCenter.default.addObserver(self, selector: #selector(ARViewController.showSocialNetworks), name: NSNotification.Name(rawValue: "showSocialNetworksID"), object: nil)
    }
    @objc func showSocialNetworks() {
        let layout = UICollectionViewFlowLayout()
        let viewController = UserProfileController(collectionViewLayout: layout)
        
        //present some type of user profile modally
        viewController.modalTransitionStyle = .crossDissolve
        viewController.modalPresentationStyle = .overCurrentContext
        self.present(viewController, animated: true, completion: nil)
    }
    
    @objc func showCreateEvent() {
        print("yay")
        let viewController = CreateEventController()
        
        
        //present some type of user profile modally
        viewController.modalTransitionStyle = .crossDissolve
        viewController.modalPresentationStyle = .overCurrentContext
        UIApplication.topViewController()?.present(viewController, animated: true, completion: nil)
    }
    
    
    
    
}


class SpriteKitButton: SKSpriteNode {
    
    private let textureDefault: SKTexture
    private let textureActive: SKTexture
    
    init(defaultImageNamed: String, activeImageNamed:String) {
        textureDefault = SKTexture(imageNamed: defaultImageNamed)
        textureActive = SKTexture(imageNamed: activeImageNamed)
        super.init(texture: textureDefault, color: .clear, size: textureDefault.size())
        self.isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }
    
    var touchBeganCallback: (() -> Void)?
    var touchEndedCallback: (() -> Void)?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.texture = textureActive
        touchBeganCallback?()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.texture = textureDefault
        touchEndedCallback?()
    }
}

class ButtonScene: SKScene {

    override func didMove(to view: SKView) {
        
        // 1. create the button
        let button = SpriteKitButton(defaultImageNamed: "default", activeImageNamed: "active")
        
        // 2. write what should happen when the button is tapped
        button.touchBeganCallback = {
            print("Touch began")
        }
        
        // 3. write what should happen when the button is released
        button.touchEndedCallback = {
            print("Touch ended")
            ARViewController().showCreateEvent()
        }
        
        // 4. add the button to the scene
        addChild(button)
        
    }
}



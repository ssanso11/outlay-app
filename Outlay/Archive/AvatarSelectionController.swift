//
//  AvatarSelectionController.swift
//  Outlay
//
//  Created by Sebastian Sanso on 9/23/18.
//  Copyright © 2018 Sebastian Sanso. All rights reserved.
//

import UIKit
import SceneKit

class AvatarSelectionController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    let cellId = "cellId"
    
   
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = UIColor.white//init(red: 61/255, green: 201/255, blue: 150/255, alpha: 1)
        
        return collectionView
    }()
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! AvatarCell

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        print("yrs")

        cell?.layer.borderColor = UIColor.blue.cgColor
        cell?.layer.borderWidth = 5
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width-2)/3
        return CGSize(width: width, height: width)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        avatarAdd()
        
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(AvatarCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.anchor(view.topAnchor, left: nil, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: view.frame.width/2, heightConstant: view.frame.height)
    }
    
    func avatarAdd(){
        let avatarView = SCNView(frame: self.view.frame)
        self.view.addSubview(avatarView)
        
        let scene = SCNScene()
        avatarView.scene = scene
        
        let camera = SCNCamera()
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: -3.0, y: 3.0, z: 3.0)
        
        let ambientLight = SCNLight()
        ambientLight.type = SCNLight.LightType.ambient
        ambientLight.color = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        cameraNode.light = ambientLight
        
        let light = SCNLight()
        light.type = SCNLight.LightType.spot
        light.spotInnerAngle = 30.0
        light.spotOuterAngle = 80.0
        light.castsShadow = true
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(x: 1.5, y: 1.5, z: 1.5)
        
        let cubeGeometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
        let cubeNode = SCNNode(geometry: cubeGeometry)
        
        let planeGeometry = SCNPlane(width: 100.0, height: 100.0)
        let planeNode = SCNNode(geometry: planeGeometry)
        planeNode.eulerAngles = SCNVector3(x: GLKMathDegreesToRadians(-90), y: 0, z: 0)
        planeNode.position = SCNVector3(x: 0, y: -0.5, z: 0)
        
        let redMaterial = SCNMaterial()
        redMaterial.diffuse.contents = UIColor.red
        cubeGeometry.materials = [redMaterial]
        
        let greenMaterial = SCNMaterial()
        greenMaterial.diffuse.contents = UIColor.green
        planeGeometry.materials = [greenMaterial]
        
        let constraint = SCNLookAtConstraint(target: cubeNode)
        constraint.isGimbalLockEnabled = true
        cameraNode.constraints = [constraint]
        lightNode.constraints = [constraint]
        
        scene.rootNode.addChildNode(lightNode)
        scene.rootNode.addChildNode(cameraNode)
        scene.rootNode.addChildNode(cubeNode)
        scene.rootNode.addChildNode(planeNode)
    }
}

class AvatarCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .green
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

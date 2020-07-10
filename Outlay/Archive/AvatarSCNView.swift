//
//  AvatarSKNView.swift
//  Outlay
//
//  Created by Sebastian Sanso on 10/1/18.
//  Copyright © 2018 Sebastian Sanso. All rights reserved.
//

import UIKit
import SceneKit

class AvatarSceneView: SCNView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

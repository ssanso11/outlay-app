//
//  TopicsCells.swift
//  Outlay
//
//  Created by Sebastian Sanso on 1/10/18.
//  Copyright © 2018 Sebastian Sanso. All rights reserved.
//

import UIKit

class TopicsCells: UICollectionViewCell {
    
    var page: Page? {
        didSet {
            
            guard let page = page else {
                return
            }
            
            mathButton.setTitle(page.Button, for: UIControlState())
        }
    }
    
    
    
    lazy var mathButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.lightGray
        button.setTitle("Math", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 9)
        button.layer.cornerRadius = 5
        return button
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    func setupViews() {
        addSubview(mathButton)
        mathButton.anchorToTop(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
}

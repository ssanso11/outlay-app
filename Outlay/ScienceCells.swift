//
//  ScienceCells.swift
//  Outlay
//
//  Created by Sebastian Sanso on 1/11/18.
//  Copyright © 2018 Sebastian Sanso. All rights reserved.
//

import Foundation
import UIKit

class ScienceCells: UICollectionViewCell {

    
    var pages2: Page? {
        didSet {
            
            guard let page = pages2 else {
                return
            }
            
            scienceButton.setTitle(page.Button, for: UIControlState())
        }
    }
    
    
    lazy var scienceButton: UIButton = {
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
        addSubview(scienceButton)
        scienceButton.anchorToTop(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    let pages: [Page] = {
//        //let firstPage = Page(Button: "Kindergarden Math")
//        let secondPage = Page(Button: "1st Grade Math")
//        let thirdPage = Page(Button: "2nd Grade Math")
//        let fourthPage = Page(Button: "3rd Grade Math")
//        let fifthPage = Page(Button: "4th Grade Math")
//        let sixthPage = Page(Button: "5th Grade Math")
//        let seventhPage = Page(Button: "6th Grade Math")
//        let eightPage = Page(Button: "7th Grade Math")
//        let ninePage = Page(Button: "8th Grade Math")
//        let tenPage = Page(Button: "Algebra 1")
//        let elevenPage = Page(Button: "Geometry")
//        let twelvePage = Page(Button: "Algebra 2")
//        let thirteenPage = Page(Button: "Trigonometry")
//        let fourteenPage = Page(Button: "Pre-calculus")
//        let fifteenPage = Page(Button: "Statistics")
//        let sixteenPage = Page(Button: "AP Calculus AB")
//        let seventeenPage = Page(Button: "AP Calculus BC")
//        let eighteenPage = Page(Button: "AP Statistics")
//
//        return [secondPage, thirdPage, fourthPage, fifthPage, sixthPage, seventhPage, eightPage, ninePage, tenPage, elevenPage, twelvePage, thirteenPage, fourteenPage, fifteenPage, sixteenPage, seventeenPage, eighteenPage]
//    }()
//
//    let pages2: [Page] = {
//        let firstPage = Page(Button: "Science")
//        return [firstPage]
//    }()
    
    
}

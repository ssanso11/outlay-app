//
//  Models.swift
//  Outlay
//
//  Created by Sebastian Sanso on 1/13/18.
//  Copyright © 2018 Sebastian Sanso. All rights reserved.
//

import UIKit

class SubjectCategory: NSObject {
    var name: String?
    var subjects: [Subject]?
    
    static func sampleSubjectCategories() -> [SubjectCategory] {
        let roboticsSubjects = SubjectCategory()
        roboticsSubjects.name = "Robotics"
        var subjects = [Subject]()
        
        //logic
        let algebraOne = Subject()
        algebraOne.name = "Sebastian Sanso"
        algebraOne.category = "For Math"
        algebraOne.descriptionOfPerson = "My name is Sebastian, and I tutor Algebra 1."
        subjects.append(algebraOne)
        roboticsSubjects.subjects = subjects
        
        let electronicSubjects = SubjectCategory()
        electronicSubjects.name = "Electronics"
        
        var science = [Subject]()
        
        let biology = Subject()
        biology.name = "Aidan Parsa"
        biology.category = "For Science"
        biology.descriptionOfPerson = "My name is Aidan, and I tutor Biology."
        science.append(biology)
        
        electronicSubjects.subjects = science
        return [roboticsSubjects, electronicSubjects]
    }
}

class Subject: NSObject {
    
    var id: NSNumber?
    var name: String?
    var descriptionOfPerson: String?
    var category: String?
}

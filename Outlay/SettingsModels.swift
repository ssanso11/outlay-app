//
//  SettingsModels.swift
//  Outlay
//
//  Created by Sebastian Sanso on 1/15/18.
//  Copyright © 2018 Sebastian Sanso. All rights reserved.
//

import UIKit


class SettingsCategory: NSObject {
    var name: String?
    var setting: [SetingsTableEdits]?
    
    static func sampleSettingsCategory() -> [SettingsCategory] {
        let logout = SubjectCategory()
        logout.name = "Logout"
        var settings = [SetingsTableEdits]()
        
        //logic
        let algebraOne = SetingsTableEdits()
        algebraOne.name = "Sebastian Sanso"
        settings.append(algebraOne)
        logout.setting = settings
        
        
        return [logout]
    }
}
class SetingsTableEdits: NSObject {
    
    var id: NSNumber?
    var name: String?
}

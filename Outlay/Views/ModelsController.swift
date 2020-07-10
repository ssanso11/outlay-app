//
//  ModelsController.swift
//  Outlay
//
//  Created by Sebastian Sanso on 1/13/19.
//  Copyright © 2019 Sebastian Sanso. All rights reserved.
//

import Foundation
import MapKit
import Mapbox

class Event: NSObject, MGLAnnotation {
    
    
    var coordinate: CLLocationCoordinate2D
    var title: String!
    var uniqueId: String!
    var subtitle: String?
    var eventImageUrl: String!
    
    
    
    init(title: String, eventCoordinate: CLLocationCoordinate2D, uniqueId: String, subtitle: String, eventImageUrl: String) {
        self.title = title
        self.coordinate = eventCoordinate
        self.uniqueId = uniqueId
        self.subtitle = subtitle
        self.eventImageUrl = eventImageUrl
        
    }
}

struct Messages {
    var message: String!
    var fromId: String!
    
    
    
    init(message: String, fromId: String) {
        self.message = message
        self.fromId = fromId
        
    }
}

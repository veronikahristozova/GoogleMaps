//
//  Marker.swift
//  GoogleMapsxAllterco
//
//  Created by Veronika Hristozova on 7/13/17.
//  Copyright © 2017 Veronika Hristozova. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

//Marker Model
class Marker: Object {
    dynamic var id: String = ""
    dynamic var locality: String = ""
    dynamic var lines: String = ""
    dynamic var thoroughfare: String = ""
    dynamic var country: String = ""
    dynamic var lat: Double = 0.0
    dynamic var long: Double = 0.0
    dynamic var imageData = NSData()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(id: String, locality: String, lines: String, thoroughfare: String, country: String, lat: Double, long: Double, imageData: NSData? = nil) {
        self.init()
        
        self.id           = id
        self.locality     = locality
        self.lines        = lines
        self.thoroughfare = thoroughfare
        self.country      = country
        self.lat          = lat
        self.long         = long
        
        if let imageData = imageData {
            self.imageData = imageData
        }
    }
}

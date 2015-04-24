//
//  Player.swift
//  The Pursuit
//
//  Created by Cenny Davidsson on 2015-04-23.
//  Copyright (c) 2015 Cenny Davidsson. All rights reserved.
//

import Foundation
import MapKit
import Parse

struct Player {
    var objectID: String
    var name: String
    var location: CLLocation
    var isReady: Bool
    var isPrey: Bool
    var isCreator: Bool
    
    init(player: PFObject) {
        self.objectID = player.objectId ?? ""
        self.name = player["name"] as? String ?? "No name"
        self.isReady = player["isReady"] as? Bool ?? false
        self.isPrey = player["ISPREY"] as? Bool ?? false
        self.isCreator = player["isCreator"] as? Bool ?? false
        
        let geoPointLocation = player["location"] as? PFGeoPoint
        self.location = CLLocation(latitude: geoPointLocation?.latitude ?? 0, longitude: geoPointLocation?.longitude ?? 0)
    }
}
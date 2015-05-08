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
    var parsePlayer: PFObject
    var objectID: String
    var name: String
    var location: CLLocationCoordinate2D
    var isReady: Bool
    var isPrey: Bool
    var isCreator: Bool
    
    init(player: PFObject) {
        objectID = player.objectId ?? ""
        parsePlayer = player
        name = player["name"] as? String ?? "No name"
        isReady = player["isReady"] as? Bool ?? false
        isPrey = player["isPrey"] as? Bool ?? false
        isCreator = player["isCreator"] as? Bool ?? false
        
        let geoPointLocation = player["location"] as? PFGeoPoint
        location = CLLocationCoordinate2D(latitude: geoPointLocation?.latitude ?? 0, longitude: geoPointLocation?.longitude ?? 0)
    }
}

extension Player: Printable {
    var description: String {
        return "Player: \(name), objectID: \(objectID), location: \(location.latitude)"
    }
}

extension Player: Equatable {}

func ==(lhs: Player, rhs: Player) -> Bool {
    return lhs.objectID == rhs.objectID
}
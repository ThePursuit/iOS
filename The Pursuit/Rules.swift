//
//  Rules.swift
//  The Pursuit
//
//  Created by Cenny Davidsson on 2015-04-23.
//  Copyright (c) 2015 Cenny Davidsson. All rights reserved.
//

import Foundation
import Parse

struct Rules {
    var areaRadius: Int
    var catchRadius: Int
    var durationTime: Int
    var maxPlayers: Int
    
    init(rules: PFObject) {
        areaRadius = rules["areaRadius"] as? Int ?? 0
        catchRadius = rules["catchRadius"] as? Int ?? 0
        durationTime = rules["durationTime"] as? Int ?? 0
        maxPlayers = rules["maxPlayers"] as? Int ?? 0
    }
}
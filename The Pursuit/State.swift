//
//  State.swift
//  The Pursuit
//
//  Created by Cenny Davidsson on 2015-04-23.
//  Copyright (c) 2015 Cenny Davidsson. All rights reserved.
//

import Foundation
import Parse

struct State {
    var isPlaying: Bool
    
    init(state: PFObject) {
        isPlaying = state["isPlaying"] as? Bool ?? false
    }
}
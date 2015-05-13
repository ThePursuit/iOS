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
    var preyCought: Bool
    var startTime: NSDate
    var endTime: NSDate
    
    
    init(state: PFObject) {
        isPlaying = state["isPlaying"] as? Bool ?? false
        preyCought = state["preyCaught"] as? Bool ?? false
        startTime = state["startTime"] as? NSDate ?? NSDate()
        endTime = state["endTime"] as? NSDate ?? NSDate()
    }
}
//
//  Game.swift
//  The Pursuit
//
//  Created by Cenny Davidsson on 2015-03-29.
//  Copyright (c) 2015 Cenny Davidsson. All rights reserved.
//

import Foundation
import Parse

struct Game {
    var parseGame: PFObject?
    var players: [Player]
    var ID: String
    var state: State?
    var rules: Rules?
    
    
    init(game: PFObject, players: [PFObject], rules: PFObject?, state: PFObject?) {
        self.ID = game["gameID"] as? String ?? "Missing ID"
        self.players = players.map { Player(player: $0) }
        
        if let state = state {
            self.state = State(state: state)
        }
        
        if let rules = rules {
            self.rules = Rules(rules: rules)
        }
    }
}

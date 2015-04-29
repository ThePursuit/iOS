//
//  GameStore.swift
//  The Pursuit
//
//  Created by Cenny Davidsson on 2015-04-23.
//  Copyright (c) 2015 Cenny Davidsson. All rights reserved.
//

import Foundation
import Parse
import MapKit

typealias Completion = () -> ()
typealias CompletionWithState = (State?, NSError?) -> ()
typealias CompletionWithPlayer = (Player?, NSError?) -> ()
typealias CompletionWithGame = (Game?, NSError?) -> ()
typealias CompletionWithPlayers = ([Player]?, NSError?) -> ()
typealias CompletionWithGameAndPlayer = (Game?, Player?, NSError?) -> ()
typealias CompletionWithStateRulesAndPlayers = (State?, Rules?, [Player]?, NSError?) -> ()

class GameStore {
    
    // MARK: Get values
    
    class func getStateRulesAndPlayersFromGame(gameObject: PFObject, completion: CompletionWithStateRulesAndPlayers) {
        let rulesQuery = gameObject.relationForKey("rules").query()
        let stateQuery = gameObject.relationForKey("state").query()
        let playersQuery = gameObject.relationForKey("players").query()
        
        rulesQuery?.findObjectsInBackgroundWithBlock { (rulesObjects, error) -> Void in
            stateQuery?.findObjectsInBackgroundWithBlock { (stateObjects, error) -> Void in
                playersQuery?.findObjectsInBackgroundWithBlock { (playersObjects, error) -> Void in
                    if let rulesObject = rulesObjects?.first as? PFObject,
                        let stateObject = stateObjects?.first as? PFObject,
                        let playersObject = playersObjects as? [PFObject] {
                            let players = playersObject.map { Player(player: $0) }
                            let state = State(state: stateObject)
                            let rules = Rules(rules: rulesObject)
                            completion(state, rules, players, nil)
                    }
                    if let error = error {
                        completion(nil, nil, nil, error)
                    }
                }
                if let error = error {
                    completion(nil, nil, nil, error)
                }
            }
            if let error = error {
                completion(nil, nil, nil, error)
            }
        }
    }
    
    class func getStateFromGame(game: Game, completion: CompletionWithState) {
        let stateRelationQuery = game.parseGame.relationForKey("state").query()
        println("\(stateRelationQuery)")
        println("\(game.parseGame)")
        stateRelationQuery?.findObjectsInBackgroundWithBlock() { (objects, error) -> Void in
            if let stateObject = objects?.first as? PFObject {
                let state = State(state: stateObject)
                completion(state, nil)
            }
            if let error = error {
                completion(nil, error)
            }
            
        }
    }
    
    class func reloadPlayersInGame(game:Game, completion: CompletionWithPlayers) {
        let playersRelation = game.parseGame.relationForKey("players")
        playersRelation.query()!.findObjectsInBackgroundWithBlock() { (objects, error) -> Void in
            if let objects = (objects as? [PFObject]) {
                let players = objects.map { Player(player:$0) }
                completion(players, nil)
            }
            if let error = error {
                completion(nil, error)
            }
        }
        
    }
    
    // MARK: Set Values
    
    class func changeNameForPlayer(var player: Player, name: String, completion: CompletionWithPlayer) {
        player.parsePlayer["name"] = name
        player.parsePlayer.saveInBackgroundWithBlock { (result, error) -> Void in
            if result {
                player.name = name
                completion(player, nil)
            } else if let error = error {
                completion(nil, error)
            }
        }
    }
    
    class func changeReadyStatusForPlayer(var player: Player, to ready:Bool, completion: CompletionWithPlayer) {
        player.parsePlayer["isReady"] = ready
        player.parsePlayer.saveInBackgroundWithBlock { (result, error) -> Void in
            if result {
                player.isReady = ready
                completion(player, nil)
            } else if let error = error {
                completion(nil, error)
            }
        }
    }
    
    class func setRulesForGame(var game: Game, radius: Int, maxPlayers: Int, catchRadius: Int, timeDuration: Int, completion: CompletionWithGame) {
        
        let parameters:[String : AnyObject] = [
            "gameID": game.ID,
            "radius": radius,
            "maxPlayers": maxPlayers,
            "catchRadius": catchRadius,
            "duration": timeDuration
        ]
        
        PFCloud.callFunctionInBackground("setRules", withParameters: parameters) { (object, error) -> Void in
            
            if let gameObject = object as? PFObject {
                GameStore.getStateRulesAndPlayersFromGame(gameObject) { (state, rules, players, error) -> () in
                    if let state = state, let rules = rules {
                        game.state = state
                        game.rules = rules
                        completion(game, nil)
                    }
                    if let error = error {
                        completion(nil, error)
                    }
                }
            }
        }
    }
    
    // MARK: Call methods
    
    class func startGame(game: Game, completion: CompletionWithGame) {
        let parameters = ["gameID": game.ID]
        PFCloud.callFunctionInBackground("startGame", withParameters: parameters) { (object, error) -> Void in
            if let gameObject = object as? PFObject {
                GameStore.getStateRulesAndPlayersFromGame(gameObject) { (state, rules, players, error) -> () in
                    if let state = state, let rules = rules, players = players {
                        let game = Game(game: gameObject, players: players, rules: rules, state: state)
                        completion(game, nil)
                    }
                    if let error = error {
                        completion(nil, error)
                    }
                }
            }
        }
    }
    
    class func createGame(completion: CompletionWithGameAndPlayer) {
        PFCloud.callFunctionInBackground("createGame", withParameters: [:]) { (object, error) -> Void in
            
            if let gameObject = object?["game"] as? PFObject, let playerObject = object?["player"] as? PFObject {
                var game = Game(game: gameObject, players: [playerObject], rules: nil, state: nil)
                game.parseGame = gameObject
                completion(game, Player(player: playerObject), nil)
            }
            if let error = error {
                completion(nil, nil, error)
            }
        }
    }
    
    class func createPlayer(completion: CompletionWithPlayer) {
        PFCloud.callFunctionInBackground("createPlayer", withParameters: [:]) { (object, error) -> Void in
            if let playerObject = object as? PFObject {
                let player = Player(player: playerObject)
                completion(player, error)
            }
            if let error = error {
                completion(nil, error)
            }
        }
    }
    
    class func joinGameWithPlayer(player: Player, withCode code: String, completion: CompletionWithGame) {
        let parameters = ["gameID": code, "playerObjID" : player.objectID]
        PFCloud.callFunctionInBackground("joinGame", withParameters: parameters) { (object, error) -> Void in
            if let gameObject = object as? PFObject {
                GameStore.getStateRulesAndPlayersFromGame(gameObject) { (state, rules, players, error) -> () in
                    if let state = state, let rules = rules, players = players {
                        let game = Game(game: gameObject, players: players, rules: rules, state: state)
                        completion(game, nil)
                    }
                    if let error = error {
                        completion(nil, error)
                    }
                }
            }
        }
    }
    
    class func updateGame(var game: Game, withPlayer player: Player, completion: CompletionWithGameAndPlayer) {
        let parameters = [
            "gameID": game.ID,
            "playerObjID": player.objectID,
            "longitude": "\(player.location.longitude)",
            "latitude": "\(player.location.latitude)"
        ]
        
        PFCloud.callFunctionInBackground("updateGame", withParameters: parameters) { (object, error) -> Void in
            
            if let gameObject = object as? PFObject {
                GameStore.getStateRulesAndPlayersFromGame(gameObject) { (state, rules, players, error) -> () in
                    if let state = state, let rules = rules, let players = players {
                        game.state = state
                        game.players = players
                        game.rules = rules
                        completion(game, player, nil)
                    }
                    if let error = error {
                        completion(nil, nil, error)
                    }
                }
            }
        }
    }
    
    class func tryCatch(game: Game, player: Player, completion: CompletionWithGame) {
        
    }
}
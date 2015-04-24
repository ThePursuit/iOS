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
typealias CompletionWithPlayer = (Player?, NSError?) -> ()
typealias CompletionWithPlayers = ([Player?], NSError?) -> ()
typealias CompletionWithGameAndPlayer = (Game?, Player?, NSError?) -> ()


class GameStore {
    
//    func changeName(name: String) {
//        if let player = player {
//            player["name"] = name
//            player.saveInBackgroundWithBlock(nil)
//        }
//    }
//    
//    func switchReadyStatus(completion: CompletionWithReturn) {
//        if let readyStatus = player!["isReady"] as? Bool {
//            player!["isReady"] = !readyStatus
//        } else {
//            player!["isReady"] = true
//        }
//        
//        player?.saveInBackgroundWithBlock() { (status, error) -> Void in
//            completion(self.player!["isReady"] as! Bool)
//        }
//        
//    }
//    
//    func nameForPlayerAtIndex(index: Int) -> String {
//        let playerToShow = players![index] as PFObject
//        if let name = playerToShow["name"] as? String {
//            return name
//        } else {
//            let id = playerToShow.objectId!
//            return "No name: \(id)"
//        }
//    }
//    
//    func isPlayerReadyAtIndex(index: Int) -> Bool {
//        let player = players![index] as PFObject
//        
//        if let isReady = player["isReady"] as? Bool {
//            return isReady
//        } else {
//            return false
//        }
//    }
    
    class func createGame(completion: CompletionWithGameAndPlayer) {
        PFCloud.callFunctionInBackground("createGame", withParameters: [:]) { (object, error) -> Void in
            
            if let gameObject = object?["game"] as? PFObject, let playerObject = object?["player"] as? PFObject {
                var game = Game(game: gameObject, players: [playerObject], rules: nil, state: nil)
                game.parseGame = gameObject
                completion(game, Player(player: playerObject), nil)
            } else if let error = error {
                completion(nil, nil, error)
            }
        }
    }
    
    class func createPlayer(completion: CompletionWithPlayer) {
        PFCloud.callFunctionInBackground("createPlayer", withParameters: [:]) { (object, error) -> Void in
            if let playerObject = object as? PFObject {
                let player = Player(player: playerObject)
                completion(player, error)
            } else if let error = error {
                completion(nil, error)
            }
        }
    }

    class func joinGameWithPlayer(player: Player, withCode code: String, completion: CompletionWithGameAndPlayer) {
        let parameters = ["gameID": code, "playerObjID" : player.objectID]
        PFCloud.callFunctionInBackground("joinGame", withParameters: parameters) { (object, error) -> Void in
            if let gameObject = object?["game"] as? PFObject {
                
                let rulesQuery = gameObject.relationForKey("rules").query()
                let stateQuery = gameObject.relationForKey("state").query()
                let playersQuery = gameObject.relationForKey("players").query()
                
                
                rulesQuery?.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                    if let rules = objects?.first as? Rules {
                        
                        stateQuery?.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                            playersQuery?.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                                
                            }
                        }
                    }
                    
                }
                
                
                
                
                
                //var game = Game(game: gameObject, players: , rules: nil, state: nil)
            }
//            self.game = object as? PFObject
//            completion()
        }
    }

    class func reloadPlayersInGame(game:Game, completion: CompletionWithPlayers) {
        if let playersRelation = game.parseGame?.relationForKey("players") {
            playersRelation.query()!.findObjectsInBackgroundWithBlock() { (objects, error) -> Void in
                if let objects = (objects as? [PFObject]) {
                    let players = objects.map { Player(player:$0) }
                }
            }
        }

    }
//
//    func updateGameWithCoordinate(coordinate: CLLocationCoordinate2D, completion: CompletionWithObjects) {
//        let parameters = ["gameID": game!["gameID"]!, "playerObjID": player!.objectId!, "longitude": coordinate.longitude, "latitude": coordinate.latitude]
//        PFCloud.callFunctionInBackground("updateGame", withParameters: parameters) { (object, error) -> Void in
//            
//            
//            self.game = object as? PFObject
//            let playersRelation = self.game?.relationForKey("players")
//            
//            playersRelation?.query()!.findObjectsInBackgroundWithBlock() { (objects, error) -> Void in
//                completion(objects as? [PFObject])
//            }
//        }
//    }
    
}
//
//  Game.swift
//  The Pursuit
//
//  Created by Cenny Davidsson on 2015-03-29.
//  Copyright (c) 2015 Cenny Davidsson. All rights reserved.
//

import Foundation
import Parse
import MapKit

typealias Completion = () -> ()
typealias CompletionWithObjects = ([PFObject]?) -> ()
typealias CompletionWithReturn = (Bool) -> ()

class Game {
    var game: PFObject?
    var player: PFObject?
    var prey: PFObject?
    var players: [PFObject]?
    
    var id: String {
        if let game = game {
            return game["gameID"] as? String ?? ""
        }
        return ""
    }
    
    init() {
        
    }
    
    func changeName(name: String) {
        if let player = player {
            player["name"] = name
            player.saveInBackgroundWithBlock(nil)
        }
    }
    
    func switchReadyStatus(completion: CompletionWithReturn) {
        if let readyStatus = player!["isReady"] as? Bool {
            player!["isReady"] = !readyStatus
        } else {
            player!["isReady"] = true
        }
        
        player?.saveInBackgroundWithBlock() { (status, error) -> Void in
            completion(self.player!["isReady"] as! Bool)
        }
        
    }
    
    func nameForPlayerAtIndex(index: Int) -> String {
        let playerToShow = players![index] as PFObject
        if let name = playerToShow["name"] as? String {
            return name
        } else {
            let id = playerToShow.objectId!
            return "No name: \(id)"
        }
    }
    
    func isPlayerReadyAtIndex(index: Int) -> Bool {
        let player = players![index] as PFObject
        
        if let isReady = player["isReady"] as? Bool {
            return isReady
        } else {
            return false
        }
    }
    
    func createGame(completion: CompletionWithReturn) {
        PFCloud.callFunctionInBackground("createGame", withParameters: [:]) { (object, error) -> Void in
            
            if error == nil {
                self.game = object?["game"] as! PFObject?
                self.player = object?["player"] as! PFObject?
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func getPlayerForJoin(completion: Completion) {
        PFCloud.callFunctionInBackground("createPlayer", withParameters: [:]) { (object, error) -> Void in
            self.player = object as? PFObject
            completion()
        }
    }
    
    func joinGameWithCode(code: String, completion: Completion) {
        let parameters = ["gameID": code, "playerObjID" : player!.objectId!]
        PFCloud.callFunctionInBackground("joinGame", withParameters: parameters) { (object, error) -> Void in
            self.game = object as? PFObject
            completion()
        }
    }
    
    func reloadPlayers(completion: CompletionWithObjects) {
        let playersRelation = game!.relationForKey("players")
        
        playersRelation.query()!.findObjectsInBackgroundWithBlock() { (objects, error) -> Void in
            self.players = (objects as? [PFObject])
            completion(objects as? [PFObject])
        }
    }
    
    func updateGameWithCoordinate(coordinate: CLLocationCoordinate2D, completion: CompletionWithObjects) {
        let parameters = ["gameID": game!["gameID"]!, "playerObjID": player!.objectId!, "longitude": coordinate.longitude, "latitude": coordinate.latitude]
        PFCloud.callFunctionInBackground("updateGame", withParameters: parameters) { (object, error) -> Void in
            
            
            self.game = object as? PFObject
            let playersRelation = self.game?.relationForKey("players")
            
            playersRelation?.query()!.findObjectsInBackgroundWithBlock() { (objects, error) -> Void in
                completion(objects as? [PFObject])
            }
        }
    }
    
}
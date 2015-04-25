//
//  JoinGameViewController.swift
//  The Pursuit
//
//  Created by Cenny Davidsson on 2015-03-25.
//  Copyright (c) 2015 Cenny Davidsson. All rights reserved.
//

import UIKit
import Parse

class JoinGameViewController: GameDataViewController {
    
    @IBOutlet weak var gameCodeTextView: UITextField!
    @IBOutlet weak var nameTextView: UITextField!
    
    @IBAction func joinGame(sender: AnyObject) {
        
        if let gameCode = gameCodeTextView.text, let name = nameTextView.text {
            
            GameStore.changeNameForPlayer(player!, name: name) { (player, error) -> () in
                if let player = player {
                    self.player = player
                    self.joinGameWithCode(gameCode)
                }
                if let error = error {
                    println("\(error.localizedDescription)")
                }
            }
        }
    }
    
    func joinGameWithCode(gameCode: String) {
        GameStore.joinGameWithPlayer(self.player!, withCode: gameCode) { (game, error) -> () in
            if let game = game {
                self.game = game
                self.performSegueWithIdentifier("GoToLobby", sender: nil)
            }
            if let error = error {
                println("\(error.localizedDescription)")
            }
        }
    }
}

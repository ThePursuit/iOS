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
        
        if let name = nameTextView.text {
            game?.changeName(name)
        }
        
        game?.joinGameWithCode(gameCodeTextView.text) {
            self.performSegueWithIdentifier("GoToLobby", sender: nil)
        }
    }
}

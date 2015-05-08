//
//  ViewController.swift
//  The Pursuit
//
//  Created by Cenny Davidsson on 2015-01-26.
//  Copyright (c) 2015 Cenny Davidsson. All rights reserved.
//

import UIKit
import Parse


class StartViewController: GameDataViewController {
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        locationManager.requestWhenInUseAuthorization()
    }
    
    @IBAction func createGame(sender: UIBarButtonItem) {
        
        startLoadingViewWithText("Creating game")
        GameStore.createGame { (game, player, error) -> () in
            if let game = game {
                self.game = game
                self.player = player
                self.performSegueWithIdentifier("SetGameRules", sender: nil)
            } else if let error = error {
                println("\(error.localizedDescription)")
            }
            self.stopLoadingView()
        }
    }
    
    @IBAction func joinGame(sender: AnyObject) {
        
        startLoadingViewWithText("Creating player")
        GameStore.createPlayer { (player, error) -> () in
            if let player = player {
                self.player = player
                self.performSegueWithIdentifier("JoinGame", sender: nil)                
            }
            self.stopLoadingView()
        }
    }
    
    @IBAction func unwindToStartViewController(segue: UIStoryboardSegue) {}
}


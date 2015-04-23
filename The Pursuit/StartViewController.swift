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
    
    @IBOutlet weak var createGameButton: UIButton!
    @IBOutlet weak var joinGameButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        game = Game()

        locationManager.requestWhenInUseAuthorization()
    }
    
    @IBAction func createGame(sender: UIBarButtonItem) {
        
        game?.createGame { suscess in
            if suscess {
                self.performSegueWithIdentifier("SetGameRules", sender: nil)
            }
        }
    }
    
    @IBAction func joinGame(sender: AnyObject) {
        game?.getPlayerForJoin {
            self.performSegueWithIdentifier("JoinGame", sender: nil)
        }
    }
    
    @IBAction func unwindToStartViewController(segue: UIStoryboardSegue) {}
}


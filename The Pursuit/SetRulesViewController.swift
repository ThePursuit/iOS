//
//  SetRulesViewController.swift
//  The Pursuit
//
//  Created by Cenny Davidsson on 2015-03-23.
//  Copyright (c) 2015 Cenny Davidsson. All rights reserved.
//

import UIKit
import Parse

class SetRulesViewController: GameDataViewController {
    
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var radiusSlider: UISlider!
    @IBOutlet weak var catchRadiusSlider: UISlider!
    
    @IBOutlet weak var catchLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var radiusLabel: UILabel!
    
    @IBOutlet weak var nameTextView: UITextField!
    @IBOutlet weak var createGameButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        [timeSlider, radiusSlider, catchRadiusSlider].map(sliderDidChangeValue)
    }
    
    @IBAction func setRulesAndGoToLobby(sender: AnyObject) {
        
        let radius = Int(round(radiusSlider.value))
        let catch = Int(round(catchRadiusSlider.value))
        let time = Int(round(timeSlider.value))
        
        startLoadingViewWithText("Setting up rules")
        GameStore.setRulesForGame(game!, radius: radius, catchRadius: catch, timeDuration: time) { (game, error) -> () in
            if let game = game {
                
                let name = self.nameTextView.text ?? "No name"
                
                GameStore.changeNameForPlayer(self.player!, name: name) { (player, error) -> () in
                    if let player = player {
                        self.player = player
                        self.game = game
                        self.performSegueWithIdentifier("GoToLobby", sender: nil)
                    }
                    if let error = error {
                        println("\(error.localizedDescription)")
                    }
                    self.stopLoadingView()
                }
            }
            if let error = error {
                println("\(error.localizedDescription)")
                self.stopLoadingView()
            }
        }
    }
    
    @IBAction func sliderDidChangeValue(sender: UISlider) {
        let value = Int(round(sender.value))
        switch sender {
        case timeSlider:
            timeLabel.text = "Time: \(value)min"
        case radiusSlider:
            radiusLabel.text = "Radius: \(value)m"
        case catchRadiusSlider:
            catchLabel.text = "catch: \(value)m"
        default:
            ""
        }
    }
}

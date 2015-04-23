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
    @IBOutlet weak var maxPlayerSlider: UISlider!
    
    @IBOutlet weak var maxPlayerLabel: UILabel!
    @IBOutlet weak var catchLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var radiusLabel: UILabel!
    
    @IBOutlet weak var nameTextView: UITextField!
    @IBOutlet weak var createGameButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        [timeSlider, radiusSlider, catchRadiusSlider, maxPlayerSlider].map(sliderDidChangeValue)
    }
    
    @IBAction func setRulesAndGoToLobby(sender: AnyObject) {
        
        let gameID = game!.id
        let radius = Int(round(radiusSlider.value))
        let players = Int(round(maxPlayerSlider.value))
        let catch = Int(round(catchRadiusSlider.value))
        let time = Int(round(timeSlider.value))
        
        let parameters:[String : AnyObject] = ["gameID":gameID, "radius":radius, "maxPlayers":players, "catchRadius":catch, "duration":time]
        
        PFCloud.callFunctionInBackground("setRules", withParameters: parameters) { (object, error) -> Void in
            println("\(object)")
            self.game?.game = object as? PFObject
            
            if let name = self.nameTextView.text {
                self.game?.changeName(name)
            }
            
            self.performSegueWithIdentifier("GoToLobby", sender: nil)
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
        case maxPlayerSlider:
            maxPlayerLabel.text = "Max Players: \(value)"
        default:
            ""
        }
    }
}

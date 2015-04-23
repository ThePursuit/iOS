//
//  LobbyViewController.swift
//  The Pursuit
//
//  Created by Cenny Davidsson on 2015-03-25.
//  Copyright (c) 2015 Cenny Davidsson. All rights reserved.
//

import UIKit
import Parse

class LobbyViewController: GameDataViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var gameCodeLabel: UILabel!
    
    var timer: NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        gameCodeLabel.text = "Game code: \(game!.id)"
        timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "checkForNewPlayers", userInfo: nil, repeats: true)
        timer?.fire()
        
        if let isCreator = game?.player?["isCreator"] as? Bool {
            if !isCreator {
               self.navigationItem.rightBarButtonItem = nil
            }
        }
    }
    
    func checkForNewPlayers() {
        game?.reloadPlayers { (players) -> () in
            self.tableView.reloadData()
        }
        
        let stateRelationQuery = game!.game!.relationForKey("state").query()
        stateRelationQuery?.findObjectsInBackgroundWithBlock() { (object, error) -> Void in
            let isPlaying = object!.first!["isPlaying"] as! Bool
            if isPlaying {
                self.timer?.invalidate()
                self.performSegueWithIdentifier("play", sender: nil)
            }
        }
    }
    
    @IBAction func play(sender: AnyObject) {
        let parameters = ["gameID": game!.id]
        PFCloud.callFunctionInBackground("startGame", withParameters: parameters) { (object, error) -> Void in
            
            self.game?.game = object as? PFObject
            self.performSegueWithIdentifier("play", sender: nil)
        }
    }
    
    @IBAction func readyStatusChanged(sender: UIButton) {
        sender.enabled = false
        game?.switchReadyStatus() { (status) -> () in
            if !status {
                sender.backgroundColor = UIColor.greenColor()
                sender.titleLabel?.text = "Ready"
            } else {
                sender.backgroundColor = UIColor.redColor()
                sender.titleLabel?.text = "Not ready"
            }
            sender.enabled = true
        }
    }
    
    // MARK: Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return game?.players != nil ? game!.players!.count : 0
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PlayerCell", forIndexPath: indexPath) as! UITableViewCell
        
        println("\(game!.nameForPlayerAtIndex(indexPath.row))")
        
        let isPreyString = (game!.players![indexPath.row]["isPrey"] as! Bool) ? " - Prey" : ""
        
        cell.textLabel?.text = game!.nameForPlayerAtIndex(indexPath.row) + isPreyString
        cell.accessoryType = game!.isPlayerReadyAtIndex(indexPath.row) ? .Checkmark : .None
        
        return cell
    }
    
    // MARK: Table view data delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let player = game!.players![indexPath.row]
        
        self.game?.players?.filter{ $0.objectId != player.objectId }.map { $0["isPrey"] = false }
        self.game?.players?.filter{ $0.objectId != player.objectId }.map { $0.saveInBackgroundWithBlock(nil)}
        
        player["isPrey"] = true
        player.saveInBackgroundWithBlock(nil)
    }
    
}

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
    
    // MARK: View
    
    override func viewDidLoad() {
        super.viewDidLoad()

        gameCodeLabel.text = "Game code: \(game!.ID)"
        timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "checkForNewPlayers", userInfo: nil, repeats: true)
        timer?.fire()
        
        if let isCreator = player?.isCreator where !isCreator {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    func checkForNewPlayers() {
        GameStore.reloadPlayersInGame(game!) { (players, error) -> () in
            
            if let players = players {
                self.game?.players = players
                self.tableView.reloadData()
            }
        }
        
        GameStore.getStateFromGame(game!) { (state, error) -> () in
            if let state = state {
                self.game?.state = state
                
                if state.isPlaying {
                    self.timer?.invalidate()
                    self.performSegueWithIdentifier("play", sender: nil)
                }
            }
        }
    }
    
    // MARK: User interaction
    
    @IBAction func play(sender: AnyObject) {
        
        GameStore.startGame(game!) { (game, error) -> () in
            if let game = game {
                self.game = game
                self.performSegueWithIdentifier("play", sender: nil)
            }
            if let error = error {
                println("\(error.localizedDescription)")
            }
        }
    }
    
    @IBAction func readyStatusChanged(sender: UIButton) {
        GameStore.changeReadyStatusForPlayer(player!, to: !player!.isReady) { (player, error) -> () in
            if let player = player {
                sender.backgroundColor = player.isReady ? .redColor() : .greenColor()
                sender.titleLabel?.text = player.isReady ? "Ready" : "Not ready"
            }
            if let error = error {
                println("\(error.localizedDescription)")
            }
        }
    }
    
    // MARK: Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return game?.players.count ?? 0
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PlayerCell", forIndexPath: indexPath) as! UITableViewCell
        
        let player = game!.players[indexPath.row]
        let isPreyString = (player.isPrey) ? " - Prey" : ""
        
        cell.textLabel?.text = player.name + isPreyString
        cell.accessoryType = player.isReady ? .Checkmark : .None
        
        return cell
    }
    
    // MARK: Table view data delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        let player = game!.players[indexPath.row]
//        
//        game?.players.filter{ $0.objectID != player.objectID }.map { $0.isPrey = false }
//        game?.players.filter{ $0.objectID != player.objectID }.map { $0.saveInBackgroundWithBlock(nil)}
//        
//        player.isPrey = true
//        player.saveInBackgroundWithBlock(nil)
    }
    
}

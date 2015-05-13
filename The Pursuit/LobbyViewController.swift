//
//  LobbyViewController.swift
//  The Pursuit
//
//  Created by Cenny Davidsson on 2015-03-25.
//  Copyright (c) 2015 Cenny Davidsson. All rights reserved.
//

import UIKit
import Parse
import AVFoundation

class LobbyViewController: GameDataViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var gameCodeLabel: UILabel!
    
    var timer: NSTimer?
    
    // MARK: View
    
    override func viewDidLoad() {
        super.viewDidLoad()

        AVAudioSession.sharedInstance().requestRecordPermission { (granted) -> Void in
            println("\(granted)")
        }
        
        gameCodeLabel.text = "Game code: \(game!.ID)"
        timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "checkForNewPlayers", userInfo: nil, repeats: true)
        timer?.fire()
        
        if let isCreator = player?.isCreator where !isCreator {
            self.navigationItem.rightBarButtonItem?.title = "Ready"
        }
    }
    
    func checkForNewPlayers() {
        GameStore.reloadPlayersInGame(game!) { (players, error) -> () in
            
            if let players = players {
                self.game?.players = players
                self.player = players.filter { $0 == self.player}.first!
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
    
    @IBAction func readyStatusChanged(sender: UIBarButtonItem) {
        if player!.isCreator {
            play()
        } else {
            changeReadyStatus(sender)
        }
    }
    
    func play() {
        GameStore.startGame(game!) { (game, error) -> () in
            if let game = game {
                self.game = game
            }
            if let error = error {
                println("\(error.localizedDescription)")
            }
        }
    }
    
    func changeReadyStatus(sender: UIBarButtonItem) {
        GameStore.changeReadyStatusForPlayer(player!, to: !player!.isReady) { (player, error) -> () in
            if let player = player {
                sender.title = player.isReady ? "Ready" : "Not ready"
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
        
        cell.textLabel?.text = player.name
        cell.accessoryType = player.isReady ? .Checkmark : .None
        
        return cell
    }
    
    // MARK: Navigation
    
    @IBAction func unwindToLobbyViewController(segue: UIStoryboardSegue) {
        
    }
    
}

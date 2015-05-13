//
//  GameViewController.swift
//  The Pursuit
//
//  Created by Cenny Davidsson on 2015-03-27.
//  Copyright (c) 2015 Cenny Davidsson. All rights reserved.
//

import UIKit
import MapKit
import Parse


class GameViewController: GameDataViewController, MKMapViewDelegate {
    
    // MARK: Properties
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var catchButton: UIButton!
    @IBOutlet weak var talkButton: UIButton!
    @IBOutlet weak var timerBar: UIProgressView!
    
    let talkHandler = TalkHandler()
    var updateGameTimer: NSTimer?
    var updateTimeTimer: NSTimer?
    let locationManager = CLLocationManager()
    var annotations: [MKPointAnnotation] = [] {
        didSet {
            self.map.removeAnnotations(oldValue)
            self.map.addAnnotations(annotations)
        }
    }
    
    // MARK: View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateTimeTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "updateProgressbar", userInfo: nil, repeats: true)
        
        // Setup map
        map.userTrackingMode = .Follow
    
        // other
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        UIApplication.sharedApplication().idleTimerDisabled = true
        updateGameTimer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "updateGame", userInfo: nil, repeats: true)
        updateGameTimer?.fire()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Setup UI
        talkButton.hidden = player!.isPrey
        catchButton.hidden = player!.isPrey
    }

    // MARK: Methods
    
    func updateProgressbar() {
        
        if let state = self.game!.state {
            let startTime = state.startTime
            let endTime = state.endTime
            let progress = Float(1.0 - endTime.timeIntervalSinceNow/endTime.timeIntervalSinceDate(startTime))
            
            timerBar.progress = progress
            
            if progress >= 1.0 {
                endGame()
            }
        }
    }
    
    func endGame() {
        
        self.updateGameTimer?.invalidate()
        self.updateTimeTimer?.invalidate()
        
        self.performSegueWithIdentifier("GameOver", sender: nil)
    }
    
    func updateGame() {
        
        player?.coordinate = locationManager.location.coordinate

        if let player = player, game = game {
            GameStore.updateGame(game, withPlayer: player) { (game, player, error) -> () in
                self.game = game
                self.player = player
                
                let newAnnotations = game!.players.filter { self.player == $0 && $0.isPrey }.map(self.makeAnnotations)
                self.annotations = newAnnotations
                
                let distance = self.game?.prey?.distanceToPlayer(player!)
                
                if let player = player where player.isPrey {
                    self.title = "You are the prey"
                } else {
                    self.title = "\(distance ?? 0)m"
                }
                
                if let isPlaying = game?.state?.isPlaying where !isPlaying {
                    self.endGame()
                }
                
            }
        }
        

    }
    
    func makeAnnotations(player:Player) -> MKPointAnnotation {
        let location = player.coordinate
        let annotation = MKPointAnnotation()
        annotation.title = player.name
        annotation.coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
            
        return annotation
    }
    
    // MARK: User interaction
    
    @IBAction func tryCatch(sender: AnyObject) {
        self.updateGameTimer?.invalidate()
        GameStore.tryCatch(game!, player: player!) { (game, error) -> () in
            
            if let game = game {
                self.endGame()
            }
            
            if let error = error {
                self.updateGameTimer?.fire()
            }
        }
        
    }
    
    @IBAction func startRecording(sender: UIButton) {
        talkHandler.record()
    }
    
    @IBAction func stopRecording(sender: UIButton) {
        talkHandler.stop()
    }
}

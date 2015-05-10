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
    
    let talkHandler = TalkHandler()
    var timer: NSTimer?
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
        
        // Setup map
        map.userTrackingMode = .Follow
        
        // Setup UI
        talkButton.hidden = player!.isPrey
        catchButton.hidden = player!.isPrey
    
        // other
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        UIApplication.sharedApplication().idleTimerDisabled = true
        timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "updateGame", userInfo: nil, repeats: true)
        timer?.fire()
    }

    // MARK: Methods
    
    func updateGame() {
        
        player?.coordinate = locationManager.location.coordinate
        GameStore.updateGame(game!, withPlayer: player!) { (game, player, error) -> () in
            self.game = game
            self.player = player
            
            let newAnnotations = self.game?.players.filter { self.player == $0 && !$0.isPrey }.map(self.makeAnnotations)
            if newAnnotations! != self.annotations {
                self.annotations = newAnnotations!
            } else {
                
            }

            let distance = self.game!.prey?.distanceToPlayer(player!)
                        
            if player!.isPrey {
                self.title = "You are the prey"
            } else {
                self.title = "\(distance)m"
            }
            
            if !game!.state!.isPlaying {
                self.timer?.invalidate()
                self.performSegueWithIdentifier("GameOver", sender: nil)
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
        GameStore.tryCatch(game!, player: player!) { (game, error) -> () in
            
            if let game = game {
                self.timer?.invalidate()
                self.performSegueWithIdentifier("GameOver", sender: nil)
            }
            
            if let error = error {
                
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

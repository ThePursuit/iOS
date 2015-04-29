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
    
    @IBOutlet weak var map: MKMapView!
    
    let locationManager = CLLocationManager()
    var annotations: [MKPointAnnotation] = [] {
        didSet {
            self.map.removeAnnotations(oldValue)
            self.map.addAnnotations(annotations)
        }
    }
    
    
    @IBAction func tryCatch(sender: AnyObject) {
//        let parameters = ["gameID": game!.game!["gameID"]!, "playerObjID": game!.player!.objectId!]
//        PFCloud.callFunctionInBackground("tryCatch", withParameters: parameters) { (object, error) -> Void in
//            self.game?.game = object as? PFObject
//            let isPlaying = self.game?.game!["isPlaying"] as! Bool
//            if !isPlaying {
//                self.navigationController?.popViewControllerAnimated(true)
//            }
//        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        map.showsUserLocation = true
        map.userTrackingMode = .Follow
        map.scrollEnabled = false
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation

        UIApplication.sharedApplication().idleTimerDisabled = true
        
        let timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "updateGame", userInfo: nil, repeats: true)
        timer.fire()
    }

    func updateGame() {
        
        player?.location = locationManager.location.coordinate
        GameStore.updateGame(game!, withPlayer: player!) { (game, player, error) -> () in
            self.game = game
            self.player = player
            
            let annotations = self.game?.players.filter { self.player == $0 && !$0.isPrey }.map(self.makeAnnotations)
            self.annotations = annotations!
            
            let prey = self.game!.players.filter { $0.isPrey }.first!
            let preyLocation = CLLocation(latitude: prey.location.latitude, longitude: prey.location.longitude)
            let playerLocation = CLLocation(latitude: player!.location.latitude, longitude: player!.location.longitude)
            
            let distance = preyLocation.distanceFromLocation(playerLocation)
            self.title = "\(floor(distance))m"
            
            println("Players count:\(game?.players.count)")
            println("Prey:\(prey)")
            println("Annotations count \(annotations?.count)")
            
        }
    }
    
    func makeAnnotations(player:Player) -> MKPointAnnotation {
        let location = player.location
        let annotation = MKPointAnnotation()
        annotation.title = player.name
        annotation.coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
            
        return annotation
    }
}

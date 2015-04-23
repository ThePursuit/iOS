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
        let parameters = ["gameID": game!.game!["gameID"]!, "playerObjID": game!.player!.objectId!]
        PFCloud.callFunctionInBackground("tryCatch", withParameters: parameters) { (object, error) -> Void in
            self.game?.game = object as? PFObject
            let isPlaying = self.game?.game!["isPlaying"] as! Bool
            if !isPlaying {
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        map.showsUserLocation = true
        map.userTrackingMode = .Follow
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation

        UIApplication.sharedApplication().idleTimerDisabled = true
        
        let timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "updateGame", userInfo: nil, repeats: true)
        timer.fire()
    }

    func updateGame() {
        
        let coordinate = locationManager.location.coordinate
        game?.updateGameWithCoordinate(coordinate) { (players) -> () in
            
            self.annotations = players!.filter(self.isNotThisPlayer).filter(self.isNotPrey).map(self.makeAnnotations)
            
            let prey = players!.filter(self.isPrey).first
            let locationOfPrey = prey?["location"] as? PFGeoPoint

            
            if let locationOfPrey = locationOfPrey {
            
                let locationOfPreyCL = CLLocation(latitude: locationOfPrey.latitude, longitude: locationOfPrey.longitude)
            	let locationOfPlayerCL = self.locationManager.location
            
                let distance = locationOfPlayerCL.distanceFromLocation(locationOfPreyCL)
                self.title = "\(floor(distance))m"
            }
        }
    }
    
    func makeAnnotations(player:PFObject) -> MKPointAnnotation {
        let location = player["location"] as! PFGeoPoint
        let annotation = MKPointAnnotation()
        annotation.title = player["name"] as? String ?? player.objectId
            
        annotation.title = player["name"] as? String ?? "No name";
        annotation.coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
            
        return annotation
    }
    
    func isNotThisPlayer(player:PFObject) -> Bool {
        return player.objectId! != self.game?.player!.objectId!
    }
    
    func isPrey(player:PFObject) -> Bool {
        return player["isPrey"] as! Bool
    }
    
    func isNotPrey(player:PFObject) -> Bool {
        return !(player["isPrey"] as! Bool)
    }
}

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
import AVFoundation

class GameViewController: GameDataViewController, MKMapViewDelegate, AVAudioRecorderDelegate {
    
    // MARK: Properties
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var catchButton: UIButton!
    @IBOutlet weak var talkButton: UIButton!
    
    var timer: NSTimer?
    let locationManager = CLLocationManager()
    var annotations: [MKPointAnnotation] = [] {
        didSet {
            self.map.removeAnnotations(oldValue)
            self.map.addAnnotations(annotations)
        }
    }
    
    var audioPlayer: AVAudioPlayer?
    lazy var recorder: AVAudioRecorder = {
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docsDir = dirPaths[0] as! String
        let soundFilePath =
        docsDir.stringByAppendingPathComponent("voice.m4a")
        let soundFileURL = NSURL(fileURLWithPath: soundFilePath)
        
        let audioSession = AVAudioSession.sharedInstance()
        audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
        
        let recordSetting: [NSObject : AnyObject] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 2
        ]
        
        let recorder = AVAudioRecorder(URL: soundFileURL, settings: recordSetting, error: nil)
        recorder.delegate = self
        recorder.meteringEnabled = true
        recorder.prepareToRecord()
        
        return recorder
    }()
    
    // MARK: View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup map

        map.userTrackingMode = .Follow
        
        // Setup UI
        
//        talkButton.hidden = player!.isPrey
        catchButton.hidden = player!.isPrey
    
        // other
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        UIApplication.sharedApplication().idleTimerDisabled = true
        timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "updateGame", userInfo: nil, repeats: true)
        timer?.fire()
    }

    // MARK: Methods
    
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
                        
            if player!.isPrey {
                self.title = "You are the prey"
            } else {
                self.title = "\(floor(distance))m"
            }
            
            if !game!.state!.isPlaying {
                self.timer?.invalidate()
                self.performSegueWithIdentifier("GameOver", sender: nil)
            }
            
        }
    }
    
    func makeAnnotations(player:Player) -> MKPointAnnotation {
        let location = player.location
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
        let audioSession = AVAudioSession.sharedInstance()
        audioSession.setActive(true, error: nil)
        recorder.record()
    }
    
    @IBAction func stopRecording(sender: UIButton) {
        recorder.stop()
        
        let audioSession = AVAudioSession.sharedInstance()
        audioSession.setActive(false, error: nil)
    }
    
    // MARK: AVAudioRecorderDelegate
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        audioPlayer = AVAudioPlayer(contentsOfURL: recorder.url, error: nil)
        
        let soundData = NSData(contentsOfURL: recorder.url)!
        println("\(soundData.si)")
        game?.parseGame["sound"] = soundData
        game?.parseGame.saveInBackgroundWithBlock { (suc, error) -> Void in
            
        }
        audioPlayer?.play()
    }
}

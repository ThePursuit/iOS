//
//  TalkHandler.swift
//  The Pursuit
//
//  Created by Cenny Davidsson on 2015-05-08.
//  Copyright (c) 2015 Cenny Davidsson. All rights reserved.
//

import Foundation
import AVFoundation

class TalkHandler: NSObject, AVAudioRecorderDelegate {
    
    var game: Game?
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
    
    func record() {
        let audioSession = AVAudioSession.sharedInstance()
        audioSession.setActive(true, error: nil)
        recorder.record()
    }
    
    func stop() {
        recorder.stop()
        
        let audioSession = AVAudioSession.sharedInstance()
        audioSession.setActive(false, error: nil)
    }
    
    // MARK: AVAudioRecorderDelegate
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        audioPlayer = AVAudioPlayer(contentsOfURL: recorder.url, error: nil)
        
        let soundData = NSData(contentsOfURL: recorder.url)!
        
        game?.parseGame["sound"] = soundData
        game?.parseGame.saveInBackgroundWithBlock { (suc, error) -> Void in
        
        }
        audioPlayer?.play()
    }
}
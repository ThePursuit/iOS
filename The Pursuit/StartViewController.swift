//
//  ViewController.swift
//  The Pursuit
//
//  Created by Cenny Davidsson on 2015-01-26.
//  Copyright (c) 2015 Cenny Davidsson. All rights reserved.
//

import UIKit
import Parse

enum ParseCloudFunction: String {
    case CreateGame = "createGame"
}

extension PFCloud {
    class func callFunctionInBackground(function: ParseCloudFunction, withParameters: Dictionary <String, String>) {
        
    }
}

class StartViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func createGame(sender: AnyObject) {
        PFCloud.callFunctionInBackground("createGame", withParameters: [:]) {
            
        }
        PFCloud.callFunctionInBackground(.CreateGame, withParameters: [:])
    }
    

    @IBAction func unwindToStartViewController(segue: UIStoryboardSegue) {}
    
}


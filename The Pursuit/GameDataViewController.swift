//
//  GameDataViewController.swift
//  The Pursuit
//
//  Created by Cenny Davidsson on 2015-04-08.
//  Copyright (c) 2015 Cenny Davidsson. All rights reserved.
//

import UIKit

protocol Enabeld {
    var enabled: Bool { get set }
}

extension UIButton: Enabeld {}
extension UIBarButtonItem: Enabeld {}

class GameDataViewController: UIViewController {
    var game: Game?
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if let destination = segue.destinationViewController as? GameDataViewController {
            destination.game = game
        }
    }
}

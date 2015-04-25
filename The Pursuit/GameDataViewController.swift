//
//  GameDataViewController.swift
//  The Pursuit
//
//  Created by Cenny Davidsson on 2015-04-08.
//  Copyright (c) 2015 Cenny Davidsson. All rights reserved.
//

import UIKit

class GameDataViewController: UIViewController {
    var game: Game?
    var player: Player?
    var isLoading = false
    
    // MARK: Loading view
    
    func startLoadingViewWithText(text: String?) {
        if !isLoading {
            isLoading = true
            let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
            if let text = text {
                hud.labelText = text
            }
        } else {
            println("Loading view already showing")
        }
    }
    
    func stopLoadingView() {
        if isLoading {
            isLoading = false
            MBProgressHUD.hideHUDForView(self.view, animated: true)
        } else {
            println("No loading view to stop")
        }
    }
    
    func showMessage(message: String) {
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.labelText = message
        hud.mode = .Text
        hud.hide(true, afterDelay: 2)
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if let destination = segue.destinationViewController as? GameDataViewController {
            destination.player = player
            destination.game = game
        }
    }
}

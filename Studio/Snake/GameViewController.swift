//
//  GameViewController.swift
//  Snake
//
//  Created by Alexander Pagliaro on 11/13/14.
//  Copyright (c) 2014 Limit Point LLC. All rights reserved.
//

import UIKit
import SpriteKit

struct GameViewControllerNotifications {
    static let shouldPause = "GameShouldPauseNotification"
    static let shouldResume = "GameShouldResumeNotification"
    static let didStart = "GameDidStartNotification"
    static let didEnd = "GameDidEndNotification"
}

extension SKNode {
    class func unarchiveFromFile(file : NSString) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file as String, ofType: "sks") {
            let sceneData = try! NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe)
            let archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController {
    
    @IBOutlet weak var skView : SKView!
    
    func gameDidStart(sender : AnyObject) {
        
        
    }
    
    func gameDidEnd(sender : AnyObject) {
        
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameViewController.gameDidStart(_:)), name: GameViewControllerNotifications.didStart, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameViewController.gameDidEnd(_:)), name: GameViewControllerNotifications.didEnd, object: nil)
        
        
    }
    
    deinit {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
    }
    
    
    override func viewDidLayoutSubviews() {
        
        if (skView.scene == nil) {
        
            if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
                // Configure the view.
                //self.skView.showsFPS = true
                //self.skView.showsNodeCount = true
                
                /* Sprite Kit applies additional optimizations to improve rendering performance */
                self.skView.ignoresSiblingOrder = true
                
                /* Set the scale mode to scale to fit the window */
                scene.size = self.skView.bounds.size
                scene.scaleMode = SKSceneScaleMode.Fill
                
                self.skView.presentScene(scene)
                
            }
            
        }
        
    }

    override func shouldAutorotate() -> Bool {
        return false
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
}

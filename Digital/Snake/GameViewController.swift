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
    class func unarchiveFromFile(_ file : NSString) -> SKNode? {
        if let path = Bundle.main.path(forResource: file as String, ofType: "sks") {
            let sceneData = try! Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let archiver = NSKeyedUnarchiver(forReadingWith: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as! GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController {
    
    @IBOutlet weak var skView : SKView!
    
    func gameDidStart(_ sender : AnyObject) {
        
        
    }
    
    func gameDidEnd(_ sender : AnyObject) {
        
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.gameDidStart(_:)), name: NSNotification.Name(rawValue: GameViewControllerNotifications.didStart), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.gameDidEnd(_:)), name: NSNotification.Name(rawValue: GameViewControllerNotifications.didEnd), object: nil)
        
        
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
        
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
                scene.scaleMode = SKSceneScaleMode.fill
                
                self.skView.presentScene(scene)
                
            }
            
        }
        
    }

    override var shouldAutorotate : Bool {
        return false
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    
}

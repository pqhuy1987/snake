//
//  GameCenterManager.swift
//  Snake
//
//  Created by Alexander Pagliaro on 12/23/14.
//  Copyright (c) 2014 Limit Point LLC. All rights reserved.
//

import Foundation
import GameKit

class GameScoreManager {
    
    class func highscore() -> Int {
        
        let score : Int = NSUserDefaults.standardUserDefaults().integerForKey("hiscore")
        
        return score
        
    }
    
    class func reportScore(score : Int) -> Bool {
        
        let oldHiScore = NSUserDefaults.standardUserDefaults().integerForKey("hiscore")
        
        if (score > oldHiScore) {
            
            NSUserDefaults.standardUserDefaults().setInteger(score, forKey: "hiscore")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            return true
            
        }
        
        return false
        
    }
    
}
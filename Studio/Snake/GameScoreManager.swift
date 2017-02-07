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
        
        let score : Int = UserDefaults.standard.integer(forKey: "hiscore")
        
        return score
        
    }
    
    class func reportScore(_ score : Int) -> Bool {
        
        let oldHiScore = UserDefaults.standard.integer(forKey: "hiscore")
        
        if (score > oldHiScore) {
            
            UserDefaults.standard.set(score, forKey: "hiscore")
            UserDefaults.standard.synchronize()
            
            return true
            
        }
        
        return false
        
    }
    
}

//
//  GameMusicPlayer.swift
//  Snake
//
//  Created by Alexander Pagliaro on 12/20/14.
//  Copyright (c) 2014 Limit Point LLC. All rights reserved.
//

import Foundation
import AVFoundation

class GameMusicPlayer : NSObject, AVAudioPlayerDelegate {
    
    var titleMusicPlayer = try! AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "Snake Title", withExtension: "m4a")!, fileTypeHint: nil)
    var gameOverPlayer = try! AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "game over 1", withExtension: "m4a")!, fileTypeHint: nil)
    var level1Player =  try! AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "Snake 1", withExtension: "m4a")!, fileTypeHint: nil)
    var level2Player : AVAudioPlayer?
    var soundFXPlayer = try! AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "Coin", withExtension: "caf")!, fileTypeHint: nil)
    var startFXPlayer = try! AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "Start", withExtension: "caf")!, fileTypeHint: nil)
    var endFXPlayer = try! AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "End", withExtension: "caf")!, fileTypeHint: nil)
    
    func playTitleMusic() {
        
        gameOverPlayer.stop()
        gameOverPlayer.prepareToPlay()
        level1Player.prepareToPlay()
        level2Player = nil
        
        if AVAudioSession.sharedInstance().secondaryAudioShouldBeSilencedHint == false {
            
            print("starting music player")
            titleMusicPlayer.currentTime = 0
            titleMusicPlayer.play()
            
        }
        
    }
    
    func playNextSong() {
        
        titleMusicPlayer.stop()
        
        if (AVAudioSession.sharedInstance().secondaryAudioShouldBeSilencedHint == false) {
            
            if (level2Player != nil) {
                print("we have a player")
            }
            
            if level2Player != nil {
                
                level1Player.stop()
                
                level2Player?.delegate = self
                level2Player?.currentTime = 0
                level2Player?.play()
                
            } else {
                
                level1Player.delegate = self
                level1Player.currentTime = 0
                level1Player.play()
                
            }
            
        }
        
    }
    
    func playGameOverMusic() {
        
        titleMusicPlayer.prepareToPlay()
        level1Player.stop()
        level2Player?.stop()
        
        if AVAudioSession.sharedInstance().secondaryAudioShouldBeSilencedHint == false {
            
            gameOverPlayer.currentTime = 0
            self.gameOverPlayer.play()
            
        }
        
    }
    
    func playFX() {
        soundFXPlayer.stop()
        soundFXPlayer.currentTime = 0
        soundFXPlayer.play()
    }
    
    func playStartFX() {
        startFXPlayer.play()
    }
    
    func playEndFX() {
        endFXPlayer.play()
    }
    
    func pause() {
        
        level1Player.pause()
        level2Player?.pause()
        
    }
    
    func stopSecondaryAudio() {
        
        if (AVAudioSession.sharedInstance().secondaryAudioShouldBeSilencedHint) {
        
            self.titleMusicPlayer.stop()
            self.gameOverPlayer.stop()
            level1Player.stop()
            level2Player?.stop()
            
        }
        
    }
    
    func resume() {
        if ((level2Player?.play()) != nil) {
            level1Player.stop()
        } else {
            level1Player.play()
        }
    }
    
    func prepareLevel2() {
        
        if level2Player == nil {
            
            print("prepare level 2")
        
            level2Player = try! AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "Tetrahedron Demo 8", withExtension: "m4a")!, fileTypeHint: nil)
            level2Player?.prepareToPlay()
            
        }
        
    }
    
    override init() {
        
        super.init()
        
        _ = try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient, with: AVAudioSessionCategoryOptions())
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameMusicPlayer.stopSecondaryAudio), name: NSNotification.Name.AVAudioSessionSilenceSecondaryAudioHint, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GameMusicPlayer.stopSecondaryAudio), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
        titleMusicPlayer.numberOfLoops = -1
        gameOverPlayer.numberOfLoops = -1
        
        soundFXPlayer.prepareToPlay()
        startFXPlayer.prepareToPlay()
        endFXPlayer.prepareToPlay()
        
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
        
        
    }
    
    //MARK: - AVAudioPlayerDelegate -
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        // Only use player2 once at a time
        if (player == level2Player) {
            level2Player = nil
        }
        
        playNextSong()
        
    }
    
    
}

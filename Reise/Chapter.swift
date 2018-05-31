//
//  GameChapter.swift
//  Reise
//
//  Created by Nils Schwenkel on 28.05.18.
//  Copyright © 2018 Nils Schwenkel. All rights reserved.
//

import Foundation
import SpriteKit
import AVFoundation

class Chapter {
    let title: String
    private var scenes: [Scene] = Array()
    private var currentScene: Scene?
    private var nextScene: Scene?
    private var currentSceneIndex: Int = 0
    
    init(title: String) {
        self.title = title
    }
    
    public func add(scene: Scene)
    {
        self.scenes.append(scene)
    }
    
    public func load(on: SKScene, withSize: CGSize, audioEngine: AVAudioEngine, output: AVAudioMixerNode) {
        let size = withSize
        
        if (!scenes.isEmpty)
        {
            currentSceneIndex = scenes.startIndex
            currentScene = scenes[currentSceneIndex]
            
            currentScene?.load(on: on, withSize: withSize, atPosition: CGPoint(x : 0, y : size.height), audioEngine: audioEngine, output: output)
        }
        
        if(scenes.count > 1)
        {
            nextScene = scenes[1];
            
            let sceneStartingPosition = CGPoint(x: (currentScene?.getWidth()) ?? 0,
                                                      y: size.height)
            
            nextScene?.load(on: on, withSize: withSize, atPosition: sceneStartingPosition)
        }
    }
    
    public func update(on: SKScene, move: Bool, timeSinceLastFrame: TimeInterval, audioEngine: AVAudioEngine, output: AVAudioMixerNode) {
        
        // current scene could move out of the left side of the screen. lets update it first
        currentScene?.update(on: on, move: move, timeSinceLastFrame: timeSinceLastFrame, audioEngine: audioEngine, output: output)
        nextScene?.update(on: on, move: currentScene?.isMoving ?? false, timeSinceLastFrame: timeSinceLastFrame, audioEngine: audioEngine, output: output)

        /*
        if(!(currentScene?.isVisible() ?? false))
        {
            currentScene = nextScene
        }*/
        
    }
}

//
//  GameLayer.swift
//  Reise
//
//  Created by Nils Schwenkel on 28.05.18.
//  Copyright © 2018 Nils Schwenkel. All rights reserved.
//

import Foundation
import AVFoundation
import SpriteKit

class Layer {
    
    var isVisible: Bool = false
    private let texture: SKTexture
    private var sprite: SKSpriteNode?
    private let speed: Float
    private var sounds: [Sound] = Array()
    
    init(texture: SKTexture, speed: Float) {
        self.texture = texture
        self.speed = speed
    }
    
    func add(sound: Sound) {
        self.sounds.append(sound)
    }
    
    public func load(on: SKScene, withSize: CGSize, atPosition: CGPoint) {
        // Prepare the sky sprites
        sprite = SKSpriteNode(texture: texture)
        sprite?.anchorPoint = CGPoint( x: 0, y: 1)
        sprite?.position = atPosition
        sprite?.aspectFillToSize(fillSize: withSize) // Do this after you set texture
        
        if(nil != sprite) {
            // Add the sprites to the scene
            on.addChild(sprite!);
        }
        
        isVisible = true
    }
    
    func load(on: SKScene, withSize: CGSize, atPosition: CGPoint, audioEngine: AVAudioEngine, output: AVAudioMixerNode) {
        load(on: on, withSize: withSize, atPosition: atPosition)
        playSound(audioEngine: audioEngine, output: output)
    }
    
    public func update(on: SKScene, timeSinceLastFrame: TimeInterval, audioEngine: AVAudioEngine, output: AVAudioMixerNode) {
        
        if(isVisible) {
            move(on: on, timeSinceLastFrame: timeSinceLastFrame)
            playSound(audioEngine: audioEngine, output: output)
        } else {
            stopSound(audioEngine: audioEngine)
        }
    }
    
    private func playSound(audioEngine: AVAudioEngine, output: AVAudioMixerNode) {
        
        let position = (sprite?.position.x ?? 0  /* TODO - xOffset */ ) * -1
        
        for sound in sounds {
            if(position >= sound.startPosition && position <= sound.endPosition)
            {
                if(!sound.isPlaying)
                {
                    sound.play(audioEngine: audioEngine, output: output)
                }
            }
            else if(sound.isPlaying)
            {
                sound.stop()
            }
        }
    }
    
    private func stopSound(audioEngine: AVAudioEngine) {
        for sound in sounds {
            if(sound.isPlaying)
            {
                sound.stop()
            }
        }
    }
    
    private func move(on: SKScene, timeSinceLastFrame: TimeInterval) {
        var newPosition: CGPoint
        
        // Shift the sprite leftward based on the speed
        newPosition = sprite?.position ?? CGPoint(x: 0, y: 0)
        newPosition.x -= CGFloat(speed * Float(timeSinceLastFrame))
        sprite?.position = newPosition
        
        if (sprite?.frame.maxX) ?? 0 < on.frame.minX {
            isVisible = false
        }
    }
    
    public func getWidth() -> CGFloat {
        return sprite?.size.width ?? 0;
    }
}

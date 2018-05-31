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

class AutoScrollingLayer : Layer {
    var nextSprite: SKSpriteNode?
    
    override func update(on: SKScene, moveLayer: Bool, timeSinceLastFrame: TimeInterval, audioEngine: AVAudioEngine, output: AVAudioMixerNode) {
        super.update(on: on, moveLayer: true, timeSinceLastFrame: abs(timeSinceLastFrame), audioEngine: audioEngine, output: output)
    }
    
    override func load(on: SKScene, withSize: CGSize, atPosition: CGPoint) {

        super.load(on: on, withSize: withSize, atPosition: atPosition)
        
        var firstActions: [SKAction] = Array()
        
        nextSprite = sprite?.copy() as? SKSpriteNode
        nextSprite?.position = CGPoint(x: sprite?.size.width ?? 0, y: nextSprite?.position.y ?? 0)
        
        if(nil != nextSprite) {
            on.addChild(nextSprite!)
        }
        
        // TODO create a autoScrollLayer in json bcause speed != duration!
        firstActions.append(SKAction.move(to: CGPoint(x: atPosition.x - (sprite?.size.width)!, y: atPosition.y), duration: TimeInterval(speed)))
        firstActions.append(SKAction.move(to: CGPoint(x: atPosition.x + (sprite?.size.width)!, y: atPosition.y), duration: TimeInterval(0)))
        firstActions.append(SKAction.move(to: CGPoint(x: atPosition.x, y: atPosition.y), duration: TimeInterval(speed)))

        // TODO move one time scrall layer and use the following action to remove Layer when done: firstActions.append(SKAction.removeFromParent())
        
        sprite?.run(SKAction.repeatForever(SKAction.sequence(firstActions)))
        
        var secondActions: [SKAction] = Array()
        
        secondActions.append(SKAction.move(to: CGPoint(x: atPosition.x, y: atPosition.y), duration: TimeInterval(speed)))
        secondActions.append(SKAction.move(to: CGPoint(x: atPosition.x - (sprite?.size.width)!, y: atPosition.y), duration: TimeInterval(speed)))
        secondActions.append(SKAction.move(to: CGPoint(x: atPosition.x + (sprite?.size.width)!, y: atPosition.y), duration: TimeInterval(0)))
        nextSprite?.run(SKAction.repeatForever(SKAction.sequence(secondActions)))
        
    }
    
    override func move(on: SKScene, timeSinceLastFrame: TimeInterval) {
        // movement is done via SKActions
        // TODO other direction
    }
}

class Layer {
    
    var isVisible: Bool = false
    let texture: SKTexture
    var sprite: SKSpriteNode?
    private var nextSprite: SKSpriteNode? // TODO create AutoScrollingLayer
    let speed: Float
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
    
    public func update(on: SKScene, moveLayer: Bool, timeSinceLastFrame: TimeInterval, audioEngine: AVAudioEngine, output: AVAudioMixerNode) {
        
        if(isVisible) {
            if(moveLayer) {
               move(on: on, timeSinceLastFrame: timeSinceLastFrame)
            }
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
    
    func move(on: SKScene, timeSinceLastFrame: TimeInterval) {
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
    
    public func getHight() -> CGFloat {
        return sprite?.size.height ?? 0
    }
}

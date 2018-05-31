//
//  GameScenery.swift
//  Reise
//
//  Created by Nils Schwenkel on 27.05.18.
//  Copyright © 2018 Nils Schwenkel. All rights reserved.
//

import Foundation
import SpriteKit
import AVFoundation

class FirstScene : Scene {
    
    override func add(layer: Layer) {
        layer.limitMinXPosition = true
        super.add(layer: layer)
    }
}

class LastScene : Scene {
    override func add(layer: Layer) {
        layer.limitMaxXPosition = true
        super.add(layer: layer)
    }
}

class LonlyScene : Scene {
    override func add(layer: Layer) {
        layer.limitMinXPosition = true
        layer.limitMaxXPosition = true
        super.add(layer: layer)
    }
}

class Scene {
    var isMoving: Bool = false
    private var layer: [Layer] = Array()
    
    func add(layer: Layer) {
        self.layer.append(layer)
    }
    
    func add(layer: [Layer]) {
        for l in layer {
            add(layer: l)
        }
    }
    
    func load(on: SKScene, withSize: CGSize, atPosition: CGPoint) {
        for layer in self.layer {
            layer.load(on: on, withSize: withSize, atPosition: atPosition)
        }
    }
    
    func load(on: SKScene, withSize: CGSize, atPosition: CGPoint, audioEngine: AVAudioEngine, output: AVAudioMixerNode) {
        for layer in self.layer {
            layer.load(on: on, withSize: withSize, atPosition: atPosition, audioEngine: audioEngine, output: output)
        }
    }
    
    public func update(on: SKScene, move: Bool, timeSinceLastFrame: TimeInterval, audioEngine: AVAudioEngine, output: AVAudioMixerNode) {
        if !self.layer.isEmpty {
            let frontLayer = self.layer.last!
            frontLayer.update(on: on, moveLayer: move, timeSinceLastFrame: timeSinceLastFrame, audioEngine: audioEngine, output: output)
        
            isMoving = frontLayer.isMoving && move
            
            for i in self.layer.indices.dropLast() {
                self.layer[i].update(on: on, moveLayer: isMoving, timeSinceLastFrame: timeSinceLastFrame, audioEngine: audioEngine, output: output)
            }
        }
    }
    
    func isVisible() -> Bool {
        for layer in self.layer {
            if(layer.isVisible) {
                return true
            }
        }
        
        return false
    }
    
    public func getWidth() -> CGFloat {
        var maxLayerWidth: CGFloat = 0
        
        for layer in self.layer {
            if(layer.getWidth() > maxLayerWidth) {
                maxLayerWidth = layer.getWidth();
            }
        }
        
        return maxLayerWidth;
    }
}


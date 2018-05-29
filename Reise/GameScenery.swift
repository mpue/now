//
//  GameScenery.swift
//  Reise
//
//  Created by Nils Schwenkel on 27.05.18.
//  Copyright © 2018 Nils Schwenkel. All rights reserved.
//

import Foundation
import SpriteKit

class GameScenery {
    var layerImageNames : [String]
    var sound: [ScenerySound]
    var layer: [SKSpriteNode?] = Array()
    
    init(layer: [String], sound: [ScenerySound]) {
        self.layerImageNames = layer
        self.sound = sound
    }
    
    public func getMaxLayerWith() -> CGFloat
    {
        var maxLayerWidth: CGFloat = 0
        
        if(!layer.isEmpty)
        {
            for layer in self.layer {
                if((layer?.size.width)! > maxLayerWidth) {
                    maxLayerWidth = (layer?.size.width)!;
                }
            }
        }
        return maxLayerWidth;
    }
}

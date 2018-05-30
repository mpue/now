//
//  ChapterParser.swift
//  Reise
//
//  Created by Nils Schwenkel on 29.05.18.
//  Copyright © 2018 Nils Schwenkel. All rights reserved.
//

import Foundation
import AVFoundation
import SpriteKit

class ChapterParser {
    struct JsonSound : Codable {
        let file: String
        let type : String
        let startPosition: Float
        let endPosition: Float
        var volume: Float? = 1.0
        var startTime: UInt64? = 0
        var fadeInDuration: Float? = 1.0
        var fadeOutDuration: Float? = 3.0
    }
    
    struct JsonLayer : Codable {
        let image: String
        let speed: Float
        var autoScroll: Bool? = false
        let sound: [JsonSound]
    }
    
    struct JsonScene : Codable {
        let layer: [JsonLayer]
    }
    
    struct JsonChapter : Codable {
        let title: String
        let scenes: [JsonScene]
    }
    
    public func parse(json: Data) throws -> Chapter {
        let decoder = JSONDecoder()
        let chapter = try decoder.decode(JsonChapter.self, from: json)
        
        let gameChapter = Chapter(title: chapter.title)
        
        for scene in chapter.scenes {
            let gameScene = Scene()
            
            for layer in scene.layer {
                let imagePath = "chapter/" + chapter.title + "/" + layer.image
                
                // check image path
                guard Bundle.main.path(forResource: imagePath, ofType: nil) != nil else {
                    throw ("invalid image path: " + imagePath)
                }
                
                let image = SKTexture(imageNamed: imagePath)
                var gameLayer : Layer
                if(layer.autoScroll ?? false) {
                    gameLayer = AutoScrollingLayer(texture: image, speed: layer.speed)
                } else {
                    gameLayer = Layer(texture: image, speed: layer.speed)
                }
                
                for sound in layer.sound {
                    let soundPath = "chapter/" + chapter.title + "/sound/" + sound.file
                    guard let fileUrl = Bundle.main.url(forResource: soundPath, withExtension: sound.type) else {
                        throw ("invalid sound path: " + soundPath)
                    }
                    
                    let file = try AVAudioFile.init(forReading: fileUrl.absoluteURL)
                    
                    let gameSound = Sound(file: file, startPosition: sound.startPosition, endPosition: sound.endPosition, volume: sound.volume!, startTime: sound.startTime!, fadeInDuration: sound.fadeInDuration!, fadeOutDuration: sound.fadeOutDuration!)
                    
                    gameLayer.add(sound: gameSound)
                    
                }
                gameScene.add(layer: gameLayer)
            }
            gameChapter.add(scene: gameScene)
        }
        
        return gameChapter
    }
    
}

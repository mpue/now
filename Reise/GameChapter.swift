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
                let gameLayer = Layer(texture: image, speed: layer.speed)
                
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
class Sound {
    let startPosition: CGFloat
    let endPosition: CGFloat
    var isPlaying: Bool = false
    
    private let file: AVAudioFile
    private let volume: Float
    private let startTime: UInt64
    private let fadeInDuration: TimeInterval
    private let fadeOutDuration: TimeInterval
    
    private let soundBuffer: AVAudioPCMBuffer
    private var player: AVAudioPlayerNode?
    
    private var targetVolume: Float = 0
    private var startVolume: Float = 0
    private var fadeTime: TimeInterval = 0
    private var fadeStart: TimeInterval = 0
    private var timer: Timer?
    
    init(file: AVAudioFile, startPosition: Float, endPosition: Float, volume: Float, startTime: UInt64, fadeInDuration: Float, fadeOutDuration: Float) {
        self.file = file
        self.startPosition = CGFloat(startPosition)
        self.endPosition = CGFloat(endPosition)
        self.volume = volume
        self.startTime = startTime
        self.fadeInDuration = TimeInterval(fadeInDuration)
        self.fadeOutDuration = TimeInterval(fadeOutDuration)
        
        let audioFormat = file.processingFormat
        let audioFrameCount = UInt32(file.length)
        self.soundBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: audioFrameCount)!
        try! file.read(into: self.soundBuffer, frameCount: audioFrameCount)
    }
    
    public func play(audioEngine: AVAudioEngine, output: AVAudioMixerNode) {
        let player = AVAudioPlayerNode()
        self.player = player
        audioEngine.attach(player)
        // Notice the output is the mixer in this case
        audioEngine.connect(player, to: output, format: nil)
        
        player.scheduleBuffer(self.soundBuffer, at: nil, options:.loops, completionHandler: nil)
        
        let s = AVAudioTime(hostTime: self.startTime)
        player.play(at: s)
        //player.volume = 0
        
        fadeIn(duration: self.fadeInDuration)
        isPlaying = true
        
        print("play \(self.file.url)) ");
    }
    
    public func stop() {
        isPlaying = false
        fadeOut(duration: self.fadeOutDuration)
        print("stop \(self.file.url)) ");
    }
    
    private func fadeTo(volume: Float, duration: TimeInterval = 1.0) {
        startVolume = player?.volume ?? 1
        targetVolume = volume
        fadeTime = duration
        fadeStart = NSDate().timeIntervalSinceReferenceDate
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 0.015, target: self, selector: #selector(handleFadeTo), userInfo: nil, repeats: true)
        }
    }
    
    private func fadeIn(duration: TimeInterval = 1.0) {
        player?.volume = 0.0
        print(volume)
        fadeTo(volume: self.volume, duration: duration)
    }
    
    private func fadeOut(duration: TimeInterval = 1.0) {
        fadeTo(volume: 0.0, duration: duration)
    }
    
    @objc func handleFadeTo() {
        let now = NSDate().timeIntervalSinceReferenceDate
        let delta: Float = (Float(now - fadeStart) / Float(fadeTime) * (targetVolume - startVolume))
        let volume = startVolume + delta
        player?.volume = volume
        if delta > 0.0 && volume >= targetVolume ||
            delta < 0.0 && volume <= targetVolume || delta == 0.0 {
            player?.volume = targetVolume
            timer?.invalidate()
            timer = nil
            if player?.volume == 0 {
                player?.stop()
                //TODO audioEngine.detach(player!)
                
                player = nil
            }
        }
    }
}

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

class Scene {
    private var layer: [Layer] = Array()
    
    func add(layer: Layer) {
        self.layer.append(layer)
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
    
    public func update(on: SKScene, timeSinceLastFrame: TimeInterval, audioEngine: AVAudioEngine, output: AVAudioMixerNode) {
        for layer in self.layer {
            layer.update(on: on, timeSinceLastFrame: timeSinceLastFrame, audioEngine: audioEngine, output: output)
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
    
    public func update(on: SKScene, timeSinceLastFrame: TimeInterval, audioEngine: AVAudioEngine, output: AVAudioMixerNode) {
        
        currentScene?.update(on: on, timeSinceLastFrame: timeSinceLastFrame, audioEngine: audioEngine, output: output)
        nextScene?.update(on: on, timeSinceLastFrame: timeSinceLastFrame, audioEngine: audioEngine, output: output)

        if(!(currentScene?.isVisible() ?? false))
        {
            currentScene = nextScene
        }
        
    }
}

// The simplest way is to make String conform to Error:
extension String: Error {}

extension SKSpriteNode {
    
    func aspectFillToSize(fillSize: CGSize) {
        
        if texture != nil {
            self.size = texture!.size()
            
            let verticalRatio = fillSize.height / self.texture!.size().height
            let horizontalRatio = fillSize.width /  self.texture!.size().width
            
            let scaleRatio = horizontalRatio > verticalRatio ? horizontalRatio : verticalRatio
            
            self.setScale(scaleRatio)
        }
    }
}

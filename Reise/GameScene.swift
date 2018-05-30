//
//  GameScene.swift
//  Reise
//
//  Created by Nils Schwenkel on 24.05.18.
//  Copyright © 2018 Nils Schwenkel. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation



class GameScene: SKScene {
    
    private var move: Bool = false
    
    private var myAudioEngine: AVAudioEngine = AVAudioEngine()
    private var mixer: AVAudioMixerNode = AVAudioMixerNode()
    
    // Time of last frame
    private var lastFrameTime : TimeInterval = 0
    
    // Time since last frame
    private var deltaTime : TimeInterval = 0
    
    private var direction: Float = 1;
    private var xOffset: CGFloat = 0
    private var chapter: Chapter?
    
    init(size: CGSize, chapter: Chapter) {
        
        super.init(size: size)
        
        self.chapter = chapter
        
        self.myAudioEngine.attach(self.mixer)
        self.myAudioEngine.connect(self.mixer, to: self.myAudioEngine.outputNode, format: nil)
        // !important - start the engine *before* setting up the player nodes
        try! self.myAudioEngine.start()
        
        self.chapter?.load(on: self, withSize: size, audioEngine: self.myAudioEngine, output: self.mixer)
        
        /*
        // do work in a background thread
        DispatchQueue.global(qos: .background).async {
         
        }*/
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }
    
    override func didMove(to view: SKView) {
    }

    func touchDown(atPoint pos : CGPoint) {

    }
    
    func touchMoved(toPoint pos : CGPoint) {

    }
    
    func touchUp(atPoint pos : CGPoint) {

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        
        var isRight : Bool = false
        var isLeft : Bool = false
        
        for touch in touches {
            let location = touch.location(in: self)

            if(location.x < self.frame.size.width/2){
                isLeft = true
            }
            
            if(location.x > self.frame.size.width/2){
                isRight = true
            }
        }
        
        if (isRight && isLeft){
            // "Both touched"
            // do something..
        } else if(isRight) {
            direction = 1
        } else if(isLeft) {
            direction = -1
        }

        move = true
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        move = false;
        direction *= -1;
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    @IBAction func Play(_ sender: AnyObject) {
        print("play")
    }
    
    @IBAction func Pause(_ sender: AnyObject) {
        print("pause")
    }
    
    @IBAction func Restart(_ sender: AnyObject) {
        print("restart")
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // If we don't have a last frame time value, this is the first frame,
        // so delta time will be zero.
        if lastFrameTime <= 0 {
            lastFrameTime = currentTime
        }
        
        // Update delta time
        deltaTime = currentTime - lastFrameTime
        
        // Set last frame time to current time
        lastFrameTime = currentTime
        
        
        chapter?.update(on: self, move: move, timeSinceLastFrame: deltaTime * TimeInterval(direction), audioEngine: self.myAudioEngine, output: self.mixer)
        
    }
}

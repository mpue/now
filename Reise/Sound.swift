//
//  Sound.swift
//  Reise
//
//  Created by Nils Schwenkel on 27.05.18.
//  Copyright © 2018 Nils Schwenkel. All rights reserved.
//

import Foundation
import AVFoundation

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

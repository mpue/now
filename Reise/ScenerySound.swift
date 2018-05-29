//
//  Sound.swift
//  Reise
//
//  Created by Nils Schwenkel on 27.05.18.
//  Copyright © 2018 Nils Schwenkel. All rights reserved.
//

import Foundation
import AVFoundation

class ScenerySound {
    private var fileName: String
    private var soundBuffer : AVAudioPCMBuffer
    private var player: AVAudioPlayerNode?
    
    var start: CGFloat
    var end: CGFloat
    
    private var targetVolume: Float = 0
    private var startVolume: Float = 0
    private var fadeTime: TimeInterval = 0
    private var fadeStart: TimeInterval = 0
    private var timer: Timer?
    
    private var isPlayingValue: Bool = false
    
    private var startTime: UInt64
    private var fadeInDuration: Float
    private var fadeOutDuration: Float
    
    
    init(fileName: String, start: CGFloat, end: CGFloat, startTime: UInt64 = 0, fadeInDuration: Float = 0.5, fadeOutDuration: Float = 3) {
        self.fileName = fileName
        self.start = start
        self.end = end
        self.startTime = startTime
        self.fadeInDuration = fadeInDuration
        self.fadeOutDuration = fadeOutDuration
        
        let fileUrl = Bundle.main.url(forResource: fileName, withExtension: "mp3")
        let file = try! AVAudioFile.init(forReading: (fileUrl?.absoluteURL)!)
        
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

        fadeIn(duration: TimeInterval(self.fadeInDuration))
        isPlayingValue = true
        
        print("play \(self.fileName)) ");
    }
    
    public func stop() {
        isPlayingValue = false
        fadeOut(duration: TimeInterval(self.fadeOutDuration))
        print("stop \(self.fileName)) ");

    }
    
    public func isPlaying() -> Bool {
        if(nil == player)
        {
            return false;
        }
        return isPlayingValue
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
        fadeTo(volume: 1.0, duration: duration)
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

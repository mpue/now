//
//  GameViewController.swift
//  Reise
//
//  Created by Nils Schwenkel on 24.05.18.
//  Copyright © 2018 Nils Schwenkel. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        /*
        // enable background audio playback
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryMultiRoute)
        } catch {
            print(error)
        }*/
        let parser = ChapterParser()
        let chapterConfigFiles = ["chapter/demo/config", "chapter/parallax/config", "chapter/one/config", "chapter/two/config"]
        var chapters: [Chapter] = Array()
        
        for configFile in chapterConfigFiles {
            if let path = Bundle.main.path(forResource: configFile, ofType: "json") {
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                    
                    let chapter = try parser.parse(json: data)
                    
                    chapters.append(chapter)
                } catch {
                    // handle error
                    print(error)
                }
            } else {
                print("invalid path")
            }
        }
        print(self.view.frame.size)
        
        let scene = Menu(size:CGSize(width: self.view.frame.size.height, height: self.view.frame.size.width), chapters: chapters)
        
        let skView = self.view as! SKView
        scene.scaleMode = .aspectFill
        
        skView.presentScene(scene)
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscape
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

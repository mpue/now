//
//  Menu.swift
//  Reise
//
//  Created by Nils Schwenkel on 28.05.18.
//  Copyright © 2018 Nils Schwenkel. All rights reserved.
//

import Foundation
import SpriteKit

class Menu: SKScene {

    var parallaxLabel : SKLabelNode
    var oneLabel : SKLabelNode
    var chapterParallax: Chapter?
    var chapterOne: Chapter?
    var chapter: [Chapter] = Array()
    
    override init(size: CGSize) {
        let parser = ChapterParser()
        
        let chapterConfigFiles = ["chapter/parallax/config", "chapter/one/config"]
        
        for configFile in chapterConfigFiles {
            if let path = Bundle.main.path(forResource: configFile, ofType: "json") {
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                    
                    let chapter = try parser.parse(json: data)
                    
                    self.chapter.append(chapter)
                } catch {
                    // handle error
                    print(error)
                }
            } else {
                print("invalid path")
            }
        }
        
        
        parallaxLabel = SKLabelNode(text: "Chapter: " + chapter[0].title )
        oneLabel =  SKLabelNode(text: "Chapter: " + chapter[1].title)
        
        
        super.init(size: size)

        
        parallaxLabel.fontSize = 65
        parallaxLabel.position.x = self.frame.size.width/4
        parallaxLabel.position.y = self.frame.size.height/2
        self.addChild(parallaxLabel)

        oneLabel.fontSize = 65
        oneLabel.position.x = self.frame.size.width/4 * 3
        oneLabel.position.y = self.frame.size.height/2
        self.addChild(oneLabel)
        
        
        let chapterParallaxConfig = """
        
        """.data(using: .utf8)!
        
        
        do {
            chapterParallax = try parser.parse(json: chapterParallaxConfig)
        } catch {
            print(error)
        }
        
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
        
        var chapter : Chapter?
        
        if (isRight && isLeft){
            // "Both touched"
            // do something..
        } else if(isRight) {
            chapter = self.chapter[1]

        } else if(isLeft) {
            chapter = self.chapter[0]
        }
        

        if(nil != chapter)
        {
            let scene = GameScene(size:CGSize(width: 1920, height: 1080), chapter: chapter!)
            self.scene?.view?.presentScene(scene, transition: SKTransition.doorsOpenHorizontal(withDuration: TimeInterval(2)))
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
